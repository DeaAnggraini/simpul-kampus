import 'api_client.dart';

class Profil {
  const Profil({
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.semester,
    required this.sks,
    required this.ipk,
    this.dosenPa,
  });
  final String nim, nama, prodi;
  final int semester, sks;
  final double ipk;
  final String? dosenPa;

  factory Profil.dariJson(Map<String, dynamic> j) => Profil(
        nim: j['nim'] as String,
        nama: j['nama'] as String,
        prodi: j['prodi'] as String,
        semester: keInt(j['semester']),
        sks: keInt(j['sks_tempuh']),
        ipk: double.parse('${j['ipk']}'),
        dosenPa: j['dosen_pa'] as String?,
      );
}

class ItemJadwal {
  const ItemJadwal({
    required this.nama,
    required this.dosen,
    required this.mulai,
    required this.selesai,
    required this.ruang,
  });
  final String nama, dosen, mulai, selesai, ruang;

  factory ItemJadwal.dariJson(Map<String, dynamic> j) => ItemJadwal(
        nama: j['nama'] as String,
        dosen: j['dosen'] as String,
        mulai: (j['jam_mulai'] as String).substring(0, 5),
        selesai: (j['jam_selesai'] as String).substring(0, 5),
        ruang: j['ruang'] as String,
      );
}

class Beranda {
  const Beranda(this.profil, this.jadwal, this.pengumuman);
  final Profil profil;
  final List<ItemJadwal> jadwal;
  final List<Map<String, dynamic>> pengumuman;

  factory Beranda.dariJson(Map<String, dynamic> j) => Beranda(
        Profil.dariJson(j['profil'] as Map<String, dynamic>),
        [
          for (final x in j['jadwal_hari_ini'] as List)
            ItemJadwal.dariJson(x as Map<String, dynamic>)
        ],
        [for (final x in j['pengumuman'] as List) x as Map<String, dynamic>],
      );
}