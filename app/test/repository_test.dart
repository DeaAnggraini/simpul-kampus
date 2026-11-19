import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:simpul_kampus/berita.dart';
import 'package:simpul_kampus/kelas.dart';
import 'package:simpul_kampus/krs.dart';
import 'package:simpul_kampus/perpustakaan.dart';

import 'helpers/palsu.dart';

void main() {
  test('KrsRepository.simpan mengirim POST dengan daftar kelas dan membaca total SKS', () async {
    late http.Request diterima;
    final repo = KrsRepository(
      apiPalsu((req) async {
        diterima = req;
        return jsonRes({'pesan': 'KRS tersimpan.', 'total_sks': 6});
      }),
    );

    final total = await repo.simpan([1, 3]);

    expect(total, 6);
    expect(diterima.method, 'POST');
    expect(diterima.url.path, endsWith('/krs.php'));
    expect(jsonDecode(diterima.body), {
      'kelas_ids': [1, 3],
    });
  });

  test(
    'PerpustakaanRepository.cari hanya mengirim q bila ada kata kunci',
    () async {
      final diterima = <http.Request>[];
      final repo = PerpustakaanRepository(
        apiPalsu((req) async {
          diterima.add(req);
          return jsonRes({'data': []});
        }),
      );

      await repo.cari('');
      await repo.cari('dart');

      expect(diterima[0].url.queryParameters.containsKey('q'), isFalse);
      expect(diterima[1].url.queryParameters['q'], 'dart');
    },
  );

  test('PerpustakaanRepository.kembalikan mengembalikan denda', () async {
    late http.Request diterima;
    final repo = PerpustakaanRepository(
      apiPalsu((req) async {
        diterima = req;
        return jsonRes({'pesan': 'Buku dikembalikan.', 'denda': 3000});
      }),
    );

    expect(await repo.kembalikan(9), 3000);
    expect(jsonDecode(diterima.body), {'peminjaman_id': 9});
  });

  test(
    'PerpustakaanRepository.pinjam meneruskan galat aturan dari server',
    () async {
      final repo = PerpustakaanRepository(
        apiPalsu((_) async => jsonRes({'pesan': 'Stok buku habis.'}, 422)),
      );
      await expectLater(repo.pinjam(1), throwsA(isA<Exception>()));
    },
  );

  test(
    'BeritaRepository.daftar mengirim kategori dan membaca hak menulis',
    () async {
      late http.Request diterima;
      final repo = BeritaRepository(
        apiPalsu((req) async {
          diterima = req;
          return jsonRes({
            'bisa_menulis': true,
            'data': [
              {
                'id': 1,
                'judul': 'J',
                'ringkas': 'R',
                'kategori': 'Beasiswa',
                'dibuat': '2026-11-18 08:00:00',
              },
            ],
          });
        }),
      );

      final d = await repo.daftar(kategori: 'Beasiswa');

      expect(diterima.url.queryParameters['kategori'], 'Beasiswa');
      expect(d.bisaMenulis, isTrue);
      expect(d.data.single.judul, 'J');
    },
  );

  test('KelasRepository.detail mengirim id dan membaca isi kelas', () async {
    late http.Request diterima;
    final repo = KelasRepository(
      apiPalsu((req) async {
        diterima = req;
        return jsonRes({
          'kelas': {
            'id': 4,
            'kelas': 'A',
            'kode': 'IKM301',
            'mk_nama': 'Pemrograman Mobile',
            'dosen': 'Dosen Contoh',
            'hari': 2,
            'jam_mulai': '08:00:00',
            'jam_selesai': '10:30:00',
            'ruang': 'Lab 1',
            'tautan_rapat': null,
          },
          'bisa_menulis': false,
          'pengumuman': [],
          'tugas': [],
          'anggota': [],
        });
      }),
    );

    final d = await repo.detail(4);

    expect(diterima.url.queryParameters['id'], '4');
    expect(d.namaMk, 'Pemrograman Mobile');
    expect(d.tautanRapat, isNull);
    expect(d.bolehTulis, isFalse);
  });
}
