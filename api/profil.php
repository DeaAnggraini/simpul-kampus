<?php
require __DIR__ . '/koneksi.php';
$saya = penggunaDariToken();
if ($saya['peran'] !== 'mahasiswa') kirim(403, ['pesan' => 'Khusus mahasiswa.']);

$q = db()->prepare(
    'SELECT p.nomor_induk AS nim, p.nama, p.email, pr.nama AS prodi,
            f.nama AS fakultas, kr.nama AS kurikulum, m.angkatan, dp.nama AS dosen_pa
     FROM mahasiswa m
     JOIN pengguna p ON p.id = m.pengguna_id
     JOIN prodi pr ON pr.id = m.prodi_id
     JOIN fakultas f ON f.id = pr.fakultas_id
     JOIN kurikulum kr ON kr.id = m.kurikulum_id
     LEFT JOIN pengguna dp ON dp.id = m.dosen_pa_id
     WHERE m.pengguna_id = ?'
);
$q->execute([$saya['id']]);
kirim(200, ['data' => $q->fetch()]);