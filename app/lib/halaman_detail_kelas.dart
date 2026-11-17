import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_client.dart';
import 'form_kelas.dart';
import 'kelas.dart';

class HalamanDetailKelas extends StatefulWidget {
  const HalamanDetailKelas({super.key, required this.repo, required this.kelasId});
  final KelasRepository repo;
  final int kelasId;
  @override
  State<HalamanDetailKelas> createState() => _HalamanDetailKelasState();
}

class _HalamanDetailKelasState extends State<HalamanDetailKelas>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  DetailKelas? _data;
  String? _galat;
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) setState(() {}); // ganti tombol tambah sesuai tab
    });
    _muat();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    try {
      final d = await widget.repo.detail(widget.kelasId);
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

  Future<void> _jalankan(Future<void> Function() aksi, String sukses) async {
    try {
      await aksi();
      _info(sukses);
      await _muat();
    } on ApiGagal catch (e) {
      _info(e.pesan);
    }
  }

  Future<void> _tambahPengumuman() async {
    final isi = await tampilkanFormTeks(context, judul: 'Pengumuman baru', label: 'Isi pengumuman');
    if (isi == null || !mounted) return;
    await _jalankan(() => widget.repo.buatPengumuman(widget.kelasId, isi), 'Pengumuman terkirim.');
  }

  Future<void> _tambahTugas() async {
    final data = await tampilkanFormTugas(context);
    if (data == null || !mounted) return;
    await _jalankan(
      () => widget.repo.buatTugas(widget.kelasId,
          judul: data.judul, deskripsi: data.deskripsi, tenggat: data.tenggat),
      'Tugas dibuat.',
    );
  }

  Future<void> _kumpul(Tugas t) async {
    if (t.lewat) {
      _info('Tenggat sudah lewat.');
      return;
    }
    final jawaban = await tampilkanFormTeks(
      context,
      judul: t.judul,
      label: 'Jawaban atau tautan',
      awal: t.jawaban ?? '',
      tombol: t.terkirim ? 'Perbarui' : 'Kumpulkan',
      maksimal: 2000,
    );
    if (jawaban == null || !mounted) return;
    await _jalankan(() => widget.repo.kumpul(t.id, jawaban), 'Tugas terkumpul.');
  }

  Future<void> _gabung(String url) async {
    try {
      final berhasil = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!berhasil) _info('Tautan rapat tidak dapat dibuka.');
    } on Exception {
      _info('Tautan rapat tidak dapat dibuka.');
    }
  }

  Widget _header(DetailKelas d) => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${d.kode} · Kelas ${d.kelas}', style: Theme.of(context).textTheme.titleSmall),
                  Text('${d.jadwal} · ${d.ruang}'),
                  Text(d.dosen),
                ],
              ),
            ),
            if (d.tautanRapat != null)
              FilledButton.icon(
                onPressed: () => _gabung(d.tautanRapat!),
                icon: const Icon(Icons.videocam),
                label: const Text('Rapat'),
              ),
          ],
        ),
      );

  Widget _kosong(String pesan) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [Padding(padding: const EdgeInsets.all(24), child: Text(pesan))],
      );

  Widget _tabPengumuman(DetailKelas d) => RefreshIndicator(
        onRefresh: _muat,
        child: d.pengumuman.isEmpty
            ? _kosong('Belum ada pengumuman.')
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                children: [
                  for (final p in d.pengumuman)
                    Card(
                      child: ListTile(
                        title: Text(p.isi),
                        subtitle: Text('${p.penulis} · ${formatWaktu(p.dibuat)}'),
                      ),
                    ),
                ],
              ),
      );

  Widget _lencana(Tugas t, bool dosen) {
    if (dosen) return Text('${t.jumlahTerkirim} terkumpul');
    if (t.terkirim) {
      return const Chip(avatar: Icon(Icons.check, size: 16), label: Text('Terkumpul'));
    }
    if (t.lewat) {
      return Chip(
        label: Text('Terlambat', style: TextStyle(color: Theme.of(context).colorScheme.error)),
      );
    }
    return const Chip(label: Text('Belum'));
  }

  Widget _tabTugas(DetailKelas d) => RefreshIndicator(
        onRefresh: _muat,
        child: d.tugas.isEmpty
            ? _kosong('Belum ada tugas.')
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                children: [
                  for (final t in d.tugas)
                    Card(
                      child: ListTile(
                        isThreeLine: (t.deskripsi ?? '').isNotEmpty,
                        title: Text(t.judul),
                        subtitle: Text(
                          'Tenggat ${formatWaktu(t.tenggat)}'
                          '${(t.deskripsi ?? '').isEmpty ? '' : '\n${t.deskripsi}'}',
                        ),
                        trailing: _lencana(t, d.bolehTulis),
                        onTap: d.bolehTulis ? null : () => _kumpul(t),
                      ),
                    ),
                ],
              ),
      );

  Widget _tabAnggota(DetailKelas d) => RefreshIndicator(
        onRefresh: _muat,
        child: d.anggota.isEmpty
            ? _kosong('Belum ada anggota.')
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  for (final a in d.anggota)
                    ListTile(
                      leading: CircleAvatar(child: Text(a.nama.isEmpty ? '?' : a.nama[0])),
                      title: Text(a.nama),
                      subtitle: a.nim == null ? null : Text(a.nim!),
                    ),
                ],
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
        _header(d),
        const Divider(height: 1),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [_tabPengumuman(d), _tabTugas(d), _tabAnggota(d)],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bolehTulis = _data?.bolehTulis ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(_data?.namaMk ?? 'Kelas'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Pengumuman'), Tab(text: 'Tugas'), Tab(text: 'Anggota')],
        ),
      ),
      body: _isi(),
      floatingActionButton: (bolehTulis && _tab.index != 2)
          ? FloatingActionButton.extended(
              onPressed: _tab.index == 0 ? _tambahPengumuman : _tambahTugas,
              icon: const Icon(Icons.add),
              label: Text(_tab.index == 0 ? 'Pengumuman' : 'Tugas'),
            )
          : null,
    );
  }
}