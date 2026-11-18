import 'package:material_ui/material_ui.dart';
import 'api_client.dart';
import 'format.dart';
import 'kelas.dart' show formatWaktu;
import 'perpustakaan.dart';

class HalamanPerpustakaan extends StatefulWidget {
  const HalamanPerpustakaan({super.key, required this.repo, this.tabAwal = 0});
  final PerpustakaanRepository repo;
  final int tabAwal;
  @override
  State<HalamanPerpustakaan> createState() => _HalamanPerpustakaanState();
}

class _HalamanPerpustakaanState extends State<HalamanPerpustakaan>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _cari = TextEditingController();
  List<Buku>? _buku;
  DaftarPinjaman? _pinjaman;
  String? _galat;
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this, initialIndex: widget.tabAwal == 1 ? 1 : 0);
    _muat();
  }

  @override
  void dispose() {
    _tab.dispose();
    _cari.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    try {
      final buku = await widget.repo.cari(_cari.text.trim());
      final pinjaman = await widget.repo.daftarPinjaman();
      if (!mounted) return;
      setState(() {
        _buku = buku;
        _pinjaman = pinjaman;
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

  Future<void> _pinjam(Buku b) async {
    try {
      await widget.repo.pinjam(b.id);
      _info('"${b.judul}" dipinjam.');
      await _muat();
    } on ApiGagal catch (e) {
      _info(e.pesan);
    }
  }

  Future<void> _kembalikan(Pinjaman p) async {
    try {
      final denda = await widget.repo.kembalikan(p.id);
      _info(denda > 0 ? 'Dikembalikan. Denda ${denda.rupiah}.' : 'Dikembalikan.');
      await _muat();
    } on ApiGagal catch (e) {
      _info(e.pesan);
    }
  }

  Widget _aksi(Buku b) {
    if (b.dipinjamSaya) return const Chip(label: Text('Dipinjam'));
    if (b.tersedia <= 0) return const Chip(label: Text('Habis'));
    return FilledButton.tonal(onPressed: () => _pinjam(b), child: const Text('Pinjam'));
  }

  Widget _katalog(List<Buku> buku) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _cari,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _muat(),
              decoration: const InputDecoration(
                hintText: 'Cari judul, penulis, atau kategori',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: buku.isEmpty
                ? const Center(child: Text('Buku tidak ditemukan.'))
                : ListView.builder(
                    itemCount: buku.length,
                    itemBuilder: (context, i) {
                      final b = buku[i];
                      return ListTile(
                        isThreeLine: true,
                        title: Text(b.judul),
                        subtitle: Text(
                          '${b.penulis} · ${b.kategori}${b.tahun == null ? '' : ' · ${b.tahun}'}\n'
                          'Tersedia ${b.tersedia}',
                        ),
                        trailing: _aksi(b),
                      );
                    },
                  ),
          ),
        ],
      );

  Widget _judul(String teks) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Text(teks, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _tabPinjaman(DaftarPinjaman p) {
    final skema = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _muat,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: skema.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: Text('Denda berjalan ${p.dendaBerjalan.rupiah}'),
              subtitle: Text(
                'Maksimal ${p.maks} pinjaman, ${p.lamaHari} hari, denda ${p.dendaPerHari.rupiah} per hari. '
                'Pengembalian di aplikasi ini hanya simulasi.',
              ),
              isThreeLine: true,
            ),
          ),
          _judul('Sedang dipinjam (${p.aktif.length})'),
          if (p.aktif.isEmpty) const Card(child: ListTile(title: Text('Tidak ada pinjaman aktif.'))),
          for (final x in p.aktif)
            Card(
              child: ListTile(
                title: Text(x.judul),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jatuh tempo ${formatWaktu(x.jatuhTempo)}'),
                    if (x.terlambat)
                      Text(
                        'Terlambat ${x.hariTelat} hari · denda ${x.denda.rupiah}',
                        style: TextStyle(color: skema.error),
                      ),
                  ],
                ),
                trailing: TextButton(
                  onPressed: () => _kembalikan(x),
                  child: const Text('Kembalikan'),
                ),
              ),
            ),
          _judul('Riwayat'),
          if (p.riwayat.isEmpty) const Card(child: ListTile(title: Text('Belum ada riwayat.'))),
          for (final x in p.riwayat)
            Card(
              child: ListTile(
                title: Text(x.judul),
                subtitle: Text(
                  'Dikembalikan ${formatWaktu(x.dikembalikan ?? x.jatuhTempo)}'
                  '${x.denda > 0 ? ' · denda ${x.denda.rupiah}' : ''}',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _isi() {
    final buku = _buku;
    final pinjaman = _pinjaman;
    if (buku == null || pinjaman == null) {
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
    return TabBarView(controller: _tab, children: [_katalog(buku), _tabPinjaman(pinjaman)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perpustakaan'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Katalog'), Tab(text: 'Pinjaman saya')],
        ),
      ),
      body: _isi(),
    );
  }
}