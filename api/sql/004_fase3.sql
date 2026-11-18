CREATE TABLE notifikasi (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pengguna_id INT UNSIGNED NOT NULL,
  kelas_id INT UNSIGNED NULL,
  jenis ENUM('pengumuman','tugas') NOT NULL,
  judul VARCHAR(150) NOT NULL,
  isi VARCHAR(255) NOT NULL,
  dibuat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dibaca_pada DATETIME NULL,          -- NULL berarti belum dibaca
  INDEX idx_notif_pengguna (pengguna_id, dibaca_pada, id),
  FOREIGN KEY (pengguna_id) REFERENCES pengguna(id) ON DELETE CASCADE,
  FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE preferensi_notifikasi (
  pengguna_id INT UNSIGNED NOT NULL,
  kelas_id INT UNSIGNED NOT NULL,
  aktif TINYINT(1) NOT NULL DEFAULT 1,   -- tanpa baris berarti aktif
  PRIMARY KEY (pengguna_id, kelas_id),
  FOREIGN KEY (pengguna_id) REFERENCES pengguna(id) ON DELETE CASCADE,
  FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Target SKS lulus per prodi (data fiktif, IKOM mengikuti contoh syarat 138 SKS)
ALTER TABLE prodi ADD COLUMN sks_lulus SMALLINT UNSIGNED NOT NULL DEFAULT 144;
UPDATE prodi SET sks_lulus = 138 WHERE kode = 'IKOM';

-- Notifikasi contoh dari pengumuman dan tugas yang sudah ada
INSERT INTO notifikasi (pengguna_id, kelas_id, jenis, judul, isi, dibuat)
SELECT r.mahasiswa_id, a.kelas_id, 'pengumuman', CONCAT('Pengumuman ', mk.nama), LEFT(a.isi, 255), a.dibuat
FROM pengumuman_kelas a
JOIN kelas k ON k.id = a.kelas_id
JOIN matakuliah mk ON mk.id = k.matakuliah_id
JOIN krs r ON r.kelas_id = a.kelas_id;

INSERT INTO notifikasi (pengguna_id, kelas_id, jenis, judul, isi, dibuat)
SELECT r.mahasiswa_id, t.kelas_id, 'tugas', CONCAT('Tugas baru ', mk.nama), LEFT(t.judul, 255), t.dibuat
FROM tugas t
JOIN kelas k ON k.id = t.kelas_id
JOIN matakuliah mk ON mk.id = k.matakuliah_id
JOIN krs r ON r.kelas_id = t.kelas_id;

-- Pengumuman lama dianggap sudah dibaca dua jam setelah terbit (bahan data waktu baca)
UPDATE notifikasi SET dibaca_pada = dibuat + INTERVAL 2 HOUR
WHERE jenis = 'pengumuman' AND dibuat < NOW() - INTERVAL 48 HOUR;