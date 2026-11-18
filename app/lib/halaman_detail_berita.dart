import 'package:material_ui/material_ui.dart';
import 'berita.dart';
import 'kelas.dart' show formatWaktu;
import 'pemuat_data.dart';

class HalamanDetailBerita extends StatelessWidget {
  const HalamanDetailBerita({super.key, required this.repo, required this.id});
  final BeritaRepository repo;
  final int id;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Berita')),
      body: PemuatData<BeritaDetail>(
        ambil: () => repo.detail(id),
        builder: (context, b) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Align(alignment: Alignment.centerLeft, child: Chip(label: Text(b.kategori))),
            const SizedBox(height: 8),
            Text(b.judul, style: teks.headlineSmall),
            const SizedBox(height: 4),
            Text('${formatWaktu(b.dibuat)}${b.penulis == null ? '' : ' · ${b.penulis}'}'),
            const Divider(height: 32),
            Text(b.isi, style: teks.bodyLarge),
          ],
        ),
      ),
    );
  }
}