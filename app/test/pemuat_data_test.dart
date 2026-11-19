import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simpul_kampus/api_client.dart';
import 'package:simpul_kampus/pemuat_data.dart';

Widget bungkus(Widget anak) => MaterialApp(home: Scaffold(body: anak));

void main() {
  testWidgets('menampilkan loading lalu data', (tester) async {
    final c = Completer<String>();
    await tester.pumpWidget(
      bungkus(
        PemuatData<String>(
          ambil: () => c.future,
          builder: (context, d) => ListView(children: [Text(d)]),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    c.complete('Data siap');
    await tester.pump();

    expect(find.text('Data siap'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('galat menampilkan pesan dan Coba lagi memuat ulang', (
    tester,
  ) async {
    var panggilan = 0;
    Future<String> ambil() async {
      panggilan++;
      if (panggilan == 1) throw ApiGagal('Server tidak dapat dihubungi.');
      return 'Data siap';
    }

    await tester.pumpWidget(
      bungkus(
        PemuatData<String>(
          ambil: ambil,
          builder: (context, d) => ListView(children: [Text(d)]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Server tidak dapat dihubungi.'), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Data siap'), findsOneWidget);
    expect(panggilan, 2);
  });
}
