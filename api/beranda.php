<?php
require __DIR__ . '/koneksi.php';
$saya = penggunaDariToken();
if ($saya['peran'] !== 'mahasiswa') {
    kirim(403, ['pesan' => 'Beranda ini khusus mahasiswa.']);
}

$q = db()->prepare(
    'SELECT p.nomor_induk AS nim, p.nama, pr.nama AS prodi, dp.nama AS dosen_pa
     FROM mahasiswa m
     JOIN pengguna p ON p.id = m.pengguna_id
     JOIN prodi pr ON pr.id = m.prodi_id
     LEFT JOIN pengguna dp ON dp.id = m.dosen_pa_id
     WHERE m.pengguna_id = ?'
);
$q->execute([$saya['id']]);
$profil = $q->fetch();

$q = db()->prepare(
    'SELECT COALESCE(SUM(mk.sks), 0) AS sks,
            COALESCE(SUM(mk.sks * CASE r.nilai_huruf
              WHEN "A" THEN 4 WHEN "B" THEN 3 WHEN "C" THEN 2 WHEN "D" THEN 1 ELSE 0 END), 0) AS mutu
     FROM krs r
     JOIN kelas k ON k.id = r.kelas_id
     JOIN matakuliah mk ON mk.id = k.matakuliah_id
     WHERE r.mahasiswa_id = ? AND r.nilai_huruf IS NOT NULL'
);
$q->execute([$saya['id']]);
$h = $q->fetch();
$profil['sks_tempuh'] = (int) $h['sks'];
$profil['ipk'] = $h['sks'] > 0 ? round($h['mutu'] / $h['sks'], 2) : 0;

// Semester berjalan, dihitung dari jumlah tahun akademik yang pernah diambil KRS-nya
$q = db()->prepare('SELECT COUNT(DISTINCT k.tahun_akademik_id) FROM krs r
                    JOIN kelas k ON k.id = r.kelas_id WHERE r.mahasiswa_id = ?');
$q->execute([$saya['id']]);
$profil['semester'] = (int) $q->fetchColumn();

$q = db()->prepare(
    'SELECT mk.kode, mk.nama, mk.sks, dp.nama AS dosen, k.jam_mulai, k.jam_selesai, k.ruang
     FROM krs r
     JOIN kelas k ON k.id = r.kelas_id
     JOIN tahun_akademik t ON t.id = k.tahun_akademik_id AND t.aktif = 1
     JOIN matakuliah mk ON mk.id = k.matakuliah_id
     JOIN pengguna dp ON dp.id = k.dosen_id
     WHERE r.mahasiswa_id = ? AND k.hari = ?
     ORDER BY k.jam_mulai'
);
$q->execute([$saya['id'], (int) date('N')]);
$jadwal = $q->fetchAll();

$info = db()->query('SELECT judul, isi, dibuat FROM pengumuman ORDER BY id DESC LIMIT 5')->fetchAll();

kirim(200, ['profil' => $profil, 'jadwal_hari_ini' => $jadwal, 'pengumuman' => $info]);