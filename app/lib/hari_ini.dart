import 'api_client.dart';

String _hhmm(String s) => s.substring(0, 5);

String sisaWaktu(int jam) {
  if (jam < 1) return 'kurang dari 1 jam';
  if (jam < 24) return '$jam jam lagi';
  return '${jam ~/ 24} hari lagi';
}

class JadwalHariIni {
  const JadwalHariIni({
    required this.kelasId,
    required this.nama,
    required this.kelas,
    required this.dosen,
    required this.mulai,
    required this.selesai,
    required this.ruang,
  });
  final int kelasId;
  final String nama, kelas, dosen, mulai, selesai, ruang;

  factory JadwalHariIni.dariJson(Map<String, dynamic> j) => JadwalHariIni(
        kelasId: keInt(j['kelas_id']),
        nama: j['nama'] as String,
        kelas: j['kelas'] as String,
        dosen: j['dosen'] as String,
        mulai: _hhmm(j['jam_mulai'] as String),
        selesai: _hhmm(j['jam_selesai'] as String),
        ruang: j['ruang'] as String,
      );
}

class TugasMendesak {
  const TugasMendesak({
    required this.id,
    required this.judul,
    required this.tenggat,
    required this.kelasId,
    required this.matakuliah,
    required this.sisaJam,
  });
  final int id, kelasId, sisaJam;
  final String judul, tenggat, matakuliah;

  factory TugasMendesak.dariJson(Map<String, dynamic> j) => TugasMendesak(
        id: keInt(j['id']),
        judul: j['judul'] as String,
        tenggat: j['tenggat'] as String,
        kelasId: keInt(j['kelas_id']),
        matakuliah: j['matakuliah'] as String,
        sisaJam: keInt(j['sisa_jam']),
      );
}

class InfoKampus {
  const InfoKampus({required this.judul, required this.isi, required this.dibuat});
  final String judul, isi, dibuat;

  factory InfoKampus.dariJson(Map<String, dynamic> j) => InfoKampus(
        judul: j['judul'] as String,
        isi: j['isi'] as String,
        dibuat: j['dibuat'] as String,
      );
}

class RingkasanHarian {
  const RingkasanHarian({required this.pengumuman, required this.tugas, required this.belumDibaca});
  final int pengumuman, tugas, belumDibaca;
}

class TagihanRingkas {
  const TagihanRingkas({
    required this.id,
    required this.jenis,
    required this.nominal,
    required this.jatuhTempo,
    required this.terlambat,
  });
  final int id, nominal;
  final String jenis, jatuhTempo;
  final bool terlambat;

  factory TagihanRingkas.dariJson(Map<String, dynamic> j) => TagihanRingkas(
        id: keInt(j['id']),
        jenis: j['jenis'] as String,
        nominal: keInt(j['nominal']),
        jatuhTempo: j['jatuh_tempo'] as String,
        terlambat: j['terlambat'] == true,
      );
}

class BukuJatuhTempo {
  const BukuJatuhTempo({
    required this.id,
    required this.judul,
    required this.jatuhTempo,
    required this.terlambat,
    required this.sisaJam,
  });
  final int id, sisaJam;
  final String judul, jatuhTempo;
  final bool terlambat;

  factory BukuJatuhTempo.dariJson(Map<String, dynamic> j) => BukuJatuhTempo(
        id: keInt(j['id']),
        judul: j['judul'] as String,
        jatuhTempo: j['jatuh_tempo'] as String,
        terlambat: j['terlambat'] == true,
        sisaJam: keInt(j['sisa_jam']),
      );
}

class HariIni {
  const HariIni({
    required this.nama,
    required this.ipk,
    required this.sks,
    required this.jadwal,
    required this.tugas,
    required this.info,
    required this.ringkasan,
    required this.tagihan,
    required this.buku,
  });
  final String nama;
  final double ipk;
  final int sks;
  final List<JadwalHariIni> jadwal;
  final List<TugasMendesak> tugas;
  final List<InfoKampus> info;
  final RingkasanHarian ringkasan;
  final List<TagihanRingkas> tagihan;
  final List<BukuJatuhTempo> buku;

  factory HariIni.dariJson(Map<String, dynamic> j) {
    final r = j['ringkasan'] as Map<String, dynamic>;
    return HariIni(
      nama: j['nama'] as String,
      ipk: (j['ipk'] as num).toDouble(),
      sks: keInt(j['sks']),
      jadwal: [for (final x in j['jadwal'] as List) JadwalHariIni.dariJson(x as Map<String, dynamic>)],
      tugas: [for (final x in j['tugas'] as List) TugasMendesak.dariJson(x as Map<String, dynamic>)],
      info: [for (final x in j['info'] as List) InfoKampus.dariJson(x as Map<String, dynamic>)],
      tagihan: [for (final x in j['tagihan'] as List) TagihanRingkas.dariJson(x as Map<String, dynamic>)],
      buku: [for (final x in j['buku'] as List) BukuJatuhTempo.dariJson(x as Map<String, dynamic>)],
      ringkasan: RingkasanHarian(
        pengumuman: keInt(r['pengumuman']),
        tugas: keInt(r['tugas']),
        belumDibaca: keInt(r['belum_dibaca']),
      ),
    );
  }
}

class HariIniRepository {
  HariIniRepository(this._api);
  final ApiClient _api;

  Future<HariIni> ambil() async => HariIni.dariJson(await _api.kirim('GET', 'hari_ini.php'));
}