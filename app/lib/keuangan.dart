import 'api_client.dart';

class Tagihan {
  const Tagihan({
    required this.id,
    required this.nominal,
    required this.jenis,
    required this.periode,
    required this.jatuhTempo,
    required this.kodeBayar,
    required this.terlambat,
    this.dibayarPada,
  });
  final int id, nominal;
  final String jenis, periode, jatuhTempo, kodeBayar;
  final String? dibayarPada;
  final bool terlambat;

  factory Tagihan.dariJson(Map<String, dynamic> j) => Tagihan(
        id: keInt(j['id']),
        nominal: keInt(j['nominal']),
        jenis: j['jenis'] as String,
        periode: j['periode'] as String,
        jatuhTempo: j['jatuh_tempo'] as String,
        kodeBayar: j['kode_bayar'] as String,
        terlambat: j['terlambat'] == true,
        dibayarPada: j['dibayar_pada'] as String?,
      );
}

class Keuangan {
  const Keuangan({required this.belum, required this.lunas, required this.totalBelum});
  final List<Tagihan> belum, lunas;
  final int totalBelum;

  factory Keuangan.dariJson(Map<String, dynamic> j) => Keuangan(
        belum: [for (final x in j['belum'] as List) Tagihan.dariJson(x as Map<String, dynamic>)],
        lunas: [for (final x in j['lunas'] as List) Tagihan.dariJson(x as Map<String, dynamic>)],
        totalBelum: keInt(j['total_belum']),
      );
}

class KeuanganRepository {
  KeuanganRepository(this._api);
  final ApiClient _api;

  Future<Keuangan> ambil() async => Keuangan.dariJson(await _api.kirim('GET', 'keuangan.php'));
}