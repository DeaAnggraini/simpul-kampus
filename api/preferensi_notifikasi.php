<?php
require __DIR__ . '/kelas_util.php';
$saya = penggunaDariToken();
if ($saya['peran'] !== 'mahasiswa') kirim(403, ['pesan' => 'Khusus mahasiswa.']);
$uid = (int) $saya['id'];

switch ($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        $q = db()->prepare(
            'SELECT k.id AS kelas_id, mk.nama, k.nama AS kelas, COALESCE(p.aktif, 1) AS aktif
             FROM krs r
             JOIN kelas k ON k.id = r.kelas_id
             JOIN tahun_akademik t ON t.id = k.tahun_akademik_id AND t.aktif = 1
             JOIN matakuliah mk ON mk.id = k.matakuliah_id
             LEFT JOIN preferensi_notifikasi p ON p.pengguna_id = r.mahasiswa_id AND p.kelas_id = k.id
             WHERE r.mahasiswa_id = ? ORDER BY mk.nama'
        );
        $q->execute([$uid]);
        kirim(200, ['data' => $q->fetchAll()]);

    case 'POST': // {"kelas_id": 3, "aktif": false}
        $in = bacaJson();
        $kelas = aksesKelas($saya, (int) ($in['kelas_id'] ?? 0));
        if (!$kelas) kirim(404, ['pesan' => 'Kelas tidak ditemukan.']);
        $aktif = !empty($in['aktif']) ? 1 : 0;
        db()->prepare(
            'INSERT INTO preferensi_notifikasi (pengguna_id, kelas_id, aktif) VALUES (?, ?, ?)
             ON DUPLICATE KEY UPDATE aktif = ?'
        )->execute([$uid, $kelas['id'], $aktif, $aktif]);
        kirim(200, ['pesan' => 'Pengaturan tersimpan.']);

    default:
        kirim(405, ['pesan' => 'Metode tidak didukung.']);
}