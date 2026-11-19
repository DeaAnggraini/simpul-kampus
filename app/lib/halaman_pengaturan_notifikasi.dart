import 'package:material_ui/material_ui.dart';

import 'api_client.dart';
import 'notifikasi.dart';

class HalamanPengaturanNotifikasi extends StatefulWidget {
  const HalamanPengaturanNotifikasi({super.key, required this.repo});
  final NotifikasiRepository repo;
  @override
  State<HalamanPengaturanNotifikasi> createState() =>
      _HalamanPengaturanNotifikasiState();
}

class _HalamanPengaturanNotifikasiState
    extends State<HalamanPengaturanNotifikasi> {
  List<PreferensiKelas>? _daftar;
  String? _galat;
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final d = await widget.repo.preferensi();
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

  Future<void> _ubah(PreferensiKelas p, bool nilai) async {
    final lama = _daftar;
    setState(
      () => _daftar = [
        for (final x in lama ?? const <PreferensiKelas>[])
          x.kelasId == p.kelasId ? x.dengan(nilai) : x,
      ],
    );
    try {
      await widget.repo.aturPreferensi(p.kelasId, nilai);
    } on ApiGagal catch (e) {
      if (!mounted) return;
      setState(() => _daftar = lama); // kembalikan bila gagal
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.pesan)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final daftar = _daftar;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi per kelas')),
      body: daftar == null
          ? Center(
              child: _memuat
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _galat ?? 'Data tidak tersedia.',
                        textAlign: TextAlign.center,
                      ),
                    ),
            )
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Matikan kelas yang kabarnya tidak ingin Anda terima.',
                  ),
                ),
                for (final p in daftar)
                  SwitchListTile(
                    title: Text(p.nama),
                    subtitle: Text('Kelas ${p.kelas}'),
                    value: p.aktif,
                    onChanged: (v) => _ubah(p, v),
                  ),
              ],
            ),
    );
  }
}
