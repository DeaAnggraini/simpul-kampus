<?php
require __DIR__ . '/perpus_util.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') kirim(405, ['pesan' => 'Gunakan metode POST.']);
$saya = penggunaDariToken();
if ($saya['peran'] !== 'mahasiswa') kirim(403, ['pesan' => 'Khusus mahasiswa.']);

$id = (int) (bacaJson()['peminjaman_id'] ?? 0);
$mhs = (int) $saya['id'];

$q = db()->prepare(
    'SELECT GREATEST(DATEDIFF(NOW(), jatuh_tempo), 0) AS hari_telat
     FROM peminjaman WHERE id = ? AND mahasiswa_id = ? AND dikembalikan IS NULL'
);
$q->execute([$id, $mhs]);
$p = $q->fetch();
if (!$p) kirim(404, ['pesan' => 'Peminjaman aktif tidak ditemukan.']);

db()->prepare('UPDATE peminjaman SET dikembalikan = NOW()
               WHERE id = ? AND mahasiswa_id = ? AND dikembalikan IS NULL')->execute([$id, $mhs]);
kirim(200, ['pesan' => 'Buku dikembalikan.', 'denda' => (int) $p['hari_telat'] * DENDA_PER_HARI]);