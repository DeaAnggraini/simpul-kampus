import 'package:go_router/go_router.dart';
import 'akademik.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'halaman_akademik.dart';
import 'halaman_akun.dart';
import 'halaman_beranda.dart';
import 'halaman_khs.dart';
import 'halaman_login.dart';
import 'halaman_riwayat.dart';
import 'kerangka_navigasi.dart';

GoRouter buatRouter(ApiClient api, AuthService auth) {
  final repo = AkademikRepository(api);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth, // router menilai ulang saat status login berubah
    redirect: (context, state) {
      final sudahMasuk = auth.pengguna != null;
      final diLogin = state.matchedLocation == '/masuk';
      if (!sudahMasuk) return diLogin ? null : '/masuk';
      if (diLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/masuk', builder: (c, s) => HalamanLogin(auth: auth)),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => KerangkaNavigasi(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/',
              builder: (c, s) => HalamanBeranda(api: api, auth: auth),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/akademik',
              builder: (c, s) => const HalamanAkademik(),
              routes: [
                GoRoute(path: 'khs', builder: (c, s) => HalamanKhs(repo: repo)),
                GoRoute(path: 'riwayat', builder: (c, s) => HalamanRiwayat(repo: repo)),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/akun',
              builder: (c, s) => HalamanAkun(repo: repo, auth: auth),
            ),
          ]),
        ],
      ),
    ],
  );
}