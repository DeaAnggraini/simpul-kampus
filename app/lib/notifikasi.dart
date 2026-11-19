import 'api_client.dart';

class Notifikasi {
  const Notifikasi({
    required this.id,
    required this.jenis,
    required this.judul,
    required this.isi,
    required this.dibuat,
    required this.dibaca,
    this.kelasId,
  });
  final int id;
  final int? kelasId;
  final String jenis, judul, isi, dibuat;
  final bool dibaca;

  Notifikasi sudahDibaca() => Notifikasi(
    id: id,
    kelasId: kelasId,
    jenis: jenis,
    judul: judul,
    isi: isi,
    dibuat: dibuat,
    dibaca: true,
  );

  factory Notifikasi.dariJson(Map<String, dynamic> j) => Notifikasi(
    id: keInt(j['id']),
    kelasId: j['kelas_id'] == null ? null : keInt(j['kelas_id']),
    jenis: j['jenis'] as String,
    judul: j['judul'] as String,
    isi: j['isi'] as String,
    dibuat: j['dibuat'] as String,
    dibaca: j['dibaca'] == true,
  );
}

class PreferensiKelas {
  const PreferensiKelas({
    required this.kelasId,
    required this.nama,
    required this.kelas,
    required this.aktif,
  });
  final int kelasId;
  final String nama, kelas;
  final bool aktif;

  PreferensiKelas dengan(bool aktif) =>
      PreferensiKelas(kelasId: kelasId, nama: nama, kelas: kelas, aktif: aktif);

  factory PreferensiKelas.dariJson(Map<String, dynamic> j) => PreferensiKelas(
    kelasId: keInt(j['kelas_id']),
    nama: j['nama'] as String,
    kelas: j['kelas'] as String,
    aktif: keInt(j['aktif']) == 1,
  );
}

class NotifikasiRepository {
  NotifikasiRepository(this._api);
  final ApiClient _api;

  Future<List<Notifikasi>> daftar() async {
    final d = await _api.kirim('GET', 'notifikasi.php');
    return [
      for (final x in d['data'] as List)
        Notifikasi.dariJson(x as Map<String, dynamic>),
    ];
  }

  Future<void> tandaiBaca(int id) async {
    await _api.kirim('POST', 'notifikasi.php', body: {'id': id});
  }

  Future<void> tandaiSemua() async {
    await _api.kirim('POST', 'notifikasi.php', body: {'semua': true});
  }

  Future<List<PreferensiKelas>> preferensi() async {
    final d = await _api.kirim('GET', 'preferensi_notifikasi.php');
    return [
      for (final x in d['data'] as List)
        PreferensiKelas.dariJson(x as Map<String, dynamic>),
    ];
  }

  Future<void> aturPreferensi(int kelasId, bool aktif) async {
    await _api.kirim(
      'POST',
      'preferensi_notifikasi.php',
      body: {'kelas_id': kelasId, 'aktif': aktif},
    );
  }
}
