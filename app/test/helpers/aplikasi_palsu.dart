import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:simpul_kampus/auth_service.dart';
import 'package:simpul_kampus/main.dart';
import 'package:simpul_kampus/router.dart';

import 'palsu.dart';

Map<String, dynamic> hariIniPalsu() => {
  'nama': 'Mahasiswa Contoh',
  'ipk': 3.63,
  'sks': 8,
  'jadwal': [],
  'tugas': [],
  'tagihan': [],
  'buku': [],
  'info': [
    {
      'judul': 'Selamat datang',
      'isi': 'Data contoh.',
      'dibuat': '2026-11-18 08:00:00',
    },
  ],
  'ringkasan': {'pengumuman': 0, 'tugas': 0, 'belum_dibaca': 0},
};

/// Lima kelas. Basis Data dan Kecerdasan Buatan bentrok, Algoritma sudah lulus, batas 5 SKS.
Map<String, dynamic> krsPalsu() {
  Map<String, dynamic> k(
    int id,
    int mk,
    String nama,
    int sks,
    int hari,
    String mulai,
    String selesai, {
    bool lulus = false,
  }) => {
    'kelas_id': id,
    'mk_id': mk,
    'kode': 'KODE$mk',
    'nama': nama,
    'sks': sks,
    'kelas': 'A',
    'dosen': 'Dosen Contoh',
    'hari': hari,
    'jam_mulai': mulai,
    'jam_selesai': selesai,
    'ruang': 'Lab 1',
    'kuota': 40,
    'terisi': 10,
    'diambil': false,
    'sudah_lulus': lulus,
  };
  return {
    'tahun': '2026/2027 Ganjil',
    'batas_sks': 5,
    'data': [
      k(1, 1, 'Basis Data', 3, 2, '08:00:00', '10:30:00'),
      k(2, 2, 'Kecerdasan Buatan', 3, 2, '09:00:00', '11:30:00'),
      k(3, 3, 'Jaringan Komputer', 3, 3, '08:00:00', '10:30:00'),
      k(4, 4, 'Statistika', 2, 4, '08:00:00', '09:40:00'),
      k(
        5,
        5,
        'Algoritma dan Pemrograman',
        3,
        1,
        '08:00:00',
        '10:30:00',
        lulus: true,
      ),
    ],
  };
}

Future<http.Response> serverPalsu(http.Request req) async {
  final jalur = req.url.path.split('/').last;
  switch ('${req.method} $jalur') {
    case 'POST masuk.php':
      final b = jsonDecode(req.body) as Map<String, dynamic>;
      return b['sandi'] == 'rahasia123'
          ? jsonRes({
              'token': 'a' * 64,
              'pengguna': {
                'id': 2,
                'nama': 'Mahasiswa Contoh',
                'peran': 'mahasiswa',
              },
            })
          : jsonRes({'pesan': 'NIM atau kata sandi salah.'}, 401);
    case 'POST keluar.php':
      return jsonRes({'pesan': 'Berhasil keluar.'});
    case 'GET hari_ini.php':
      return jsonRes(hariIniPalsu());
    case 'GET krs.php':
      return jsonRes(krsPalsu());
    case 'POST krs.php':
      return jsonRes({'pesan': 'KRS tersimpan.', 'total_sks': 3});
  }
  return jsonRes({'pesan': 'Tidak ada rute palsu untuk $jalur.'}, 404);
}

/// Aplikasi sungguhan (router, halaman, state) dengan server dan penyimpanan palsu.
Future<Widget> buatAplikasiPalsu() async {
  final api = apiPalsu(serverPalsu);
  final auth = AuthService(api, prefs: PrefPalsu());
  await auth.muat();
  return SimpulApp(router: buatRouter(api, auth));
}

/// Login, buka KRS, pilih satu kelas, simpan.
Future<void> alurLoginSampaiKrs(WidgetTester tester) async {
  await tester.pumpAndSettle();
  expect(find.text('Masuk untuk melanjutkan'), findsOneWidget);
  await tester.enterText(find.byType(TextFormField).at(0), '4240000001');
  await tester.enterText(find.byType(TextFormField).at(1), 'rahasia123');
  await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
  await tester.pumpAndSettle();
  expect(find.text('Halo, Mahasiswa Contoh'), findsOneWidget);

  await tester.tap(find.text('Akademik'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pengisian KRS'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Basis Data · Kelas A'));
  await tester.pump();
  await tester.tap(find.text('Simpan KRS'));
  await tester.pumpAndSettle();
  expect(find.text('KRS tersimpan (3 SKS).'), findsOneWidget);
}
