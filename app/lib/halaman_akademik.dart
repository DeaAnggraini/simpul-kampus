import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class HalamanAkademik extends StatelessWidget {
  const HalamanAkademik({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akademik')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.grading),
            title: const Text('Kartu Hasil Studi (KHS)'),
            subtitle: const Text('Nilai per semester'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/akademik/khs'),
          ),
          ListTile(
            leading: const Icon(Icons.show_chart),
            title: const Text('Riwayat IPS dan IPK'),
            subtitle: const Text('Perkembangan tiap semester'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/akademik/riwayat'),
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Pengisian KRS'),
            subtitle: const Text('Pilih kelas semester ini'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/akademik/krs'),
          ),
        ],
      ),
    );
  }
}