import 'api_client.dart';

const kategoriBerita = ['Umum', 'Akademik', 'Beasiswa', 'Kegiatan', 'Fasilitas'];

class BeritaRingkas {
  const BeritaRingkas({
    required this.id,
    required this.judul,
    required this.ringkas,
    required this.kategori,
    required this.dibuat,
  });
  final int id;
  final String judul, ringkas, kategori, dibuat;

  factory BeritaRingkas.dariJson(Map<String, dynamic> j) => BeritaRingkas(
        id: keInt(j['id']),
        judul: j['judul'] as String,
        ringkas: j['ringkas'] as String,
        kategori: j['kategori'] as String,
        dibuat: j['dibuat'] as String,
      );
}

class BeritaDetail {
  const BeritaDetail({
    required this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuat,
    this.penulis,
  });
  final int id;
  final String judul, isi, kategori, dibuat;
  final String? penulis;

  factory BeritaDetail.dariJson(Map<String, dynamic> j) => BeritaDetail(
        id: keInt(j['id']),
        judul: j['judul'] as String,
        isi: j['isi'] as String,
        kategori: j['kategori'] as String,
        dibuat: j['dibuat'] as String,
        penulis: j['penulis'] as String?,
      );
}

class DaftarBerita {
  const DaftarBerita({required this.bisaMenulis, required this.data});
  final bool bisaMenulis;
  final List<BeritaRingkas> data;
}

class BeritaRepository {
  BeritaRepository(this._api);
  final ApiClient _api;

  Future<DaftarBerita> daftar({String cari = '', String? kategori}) async {
    final d = await _api.kirim('GET', 'berita.php', query: {
      if (cari.isNotEmpty) 'q': cari,
      if (kategori != null) 'kategori': kategori,
    });
    return DaftarBerita(
      bisaMenulis: d['bisa_menulis'] == true,
      data: [for (final x in d['data'] as List) BeritaRingkas.dariJson(x as Map<String, dynamic>)],
    );
  }

  Future<BeritaDetail> detail(int id) async {
    final d = await _api.kirim('GET', 'berita.php', query: {'id': '$id'});
    return BeritaDetail.dariJson(d['data'] as Map<String, dynamic>);
  }

  Future<void> buat({required String judul, required String kategori, required String isi}) async {
    await _api.kirim('POST', 'berita.php', body: {'judul': judul, 'kategori': kategori, 'isi': isi});
  }
}