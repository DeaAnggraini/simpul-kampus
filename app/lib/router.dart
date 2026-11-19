import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'akademik.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'berita.dart';
import 'halaman_akademik.dart';
import 'halaman_akun.dart';
import 'halaman_berita.dart';
import 'halaman_detail_berita.dart';
import 'halaman_detail_kelas.dart';
import 'halaman_hari_ini.dart';
import 'halaman_kartu.dart';
import 'halaman_kelas.dart';
import 'halaman_kelulusan.dart';
import 'halaman_khusus.dart';
import 'halaman_keuangan.dart';
import 'halaman_khs.dart';
import 'halaman_krs.dart';
import 'halaman_layanan.dart';
import 'halaman_login.dart';
import 'halaman_notifikasi.dart';
import 'halaman_pengaturan_notifikasi.dart';
import 'halaman_perpustakaan.dart';
import 'halaman_riwayat.dart';
import 'halaman_simulasi.dart';
import 'hari_ini.dart';
import 'kelas.dart';
import 'kelulusan.dart';
import 'kerangka_navigasi.dart';
import 'keuangan.dart';
import 'krs.dart';
import 'notifikasi.dart';
import 'perpustakaan.dart';

GoRouter buatRouter(ApiClient api, AuthService auth) {
  final akademikRepo = AkademikRepository(api);
  final krsRepo = KrsRepository(api);
  final kelasRepo = KelasRepository(api);
  final hariIniRepo = HariIniRepository(api);
  final notifRepo = NotifikasiRepository(api);
  final kelulusanRepo = KelulusanRepository(api);
  final keuanganRepo = KeuanganRepository(api);
  final perpusRepo = PerpustakaanRepository(api);
  final beritaRepo = BeritaRepository(api);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth, // router menilai ulang saat status login berubah
    redirect: (context, state) {
      final sudahMasuk = auth.pengguna != null;
      final diLogin = state.matchedLocation == '/masuk';
      if (!sudahMasuk) return diLogin ? null : '/masuk';
      if (diLogin) return '/';
      final peran = auth.pengguna?.peran;
      if (peran == 'dosen' && state.matchedLocation == '/') return '/kelas';
      if (peran == 'admin' && state.matchedLocation == '/') {
        return '/layanan/berita';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/masuk',
        builder: (c, s) => HalamanLogin(auth: auth),
      ),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (c, s) => _untuk(
                  auth,
                  {'mahasiswa'},
                  'Hari Ini',
                  () => HalamanHariIni(repo: hariIniRepo),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/akademik',
                builder: (c, s) => _untuk(
                  auth,
                  {'mahasiswa'},
                  'Akademik',
                  () => const HalamanAkademik(),
                ),
                routes: [
                  GoRoute(
                    path: 'khs',
                    builder: (c, s) => HalamanKhs(repo: akademikRepo),
                  ),
                  GoRoute(
                    path: 'riwayat',
                    builder: (c, s) => HalamanRiwayat(repo: akademikRepo),
                  ),
                  GoRoute(
                    path: 'krs',
                    builder: (c, s) => HalamanKrs(repo: krsRepo),
                  ),
                  GoRoute(
                    path: 'kelulusan',
                    builder: (c, s) => HalamanKelulusan(repo: kelulusanRepo),
                  ),
                  GoRoute(
                    path: 'simulasi',
                    builder: (c, s) => HalamanSimulasi(repo: kelulusanRepo),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kelas',
                builder: (c, s) => _untuk(
                  auth,
                  {'mahasiswa', 'dosen'},
                  'Kelas',
                  () => HalamanKelas(repo: kelasRepo),
                ),
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
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/layanan',
                builder: (c, s) => HalamanLayanan(
                  mahasiswa: auth.pengguna?.peran == 'mahasiswa',
                ),
                routes: [
                  GoRoute(
                    path: 'keuangan',
                    builder: (c, s) => HalamanKeuangan(repo: keuanganRepo),
                  ),
                  GoRoute(
                    path: 'perpustakaan',
                    builder: (c, s) => HalamanPerpustakaan(
                      repo: perpusRepo,
                      tabAwal:
                          int.tryParse(s.uri.queryParameters['tab'] ?? '') ?? 0,
                    ),
                  ),
                  GoRoute(
                    path: 'kartu',
                    builder: (c, s) => HalamanKartu(repo: akademikRepo),
                  ),
                  GoRoute(
                    path: 'berita',
                    builder: (c, s) => HalamanBerita(repo: beritaRepo),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (c, s) => HalamanDetailBerita(
                          repo: beritaRepo,
                          id: int.tryParse(s.pathParameters['id'] ?? '') ?? 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/akun',
                builder: (c, s) => HalamanAkun(repo: akademikRepo, auth: auth),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Widget _untuk(
  AuthService auth,
  Set<String> peran,
  String judul,
  Widget Function() halaman,
) => peran.contains(auth.pengguna?.peran)
    ? halaman()
    : HalamanKhusus(judul: judul, peran: peran);
