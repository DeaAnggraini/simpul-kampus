import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'api_client.dart';
import 'berita.dart';
import 'form_berita.dart';
import 'kelas.dart' show formatWaktu;

class HalamanBerita extends StatefulWidget {
  const HalamanBerita({super.key, required this.repo});
  final BeritaRepository repo;
  @override
  State<HalamanBerita> createState() => _HalamanBeritaState();
}

class _HalamanBeritaState extends State<HalamanBerita> {
  final _cari = TextEditingController();
  String? _kategori;
  DaftarBerita? _data;
  String? _galat;
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    try {
      final d = await widget.repo.daftar(cari: _cari.text.trim(), kategori: _kategori);
      if (!mounted) return;
      setState(() {
        _data = d;
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

  void _pilih(String? kategori) {
    setState(() => _kategori = kategori);
    _muat();
  }

  Future<void> _tulis() async {
    final d = await tampilkanFormBerita(context);
    if (d == null || !mounted) return;
    try {
      await widget.repo.buat(judul: d.judul, kategori: d.kategori, isi: d.isi);
      _info('Berita diterbitkan.');
      await _muat();
    } on ApiGagal catch (e) {
      _info(e.pesan);
    }
  }

  Widget _chip(String label, String? nilai) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _kategori == nilai,
          onSelected: (_) => _pilih(nilai),
        ),
      );

  Widget _isi() {
    final d = _data;
    if (d == null) {
      if (_memuat) return const Center(child: CircularProgressIndicator());
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 12),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: _cari,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _muat(),
            decoration: const InputDecoration(
              hintText: 'Cari berita',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _chip('Semua', null),
              for (final k in kategoriBerita) _chip(k, k),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _muat,
            child: d.data.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [Padding(padding: EdgeInsets.all(24), child: Text('Berita tidak ditemukan.'))],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    children: [
                      for (final n in d.data)
                        Card(
                          child: ListTile(
                            isThreeLine: true,
                            title: Text(n.judul),
                            subtitle: Text('${n.kategori} · ${formatWaktu(n.dibuat)}\n${n.ringkas}',
                                maxLines: 3, overflow: TextOverflow.ellipsis),
                            onTap: () => context.push('/layanan/berita/${n.id}'),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Berita Kampus')),
      body: _isi(),
      floatingActionButton: (_data?.bisaMenulis ?? false)
          ? FloatingActionButton.extended(
              onPressed: _tulis,
              icon: const Icon(Icons.add),
              label: const Text('Berita'),
            )
          : null,
    );
  }
}