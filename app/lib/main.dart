import 'package:material_ui/material_ui.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'halaman_beranda.dart';
import 'halaman_login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiClient();
  final auth = AuthService(api);
  await auth.muat(); // pulihkan sesi bila sudah pernah masuk
  runApp(SimpulApp(api: api, auth: auth));
}

class SimpulApp extends StatelessWidget {
  const SimpulApp({super.key, required this.api, required this.auth});
  final ApiClient api;
  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simpul Kampus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00796B)),
      ),
      home: ListenableBuilder(
        listenable: auth,
        builder: (context, _) => auth.pengguna == null
            ? HalamanLogin(auth: auth)
            : HalamanBeranda(api: api, auth: auth),
      ),
    );
  }
}