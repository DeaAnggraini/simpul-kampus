import 'package:material_ui/material_ui.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'beranda.dart';

class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key, required this.api, required this.auth});
  final ApiClient api;
  final AuthService auth;
  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> {
  late Future<Beranda> _future; // dibuat di initState, BUKAN di build()

  @override
  void initState() {
    super.initState();
    _future = _ambil();
  }

  Future<Beranda> _ambil() async {
    try {
      return Beranda.dariJson(await widget.api.kirim('GET', 'beranda.php'));
    } on ApiGagal catch (e) {
      if (e.status == 401) await widget.auth.keluar(); // sesi habis
      rethrow;
    }
  }

  void _muatUlang() => setState(() => _future = _ambil());

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simpul Kampus'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: widget.auth.keluar,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<Beranda>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 12),
                    Text('${snap.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                        onPressed: _muatUlang, child: const Text('Coba lagi')),
                  ],
                ),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final b = snap.data!;
          return RefreshIndicator(
            onRefresh: () async => _muatUlang(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(b.profil.nama, style: teks.titleMedium),
                    subtitle: Text(
                      '${b.profil.nim} · ${b.profil.prodi}\n'
                      'Semester ${b.profil.semester} · ${b.profil.sks} SKS · '
                      'IPK ${b.profil.ipk.toStringAsFixed(2)}',
                    ),
                    isThreeLine: true,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Jadwal hari ini', style: teks.titleMedium),
                if (b.jadwal.isEmpty)
                  const ListTile(title: Text('Tidak ada jadwal hari ini.')),
                for (final j in b.jadwal)
                  Card(
                    child: ListTile(
                      title: Text(j.nama),
                      subtitle: Text(
                          '${j.mulai} sampai ${j.selesai} · ${j.ruang}\n${j.dosen}'),
                      isThreeLine: true,
                    ),
                  ),
                const SizedBox(height: 16),
                Text('Informasi', style: teks.titleMedium),
                for (final p in b.pengumuman)
                  Card(
                    child: ListTile(
                      title: Text(p['judul'] as String),
                      subtitle: Text(p['isi'] as String),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}