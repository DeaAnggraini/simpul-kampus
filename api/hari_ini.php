<?php
require __DIR__ . '/akademik_util.php';
$saya = penggunaDariToken();
if ($saya['peran'] !== 'mahasiswa') kirim(403, ['pesan' => 'Khusus mahasiswa.']);
$pdo = db();
$mhs = (int) $saya['id'];
$nilai = ringkasanNilai($mhs);

// Hari dihitung MySQL (WEEKDAY: Senin 0), jadi Senin menjadi 1
$q = $pdo->prepare(
    'SELECT k.id AS kelas_id, mk.nama, k.nama AS kelas, pd.nama AS dosen,
            k.jam_mulai, k.jam_selesai, k.ruang
     FROM krs r
     JOIN kelas k ON k.id = r.kelas_id
     JOIN tahun_akademik t ON t.id = k.tahun_akademik_id AND t.aktif = 1
     JOIN matakuliah mk ON mk.id = k.matakuliah_id
     JOIN pengguna pd ON pd.id = k.dosen_id
     WHERE r.mahasiswa_id = ? AND k.hari = WEEKDAY(NOW()) + 1
     ORDER BY k.jam_mulai'
);
$q->execute([$mhs]);
$jadwal = $q->fetchAll();

// Tugas belum dikumpulkan yang tenggatnya belum lewat
$q = $pdo->prepare(
    'SELECT t.id, t.judul, t.tenggat, k.id AS kelas_id, mk.nama AS matakuliah,
            TIMESTAMPDIFF(HOUR, NOW(), t.tenggat) AS sisa_jam
     FROM tugas t
     JOIN kelas k ON k.id = t.kelas_id
     JOIN tahun_akademik ta ON ta.id = k.tahun_akademik_id AND ta.aktif = 1
     JOIN matakuliah mk ON mk.id = k.matakuliah_id
     JOIN krs r ON r.kelas_id = k.id AND r.mahasiswa_id = ?
     LEFT JOIN pengumpulan s ON s.tugas_id = t.id AND s.mahasiswa_id = r.mahasiswa_id
     WHERE t.tenggat >= NOW() AND s.tugas_id IS NULL
     ORDER BY t.tenggat LIMIT 5'
);
$q->execute([$mhs]);
$tugas = $q->fetchAll();

$info = $pdo->query('SELECT judul, isi, dibuat FROM pengumuman ORDER BY id DESC LIMIT 3')->fetchAll();

// Ringkasan harian: kabar 24 jam terakhir dan notifikasi yang belum dibaca
$q = $pdo->prepare(
    "SELECT COALESCE(SUM(jenis = 'pengumuman' AND dibuat >= NOW() - INTERVAL 24 HOUR), 0) AS pengumuman,
            COALESCE(SUM(jenis = 'tugas' AND dibuat >= NOW() - INTERVAL 24 HOUR), 0) AS tugas,
            COALESCE(SUM(dibaca_pada IS NULL), 0) AS belum_dibaca
     FROM notifikasi WHERE pengguna_id = ?"
);
$q->execute([$mhs]);
$r = $q->fetch();

kirim(200, [
    'nama' => $saya['nama'],
    'ipk' => $nilai['ipk'],
    'sks' => $nilai['sks'],
    'jadwal' => $jadwal,
    'tugas' => $tugas,
    'info' => $info,
    'ringkasan' => [
        'pengumuman' => (int) $r['pengumuman'],
        'tugas' => (int) $r['tugas'],
        'belum_dibaca' => (int) $r['belum_dibaca'],
    ],
]);