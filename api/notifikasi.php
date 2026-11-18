<?php
require __DIR__ . '/kelas_util.php';
$saya = penggunaDariToken();
if ($saya['peran'] !== 'mahasiswa') kirim(403, ['pesan' => 'Khusus mahasiswa.']);
$pdo = db();
$uid = (int) $saya['id'];

switch ($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        $q = $pdo->prepare(
            'SELECT id, kelas_id, jenis, judul, isi, dibuat, (dibaca_pada IS NOT NULL) AS dibaca
             FROM notifikasi WHERE pengguna_id = ? ORDER BY id DESC LIMIT 50'
        );
        $q->execute([$uid]);
        $data = $q->fetchAll();
        foreach ($data as &$n) $n['dibaca'] = (bool) $n['dibaca'];
        unset($n);
        $q = $pdo->prepare('SELECT COUNT(*) FROM notifikasi WHERE pengguna_id = ? AND dibaca_pada IS NULL');
        $q->execute([$uid]);
        kirim(200, ['data' => $data, 'belum_dibaca' => (int) $q->fetchColumn()]);

    case 'POST': // {"id": 5} atau {"semua": true}
        $in = bacaJson();
        if (!empty($in['semua'])) {
            $pdo->prepare('UPDATE notifikasi SET dibaca_pada = NOW()
                           WHERE pengguna_id = ? AND dibaca_pada IS NULL')->execute([$uid]);
        } else {
            $pdo->prepare('UPDATE notifikasi SET dibaca_pada = NOW()
                           WHERE id = ? AND pengguna_id = ? AND dibaca_pada IS NULL')
                ->execute([(int) ($in['id'] ?? 0), $uid]);
        }
        kirim(200, ['pesan' => 'Ditandai sudah dibaca.']);

    default:
        kirim(405, ['pesan' => 'Metode tidak didukung.']);
}