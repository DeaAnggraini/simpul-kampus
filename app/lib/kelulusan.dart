import 'api_client.dart';

class MkWajib {
  const MkWajib({
    required this.kode,
    required this.nama,
    required this.sks,
    required this.semesterKe,
    required this.sedangDiambil,
  });
  final String kode, nama;
  final int sks, semesterKe;
  final bool sedangDiambil;

  factory MkWajib.dariJson(Map<String, dynamic> j) => MkWajib(
    kode: j['kode'] as String,
    nama: j['nama'] as String,
    sks: keInt(j['sks']),
    semesterKe: keInt(j['semester_ke']),
    sedangDiambil: j['sedang_diambil'] == true,
  );
}

class Kelulusan {
  const Kelulusan({
    required this.sksTarget,
    required this.sksLulus,
    required this.sksSisa,
    required this.sksBernilai,
    required this.persen,
    required this.ipk,
    required this.wajibBelum,
  });
  final int sksTarget, sksLulus, sksSisa, sksBernilai;
  final double persen, ipk;
  final List<MkWajib> wajibBelum;

  double get rasio =>
      sksTarget == 0 ? 0.0 : (sksLulus / sksTarget).clamp(0.0, 1.0).toDouble();

  factory Kelulusan.dariJson(Map<String, dynamic> j) => Kelulusan(
    sksTarget: keInt(j['sks_target']),
    sksLulus: keInt(j['sks_lulus']),
    sksSisa: keInt(j['sks_sisa']),
    sksBernilai: keInt(j['sks_bernilai']),
    persen: (j['persen'] as num).toDouble(),
    ipk: (j['ipk'] as num).toDouble(),
    wajibBelum: [
      for (final x in j['wajib_belum'] as List)
        MkWajib.dariJson(x as Map<String, dynamic>),
    ],
  );
}

class KelulusanRepository {
  KelulusanRepository(this._api);
  final ApiClient _api;

  Future<Kelulusan> ambil() async =>
      Kelulusan.dariJson(await _api.kirim('GET', 'kelulusan.php'));
}
