import 'api_client.dart';
import 'krs.dart' show namaHari;

String _d2(int n) => n.toString().padLeft(2, '0');

/// "2026-11-20 23:59:00" menjadi "20/11/2026 23.59"
String formatWaktu(String s) {
  final t = DateTime.parse(s);
  return '${_d2(t.day)}/${_d2(t.month)}/${t.year} ${_d2(t.hour)}.${_d2(t.minute)}';
}

/// Format yang diterima server.
String keFormatServer(DateTime t) =>
    '${t.year}-${_d2(t.month)}-${_d2(t.day)} ${_d2(t.hour)}:${_d2(t.minute)}:00';

class KelasSaya {
  const KelasSaya({
    required this.id,
    required this.kode,
    required this.nama,
    required this.kelas,
    required this.dosen,
    required this.hari,
    required this.mulai,
    required this.selesai,
    required this.ruang,
    required this.jumlahAnggota,
  });
  final int id, hari, jumlahAnggota;
  final String kode, nama, kelas, dosen, mulai, selesai, ruang;

  String get jadwal => '${namaHari[hari]} $mulai sampai $selesai';

  factory KelasSaya.dariJson(Map<String, dynamic> j) => KelasSaya(
        id: keInt(j['id']),
        kode: j['kode'] as String,
        nama: j['nama'] as String,
        kelas: j['kelas'] as String,
        dosen: j['dosen'] as String,
        hari: keInt(j['hari']),
        mulai: (j['jam_mulai'] as String).substring(0, 5),
        selesai: (j['jam_selesai'] as String).substring(0, 5),
        ruang: j['ruang'] as String,
        jumlahAnggota: keInt(j['jumlah_anggota']),
      );
}

class Pengumuman {
  const Pengumuman({required this.id, required this.isi, required this.dibuat, required this.penulis});
  final int id;
  final String isi, dibuat, penulis;

  factory Pengumuman.dariJson(Map<String, dynamic> j) => Pengumuman(
        id: keInt(j['id']),
        isi: j['isi'] as String,
        dibuat: j['dibuat'] as String,
        penulis: j['penulis'] as String,
      );
}

class Tugas {
  const Tugas({
    required this.id,
    required this.judul,
    required this.tenggat,
    required this.lewat,
    required this.jumlahTerkirim,
    this.deskripsi,
    this.jawaban,
  });
  final int id, jumlahTerkirim;
  final String judul, tenggat;
  final String? deskripsi, jawaban;
  final bool lewat;

  bool get terkirim => jawaban != null;

  factory Tugas.dariJson(Map<String, dynamic> j) => Tugas(
        id: keInt(j['id']),
        judul: j['judul'] as String,
        tenggat: j['tenggat'] as String,
        lewat: j['lewat'] == true,
        jumlahTerkirim: keInt(j['jumlah_terkirim']),
        deskripsi: j['deskripsi'] as String?,
        jawaban: j['jawaban'] as String?,
      );
}

class Anggota {
  const Anggota({required this.nama, this.nim});
  final String nama;
  final String? nim;

  factory Anggota.dariJson(Map<String, dynamic> j) =>
      Anggota(nama: j['nama'] as String, nim: j['nim'] as String?);
}

class DetailKelas {
  const DetailKelas({
    required this.id,
    required this.kelas,
    required this.kode,
    required this.namaMk,
    required this.dosen,
    required this.hari,
    required this.mulai,
    required this.selesai,
    required this.ruang,
    required this.bolehTulis,
    required this.pengumuman,
    required this.tugas,
    required this.anggota,
    this.tautanRapat,
  });
  final int id, hari;
  final String kelas, kode, namaMk, dosen, mulai, selesai, ruang;
  final String? tautanRapat;
  final bool bolehTulis;
  final List<Pengumuman> pengumuman;
  final List<Tugas> tugas;
  final List<Anggota> anggota;

  String get jadwal => '${namaHari[hari]} $mulai sampai $selesai';

  factory DetailKelas.dariJson(Map<String, dynamic> j) {
    final k = j['kelas'] as Map<String, dynamic>;
    return DetailKelas(
      id: keInt(k['id']),
      kelas: k['kelas'] as String,
      kode: k['kode'] as String,
      namaMk: k['mk_nama'] as String,
      dosen: k['dosen'] as String,
      hari: keInt(k['hari']),
      mulai: (k['jam_mulai'] as String).substring(0, 5),
      selesai: (k['jam_selesai'] as String).substring(0, 5),
      ruang: k['ruang'] as String,
      tautanRapat: k['tautan_rapat'] as String?,
      bolehTulis: j['bisa_menulis'] == true,
      pengumuman: [for (final x in j['pengumuman'] as List) Pengumuman.dariJson(x as Map<String, dynamic>)],
      tugas: [for (final x in j['tugas'] as List) Tugas.dariJson(x as Map<String, dynamic>)],
      anggota: [for (final x in j['anggota'] as List) Anggota.dariJson(x as Map<String, dynamic>)],
    );
  }
}

/// Satu-satunya tempat yang tahu endpoint kelas.
class KelasRepository {
  KelasRepository(this._api);
  final ApiClient _api;

  Future<List<KelasSaya>> daftar() async {
    final d = await _api.kirim('GET', 'kelas.php');
    return [for (final x in d['data'] as List) KelasSaya.dariJson(x as Map<String, dynamic>)];
  }

  Future<DetailKelas> detail(int id) async => DetailKelas.dariJson(
      await _api.kirim('GET', 'kelas_detail.php', query: {'id': '$id'}));

  Future<void> buatPengumuman(int kelasId, String isi) async {
    await _api.kirim('POST', 'pengumuman_kelas.php', body: {'kelas_id': kelasId, 'isi': isi});
  }

  Future<void> buatTugas(int kelasId,
      {required String judul, required String deskripsi, required String tenggat}) async {
    await _api.kirim('POST', 'tugas.php', body: {
      'kelas_id': kelasId,
      'judul': judul,
      'deskripsi': deskripsi,
      'tenggat': tenggat,
    });
  }

  Future<void> kumpul(int tugasId, String jawaban) async {
    await _api.kirim('POST', 'pengumpulan.php', body: {'tugas_id': tugasId, 'jawaban': jawaban});
  }
}