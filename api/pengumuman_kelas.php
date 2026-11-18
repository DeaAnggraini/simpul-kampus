<?php
require __DIR__ . '/kelas_util.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') kirim(405, ['pesan' => 'Gunakan metode POST.']);
$saya = penggunaDariToken();
if ($saya['peran'] !== 'dosen') {
    kirim(403, ['pesan' => 'Hanya dosen pengampu yang dapat membuat pengumuman.']);
}
$in = bacaJson();
$kelas = aksesKelas($saya, (int) ($in['kelas_id'] ?? 0));
if (!$kelas) kirim(404, ['pesan' => 'Kelas tidak ditemukan.']);

$isi = trim((string) ($in['isi'] ?? ''));
if ($isi === '' || mb_strlen($isi) > 1000) {
    kirim(422, ['pesan' => 'Isi wajib diisi, maksimal 1000 karakter.']);
}
db()->prepare('INSERT INTO pengumuman_kelas (kelas_id, penulis_id, isi) VALUES (?, ?, ?)')
    ->execute([$kelas['id'], $saya['id'], $isi]);
buatNotifikasiKelas((int) $kelas['id'], 'pengumuman', 'Pengumuman ' . $kelas['mk_nama'], $isi);
kirim(201, ['pesan' => 'Pengumuman terkirim.']);