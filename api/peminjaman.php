<?php
require __DIR__ . '/perpus_util.php';
$saya = penggunaDariToken();
if ($saya['peran'] !== 'mahasiswa') kirim(403, ['pesan' => 'Khusus mahasiswa.']);
$pdo = db();
$mhs = (int) $saya['id'];

switch ($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        $q = $pdo->prepare(
            'SELECT p.id, p.buku_id, b.judul, b.penulis, p.dipinjam, p.jatuh_tempo, p.dikembalikan,
                    (p.dikembalikan IS NULL AND p.jatuh_tempo < NOW()) AS terlambat,
                    GREATEST(DATEDIFF(COALESCE(p.dikembalikan, NOW()), p.jatuh_tempo), 0) AS hari_telat
             FROM peminjaman p JOIN buku b ON b.id = p.buku_id
             WHERE p.mahasiswa_id = ? ORDER BY p.id DESC LIMIT 100'
        );
        $q->execute([$mhs]);
        $aktif = [];
        $riwayat = [];
        $berjalan = 0;
        foreach ($q->fetchAll() as $p) {
            $p['terlambat'] = (bool) $p['terlambat'];
            $p['hari_telat'] = (int) $p['hari_telat'];
            $p['denda'] = $p['hari_telat'] * DENDA_PER_HARI;
            if ($p['dikembalikan'] === null) {
                $aktif[] = $p;
                $berjalan += $p['denda'];
            } else {
                $riwayat[] = $p;
            }
        }
        kirim(200, [
            'aktif' => $aktif,
            'riwayat' => $riwayat,
            'denda_berjalan' => $berjalan,
            'maks_pinjam' => MAKS_PINJAM,
            'lama_hari' => LAMA_PINJAM_HARI,
            'denda_per_hari' => DENDA_PER_HARI,
        ]);

    case 'POST':
        $bukuId = (int) (bacaJson()['buku_id'] ?? 0);
        $pdo->beginTransaction();
        $tolak = function (int $status, string $pesan) use ($pdo): never {
            $pdo->rollBack();
            kirim($status, ['pesan' => $pesan]);
        };
        try {
            // Kunci baris buku agar dua mahasiswa tidak mengambil eksemplar terakhir bersamaan
            $q = $pdo->prepare('SELECT id, stok FROM buku WHERE id = ? FOR UPDATE');
            $q->execute([$bukuId]);
            $buku = $q->fetch();
            if (!$buku) $tolak(404, 'Buku tidak ditemukan.');

            $q = $pdo->prepare(
                'SELECT COUNT(*) AS aktif,
                        COALESCE(SUM(jatuh_tempo < NOW()), 0) AS telat,
                        COALESCE(SUM(buku_id = ?), 0) AS sama
                 FROM peminjaman WHERE mahasiswa_id = ? AND dikembalikan IS NULL'
            );
            $q->execute([$bukuId, $mhs]);
            $s = $q->fetch();
            if ((int) $s['sama'] > 0) $tolak(422, 'Buku ini sedang Anda pinjam.');
            if ((int) $s['telat'] > 0) $tolak(422, 'Kembalikan buku yang terlambat lebih dulu.');
            if ((int) $s['aktif'] >= MAKS_PINJAM) $tolak(422, 'Batas ' . MAKS_PINJAM . ' pinjaman aktif sudah tercapai.');

            $q = $pdo->prepare('SELECT COUNT(*) FROM peminjaman WHERE buku_id = ? AND dikembalikan IS NULL');
            $q->execute([$bukuId]);
            if ((int) $q->fetchColumn() >= (int) $buku['stok']) $tolak(422, 'Stok buku habis.');

            $pdo->prepare(
                'INSERT INTO peminjaman (buku_id, mahasiswa_id, jatuh_tempo)
                 VALUES (?, ?, NOW() + INTERVAL ' . LAMA_PINJAM_HARI . ' DAY)'
            )->execute([$bukuId, $mhs]);
            $pdo->commit();
        } catch (PDOException $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            kirim(500, ['pesan' => 'Terjadi kesalahan pada server.']);
        }
        kirim(201, ['pesan' => 'Peminjaman berhasil. Jatuh tempo ' . LAMA_PINJAM_HARI . ' hari lagi.']);

    default:
        kirim(405, ['pesan' => 'Metode tidak didukung.']);
}