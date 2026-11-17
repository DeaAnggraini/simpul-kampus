<?php
require_once __DIR__ . '/koneksi.php';

/** Data kelas bila pengguna berhak (mahasiswa anggota atau dosen pengampu), selain itu null. */
function aksesKelas(array $saya, int $kelasId): ?array
{
    if ($kelasId <= 0) return null;
    $dasar = 'SELECT k.id, k.nama AS kelas, k.hari, k.jam_mulai, k.jam_selesai, k.ruang, k.tautan_rapat,
                     mk.kode, mk.nama AS mk_nama, mk.sks, pd.nama AS dosen
              FROM kelas k
              JOIN matakuliah mk ON mk.id = k.matakuliah_id
              JOIN pengguna pd ON pd.id = k.dosen_id ';
    if ($saya['peran'] === 'dosen') {
        $q = db()->prepare($dasar . 'WHERE k.id = ? AND k.dosen_id = ?');
        $q->execute([$kelasId, $saya['id']]);
    } elseif ($saya['peran'] === 'mahasiswa') {
        $q = db()->prepare($dasar . 'JOIN krs r ON r.kelas_id = k.id AND r.mahasiswa_id = ? WHERE k.id = ?');
        $q->execute([$saya['id'], $kelasId]);
    } else {
        return null;
    }
    return $q->fetch() ?: null;
}