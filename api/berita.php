<?php
require __DIR__ . '/koneksi.php';
const KATEGORI = ['Umum', 'Akademik', 'Beasiswa', 'Kegiatan', 'Fasilitas'];
$saya = penggunaDariToken();

switch ($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        $id = (int) ($_GET['id'] ?? 0);
        if ($id > 0) {
            $q = db()->prepare(
                'SELECT n.id, n.judul, n.isi, n.kategori, n.dibuat, p.nama AS penulis
                 FROM pengumuman n LEFT JOIN pengguna p ON p.id = n.penulis_id WHERE n.id = ?'
            );
            $q->execute([$id]);
            $b = $q->fetch();
            if (!$b) kirim(404, ['pesan' => 'Berita tidak ditemukan.']);
            kirim(200, ['data' => $b]);
        }

        $cari = trim((string) ($_GET['q'] ?? ''));
        $kategori = trim((string) ($_GET['kategori'] ?? ''));
        $pola = '%' . addcslashes($cari, '%_\\') . '%';
        $sql = 'SELECT n.id, n.judul, LEFT(n.isi, 140) AS ringkas, n.kategori, n.dibuat
                FROM pengumuman n WHERE (n.judul LIKE ? OR n.isi LIKE ?)';
        $par = [$pola, $pola];
        if ($kategori !== '') {
            $sql .= ' AND n.kategori = ?';
            $par[] = $kategori;
        }
        $sql .= ' ORDER BY n.id DESC LIMIT 50';
        $q = db()->prepare($sql);
        $q->execute($par);
        kirim(200, ['bisa_menulis' => $saya['peran'] === 'admin', 'data' => $q->fetchAll()]);

    case 'POST':
        if ($saya['peran'] !== 'admin') kirim(403, ['pesan' => 'Hanya admin yang dapat menerbitkan berita.']);
        $in = bacaJson();
        $judul = trim((string) ($in['judul'] ?? ''));
        $kategori = trim((string) ($in['kategori'] ?? ''));
        $isi = trim((string) ($in['isi'] ?? ''));
        if ($judul === '' || mb_strlen($judul) > 150) kirim(422, ['pesan' => 'Judul wajib diisi, maksimal 150 karakter.']);
        if (!in_array($kategori, KATEGORI, true)) kirim(422, ['pesan' => 'Kategori tidak dikenal.']);
        if ($isi === '' || mb_strlen($isi) > 5000) kirim(422, ['pesan' => 'Isi wajib diisi, maksimal 5000 karakter.']);

        db()->prepare('INSERT INTO pengumuman (judul, isi, kategori, penulis_id) VALUES (?, ?, ?, ?)')
            ->execute([$judul, $isi, $kategori, (int) $saya['id']]);
        kirim(201, ['pesan' => 'Berita diterbitkan.']);

    default:
        kirim(405, ['pesan' => 'Metode tidak didukung.']);
}