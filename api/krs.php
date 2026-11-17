<?php
require __DIR__ . '/koneksi.php';
$saya = penggunaDariToken();
if ($saya['peran'] !== 'mahasiswa') kirim(403, ['pesan' => 'Khusus mahasiswa.']);

$pdo = db();
$mhs = (int) $saya['id'];

$ta = $pdo->query('SELECT id, nama, semester FROM tahun_akademik WHERE aktif = 1 LIMIT 1')->fetch();
if (!$ta) kirim(409, ['pesan' => 'Belum ada tahun akademik aktif.']);
$taId = (int) $ta['id'];

$q = $pdo->prepare('SELECT kurikulum_id FROM mahasiswa WHERE pengguna_id = ?');
$q->execute([$mhs]);
$kurikulum = (int) $q->fetchColumn();
if ($kurikulum === 0) kirim(409, ['pesan' => 'Data mahasiswa tidak lengkap.']);

/** Aturan contoh. Sesuaikan dengan pedoman akademik. */
function batasSks(int $mhs): int
{
    $q = db()->prepare(
        'SELECT SUM(mk.sks) AS sks,
                SUM(mk.sks * CASE r.nilai_huruf WHEN "A" THEN 4 WHEN "B" THEN 3
                    WHEN "C" THEN 2 WHEN "D" THEN 1 ELSE 0 END) AS mutu
         FROM krs r JOIN kelas k ON k.id = r.kelas_id
         JOIN matakuliah mk ON mk.id = k.matakuliah_id
         WHERE r.mahasiswa_id = ? AND r.nilai_huruf IS NOT NULL'
    );
    $q->execute([$mhs]);
    $h = $q->fetch();
    if (!$h || (int) $h['sks'] === 0) return 20;
    $ipk = $h['mutu'] / $h['sks'];
    return match (true) {
        $ipk >= 3.0 => 24,
        $ipk >= 2.5 => 21,
        $ipk >= 2.0 => 18,
        default => 15,
    };
}

/** Mata kuliah yang sudah lulus (A, B, C) di semester lain. */
function matakuliahLulus(int $mhs, int $taId): array
{
    $q = db()->prepare(
        'SELECT DISTINCT k.matakuliah_id FROM krs r JOIN kelas k ON k.id = r.kelas_id
         WHERE r.mahasiswa_id = ? AND k.tahun_akademik_id <> ? AND r.nilai_huruf IN ("A","B","C")'
    );
    $q->execute([$mhs, $taId]);
    return array_map('intval', $q->fetchAll(PDO::FETCH_COLUMN));
}

switch ($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        $q = $pdo->prepare(
            'SELECT k.id AS kelas_id, mk.id AS mk_id, mk.kode, mk.nama, mk.sks, k.nama AS kelas,
                    p.nama AS dosen, k.hari, k.jam_mulai, k.jam_selesai, k.ruang, k.kuota,
                    (SELECT COUNT(*) FROM krs x WHERE x.kelas_id = k.id) AS terisi,
                    EXISTS(SELECT 1 FROM krs y WHERE y.kelas_id = k.id AND y.mahasiswa_id = ?) AS diambil
             FROM kelas k
             JOIN matakuliah mk ON mk.id = k.matakuliah_id
             JOIN kurikulum_matakuliah km ON km.matakuliah_id = mk.id AND km.kurikulum_id = ?
             JOIN pengguna p ON p.id = k.dosen_id
             WHERE k.tahun_akademik_id = ?
             ORDER BY mk.nama, k.nama'
        );
        $q->execute([$mhs, $kurikulum, $taId]);
        $lulus = matakuliahLulus($mhs, $taId);
        $baris = $q->fetchAll();
        foreach ($baris as &$b) {
            $b['diambil'] = (bool) $b['diambil'];
            $b['sudah_lulus'] = in_array((int) $b['mk_id'], $lulus, true);
        }
        unset($b);
        kirim(200, [
            'tahun' => $ta['nama'] . ' ' . ucfirst($ta['semester']),
            'batas_sks' => batasSks($mhs),
            'data' => $baris,
        ]);

    case 'POST':
        $mentah = bacaJson()['kelas_ids'] ?? [];
        $ids = is_array($mentah)
            ? array_values(array_unique(array_filter(array_map('intval', $mentah), fn ($v) => $v > 0)))
            : [];
        if (!$ids) kirim(422, ['pesan' => 'Pilih minimal satu kelas.']);
        if (count($ids) > 15) kirim(422, ['pesan' => 'Terlalu banyak kelas dipilih.']);

        $pdo->beginTransaction();
        try {
            // Kunci baris kelas agar pemeriksaan kuota tidak balapan dengan mahasiswa lain
            $tanda = implode(',', array_fill(0, count($ids), '?'));
            $q = $pdo->prepare(
                "SELECT id, matakuliah_id, tahun_akademik_id, hari, jam_mulai, jam_selesai, kuota
                 FROM kelas WHERE id IN ($tanda) ORDER BY id FOR UPDATE"
            );
            $q->execute($ids);
            $kelas = $q->fetchAll();
            if (count($kelas) !== count($ids)) {
                $pdo->rollBack();
                kirim(422, ['pesan' => 'Ada kelas yang tidak ditemukan.']);
            }

            $mkIds = array_values(array_unique(array_map(fn ($k) => (int) $k['matakuliah_id'], $kelas)));
            $tm = implode(',', array_fill(0, count($mkIds), '?'));
            $q = $pdo->prepare("SELECT id, nama, sks FROM matakuliah WHERE id IN ($tm)");
            $q->execute($mkIds);
            $mk = [];
            foreach ($q->fetchAll() as $m) $mk[(int) $m['id']] = $m;

            $q = $pdo->prepare('SELECT matakuliah_id FROM kurikulum_matakuliah WHERE kurikulum_id = ?');
            $q->execute([$kurikulum]);
            $dalamKurikulum = array_map('intval', $q->fetchAll(PDO::FETCH_COLUMN));
            $lulus = matakuliahLulus($mhs, $taId);

            $galat = [];
            $hitungMk = [];
            $total = 0;
            foreach ($kelas as $k) {
                $mid = (int) $k['matakuliah_id'];
                $nama = $mk[$mid]['nama'];
                $total += (int) $mk[$mid]['sks'];
                $hitungMk[$mid] = ($hitungMk[$mid] ?? 0) + 1;
                if ((int) $k['tahun_akademik_id'] !== $taId) $galat[] = "$nama bukan kelas semester aktif.";
                if (!in_array($mid, $dalamKurikulum, true)) $galat[] = "$nama tidak ada di kurikulum Anda.";
                if (in_array($mid, $lulus, true)) $galat[] = "$nama sudah lulus.";
            }
            foreach ($hitungMk as $mid => $n) {
                if ($n > 1) $galat[] = $mk[$mid]['nama'] . ' dipilih lebih dari satu kelas.';
            }
            for ($i = 0; $i < count($kelas); $i++) {
                for ($j = $i + 1; $j < count($kelas); $j++) {
                    $a = $kelas[$i];
                    $b = $kelas[$j];
                    if ((int) $a['hari'] === (int) $b['hari']
                        && $a['jam_mulai'] < $b['jam_selesai'] && $b['jam_mulai'] < $a['jam_selesai']) {
                        $galat[] = $mk[(int) $a['matakuliah_id']]['nama'] . ' bentrok dengan '
                                 . $mk[(int) $b['matakuliah_id']]['nama'] . '.';
                    }
                }
            }
            $batas = batasSks($mhs);
            if ($total > $batas) $galat[] = "Total $total SKS melebihi batas $batas SKS.";

            $q = $pdo->prepare('SELECT COUNT(*) FROM krs WHERE kelas_id = ? AND mahasiswa_id <> ?');
            foreach ($kelas as $k) {
                $q->execute([$k['id'], $mhs]);
                if ((int) $q->fetchColumn() >= (int) $k['kuota']) {
                    $galat[] = $mk[(int) $k['matakuliah_id']]['nama'] . ' kelasnya penuh.';
                }
            }

            if ($galat) {
                $pdo->rollBack();
                kirim(422, ['pesan' => "KRS belum dapat disimpan:\n- " . implode("\n- ", array_unique($galat))]);
            }

            // Ganti seluruh KRS semester aktif (hanya baris yang belum bernilai)
            $pdo->prepare(
                'DELETE r FROM krs r JOIN kelas k ON k.id = r.kelas_id
                 WHERE r.mahasiswa_id = ? AND k.tahun_akademik_id = ? AND r.nilai_huruf IS NULL'
            )->execute([$mhs, $taId]);
            $ins = $pdo->prepare('INSERT INTO krs (mahasiswa_id, kelas_id) VALUES (?, ?)');
            foreach ($ids as $id) $ins->execute([$mhs, $id]);
            $pdo->commit();
        } catch (PDOException $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            kirim(500, ['pesan' => 'Terjadi kesalahan pada server.']);
        }
        kirim(200, ['pesan' => 'KRS tersimpan.', 'total_sks' => $total]);

    default:
        kirim(405, ['pesan' => 'Metode tidak didukung.']);
}