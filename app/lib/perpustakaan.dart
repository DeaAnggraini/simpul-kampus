import 'api_client.dart';

class Buku {
  const Buku({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.kategori,
    required this.tersedia,
    required this.dipinjamSaya,
    this.tahun,
  });
  final int id, tersedia;
  final String judul, penulis, kategori;
  final int? tahun;
  final bool dipinjamSaya;

  factory Buku.dariJson(Map<String, dynamic> j) => Buku(
        id: keInt(j['id']),
        judul: j['judul'] as String,
        penulis: j['penulis'] as String,
        kategori: j['kategori'] as String,
        tersedia: keInt(j['tersedia']),
        dipinjamSaya: j['dipinjam_saya'] == true,
        tahun: j['tahun'] == null ? null : keInt(j['tahun']),
      );
}

class Pinjaman {
  const Pinjaman({
    required this.id,
    required this.judul,
    required this.jatuhTempo,
    required this.terlambat,
    required this.hariTelat,
    required this.denda,
    this.dikembalikan,
  });
  final int id, hariTelat, denda;
  final String judul, jatuhTempo;
  final String? dikembalikan;
  final bool terlambat;

  factory Pinjaman.dariJson(Map<String, dynamic> j) => Pinjaman(
        id: keInt(j['id']),
        judul: j['judul'] as String,
        jatuhTempo: j['jatuh_tempo'] as String,
        terlambat: j['terlambat'] == true,
        hariTelat: keInt(j['hari_telat']),
        denda: keInt(j['denda']),
        dikembalikan: j['dikembalikan'] as String?,
      );
}

class DaftarPinjaman {
  const DaftarPinjaman({
    required this.aktif,
    required this.riwayat,
    required this.dendaBerjalan,
    required this.maks,
    required this.lamaHari,
    required this.dendaPerHari,
  });
  final List<Pinjaman> aktif, riwayat;
  final int dendaBerjalan, maks, lamaHari, dendaPerHari;

  factory DaftarPinjaman.dariJson(Map<String, dynamic> j) => DaftarPinjaman(
        aktif: [for (final x in j['aktif'] as List) Pinjaman.dariJson(x as Map<String, dynamic>)],
        riwayat: [for (final x in j['riwayat'] as List) Pinjaman.dariJson(x as Map<String, dynamic>)],
        dendaBerjalan: keInt(j['denda_berjalan']),
        maks: keInt(j['maks_pinjam']),
        lamaHari: keInt(j['lama_hari']),
        dendaPerHari: keInt(j['denda_per_hari']),
      );
}

class PerpustakaanRepository {
  PerpustakaanRepository(this._api);
  final ApiClient _api;

  Future<List<Buku>> cari(String q) async {
    final d = await _api.kirim('GET', 'buku.php', query: {if (q.isNotEmpty) 'q': q});
    return [for (final x in d['data'] as List) Buku.dariJson(x as Map<String, dynamic>)];
  }

  Future<DaftarPinjaman> daftarPinjaman() async =>
      DaftarPinjaman.dariJson(await _api.kirim('GET', 'peminjaman.php'));

  Future<void> pinjam(int bukuId) async {
    await _api.kirim('POST', 'peminjaman.php', body: {'buku_id': bukuId});
  }

  /// Mengembalikan jumlah denda dalam rupiah.
  Future<int> kembalikan(int peminjamanId) async {
    final d = await _api.kirim('POST', 'pengembalian.php', body: {'peminjaman_id': peminjamanId});
    return keInt(d['denda']);
  }
}