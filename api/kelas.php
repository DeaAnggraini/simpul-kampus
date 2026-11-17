<?php
require __DIR__ . '/kelas_util.php';
$saya = penggunaDariToken();
if (!in_array($saya['peran'], ['mahasiswa', 'dosen'], true)) {
    kirim(403, ['pesan' => 'Peran tidak didukung.']);
}

$sql = 'SELECT k.id, k.nama AS kelas, mk.kode, mk.nama, mk.sks, pd.nama AS dosen,
               k.hari, k.jam_mulai, k.jam_selesai, k.ruang,
               (SELECT COUNT(*) FROM krs x WHERE x.kelas_id = k.id) AS jumlah_anggota
        FROM kelas k
        JOIN matakuliah mk ON mk.id = k.matakuliah_id
        JOIN tahun_akademik t ON t.id = k.tahun_akademik_id AND t.aktif = 1
        JOIN pengguna pd ON pd.id = k.dosen_id ';
$sql .= $saya['peran'] === 'dosen'
    ? 'WHERE k.dosen_id = ? ORDER BY mk.nama, k.nama'
    : 'JOIN krs r ON r.kelas_id = k.id AND r.mahasiswa_id = ? ORDER BY mk.nama, k.nama';

$q = db()->prepare($sql);
$q->execute([$saya['id']]);
kirim(200, ['data' => $q->fetchAll()]);