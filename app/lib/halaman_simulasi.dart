import 'package:material_ui/material_ui.dart';

import 'kelulusan.dart';
import 'pemuat_data.dart';
import 'simulasi_ip.dart';

class HalamanSimulasi extends StatelessWidget {
  const HalamanSimulasi({super.key, required this.repo});
  final KelulusanRepository repo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulasi IP Target')),
      body: PemuatData<Kelulusan>(
        ambil: repo.ambil,
        builder: (context, k) => _IsiSimulasi(data: k),
      ),
    );
  }
}

class _IsiSimulasi extends StatefulWidget {
  const _IsiSimulasi({required this.data});
  final Kelulusan data;
  @override
  State<_IsiSimulasi> createState() => _IsiSimulasiState();
}

class _IsiSimulasiState extends State<_IsiSimulasi> {
  final _target = TextEditingController(text: '3,50');

  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  double? get _nilaiTarget {
    final n = double.tryParse(_target.text.trim().replaceAll(',', '.'));
    return (n == null || n < 0 || n > 4) ? null : n;
  }

  String _teksHasil(HasilSimulasi h) => switch (h.status) {
    StatusSimulasi.tanpaSisa =>
      'Semua SKS target sudah bernilai, IPK tidak dapat diubah lagi.',
    StatusSimulasi.sudahTercapai => 'Target sudah pasti tercapai. Nilai berapa pun pada sisa SKS tidak menurunkan IPK di bawah target.',
    StatusSimulasi.mustahil =>
      'Target tidak dapat dicapai. Dibutuhkan rata-rata IPS ${h.ipsDibutuhkan.toStringAsFixed(2)}, padahal nilai tertinggi 4,00.',
    StatusSimulasi.mungkin =>
      'Dibutuhkan rata-rata IPS ${h.ipsDibutuhkan.toStringAsFixed(2)} pada sisa ${h.sksSisa} SKS.\n'
          'Contoh komposisi nilai ${h.komposisi}.',
  };

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final target = _nilaiTarget;
    final hasil = target == null
        ? null
        : hitungSimulasi(
            ipkSaatIni: d.ipk,
            sksBernilai: d.sksBernilai,
            sksTarget: d.sksTarget,
            ipkTarget: target,
          );
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: Text('IPK saat ini ${d.ipk.toStringAsFixed(2)}'),
            subtitle: Text(
              '${d.sksBernilai} SKS sudah bernilai dari target ${d.sksTarget} SKS',
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _target,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'IPK target (0,00 sampai 4,00)',
            errorText: target == null ? 'Masukkan angka 0 sampai 4' : null,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        if (hasil != null)
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_teksHasil(hasil)),
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'Bobot nilai A 4, B 3, C 2, D 1, E 0. Hitungan mengandaikan seluruh SKS target ditempuh.',
        ),
      ],
    );
  }
}
