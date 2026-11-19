<?php
require __DIR__ . '/koneksi.php';
$saya = penggunaDariToken();
if ($saya['peran'] !== 'mahasiswa') kirim(403, ['pesan' => 'Khusus mahasiswa.']);

$q = db()->prepare(
    'SELECT t.id, t.jenis, t.nominal, t.jatuh_tempo, t.status, t.dibayar_pada, t.kode_bayar,
            ta.nama AS tahun, ta.semester,
            (t.status = "belum" AND t.jatuh_tempo < NOW()) AS terlambat
     FROM tagihan t JOIN tahun_akademik ta ON ta.id = t.tahun_akademik_id
     WHERE t.mahasiswa_id = ? ORDER BY t.jatuh_tempo'
);
$q->execute([(int) $saya['id']]);

$belum = [];
$lunas = [];
$total = 0;
foreach ($q->fetchAll() as $t) {
    $t['nominal'] = (int) $t['nominal'];
    $t['terlambat'] = (bool) $t['terlambat'];
    $t['periode'] = $t['tahun'] . ' ' . ucfirst($t['semester']);
    unset($t['tahun'], $t['semester']);
    if ($t['status'] === 'lunas') {
        $lunas[] = $t;
    } else {
        $belum[] = $t;
        $total += $t['nominal'];
    }
}
kirim(200, ['belum' => $belum, 'lunas' => array_reverse($lunas), 'total_belum' => $total]);