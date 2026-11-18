import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'api_client.dart';
import 'kelas.dart' show formatWaktu;
import 'notifikasi.dart';

class HalamanNotifikasi extends StatefulWidget {
  const HalamanNotifikasi({super.key, required this.repo});
  final NotifikasiRepository repo;
  @override
  State<HalamanNotifikasi> createState() => _HalamanNotifikasiState();
}

class _HalamanNotifikasiState extends State<HalamanNotifikasi> {
  List<Notifikasi>? _daftar;
  String? _galat;
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final d = await widget.repo.daftar();
      if (!mounted) return;
      setState(() {
        _daftar = d;
        _galat = null;
      });
    } on ApiGagal catch (e) {
      if (mounted) setState(() => _galat = e.pesan);
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  void _info(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _buka(Notifikasi n) async {
    if (!n.dibaca) {
      try {
        await widget.repo.tandaiBaca(n.id);
        if (!mounted) return;
        setState(() => _daftar = [
              for (final x in _daftar ?? const <Notifikasi>[]) x.id == n.id ? x.sudahDibaca() : x
            ]);
      } on ApiGagal catch (e) {
        _info(e.pesan);
        return;
      }
    }
    final kelasId = n.kelasId;
    if (kelasId != null && mounted) context.go('/kelas/$kelasId');
  }

  Future<void> _tandaiSemua() async {
    try {
      await widget.repo.tandaiSemua();
      await _muat();
    } on ApiGagal catch (e) {
      _info(e.pesan);
    }
  }

  Widget _badan() {
    final daftar = _daftar;
    if (daftar == null) {
      if (_memuat) return const Center(child: CircularProgressIndicator());
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_galat ?? 'Data tidak tersedia.', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  setState(() => _memuat = true);
                  _muat();
                },
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }
    final primer = Theme.of(context).colorScheme.primary;
    return RefreshIndicator(
      onRefresh: _muat,
      child: daftar.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [Padding(padding: EdgeInsets.all(24), child: Text('Belum ada notifikasi.'))],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                for (final n in daftar)
                  ListTile(
                    leading: Icon(n.jenis == 'tugas' ? Icons.assignment_outlined : Icons.campaign_outlined),
                    title: Text(
                      n.judul,
                      style: TextStyle(fontWeight: n.dibaca ? FontWeight.normal : FontWeight.bold),
                    ),
                    subtitle: Text('${n.isi}\n${formatWaktu(n.dibuat)}'),
                    isThreeLine: true,
                    trailing: n.dibaca ? null : Icon(Icons.circle, size: 10, color: primer),
                    onTap: () => _buka(n),
                  ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            tooltip: 'Tandai semua dibaca',
            onPressed: _tandaiSemua,
            icon: const Icon(Icons.done_all),
          ),
          IconButton(
            tooltip: 'Atur notifikasi per kelas',
            onPressed: () => context.push('/notifikasi/pengaturan'),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: _badan(),
    );
  }
}