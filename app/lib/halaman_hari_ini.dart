import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'api_client.dart';
import 'hari_ini.dart';
import 'kelas.dart' show formatWaktu;

class HalamanHariIni extends StatefulWidget {
  const HalamanHariIni({super.key, required this.repo});
  final HariIniRepository repo;
  @override
  State<HalamanHariIni> createState() => _HalamanHariIniState();
}

class _HalamanHariIniState extends State<HalamanHariIni> {
  HariIni? _data;
  String? _galat;
  bool _memuat = true;
  bool _sibuk = false; // cegah permintaan bertumpuk
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _muat();
    // Polling ringan: kabar baru tampil tanpa menarik layar
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _muat());
  }

  @override
  void dispose() {
    _timer?.cancel(); // wajib: hentikan polling saat halaman ditutup
    super.dispose();
  }

  Future<void> _muat() async {
    if (_sibuk) return;
    _sibuk = true;
    try {
      final d = await widget.repo.ambil();
      if (!mounted) return;
      setState(() {
        _data = d;
        _galat = null;
      });
    } on ApiGagal catch (e) {
      // Bila polling gagal, data lama tetap tampil
      if (mounted && _data == null) setState(() => _galat = e.pesan);
    } finally {
      _sibuk = false;
      if (mounted) setState(() => _memuat = false);
    }
  }

  Future<void> _bukaNotifikasi() async {
    await context.push('/notifikasi');
    _muat(); // segarkan lencana setelah kembali
  }

  Widget _judul(String teks) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
        child: Text(teks, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _kosong(String teks) => Card(child: ListTile(title: Text(teks)));

  Widget _statistik(String label, String nilai) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              Text(nilai, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
      );

  Widget _isi(HariIni d) {
    final skema = Theme.of(context).colorScheme;
    final r = d.ringkasan;
    final adaKabar = r.pengumuman + r.tugas > 0;
    return RefreshIndicator(
      onRefresh: _muat,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text('Halo, ${d.nama}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statistik('IPK', d.ipk.toStringAsFixed(2))),
              const SizedBox(width: 12),
              Expanded(child: _statistik('SKS bernilai', '${d.sks}')),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            color: skema.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Ringkasan 24 jam terakhir'),
              subtitle: Text(adaKabar
                  ? '${r.pengumuman} pengumuman dan ${r.tugas} tugas baru. '
                      '${r.belumDibaca} notifikasi belum dibaca.'
                  : 'Tidak ada kabar baru. ${r.belumDibaca} notifikasi belum dibaca.'),
              isThreeLine: true,
              onTap: _bukaNotifikasi,
            ),
          ),
          _judul('Jadwal hari ini'),
          if (d.jadwal.isEmpty) _kosong('Tidak ada jadwal hari ini.'),
          for (final j in d.jadwal)
            Card(
              child: ListTile(
                title: Text(j.nama),
                subtitle: Text('${j.mulai} sampai ${j.selesai} · ${j.ruang}\n${j.dosen}'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/kelas/${j.kelasId}'),
              ),
            ),
          _judul('Tugas yang perlu dikerjakan'),
          if (d.tugas.isEmpty) _kosong('Semua tugas sudah dikumpulkan.'),
          for (final t in d.tugas)
            Card(
              child: ListTile(
                leading: Icon(Icons.assignment_outlined, color: t.sisaJam < 24 ? skema.error : null),
                title: Text(t.judul),
                subtitle: Text('${t.matakuliah} · tenggat ${formatWaktu(t.tenggat)}'),
                trailing: Text(
                  sisaWaktu(t.sisaJam),
                  style: TextStyle(color: t.sisaJam < 24 ? skema.error : null),
                ),
                onTap: () => context.go('/kelas/${t.kelasId}'),
              ),
            ),
          _judul('Informasi kampus'),
          if (d.info.isEmpty) _kosong('Belum ada informasi.'),
          for (final i in d.info) Card(child: ListTile(title: Text(i.judul), subtitle: Text(i.isi))),
        ],
      ),
    );
  }

  Widget _badan() {
    final d = _data;
    if (d != null) return _isi(d);
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

  @override
  Widget build(BuildContext context) {
    final belum = _data?.ringkasan.belumDibaca ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hari Ini'),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: _bukaNotifikasi,
            icon: Badge.count(
              count: belum,
              isLabelVisible: belum > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: _badan(),
    );
  }
}