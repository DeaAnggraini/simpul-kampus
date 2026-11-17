import 'package:material_ui/material_ui.dart';
import 'api_client.dart';
import 'krs.dart';

class HalamanKrs extends StatefulWidget {
  const HalamanKrs({super.key, required this.repo});
  final KrsRepository repo;
  @override
  State<HalamanKrs> createState() => _HalamanKrsState();
}

class _HalamanKrsState extends State<HalamanKrs> {
  DataKrs? _data;
  final Set<int> _dipilih = {};
  bool _memuat = true;
  bool _menyimpan = false;
  String? _galat;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final data = await widget.repo.ambil();
      if (!mounted) return;
      setState(() {
        _data = data;
        _galat = null;
        _dipilih
          ..clear()
          ..addAll([for (final k in data.kelas) if (k.diambil) k.kelasId]);
      });
    } on ApiGagal catch (e) {
      if (mounted) setState(() => _galat = e.pesan);
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  List<KelasTawaran> get _terpilih => [
        for (final k in _data?.kelas ?? const <KelasTawaran>[])
          if (_dipilih.contains(k.kelasId)) k
      ];

  int _total(Iterable<KelasTawaran> daftar) =>
      daftar.fold(0, (s, k) => s + k.sks);

  /// Alasan sebuah kelas tidak bisa dipilih, atau null bila boleh.
  String? _alasan(KelasTawaran k) {
    if (_dipilih.contains(k.kelasId)) return null;
    if (k.sudahLulus) return 'Sudah lulus';
    if (k.penuh) return 'Kelas penuh';
    // Kelas lain dari mata kuliah yang sama akan digantikan, jadi tidak dihitung
    final lain = [for (final x in _terpilih) if (x.mkId != k.mkId) x];
    for (final x in lain) {
      if (k.bentrok(x)) return 'Bentrok dengan ${x.nama}';
    }
    if (_total(lain) + k.sks > (_data?.batasSks ?? 0)) return 'Melebihi batas SKS';
    return null;
  }

  void _ubah(KelasTawaran k, bool? pilih) {
    setState(() {
      if (pilih == true) {
        // Satu mata kuliah hanya satu kelas
        _dipilih.removeWhere((id) => (_data?.kelas ?? const <KelasTawaran>[])
            .any((x) => x.kelasId == id && x.mkId == k.mkId));
        _dipilih.add(k.kelasId);
      } else {
        _dipilih.remove(k.kelasId);
      }
    });
  }

  Future<void> _simpan() async {
    setState(() => _menyimpan = true);
    try {
      final total = await widget.repo.simpan(_dipilih.toList());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('KRS tersimpan ($total SKS).')),
      );
      await _muat();
    } on ApiGagal catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('KRS belum tersimpan'),
          content: SingleChildScrollView(child: Text(e.pesan)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  Widget _baris(KelasTawaran k) {
    final alasan = _alasan(k);
    final galat = Theme.of(context).colorScheme.error;
    return CheckboxListTile(
      value: _dipilih.contains(k.kelasId),
      onChanged: alasan == null ? (v) => _ubah(k, v) : null,
      controlAffinity: ListTileControlAffinity.leading,
      isThreeLine: true,
      title: Text('${k.nama} · Kelas ${k.kelas}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${k.kode} · ${k.sks} SKS · ${k.jadwal} · ${k.ruang}'),
          Text('${k.dosen} · Terisi ${k.terisi}/${k.kuota}'),
          if (alasan != null) Text(alasan, style: TextStyle(color: galat)),
        ],
      ),
    );
  }

  Widget _isi() {
    final data = _data;
    if (data == null) {
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
    final total = _total(_terpilih);
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('KRS ${data.tahun}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: total / data.batasSks),
              const SizedBox(height: 4),
              Text('$total dari ${data.batasSks} SKS'),
            ],
          ),
        ),
        const Divider(height: 1),
        for (final k in data.kelas) _baris(k),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengisian KRS')),
      body: _isi(),
      bottomNavigationBar: _data == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: (_menyimpan || _dipilih.isEmpty) ? null : _simpan,
                  icon: const Icon(Icons.save),
                  label: Text(_menyimpan ? 'Menyimpan…' : 'Simpan KRS'),
                ),
              ),
            ),
    );
  }
}