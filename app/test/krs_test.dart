import 'package:flutter_test/flutter_test.dart';
import 'package:simpul_kampus/krs.dart';

KelasTawaran tawaran({
  int hari = 2,
  String mulai = '08:00',
  String selesai = '10:30',
  int kuota = 40,
  int terisi = 0,
  bool diambil = false,
}) => KelasTawaran(
  kelasId: 1,
  mkId: 1,
  kode: 'IKM302',
  nama: 'Basis Data',
  sks: 3,
  kelas: 'A',
  dosen: 'Dosen Contoh',
  hari: hari,
  mulai: mulai,
  selesai: selesai,
  ruang: 'Lab 1',
  kuota: kuota,
  terisi: terisi,
  diambil: diambil,
  sudahLulus: false,
);

void main() {
  group('KelasTawaran.bentrok', () {
    test('hari sama dan jam beririsan bentrok', () {
      final a = tawaran(mulai: '08:00', selesai: '10:30');
      final b = tawaran(mulai: '09:00', selesai: '11:30');
      expect(a.bentrok(b), isTrue);
      expect(b.bentrok(a), isTrue); // simetris
    });

    test('jam yang hanya bersentuhan tidak bentrok', () {
      final a = tawaran(mulai: '08:00', selesai: '10:30');
      final b = tawaran(mulai: '10:30', selesai: '12:00');
      expect(a.bentrok(b), isFalse);
    });

    test('hari berbeda tidak bentrok', () {
      expect(tawaran(hari: 2).bentrok(tawaran(hari: 3)), isFalse);
    });

    test('satu kelas berada di dalam kelas lain tetap bentrok', () {
      final luar = tawaran(mulai: '08:00', selesai: '12:00');
      final dalam = tawaran(mulai: '09:00', selesai: '10:00');
      expect(luar.bentrok(dalam), isTrue);
    });
  });

  test('penuh hanya berlaku bila kelas belum diambil', () {
    expect(tawaran(kuota: 10, terisi: 10).penuh, isTrue);
    expect(tawaran(kuota: 10, terisi: 9).penuh, isFalse);
    expect(tawaran(kuota: 10, terisi: 10, diambil: true).penuh, isFalse);
  });

  test('dariJson memotong detik dan menerima angka berupa teks', () {
    final k = KelasTawaran.dariJson({
      'kelas_id': '7',
      'mk_id': 3,
      'kode': 'IKM301',
      'nama': 'Pemrograman Mobile',
      'sks': '3',
      'kelas': 'A',
      'dosen': 'Dosen Contoh',
      'hari': 2,
      'jam_mulai': '08:00:00',
      'jam_selesai': '10:30:00',
      'ruang': 'Lab 1',
      'kuota': 40,
      'terisi': '12',
      'diambil': true,
      'sudah_lulus': false,
    });
    expect(k.kelasId, 7);
    expect(k.sks, 3);
    expect(k.terisi, 12);
    expect(k.jadwal, 'Selasa 08:00 sampai 10:30');
    expect(k.diambil, isTrue);
  });

  test('DataKrs.dariJson membaca tahun, batas, dan daftar kelas', () {
    final d = DataKrs.dariJson({
      'tahun': '2026/2027 Ganjil',
      'batas_sks': 24,
      'data': [],
    });
    expect(d.tahun, '2026/2027 Ganjil');
    expect(d.batasSks, 24);
    expect(d.kelas, isEmpty);
  });
}
