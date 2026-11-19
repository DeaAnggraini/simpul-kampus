import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/aplikasi_palsu.dart';

void main() {
  for (final ukuran in const [
    Size(360, 800),
    Size(840, 1000),
    Size(1280, 800),
  ]) {
    testWidgets(
      'alur utama tanpa overflow pada lebar ${ukuran.width.toInt()} dp',
      (tester) async {
        tester.view.physicalSize = ukuran;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(await buatAplikasiPalsu());
        await alurLoginSampaiKrs(tester);

        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
