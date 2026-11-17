import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiClient();
  final auth = AuthService(api);
  await auth.muat(); // pulihkan sesi bila sudah pernah masuk
  runApp(SimpulApp(router: buatRouter(api, auth)));
}

class SimpulApp extends StatelessWidget {
  const SimpulApp({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Simpul Kampus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00796B)),
      ),
      routerConfig: router,
    );
  }
}