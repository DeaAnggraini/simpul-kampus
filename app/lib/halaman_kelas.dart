import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'kelas.dart';
import 'pemuat_data.dart';

class HalamanKelas extends StatelessWidget {
  const HalamanKelas({super.key, required this.repo});
  final KelasRepository repo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelas')),
      body: PemuatData<List<KelasSaya>>(
        ambil: repo.daftar,
        builder: (context, daftar) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          children: [
            if (daftar.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Belum ada kelas. Isi KRS lebih dulu.'),
              ),
            for (final k in daftar)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(k.kelas)),
                  title: Text(k.nama),
                  subtitle: Text(
                    '${k.jadwal} · ${k.ruang}\n${k.dosen} · ${k.jumlahAnggota} mahasiswa',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/kelas/${k.id}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
