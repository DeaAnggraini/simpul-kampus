<?php
require __DIR__ . '/kelas_util.php';
$saya = penggunaDariToken();
$kelas = aksesKelas($saya, (int) ($_GET['id'] ?? 0));
if (!$kelas) kirim(404, ['pesan' => 'Kelas tidak ditemukan.']);
$pdo = db();

$q = $pdo->prepare(
    'SELECT a.id, a.isi, a.dibuat, p.nama AS penulis
     FROM pengumuman_kelas a JOIN pengguna p ON p.id = a.penulis_id
     WHERE a.kelas_id = ? ORDER BY a.id DESC LIMIT 50'
);
$q->execute([$kelas['id']]);
$pengumuman = $q->fetchAll();

// Tugas yang belum lewat tampil lebih dulu. "lewat" dihitung oleh MySQL, bukan ponsel.
$q = $pdo->prepare(
    'SELECT t.id, t.judul, t.deskripsi, t.tenggat, (t.tenggat < NOW()) AS lewat,
            s.jawaban, s.dikirim,
            (SELECT COUNT(*) FROM pengumpulan x WHERE x.tugas_id = t.id) AS jumlah_terkirim
     FROM tugas t
     LEFT JOIN pengumpulan s ON s.tugas_id = t.id AND s.mahasiswa_id = ?
     WHERE t.kelas_id = ?
     ORDER BY (t.tenggat < NOW()), t.tenggat'
);
$q->execute([$saya['peran'] === 'mahasiswa' ? $saya['id'] : 0, $kelas['id']]);
$tugas = $q->fetchAll();
foreach ($tugas as &$t) {
    $t['lewat'] = (bool) $t['lewat'];
    $t['jumlah_terkirim'] = (int) $t['jumlah_terkirim'];
}
unset($t);

$q = $pdo->prepare(
    'SELECT p.nomor_induk AS nim, p.nama FROM krs r
     JOIN pengguna p ON p.id = r.mahasiswa_id
     WHERE r.kelas_id = ? ORDER BY p.nama'
);
$q->execute([$kelas['id']]);
$anggota = $q->fetchAll();
if ($saya['peran'] !== 'dosen') { // NIM hanya terlihat oleh dosen
    foreach ($anggota as &$a) $a['nim'] = null;
    unset($a);
}

kirim(200, [
    'kelas' => $kelas,
    'bisa_menulis' => $saya['peran'] === 'dosen',
    'pengumuman' => $pengumuman,
    'tugas' => $tugas,
    'anggota' => $anggota,
]);