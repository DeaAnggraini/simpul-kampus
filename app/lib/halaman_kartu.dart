import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'akademik.dart';
import 'pemuat_data.dart';

class HalamanKartu extends StatelessWidget {
  const HalamanKartu({super.key, required this.repo});
  final AkademikRepository repo;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Kartu Anggota')),
      body: PemuatData<ProfilLengkap>(
        ambil: repo.ambilProfil,
        builder: (context, p) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('Perpustakaan Simpul Kampus', style: teks.titleMedium),
                    const SizedBox(height: 16),
                    // Latar putih agar tetap terbaca di mode gelap
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: QrImageView(
                        data: 'SIMPUL-PUSTAKA:${p.nim}',
                        size: 220,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      p.nama,
                      style: teks.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    Text('${p.nim} · ${p.prodi}', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Tunjukkan kode ini kepada petugas saat meminjam atau masuk perpustakaan.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
