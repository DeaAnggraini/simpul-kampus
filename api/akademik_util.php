<?php
require_once __DIR__ . '/koneksi.php';

/** SKS bernilai, total mutu, dan IPK. Dihitung dari nilai, tidak disimpan. */
function ringkasanNilai(int $mhs): array
{
    $q = db()->prepare(
        'SELECT COALESCE(SUM(mk.sks), 0) AS sks,
                COALESCE(SUM(mk.sks * CASE r.nilai_huruf WHEN "A" THEN 4 WHEN "B" THEN 3
                    WHEN "C" THEN 2 WHEN "D" THEN 1 ELSE 0 END), 0) AS mutu
         FROM krs r
         JOIN kelas k ON k.id = r.kelas_id
         JOIN matakuliah mk ON mk.id = k.matakuliah_id
         WHERE r.mahasiswa_id = ? AND r.nilai_huruf IS NOT NULL'
    );
    $q->execute([$mhs]);
    $h = $q->fetch();
    $sks = (int) $h['sks'];
    $mutu = (int) $h['mutu'];
    return ['sks' => $sks, 'mutu' => $mutu, 'ipk' => $sks > 0 ? round($mutu / $sks, 2) : 0.0];
}