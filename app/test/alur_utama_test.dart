import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/aplikasi_palsu.dart';

void main() {
  testWidgets('alur utama: login, buka KRS, simpan', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(await buatAplikasiPalsu());
    await alurLoginSampaiKrs(tester);

    // Bongkar pohon widget agar Timer polling dasbor ikut dibatalkan
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
