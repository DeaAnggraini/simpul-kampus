import 'api_client.dart';

const namaHari = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

class KelasTawaran {
  const KelasTawaran({
    required this.kelasId,
    required this.mkId,
    required this.kode,
    required this.nama,
    required this.sks,
    required this.kelas,
    required this.dosen,
    required this.hari,
    required this.mulai,
    required this.selesai,
    required this.ruang,
    required this.kuota,
    required this.terisi,
    required this.diambil,
    required this.sudahLulus,
  });
  final int kelasId, mkId, sks, hari, kuota, terisi;
  final String kode, nama, kelas, dosen, mulai, selesai, ruang;
  final bool diambil, sudahLulus;

  bool get penuh => !diambil && terisi >= kuota;
  String get jadwal => '${namaHari[hari]} $mulai sampai $selesai';

  /// Bentrok bila hari sama dan jam beririsan. Jam "HH:mm" aman dibandingkan sebagai teks.
  bool bentrok(KelasTawaran lain) =>
      hari == lain.hari &&
      mulai.compareTo(lain.selesai) < 0 &&
      lain.mulai.compareTo(selesai) < 0;

  factory KelasTawaran.dariJson(Map<String, dynamic> j) => KelasTawaran(
        kelasId: keInt(j['kelas_id']),
        mkId: keInt(j['mk_id']),
        kode: j['kode'] as String,
        nama: j['nama'] as String,
        sks: keInt(j['sks']),
        kelas: j['kelas'] as String,
        dosen: j['dosen'] as String,
        hari: keInt(j['hari']),
        mulai: (j['jam_mulai'] as String).substring(0, 5),
        selesai: (j['jam_selesai'] as String).substring(0, 5),
        ruang: j['ruang'] as String,
        kuota: keInt(j['kuota']),
        terisi: keInt(j['terisi']),
        diambil: j['diambil'] == true,
        sudahLulus: j['sudah_lulus'] == true,
      );
}

class DataKrs {
  const DataKrs({required this.tahun, required this.batasSks, required this.kelas});
  final String tahun;
  final int batasSks;
  final List<KelasTawaran> kelas;

  factory DataKrs.dariJson(Map<String, dynamic> j) => DataKrs(
        tahun: j['tahun'] as String,
        batasSks: keInt(j['batas_sks']),
        kelas: [
          for (final x in j['data'] as List)
            KelasTawaran.dariJson(x as Map<String, dynamic>)
        ],
      );
}

class KrsRepository {
  KrsRepository(this._api);
  final ApiClient _api;

  Future<DataKrs> ambil() async =>
      DataKrs.dariJson(await _api.kirim('GET', 'krs.php'));

  Future<int> simpan(List<int> kelasIds) async {
    final d = await _api.kirim('POST', 'krs.php', body: {'kelas_ids': kelasIds});
    return keInt(d['total_sks']);
  }
}