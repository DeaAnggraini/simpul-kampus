<?php
require __DIR__ . '/koneksi.php';
$saya = penggunaDariToken();
if ($saya['peran'] !== 'mahasiswa') kirim(403, ['pesan' => 'Khusus mahasiswa.']);

$q = db()->prepare(
    'SELECT t.id AS ta_id, t.nama AS tahun, t.semester,
            mk.kode, mk.nama, mk.sks, r.nilai_huruf AS nilai
     FROM krs r
     JOIN kelas k ON k.id = r.kelas_id
     JOIN tahun_akademik t ON t.id = k.tahun_akademik_id
     JOIN matakuliah mk ON mk.id = k.matakuliah_id
     WHERE r.mahasiswa_id = ?
     ORDER BY t.nama, FIELD(t.semester, "ganjil", "genap", "pendek"), mk.nama'
);
$q->execute([$saya['id']]);

$semua = [];
foreach ($q->fetchAll() as $b) {
    $id = $b['ta_id'];
    if (!isset($semua[$id])) {
        $semua[$id] = ['tahun' => $b['tahun'], 'semester' => $b['semester'], 'matakuliah' => []];
    }
    $semua[$id]['matakuliah'][] = [
        'kode' => $b['kode'], 'nama' => $b['nama'],
        'sks' => (int) $b['sks'], 'nilai' => $b['nilai'],
    ];
}

$bobot = ['A' => 4, 'B' => 3, 'C' => 2, 'D' => 1, 'E' => 0];
$sksKum = 0;
$mutuKum = 0;
$hasil = [];
foreach ($semua as $s) {
    $sks = 0;
    $mutu = 0;
    foreach ($s['matakuliah'] as $m) {
        if ($m['nilai'] === null) continue; // belum ada nilai, tidak dihitung
        $sks += $m['sks'];
        $mutu += $m['sks'] * $bobot[$m['nilai']];
    }
    $sksKum += $sks;
    $mutuKum += $mutu;
    $s['sks'] = $sks;
    $s['ips'] = $sks > 0 ? round($mutu / $sks, 2) : null;
    $s['ipk'] = $sksKum > 0 ? round($mutuKum / $sksKum, 2) : null;
    $s['sks_kumulatif'] = $sksKum;
    $hasil[] = $s;
}

kirim(200, [
    'data' => $hasil,
    'ipk' => $sksKum > 0 ? round($mutuKum / $sksKum, 2) : 0,
    'sks_total' => $sksKum,
]);