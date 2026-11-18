extension Rupiah on int {
  /// 1250000 menjadi "Rp1.250.000"
  String get rupiah {
    final pola = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return 'Rp${toString().replaceAllMapped(pola, (m) => '.')}';
  }
}