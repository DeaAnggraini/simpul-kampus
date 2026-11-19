import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/aplikasi_palsu.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login sampai simpan KRS di perangkat', (tester) async {
    await tester.pumpWidget(await buatAplikasiPalsu());
    await alurLoginSampaiKrs(tester);
  });
}
