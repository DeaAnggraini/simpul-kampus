INSERT INTO matakuliah (kode, nama, sks) VALUES
 ('IKM303','Jaringan Komputer',3),
 ('IKM304','Kecerdasan Buatan',3),
 ('SNS102','Statistika',2);

INSERT INTO kurikulum_matakuliah (kurikulum_id, matakuliah_id, semester_ke)
SELECT 1, id, 5 FROM matakuliah WHERE kode IN ('IKM303','IKM304','SNS102');

INSERT INTO kelas (matakuliah_id, tahun_akademik_id, nama, dosen_id, hari, jam_mulai, jam_selesai, ruang, kuota) VALUES
 ((SELECT id FROM matakuliah WHERE kode='IKM303'), (SELECT id FROM tahun_akademik WHERE aktif=1 LIMIT 1), 'A',
  (SELECT id FROM pengguna WHERE nomor_induk='D001'), 1, '13:00', '15:30', 'Lab 2', 40),
 ((SELECT id FROM matakuliah WHERE kode='IKM303'), (SELECT id FROM tahun_akademik WHERE aktif=1 LIMIT 1), 'B',
  (SELECT id FROM pengguna WHERE nomor_induk='D001'), 2, '13:00', '15:30', 'Lab 2', 40),
 ((SELECT id FROM matakuliah WHERE kode='IKM304'), (SELECT id FROM tahun_akademik WHERE aktif=1 LIMIT 1), 'A',
  (SELECT id FROM pengguna WHERE nomor_induk='D001'), 2, '09:00', '11:30', 'R 305', 40),
 ((SELECT id FROM matakuliah WHERE kode='SNS102'), (SELECT id FROM tahun_akademik WHERE aktif=1 LIMIT 1), 'A',
  (SELECT id FROM pengguna WHERE nomor_induk='D001'), 3, '13:00', '14:40', 'R 102', 40);

-- Kosongkan KRS semester aktif milik mahasiswa contoh agar bisa diisi dari awal
DELETE r FROM krs r
JOIN kelas k ON k.id = r.kelas_id
JOIN pengguna p ON p.id = r.mahasiswa_id
WHERE p.nomor_induk = '4240000001'
  AND k.tahun_akademik_id = (SELECT id FROM tahun_akademik WHERE aktif = 1 LIMIT 1)
  AND r.nilai_huruf IS NULL;