import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simpul_kampus/auth_service.dart';
import 'package:simpul_kampus/halaman_login.dart';

import 'helpers/aplikasi_palsu.dart';
import 'helpers/palsu.dart';

AuthService buatAuth() =>
    AuthService(apiPalsu(serverPalsu), prefs: PrefPalsu());

void main() {
  testWidgets('kolom kosong menampilkan pesan validasi', (tester) async {
    await tester.pumpWidget(MaterialApp(home: HalamanLogin(auth: buatAuth())));
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();
    expect(find.textContaining('wajib diisi'), findsNWidgets(2));
  });

  testWidgets('sandi salah menampilkan pesan dari server', (tester) async {
    final auth = buatAuth();
    await tester.pumpWidget(MaterialApp(home: HalamanLogin(auth: auth)));
    await tester.enterText(find.byType(TextFormField).at(0), '4240000001');
    await tester.enterText(find.byType(TextFormField).at(1), 'salah');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('NIM atau kata sandi salah.'), findsOneWidget);
    expect(auth.pengguna, isNull);
  });

  testWidgets('login benar mengisi pengguna', (tester) async {
    final auth = buatAuth();
    await tester.pumpWidget(MaterialApp(home: HalamanLogin(auth: auth)));
    await tester.enterText(find.byType(TextFormField).at(0), '4240000001');
    await tester.enterText(find.byType(TextFormField).at(1), 'rahasia123');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(auth.pengguna?.nama, 'Mahasiswa Contoh');
  });
}
