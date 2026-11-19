import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:simpul_kampus/api_client.dart';

import 'helpers/palsu.dart';

void main() {
  group('ApiClient', () {
    test('mengirim metode, alamat, token, dan body JSON', () async {
      late http.Request diterima;
      final api = apiPalsu((req) async {
        diterima = req;
        return jsonRes({'ok': true});
      })..token = 'abc';

      final hasil = await api.kirim(
        'POST',
        'krs.php',
        body: {
          'kelas_ids': [1, 2],
        },
        query: {'x': '1'},
      );

      expect(hasil['ok'], true);
      expect(diterima.method, 'POST');
      expect(diterima.url.path, endsWith('/krs.php'));
      expect(diterima.url.queryParameters['x'], '1');
      expect(diterima.headers['Authorization'], 'Bearer abc');
      expect(jsonDecode(diterima.body), {
        'kelas_ids': [1, 2],
      });
    });

    test('tanpa token, header Authorization tidak dikirim', () async {
      late http.Request diterima;
      final api = apiPalsu((req) async {
        diterima = req;
        return jsonRes({});
      });
      await api.kirim('GET', 'berita.php');
      expect(diterima.headers.containsKey('Authorization'), isFalse);
    });

    test('galat 4xx memakai pesan server dan menyimpan status', () async {
      final api = apiPalsu(
        (_) async => jsonRes({'pesan': 'Stok buku habis.'}, 422),
      );
      await expectLater(
        api.kirim('POST', 'peminjaman.php'),
        throwsA(
          isA<ApiGagal>()
              .having((e) => e.pesan, 'pesan', 'Stok buku habis.')
              .having((e) => e.status, 'status', 422),
        ),
      );
    });

    test('galat tanpa pesan memakai pesan bawaan', () async {
      final api = apiPalsu((_) async => jsonRes({}, 500));
      await expectLater(
        api.kirim('GET', 'khs.php'),
        throwsA(
          isA<ApiGagal>().having(
            (e) => e.pesan,
            'pesan',
            'Terjadi kesalahan (500).',
          ),
        ),
      );
    });

    test('jawaban bukan JSON menjadi ApiGagal', () async {
      final api = apiPalsu(
        (_) async => http.Response('<html>error</html>', 200),
      );
      await expectLater(
        api.kirim('GET', 'khs.php'),
        throwsA(
          isA<ApiGagal>().having(
            (e) => e.pesan,
            'pesan',
            contains('bukan JSON'),
          ),
        ),
      );
    });

    test('jaringan putus menjadi pesan yang ramah', () async {
      final api = apiPalsu((_) async {
        throw http.ClientException('putus');
      });
      await expectLater(
        api.kirim('GET', 'khs.php'),
        throwsA(
          isA<ApiGagal>().having(
            (e) => e.pesan,
            'pesan',
            contains('tidak dapat dihubungi'),
          ),
        ),
      );
    });

    test('401 saat sudah masuk memicu saatSesiHabis', () async {
      var dipanggil = 0;
      final api =
          apiPalsu((_) async => jsonRes({'pesan': 'Sesi berakhir.'}, 401))
            ..token = 'abc'
            ..saatSesiHabis = () async {
              dipanggil++;
            };
      await expectLater(api.kirim('GET', 'khs.php'), throwsA(isA<ApiGagal>()));
      expect(dipanggil, 1);
    });

    test('401 tanpa token (login salah) tidak memicu saatSesiHabis', () async {
      var dipanggil = 0;
      final api = apiPalsu((_) async => jsonRes({'pesan': 'Salah.'}, 401))
        ..saatSesiHabis = () async {
          dipanggil++;
        };
      await expectLater(
        api.kirim('POST', 'masuk.php'),
        throwsA(isA<ApiGagal>()),
      );
      expect(dipanggil, 0);
    });

    test(
      '401 pada keluar.php tidak memicu saatSesiHabis (hindari perulangan)',
      () async {
        var dipanggil = 0;
        final api =
            apiPalsu((_) async => jsonRes({'pesan': 'Sesi berakhir.'}, 401))
              ..token = 'abc'
              ..saatSesiHabis = () async {
                dipanggil++;
              };
        await expectLater(
          api.kirim('POST', 'keluar.php'),
          throwsA(isA<ApiGagal>()),
        );
        expect(dipanggil, 0);
      },
    );
  });

  test('keInt menerima int dan teks angka, menolak lainnya', () {
    expect(keInt(7), 7);
    expect(keInt('12'), 12);
    expect(() => keInt('abc'), throwsFormatException);
    expect(() => keInt(null), throwsFormatException);
  });
}
