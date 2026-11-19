import 'package:material_ui/material_ui.dart';

import 'kelas.dart';

/// Lembar bawah berisi satu kolom teks. Mengembalikan teks, atau null bila ditutup.
Future<String?> tampilkanFormTeks(
  BuildContext context, {
  required String judul,
  required String label,
  String awal = '',
  String tombol = 'Kirim',
  int maksimal = 1000,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FormTeks(
      judul: judul,
      label: label,
      awal: awal,
      tombol: tombol,
      maksimal: maksimal,
    ),
  );
}

class _FormTeks extends StatefulWidget {
  const _FormTeks({
    required this.judul,
    required this.label,
    required this.awal,
    required this.tombol,
    required this.maksimal,
  });
  final String judul, label, awal, tombol;
  final int maksimal;
  @override
  State<_FormTeks> createState() => _FormTeksState();
}

class _FormTeksState extends State<_FormTeks> {
  late final _teks = TextEditingController(text: widget.awal);
  String? _galat;

  @override
  void dispose() {
    _teks.dispose();
    super.dispose();
  }

  void _kirim() {
    final isi = _teks.text.trim();
    if (isi.isEmpty) {
      setState(() => _galat = 'Tidak boleh kosong');
      return;
    }
    Navigator.pop(context, isi);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.judul, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _teks,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            maxLength: widget.maksimal,
            decoration: InputDecoration(
              labelText: widget.label,
              errorText: _galat,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _kirim, child: Text(widget.tombol)),
        ],
      ),
    );
  }
}

typedef DataTugas = ({String judul, String deskripsi, String tenggat});

Future<DataTugas?> tampilkanFormTugas(BuildContext context) {
  return showModalBottomSheet<DataTugas>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _FormTugas(),
  );
}

class _FormTugas extends StatefulWidget {
  const _FormTugas();
  @override
  State<_FormTugas> createState() => _FormTugasState();
}

class _FormTugasState extends State<_FormTugas> {
  final _judul = TextEditingController();
  final _deskripsi = TextEditingController();
  DateTime? _tenggat;
  String? _galat;

  @override
  void dispose() {
    _judul.dispose();
    _deskripsi.dispose();
    super.dispose();
  }

  Future<void> _pilihTenggat() async {
    final sekarang = DateTime.now();
    final tgl = await showDatePicker(
      context: context,
      initialDate: sekarang.add(const Duration(days: 1)),
      firstDate: sekarang,
      lastDate: sekarang.add(const Duration(days: 365)),
    );
    if (tgl == null || !mounted) return;
    final jam = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 59),
    );
    if (jam == null || !mounted) return;
    setState(
      () => _tenggat = DateTime(
        tgl.year,
        tgl.month,
        tgl.day,
        jam.hour,
        jam.minute,
      ),
    );
  }

  void _kirim() {
    final judul = _judul.text.trim();
    final tenggat = _tenggat;
    if (judul.isEmpty) {
      setState(() => _galat = 'Judul wajib diisi');
      return;
    }
    if (tenggat == null) {
      setState(() => _galat = 'Pilih tenggat dulu');
      return;
    }
    Navigator.pop(context, (
      judul: judul,
      deskripsi: _deskripsi.text.trim(),
      tenggat: keFormatServer(tenggat),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = _tenggat;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tugas baru', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _judul,
            maxLength: 150,
            decoration: const InputDecoration(
              labelText: 'Judul',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _deskripsi,
            minLines: 2,
            maxLines: 4,
            maxLength: 2000,
            decoration: const InputDecoration(
              labelText: 'Deskripsi (opsional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pilihTenggat,
            icon: const Icon(Icons.event),
            label: Text(
              t == null
                  ? 'Pilih tenggat'
                  : 'Tenggat ${formatWaktu(keFormatServer(t))}',
            ),
          ),
          if (_galat != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _galat!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _kirim, child: const Text('Buat tugas')),
        ],
      ),
    );
  }
}
