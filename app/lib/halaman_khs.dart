import 'package:material_ui/material_ui.dart';
import 'akademik.dart';
import 'pemuat_data.dart';

class HalamanKhs extends StatelessWidget {
  const HalamanKhs({super.key, required this.repo});
  final AkademikRepository repo;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Kartu Hasil Studi')),
      body: PemuatData<Khs>(
        ambil: repo.ambilKhs,
        builder: (context, khs) {
          if (khs.daftar.isEmpty) {
            return ListView(children: const [
              Padding(padding: EdgeInsets.all(24), child: Text('Belum ada data KHS.')),
            ]);
          }
          final urut = khs.daftar.reversed.toList(); // terbaru di atas
          return ListView(
            children: [
              ListTile(
                title: Text('IPK ${khs.ipk.toStringAsFixed(2)}', style: teks.titleLarge),
                subtitle: Text('${khs.sksTotal} SKS tempuh'),
              ),
              const Divider(height: 1),
              for (var i = 0; i < urut.length; i++)
                ExpansionTile(
                  initiallyExpanded: i == 0,
                  title: Text(urut[i].judul),
                  subtitle: Text(urut[i].ips == null
                      ? 'Nilai belum keluar'
                      : 'IPS ${urut[i].ips!.toStringAsFixed(2)} · ${urut[i].sks} SKS'),
                  children: [
                    for (final m in urut[i].matakuliah)
                      ListTile(
                        dense: true,
                        title: Text(m.nama),
                        subtitle: Text('${m.kode} · ${m.sks} SKS'),
                        trailing: m.nilai == null
                            ? const Text('Belum ada')
                            : CircleAvatar(radius: 14, child: Text(m.nilai!)),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}