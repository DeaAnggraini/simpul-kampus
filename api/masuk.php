<?php
require __DIR__ . '/koneksi.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') kirim(405, ['pesan' => 'Gunakan metode POST.']);

$in = bacaJson();
$q = db()->prepare('SELECT id, nama, peran, sandi_hash FROM pengguna WHERE nomor_induk = ?');
$q->execute([trim((string) ($in['nim'] ?? ''))]);
$p = $q->fetch();

if (!$p || !password_verify((string) ($in['sandi'] ?? ''), $p['sandi_hash'])) {
    kirim(401, ['pesan' => 'NIM atau kata sandi salah.']);
}
$token = bin2hex(random_bytes(32));
db()->prepare('INSERT INTO token (token, pengguna_id, kedaluwarsa)
               VALUES (?, ?, NOW() + INTERVAL 7 DAY)')
    ->execute([hash('sha256', $token), $p['id']]);

kirim(200, ['token' => $token,
            'pengguna' => ['id' => $p['id'], 'nama' => $p['nama'], 'peran' => $p['peran']]]);