import 'api_client.dart';

class ProfilLengkap {
  const ProfilLengkap({
    required this.nim,
    required this.nama,
    required this.email,
    required this.prodi,
    required this.fakultas,
    required this.kurikulum,
    required this.angkatan,
    this.dosenPa,
  });
  final String nim, nama, email, prodi, fakultas, kurikulum;
  final int angkatan;
  final String? dosenPa;

  factory ProfilLengkap.dariJson(Map<String, dynamic> j) => ProfilLengkap(
        nim: j['nim'] as String,
        nama: j['nama'] as String,
        email: j['email'] as String,
        prodi: j['prodi'] as String,
        fakultas: j['fakultas'] as String,
        kurikulum: j['kurikulum'] as String,
        angkatan: keInt(j['angkatan']),
        dosenPa: j['dosen_pa'] as String?,
      );
}

class NilaiMk {
  const NilaiMk({required this.kode, required this.nama, required this.sks, this.nilai});
  final String kode, nama;
  final int sks;
  final String? nilai; // null berarti belum ada nilai

  factory NilaiMk.dariJson(Map<String, dynamic> j) => NilaiMk(
        kode: j['kode'] as String,
        nama: j['nama'] as String,
        sks: keInt(j['sks']),
        nilai: j['nilai'] as String?,
      );
}

class Semester {
  const Semester({
    required this.tahun,
    required this.jenis,
    required this.sks,
    required this.sksKumulatif,
    required this.matakuliah,
    this.ips,
    this.ipk,
  });
  final String tahun, jenis;
  final int sks, sksKumulatif;
  final double? ips, ipk;
  final List<NilaiMk> matakuliah;

  String get judul => '$tahun ${jenis[0].toUpperCase()}${jenis.substring(1)}';

  factory Semester.dariJson(Map<String, dynamic> j) => Semester(
        tahun: j['tahun'] as String,
        jenis: j['semester'] as String,
        sks: keInt(j['sks']),
        sksKumulatif: keInt(j['sks_kumulatif']),
        ips: (j['ips'] as num?)?.toDouble(),
        ipk: (j['ipk'] as num?)?.toDouble(),
        matakuliah: [
          for (final m in j['matakuliah'] as List)
            NilaiMk.dariJson(m as Map<String, dynamic>)
        ],
      );
}

class Khs {
  const Khs(this.daftar, this.ipk, this.sksTotal);
  final List<Semester> daftar;
  final double ipk;
  final int sksTotal;

  factory Khs.dariJson(Map<String, dynamic> j) => Khs(
        [for (final s in j['data'] as List) Semester.dariJson(s as Map<String, dynamic>)],
        (j['ipk'] as num).toDouble(),
        keInt(j['sks_total']),
      );
}

/// Satu-satunya tempat yang tahu endpoint data akademik.
class AkademikRepository {
  AkademikRepository(this._api);
  final ApiClient _api;

  Future<ProfilLengkap> ambilProfil() async => ProfilLengkap.dariJson(
      (await _api.kirim('GET', 'profil.php'))['data'] as Map<String, dynamic>);

  Future<Khs> ambilKhs() async => Khs.dariJson(await _api.kirim('GET', 'khs.php'));
}