import 'package:go_router/go_router.dart';
import 'akademik.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'halaman_akademik.dart';
import 'halaman_akun.dart';
import 'halaman_detail_kelas.dart';
import 'halaman_hari_ini.dart';
import 'halaman_kelas.dart';
import 'halaman_kelulusan.dart';
import 'halaman_khs.dart';
import 'halaman_krs.dart';
import 'halaman_login.dart';
import 'halaman_notifikasi.dart';
import 'halaman_pengaturan_notifikasi.dart';
import 'halaman_riwayat.dart';
import 'halaman_simulasi.dart';
import 'hari_ini.dart';
import 'kelas.dart';
import 'kelulusan.dart';
import 'kerangka_navigasi.dart';
import 'krs.dart';
import 'notifikasi.dart';

GoRouter buatRouter(ApiClient api, AuthService auth) {
  final akademikRepo = AkademikRepository(api);
  final krsRepo = KrsRepository(api);
  final kelasRepo = KelasRepository(api);
  final hariIniRepo = HariIniRepository(api);
  final notifRepo = NotifikasiRepository(api);
  final kelulusanRepo = KelulusanRepository(api);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth, // router menilai ulang saat status login berubah
    redirect: (context, state) {
      final sudahMasuk = auth.pengguna != null;
      final diLogin = state.matchedLocation == '/masuk';
      if (!sudahMasuk) return diLogin ? null : '/masuk';
      if (diLogin) return '/';
      if (auth.pengguna?.peran == 'dosen' && state.matchedLocation == '/') return '/kelas';
      return null;
    },
    routes: [
      GoRoute(path: '/masuk', builder: (c, s) => HalamanLogin(auth: auth)),
      GoRoute(
        path: '/notifikasi',
        builder: (c, s) => HalamanNotifikasi(repo: notifRepo),
        routes: [
          GoRoute(
            path: 'pengaturan',
            builder: (c, s) => HalamanPengaturanNotifikasi(repo: notifRepo),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => KerangkaNavigasi(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (c, s) => HalamanHariIni(repo: hariIniRepo)),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/akademik',
              builder: (c, s) => const HalamanAkademik(),
              routes: [
                GoRoute(path: 'khs', builder: (c, s) => HalamanKhs(repo: akademikRepo)),
                GoRoute(path: 'riwayat', builder: (c, s) => HalamanRiwayat(repo: akademikRepo)),
                GoRoute(path: 'krs', builder: (c, s) => HalamanKrs(repo: krsRepo)),
                GoRoute(path: 'kelulusan', builder: (c, s) => HalamanKelulusan(repo: kelulusanRepo)),
                GoRoute(path: 'simulasi', builder: (c, s) => HalamanSimulasi(repo: kelulusanRepo)),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/kelas',
              builder: (c, s) => HalamanKelas(repo: kelasRepo),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (c, s) => HalamanDetailKelas(
                    repo: kelasRepo,
                    kelasId: int.tryParse(s.pathParameters['id'] ?? '') ?? 0,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/akun',
              builder: (c, s) => HalamanAkun(repo: akademikRepo, auth: auth),
            ),
          ]),
        ],
      ),
    ],
  );
}