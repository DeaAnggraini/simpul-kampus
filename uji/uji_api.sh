#!/usr/bin/env bash
# Uji otomatis REST API Simpul Kampus.

B=${1:-http://localhost/simpul_kampus/api}
lulus=0
gagal=0

# kode METODE JALUR [TOKEN] [DATA] mencetak kode status HTTP
kode() {
  local args=(-s -o /dev/null -w '%{http_code}' -X "$1" "$B/$2")
  [ -n "$3" ] && args+=(-H "Authorization: Bearer $3")
  [ -n "$4" ] && args+=(-d "$4")
  curl "${args[@]}"
}

# cek NAMA HARAPAN HASIL
cek() {
  if [ "$2" = "$3" ]; then
    lulus=$((lulus + 1)); echo "LULUS  $1"
  else
    gagal=$((gagal + 1)); echo "GAGAL  $1 (harapan $2, hasil $3)"
  fi
}

# masuk NIM SANDI mencetak token
masuk() {
  curl -s -X POST "$B/masuk.php" -d "{\"nim\":\"$1\",\"sandi\":\"$2\"}" \
    | sed -n -E 's/.*"token":"([a-f0-9]{64})".*/\1/p'
}

M=$(masuk 4240000001 rahasia123)
D=$(masuk D001 rahasia123)
A=$(masuk A001 rahasia123)
if [ -z "$M" ] || [ -z "$D" ] || [ -z "$A" ]; then
  echo "Login awal gagal. Periksa Apache, MySQL, dan data seed."
  exit 1
fi

echo "== Autentikasi =="
cek "login benar" 200 "$(kode POST masuk.php '' '{"nim":"4240000001","sandi":"rahasia123"}')"
cek "login sandi salah" 401 "$(kode POST masuk.php '' '{"nim":"4240000001","sandi":"salah"}')"
cek "login injeksi SQL ditolak" 401 "$(kode POST masuk.php '' "{\"nim\":\"' OR '1'='1\",\"sandi\":\"x\"}")"
cek "masuk.php dengan GET ditolak" 405 "$(kode GET masuk.php)"
cek "tanpa token ditolak" 401 "$(kode GET khs.php)"
cek "token palsu ditolak" 401 "$(kode GET khs.php 0000000000000000000000000000000000000000000000000000000000000000)"
cek "token berformat salah ditolak" 401 "$(kode GET khs.php abc)"

echo "== Data mahasiswa =="
for j in profil.php khs.php krs.php hari_ini.php kelulusan.php notifikasi.php \
         preferensi_notifikasi.php keuangan.php peminjaman.php kelas.php; do
  cek "mahasiswa GET $j" 200 "$(kode GET "$j" "$M")"
done
cek "mahasiswa GET buku.php" 200 "$(kode GET buku.php "$M")"
cek "mahasiswa GET berita.php" 200 "$(kode GET berita.php "$M")"

echo "== Hak akses =="
cek "dosen ke hari_ini ditolak" 403 "$(kode GET hari_ini.php "$D")"
cek "dosen ke khs ditolak" 403 "$(kode GET khs.php "$D")"
cek "admin ke kelas ditolak" 403 "$(kode GET kelas.php "$A")"
cek "mahasiswa membuat tugas ditolak" 403 "$(kode POST tugas.php "$M" '{"kelas_id":1,"judul":"x","tenggat":"2030-01-01 23:59:00"}')"
cek "mahasiswa membuat pengumuman kelas ditolak" 403 "$(kode POST pengumuman_kelas.php "$M" '{"kelas_id":1,"isi":"x"}')"
cek "mahasiswa menerbitkan berita ditolak" 403 "$(kode POST berita.php "$M" '{"judul":"x","kategori":"Umum","isi":"x"}')"
cek "dosen mengumpulkan tugas ditolak" 403 "$(kode POST pengumpulan.php "$D" '{"tugas_id":1,"jawaban":"x"}')"
cek "dosen meminjam buku ditolak" 403 "$(kode POST peminjaman.php "$D" '{"buku_id":1}')"

echo "== Validasi dan data tidak ada =="
cek "kelas tidak ada" 404 "$(kode GET 'kelas_detail.php?id=999999' "$M")"
cek "tugas tidak ada" 404 "$(kode POST pengumpulan.php "$M" '{"tugas_id":999999,"jawaban":"x"}')"
cek "buku tidak ada" 404 "$(kode POST peminjaman.php "$M" '{"buku_id":999999}')"
cek "berita tidak ada" 404 "$(kode GET 'berita.php?id=999999' "$M")"
cek "KRS tanpa kelas" 422 "$(kode POST krs.php "$M" '{"kelas_ids":[]}')"
cek "berita kategori salah" 422 "$(kode POST berita.php "$A" '{"judul":"x","kategori":"Ngawur","isi":"x"}')"
cek "berita judul kosong" 422 "$(kode POST berita.php "$A" '{"judul":"","kategori":"Umum","isi":"x"}')"
cek "tugas pada kelas bukan milik dosen" 404 "$(kode POST tugas.php "$D" '{"kelas_id":999999,"judul":"x","tenggat":"2030-01-01 23:59:00"}')"
cek "pengembalian tanpa peminjaman" 404 "$(kode POST pengembalian.php "$M" '{"peminjaman_id":999999}')"

echo "== Keluar =="
T2=$(masuk 4240000001 rahasia123)
cek "keluar berhasil" 200 "$(kode POST keluar.php "$T2")"
cek "token setelah keluar ditolak" 401 "$(kode GET khs.php "$T2")"

echo
echo "Lulus $lulus, gagal $gagal"
[ "$gagal" -eq 0 ]