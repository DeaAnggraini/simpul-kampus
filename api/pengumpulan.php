<?php
require __DIR__ . '/kelas_util.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') kirim(405, ['pesan' => 'Gunakan metode POST.']);
$saya = penggunaDariToken();
if ($saya['peran'] !== 'mahasiswa') kirim(403, ['pesan' => 'Hanya mahasiswa yang dapat mengumpulkan tugas.']);

$in = bacaJson();
$q = db()->prepare('SELECT id, kelas_id, (tenggat < NOW()) AS lewat FROM tugas WHERE id = ?');
$q->execute([(int) ($in['tugas_id'] ?? 0)]);
$tugas = $q->fetch();
// Tugas milik kelas yang bukan kelas Anda dijawab sama seperti tugas yang tidak ada
if (!$tugas || !aksesKelas($saya, (int) $tugas['kelas_id'])) {
    kirim(404, ['pesan' => 'Tugas tidak ditemukan.']);
}
if ((int) $tugas['lewat'] === 1) kirim(422, ['pesan' => 'Tenggat sudah lewat.']);

$jawaban = trim((string) ($in['jawaban'] ?? ''));
if ($jawaban === '' || mb_strlen($jawaban) > 2000) {
    kirim(422, ['pesan' => 'Jawaban wajib diisi, maksimal 2000 karakter.']);
}
db()->prepare(
    'INSERT INTO pengumpulan (tugas_id, mahasiswa_id, jawaban) VALUES (?, ?, ?)
     ON DUPLICATE KEY UPDATE jawaban = ?, dikirim = NOW()'
)->execute([$tugas['id'], $saya['id'], $jawaban, $jawaban]);
kirim(200, ['pesan' => 'Tugas terkumpul.']);