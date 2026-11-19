CREATE TABLE tagihan (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  mahasiswa_id INT UNSIGNED NOT NULL,
  tahun_akademik_id INT UNSIGNED NOT NULL,
  jenis VARCHAR(60) NOT NULL,
  nominal INT UNSIGNED NOT NULL,                 -- rupiah bulat
  jatuh_tempo DATETIME NOT NULL,
  status ENUM('belum','lunas') NOT NULL DEFAULT 'belum',
  dibayar_pada DATETIME NULL,
  kode_bayar CHAR(12) NOT NULL UNIQUE,           -- kode referensi fiktif
  INDEX idx_tagihan_mhs (mahasiswa_id, status),
  FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(pengguna_id) ON DELETE CASCADE,
  FOREIGN KEY (tahun_akademik_id) REFERENCES tahun_akademik(id)
) ENGINE=InnoDB;

CREATE TABLE buku (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  judul VARCHAR(200) NOT NULL,
  penulis VARCHAR(150) NOT NULL,
  penerbit VARCHAR(100) NULL,
  tahun SMALLINT UNSIGNED NULL,
  kategori VARCHAR(60) NOT NULL,
  stok SMALLINT NOT NULL DEFAULT 1               -- jumlah eksemplar
) ENGINE=InnoDB;

CREATE TABLE peminjaman (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  buku_id INT UNSIGNED NOT NULL,
  mahasiswa_id INT UNSIGNED NOT NULL,
  dipinjam DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  jatuh_tempo DATETIME NOT NULL,
  dikembalikan DATETIME NULL,                    -- NULL berarti masih dipinjam
  INDEX idx_pinjam_mhs (mahasiswa_id, dikembalikan),
  INDEX idx_pinjam_buku (buku_id, dikembalikan),
  FOREIGN KEY (buku_id) REFERENCES buku(id) ON DELETE CASCADE,
  FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(pengguna_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Pengumuman kampus menjadi papan berita
ALTER TABLE pengumuman
  ADD COLUMN kategori VARCHAR(40) NOT NULL DEFAULT 'Umum',
  ADD COLUMN penulis_id INT UNSIGNED NULL,
  ADD CONSTRAINT fk_pengumuman_penulis
      FOREIGN KEY (penulis_id) REFERENCES pengguna(id) ON DELETE SET NULL;