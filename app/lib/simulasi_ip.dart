enum StatusSimulasi { sudahTercapai, mungkin, mustahil, tanpaSisa }

class HasilSimulasi {
  const HasilSimulasi(this.status, this.ipsDibutuhkan, this.sksSisa);
  final StatusSimulasi status;
  final double ipsDibutuhkan; // rata-rata IPS yang dibutuhkan pada sisa SKS
  final int sksSisa;

  /// Contoh komposisi dari dua huruf berdekatan, misalnya "40% A dan 60% B".
  String? get komposisi {
    if (status != StatusSimulasi.mungkin) return null;
    const huruf = ['E', 'D', 'C', 'B', 'A'];
    if (ipsDibutuhkan >= 4) return '100% A';
    final bawah = ipsDibutuhkan.floor();
    final porsiAtas = ipsDibutuhkan - bawah;
    if (porsiAtas < 0.005) return '100% ${huruf[bawah]}';
    final persenAtas = (porsiAtas * 100).round();
    return '$persenAtas% ${huruf[bawah + 1]} dan ${100 - persenAtas}% ${huruf[bawah]}';
  }
}

/// Mengandaikan seluruh SKS target ditempuh dan diberi nilai.
HasilSimulasi hitungSimulasi({
  required double ipkSaatIni,
  required int sksBernilai,
  required int sksTarget,
  required double ipkTarget,
}) {
  final sisa = sksTarget - sksBernilai;
  if (sisa <= 0) return const HasilSimulasi(StatusSimulasi.tanpaSisa, 0, 0);
  final perlu = (ipkTarget * sksTarget - ipkSaatIni * sksBernilai) / sisa;
  if (perlu <= 0) return HasilSimulasi(StatusSimulasi.sudahTercapai, 0, sisa);
  if (perlu > 4.0) return HasilSimulasi(StatusSimulasi.mustahil, perlu, sisa);
  return HasilSimulasi(StatusSimulasi.mungkin, perlu, sisa);
}
