import 'package:material_ui/material_ui.dart';
import 'akademik.dart';
import 'pemuat_data.dart';

class HalamanRiwayat extends StatelessWidget {
  const HalamanRiwayat({super.key, required this.repo});
  final AkademikRepository repo;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat IPS dan IPK')),
      body: PemuatData<Khs>(
        ambil: repo.ambilKhs,
        builder: (context, khs) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (khs.daftar.isEmpty) const Text('Belum ada data.'),
            for (final s in khs.daftar)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.judul, style: teks.titleSmall),
                      const SizedBox(height: 8),
                      if (s.ips == null)
                        const Text('Nilai belum keluar')
                      else ...[
                        LinearProgressIndicator(value: s.ips! / 4),
                        const SizedBox(height: 8),
                        Text('IPS ${s.ips!.toStringAsFixed(2)} · '
                            'IPK ${s.ipk!.toStringAsFixed(2)}'),
                        Text('${s.sks} SKS semester · ${s.sksKumulatif} SKS kumulatif'),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}