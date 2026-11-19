import 'package:material_ui/material_ui.dart';

import 'berita.dart';

typedef DataBerita = ({String judul, String kategori, String isi});

Future<DataBerita?> tampilkanFormBerita(BuildContext context) {
  return showModalBottomSheet<DataBerita>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _FormBerita(),
  );
}

class _FormBerita extends StatefulWidget {
  const _FormBerita();
  @override
  State<_FormBerita> createState() => _FormBeritaState();
}

class _FormBeritaState extends State<_FormBerita> {
  final _judul = TextEditingController();
  final _isi = TextEditingController();
  String _kategori = kategoriBerita.first;
  String? _galat;

  @override
  void dispose() {
    _judul.dispose();
    _isi.dispose();
    super.dispose();
  }

  void _kirim() {
    final judul = _judul.text.trim();
    final isi = _isi.text.trim();
    if (judul.isEmpty || isi.isEmpty) {
      setState(() => _galat = 'Judul dan isi wajib diisi');
      return;
    }
    Navigator.pop(context, (judul: judul, kategori: _kategori, isi: isi));
  }

  @override
  Widget build(BuildContext context) {
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
          Text('Berita baru', style: Theme.of(context).textTheme.titleMedium),
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
          DropdownButtonFormField<String>(
            initialValue: _kategori,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final k in kategoriBerita)
                DropdownMenuItem(value: k, child: Text(k)),
            ],
            onChanged: (v) => setState(() => _kategori = v ?? _kategori),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _isi,
            minLines: 4,
            maxLines: 8,
            maxLength: 5000,
            decoration: const InputDecoration(
              labelText: 'Isi berita',
              border: OutlineInputBorder(),
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
          FilledButton(onPressed: _kirim, child: const Text('Terbitkan')),
        ],
      ),
    );
  }
}
