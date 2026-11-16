<?php
require __DIR__ . '/koneksi.php';
$saya = penggunaDariToken();
db()->prepare('DELETE FROM token WHERE token = ?')->execute([$saya['token_hash']]);
kirim(200, ['pesan' => 'Berhasil keluar.']);