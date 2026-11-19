import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:simpul_kampus/api_client.dart';
import 'package:simpul_kampus/auth_service.dart';

import 'helpers/palsu.dart';

Future<http.Response> _server(http.Request req) async {
  final jalur = req.url.path.split('/').last;
  if (jalur == 'masuk.php') {
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
  }
  if (jalur == 'keluar.php') return jsonRes({'pesan': 'Berhasil keluar.'});
  return jsonRes({
    'pesan': 'Sesi berakhir.',
  }, 401); // endpoint lain dianggap sesi habis
}

void main() {
  late PrefPalsu prefs;
  late ApiClient api;
  late AuthService auth;

  setUp(() {
    prefs = PrefPalsu();
    api = apiPalsu(_server);
    auth = AuthService(api, prefs: prefs);
  });

  test('masuk berhasil menyimpan token dan pengguna', () async {
    var notifikasi = 0;
    auth.addListener(() => notifikasi++);

    await auth.masuk('4240000001', 'rahasia123');

    expect(auth.pengguna?.nama, 'Mahasiswa Contoh');
    expect(auth.pengguna?.peran, 'mahasiswa');
    expect(api.token, 'a' * 64);
    expect(prefs.isi['token'], 'a' * 64);
    expect(notifikasi, 1);
  });

  test(
    'masuk dengan sandi salah melempar ApiGagal dan tidak menyimpan apa pun',
    () async {
      await expectLater(
        auth.masuk('4240000001', 'salah'),
        throwsA(isA<ApiGagal>().having((e) => e.status, 'status', 401)),
      );
      expect(auth.pengguna, isNull);
      expect(api.token, isNull);
      expect(prefs.isi, isEmpty);
    },
  );

  test('keluar menghapus token, pengguna, dan data tersimpan', () async {
    await auth.masuk('4240000001', 'rahasia123');
    await auth.keluar();
    expect(auth.pengguna, isNull);
    expect(api.token, isNull);
    expect(prefs.isi, isEmpty);
  });

  test('muat memulihkan sesi yang tersimpan', () async {
    prefs.isi['token'] = 'b' * 64;
    prefs.isi['pengguna'] = jsonEncode({
      'id': 2,
      'nama': 'Mahasiswa Contoh',
      'peran': 'mahasiswa',
    });

    await auth.muat();

    expect(auth.pengguna?.nama, 'Mahasiswa Contoh');
    expect(api.token, 'b' * 64);
  });

  test('muat tanpa data tersimpan membiarkan pengguna kosong', () async {
    await auth.muat();
    expect(auth.pengguna, isNull);
  });

  test('sesi habis (401) di endpoint lain otomatis keluar', () async {
    await auth.masuk('4240000001', 'rahasia123');
    await expectLater(api.kirim('GET', 'khs.php'), throwsA(isA<ApiGagal>()));
    expect(auth.pengguna, isNull);
    expect(prefs.isi, isEmpty);
  });
}
