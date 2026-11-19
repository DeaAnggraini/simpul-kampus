import 'package:flutter_test/flutter_test.dart';
import 'package:simpul_kampus/simulasi_ip.dart';

void main() {
  test('batas tepat 4,00 masih mungkin', () {
    final h = hitungSimulasi(
      ipkSaatIni: 3.0,
      sksBernilai: 60,
      sksTarget: 120,
      ipkTarget: 3.5,
    );
    expect(h.status, StatusSimulasi.mungkin);
    expect(h.ipsDibutuhkan, 4.0);
    expect(h.komposisi, '100% A');
  });

  test('target di luar jangkauan', () {
    final h = hitungSimulasi(
      ipkSaatIni: 2.0,
      sksBernilai: 100,
      sksTarget: 144,
      ipkTarget: 3.9,
    );
    expect(h.status, StatusSimulasi.mustahil);
  });

  test('target sudah pasti tercapai', () {
    final h = hitungSimulasi(
      ipkSaatIni: 3.9,
      sksBernilai: 100,
      sksTarget: 144,
      ipkTarget: 2.0,
    );
    expect(h.status, StatusSimulasi.sudahTercapai);
  });

  test('tanpa sisa SKS', () {
    final h = hitungSimulasi(
      ipkSaatIni: 3.5,
      sksBernilai: 144,
      sksTarget: 144,
      ipkTarget: 3.7,
    );
    expect(h.status, StatusSimulasi.tanpaSisa);
  });

  test('komposisi dua huruf berdekatan', () {
    final h = hitungSimulasi(
      ipkSaatIni: 3.0,
      sksBernilai: 50,
      sksTarget: 100,
      ipkTarget: 3.2,
    );
    expect(h.ipsDibutuhkan, closeTo(3.4, 1e-9));
    expect(h.komposisi, '40% A dan 60% B');
  });
}
