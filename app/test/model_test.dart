import 'package:flutter_test/flutter_test.dart';
import 'package:simpul_kampus/akademik.dart';
import 'package:simpul_kampus/format.dart';
import 'package:simpul_kampus/hari_ini.dart';
import 'package:simpul_kampus/kelas.dart';
import 'package:simpul_kampus/kelulusan.dart';
import 'package:simpul_kampus/notifikasi.dart';
import 'package:simpul_kampus/perpustakaan.dart';

void main() {
  group('format', () {
    test('rupiah memberi titik ribuan', () {
      expect(1250000.rupiah, 'Rp1.250.000');
      expect(500.rupiah, 'Rp500');
      expect(0.rupiah, 'Rp0');
    });

    test('formatWaktu dan keFormatServer', () {
      expect(formatWaktu('2026-11-20 23:59:00'), '20/11/2026 23.59');
      expect(
        keFormatServer(DateTime(2026, 11, 5, 9, 7)),
        '2026-11-05 09:07:00',
      );
    });

    test('sisaWaktu memilih satuan yang tepat', () {
      expect(sisaWaktu(0), 'kurang dari 1 jam');
      expect(sisaWaktu(5), '5 jam lagi');
      expect(sisaWaktu(24), '1 hari lagi');
      expect(sisaWaktu(50), '2 hari lagi');
    });
  });

  group('model akademik', () {
    test('Semester tanpa nilai memiliki IPS null dan judul yang rapi', () {
      final s = Semester.dariJson({
        'tahun': '2026/2027',
        'semester': 'ganjil',
        'sks': 0,
        'sks_kumulatif': 8,
        'ips': null,
        'ipk': 3.63,
        'matakuliah': [
          {
            'kode': 'IKM301',
            'nama': 'Pemrograman Mobile',
            'sks': 3,
            'nilai': null,
          },
        ],
      });
      expect(s.judul, '2026/2027 Ganjil');
      expect(s.ips, isNull);
      expect(s.ipk, 3.63);
      expect(s.matakuliah.single.nilai, isNull);
    });

    test('Khs.dariJson membaca IPK dan total SKS', () {
      final k = Khs.dariJson({'data': [], 'ipk': 3.63, 'sks_total': 8});
      expect(k.ipk, 3.63);
      expect(k.sksTotal, 8);
    });
  });

  group('model kelas dan notifikasi', () {
    test('Tugas terkirim bila jawaban ada', () {
      final belum = Tugas.dariJson({
        'id': 1,
        'judul': 'T1',
        'tenggat': '2026-11-20 23:59:00',
        'lewat': false,
        'jumlah_terkirim': 0,
        'deskripsi': null,
        'jawaban': null,
      });
      final sudah = Tugas.dariJson({
        'id': 2,
        'judul': 'T2',
        'tenggat': '2026-11-20 23:59:00',
        'lewat': true,
        'jumlah_terkirim': '3',
        'deskripsi': 'x',
        'jawaban': 'tautan',
      });
      expect(belum.terkirim, isFalse);
      expect(sudah.terkirim, isTrue);
      expect(sudah.jumlahTerkirim, 3);
      expect(sudah.lewat, isTrue);
    });

    test('Notifikasi.sudahDibaca hanya mengubah status baca', () {
      final n = Notifikasi.dariJson({
        'id': 5,
        'kelas_id': null,
        'jenis': 'tugas',
        'judul': 'Tugas baru',
        'isi': 'x',
        'dibuat': '2026-11-18 10:00:00',
        'dibaca': false,
      });
      expect(n.kelasId, isNull);
      expect(n.dibaca, isFalse);
      expect(n.sudahDibaca().dibaca, isTrue);
      expect(n.sudahDibaca().id, 5);
    });
  });

  group('model dasbor, kelulusan, dan perpustakaan', () {
    test('HariIni.dariJson membaca semua bagian', () {
      final h = HariIni.dariJson({
        'nama': 'Mahasiswa Contoh',
        'ipk': 3.63,
        'sks': 8,
        'jadwal': [
          {
            'kelas_id': 1,
            'nama': 'Basis Data',
            'kelas': 'A',
            'dosen': 'Dosen Contoh',
            'jam_mulai': '08:00:00',
            'jam_selesai': '10:30:00',
            'ruang': 'Lab 1',
          },
        ],
        'tugas': [
          {
            'id': 3,
            'judul': 'Tugas 1',
            'tenggat': '2026-11-20 23:59:00',
            'kelas_id': 1,
            'matakuliah': 'Basis Data',
            'sisa_jam': 50,
          },
        ],
        'info': [
          {
            'judul': 'Selamat datang',
            'isi': 'Isi',
            'dibuat': '2026-11-18 08:00:00',
          },
        ],
        'tagihan': [
          {
            'id': 1,
            'jenis': 'Biaya praktikum',
            'nominal': '350000',
            'jatuh_tempo': '2026-12-01 00:00:00',
            'terlambat': false,
          },
        ],
        'buku': [
          {
            'id': 2,
            'judul': 'Basis Data Relasional',
            'jatuh_tempo': '2026-11-15 00:00:00',
            'terlambat': true,
            'sisa_jam': -72,
          },
        ],
        'ringkasan': {'pengumuman': 1, 'tugas': 2, 'belum_dibaca': 3},
      });
      expect(h.jadwal.single.mulai, '08:00');
      expect(h.tugas.single.sisaJam, 50);
      expect(h.tagihan.single.nominal, 350000);
      expect(h.buku.single.terlambat, isTrue);
      expect(h.buku.single.sisaJam, -72);
      expect(h.ringkasan.belumDibaca, 3);
    });

    test('Kelulusan.rasio dibatasi 0 sampai 1', () {
      Kelulusan k(int lulus, int target) => Kelulusan(
        sksTarget: target,
        sksLulus: lulus,
        sksSisa: 0,
        sksBernilai: lulus,
        persen: 0,
        ipk: 0,
        wajibBelum: const [],
      );
      expect(k(8, 138).rasio, closeTo(8 / 138, 1e-9));
      expect(k(150, 138).rasio, 1.0);
      expect(k(0, 0).rasio, 0.0);
    });

    test('Buku.dariJson menerima tahun kosong dan angka berupa teks', () {
      final b = Buku.dariJson({
        'id': 1,
        'judul': 'X',
        'penulis': 'Y',
        'kategori': 'Umum',
        'tersedia': '2',
        'dipinjam_saya': false,
        'tahun': null,
      });
      expect(b.tahun, isNull);
      expect(b.tersedia, 2);
      expect(b.dipinjamSaya, isFalse);
    });
  });
}
