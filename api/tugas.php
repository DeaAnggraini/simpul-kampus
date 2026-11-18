<?php
require __DIR__ . '/kelas_util.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') kirim(405, ['pesan' => 'Gunakan metode POST.']);
$saya = penggunaDariToken();
if ($saya['peran'] !== 'dosen') {
    kirim(403, ['pesan' => 'Hanya dosen pengampu yang dapat membuat tugas.']);
}
$in = bacaJson();
$kelas = aksesKelas($saya, (int) ($in['kelas_id'] ?? 0));
if (!$kelas) kirim(404, ['pesan' => 'Kelas tidak ditemukan.']);

$judul = trim((string) ($in['judul'] ?? ''));
$deskripsi = trim((string) ($in['deskripsi'] ?? ''));
$tenggat = trim((string) ($in['tenggat'] ?? ''));

if ($judul === '' || mb_strlen($judul) > 150) {
    kirim(422, ['pesan' => 'Judul wajib diisi, maksimal 150 karakter.']);
}
if (mb_strlen($deskripsi) > 2000) kirim(422, ['pesan' => 'Deskripsi maksimal 2000 karakter.']);

$t = DateTime::createFromFormat('Y-m-d H:i:s', $tenggat);
if (!$t || $t->format('Y-m-d H:i:s') !== $tenggat) {
    kirim(422, ['pesan' => 'Format tenggat tidak valid.']);
}
$q = db()->prepare('SELECT ? > NOW()'); // pakai jam MySQL agar konsisten
$q->execute([$tenggat]);
if (!(int) $q->fetchColumn()) kirim(422, ['pesan' => 'Tenggat harus di masa depan.']);

db()->prepare('INSERT INTO tugas (kelas_id, judul, deskripsi, tenggat) VALUES (?, ?, ?, ?)')
    ->execute([$kelas['id'], $judul, $deskripsi === '' ? null : $deskripsi, $tenggat]);
buatNotifikasiKelas((int) $kelas['id'], 'tugas', 'Tugas baru ' . $kelas['mk_nama'], $judul);
kirim(201, ['pesan' => 'Tugas dibuat.']);