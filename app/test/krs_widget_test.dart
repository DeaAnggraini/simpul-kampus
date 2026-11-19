import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simpul_kampus/halaman_krs.dart';
import 'package:simpul_kampus/krs.dart';

import 'helpers/aplikasi_palsu.dart';
import 'helpers/palsu.dart';

Future<void> pasang(WidgetTester tester, KrsRepository repo) async {
  tester.view.physicalSize = const Size(
    800,
    1600,
  ); // cukup tinggi agar semua baris terbangun
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: HalamanKrs(repo: repo)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('menampilkan daftar kelas dan batas SKS', (tester) async {
    await pasang(tester, KrsRepository(apiPalsu(serverPalsu)));
    expect(find.text('KRS 2026/2027 Ganjil'), findsOneWidget);
    expect(find.text('0 dari 5 SKS'), findsOneWidget);
    expect(find.text('Basis Data · Kelas A'), findsOneWidget);
  });

  testWidgets(
    'memilih kelas mengunci yang bentrok, sudah lulus, dan melebihi batas',
    (tester) async {
      await pasang(tester, KrsRepository(apiPalsu(serverPalsu)));
      await tester.tap(find.text('Basis Data · Kelas A'));
      await tester.pump();

      expect(find.text('3 dari 5 SKS'), findsOneWidget);
      expect(find.text('Bentrok dengan Basis Data'), findsOneWidget);
      expect(find.text('Sudah lulus'), findsOneWidget);
      expect(find.text('Melebihi batas SKS'), findsOneWidget);
    },
  );

  testWidgets('penolakan dari server tampil di dialog', (tester) async {
    final api = apiPalsu(
      (req) async => req.method == 'GET'
          ? jsonRes(krsPalsu())
          : jsonRes({
              'pesan': 'KRS belum dapat disimpan:\n- Contoh galat.',
            }, 422),
    );
    await pasang(tester, KrsRepository(api));

    await tester.tap(find.text('Basis Data · Kelas A'));
    await tester.pump();
    await tester.tap(find.text('Simpan KRS'));
    await tester.pumpAndSettle();

    expect(find.text('KRS belum tersimpan'), findsOneWidget);
    expect(find.textContaining('Contoh galat'), findsOneWidget);
  });
}
