import 'package:material_ui/material_ui.dart';

import 'kelulusan.dart';
import 'pemuat_data.dart';

class HalamanKelulusan extends StatelessWidget {
  const HalamanKelulusan({super.key, required this.repo});
  final KelulusanRepository repo;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Pelacak Kelulusan')),
      body: PemuatData<Kelulusan>(
        ambil: repo.ambil,
        builder: (context, k) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progres kelulusan', style: teks.titleMedium),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: k.rasio),
                    const SizedBox(height: 8),
                    Text(
                      '${k.sksLulus} dari ${k.sksTarget} SKS (${k.persen.toStringAsFixed(1)}%)',
                    ),
                    Text(
                      'Sisa ${k.sksSisa} SKS · IPK ${k.ipk.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lulus berarti nilai A, B, atau C (aturan contoh).',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
              child: Text(
                'Mata kuliah wajib yang belum lulus (${k.wajibBelum.length})',
                style: teks.titleMedium,
              ),
            ),
            if (k.wajibBelum.isEmpty)
              const Card(
                child: ListTile(
                  title: Text('Semua mata kuliah wajib sudah lulus.'),
                ),
              ),
            for (final m in k.wajibBelum)
              Card(
                child: ListTile(
                  title: Text(m.nama),
                  subtitle: Text(
                    '${m.kode} · ${m.sks} SKS · semester ${m.semesterKe}',
                  ),
                  trailing: m.sedangDiambil
                      ? const Chip(label: Text('Sedang diambil'))
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
