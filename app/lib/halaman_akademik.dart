import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class HalamanAkademik extends StatelessWidget {
  const HalamanAkademik({super.key});

  Widget _menu(
    BuildContext context,
    IconData ikon,
    String judul,
    String keterangan,
    String tujuan,
  ) => ListTile(
    leading: Icon(ikon),
    title: Text(judul),
    subtitle: Text(keterangan),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.push(tujuan),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akademik')),
      body: ListView(
        children: [
          _menu(
            context,
            Icons.edit_note,
            'Pengisian KRS',
            'Pilih kelas semester ini',
            '/akademik/krs',
          ),
          _menu(
            context,
            Icons.grading,
            'Kartu Hasil Studi (KHS)',
            'Nilai per semester',
            '/akademik/khs',
          ),
          _menu(
            context,
            Icons.show_chart,
            'Riwayat IPS dan IPK',
            'Perkembangan tiap semester',
            '/akademik/riwayat',
          ),
          _menu(
            context,
            Icons.flag_outlined,
            'Pelacak Kelulusan',
            'SKS terkumpul dan mata kuliah wajib',
            '/akademik/kelulusan',
          ),
          _menu(
            context,
            Icons.calculate_outlined,
            'Simulasi IP Target',
            'Hitung IPS yang dibutuhkan',
            '/akademik/simulasi',
          ),
        ],
      ),
    );
  }
}
