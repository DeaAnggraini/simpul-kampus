<?php
require __DIR__ . '/akademik_util.php';
$saya = penggunaDariToken();
if ($saya['peran'] !== 'mahasiswa') kirim(403, ['pesan' => 'Khusus mahasiswa.']);
$pdo = db();
$mhs = (int) $saya['id'];

$q = $pdo->prepare(
    'SELECT m.kurikulum_id, pr.sks_lulus
     FROM mahasiswa m JOIN prodi pr ON pr.id = m.prodi_id
     WHERE m.pengguna_id = ?'
);
$q->execute([$mhs]);
$m = $q->fetch();
if (!$m) kirim(409, ['pesan' => 'Data mahasiswa tidak lengkap.']);

// SKS lulus dihitung per mata kuliah (A, B, C). Mengulang tidak dihitung dua kali.
$q = $pdo->prepare(
    'SELECT mk.sks FROM krs r
     JOIN kelas k ON k.id = r.kelas_id
     JOIN matakuliah mk ON mk.id = k.matakuliah_id
     WHERE r.mahasiswa_id = ? AND r.nilai_huruf IN ("A","B","C")
     GROUP BY mk.id, mk.sks'
);
$q->execute([$mhs]);
$sksLulus = (int) array_sum($q->fetchAll(PDO::FETCH_COLUMN));
$target = (int) $m['sks_lulus'];
$nilai = ringkasanNilai($mhs);

$q = $pdo->prepare(
    'SELECT mk.kode, mk.nama, mk.sks, km.semester_ke,
            EXISTS(SELECT 1 FROM krs r
                   JOIN kelas k ON k.id = r.kelas_id
                   JOIN tahun_akademik t ON t.id = k.tahun_akademik_id AND t.aktif = 1
                   WHERE r.mahasiswa_id = ? AND k.matakuliah_id = mk.id) AS sedang_diambil
     FROM kurikulum_matakuliah km
     JOIN matakuliah mk ON mk.id = km.matakuliah_id
     WHERE km.kurikulum_id = ? AND km.wajib = 1
       AND mk.id NOT IN (SELECT k2.matakuliah_id FROM krs r2
                         JOIN kelas k2 ON k2.id = r2.kelas_id
                         WHERE r2.mahasiswa_id = ? AND r2.nilai_huruf IN ("A","B","C"))
     ORDER BY km.semester_ke, mk.nama'
);
$q->execute([$mhs, $m['kurikulum_id'], $mhs]);
$wajib = $q->fetchAll();
foreach ($wajib as &$w) {
    $w['sedang_diambil'] = (bool) $w['sedang_diambil'];
}
unset($w);

kirim(200, [
    'sks_target' => $target,
    'sks_lulus' => $sksLulus,
    'sks_sisa' => max($target - $sksLulus, 0),
    'persen' => $target > 0 ? round($sksLulus / $target * 100, 1) : 0.0,
    'sks_bernilai' => $nilai['sks'],
    'ipk' => $nilai['ipk'],
    'wajib_belum' => $wajib,
]);