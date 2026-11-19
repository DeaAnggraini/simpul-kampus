<?php
require __DIR__ . '/koneksi.php';
$saya = penggunaDariToken();

$cari = trim((string) ($_GET['q'] ?? ''));
$pola = '%' . addcslashes($cari, '%_\\') . '%';

$q = db()->prepare(
    'SELECT b.id, b.judul, b.penulis, b.penerbit, b.tahun, b.kategori, b.stok,
            b.stok - (SELECT COUNT(*) FROM peminjaman p
                      WHERE p.buku_id = b.id AND p.dikembalikan IS NULL) AS tersedia,
            EXISTS(SELECT 1 FROM peminjaman s
                   WHERE s.buku_id = b.id AND s.mahasiswa_id = ? AND s.dikembalikan IS NULL) AS dipinjam_saya
     FROM buku b
     WHERE b.judul LIKE ? OR b.penulis LIKE ? OR b.kategori LIKE ?
     ORDER BY b.judul LIMIT 50'
);
$q->execute([(int) $saya['id'], $pola, $pola, $pola]);

$data = $q->fetchAll();
foreach ($data as &$b) {
    $b['tersedia'] = max(0, (int) $b['tersedia']);
    $b['dipinjam_saya'] = (bool) $b['dipinjam_saya'];
}
unset($b);
kirim(200, ['data' => $data]);