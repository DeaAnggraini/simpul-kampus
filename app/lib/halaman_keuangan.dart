import 'package:material_ui/material_ui.dart';

import 'format.dart';
import 'keuangan.dart';
import 'kelas.dart' show formatWaktu;
import 'pemuat_data.dart';

class HalamanKeuangan extends StatelessWidget {
  const HalamanKeuangan({super.key, required this.repo});
  final KeuanganRepository repo;

  Widget _judul(BuildContext context, String teks) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Text(teks, style: Theme.of(context).textTheme.titleMedium),
  );

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Keuangan')),
      body: PemuatData<Keuangan>(
        ambil: repo.ambil,
        builder: (context, k) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: skema.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(
                  k.belum.isEmpty
                      ? 'Tidak ada tagihan'
                      : 'Belum lunas ${k.totalBelum.rupiah}',
                ),
                subtitle: const Text(
                  'Prototipe ini hanya menampilkan tagihan. Pembayaran dilakukan di luar aplikasi.',
                ),
                isThreeLine: true,
              ),
            ),
            _judul(context, 'Belum lunas (${k.belum.length})'),
            if (k.belum.isEmpty)
              const Card(
                child: ListTile(title: Text('Semua tagihan sudah lunas.')),
              ),
            for (final t in k.belum)
              Card(
                child: ListTile(
                  isThreeLine: true,
                  title: Text('${t.jenis} · ${t.nominal.rupiah}'),
                  subtitle: Text(
                    '${t.periode}\nJatuh tempo ${formatWaktu(t.jatuhTempo)}\nKode bayar ${t.kodeBayar}',
                  ),
                  trailing: Text(
                    t.terlambat ? 'Terlambat' : 'Belum lunas',
                    style: TextStyle(color: t.terlambat ? skema.error : null),
                  ),
                ),
              ),
            _judul(context, 'Lunas (${k.lunas.length})'),
            if (k.lunas.isEmpty)
              const Card(
                child: ListTile(title: Text('Belum ada riwayat pembayaran.')),
              ),
            for (final t in k.lunas)
              Card(
                child: ListTile(
                  isThreeLine: true,
                  title: Text('${t.jenis} · ${t.nominal.rupiah}'),
                  subtitle: Text(
                    '${t.periode}\nDibayar ${formatWaktu(t.dibayarPada ?? t.jatuhTempo)}',
                  ),
                  trailing: const Icon(Icons.check_circle_outline),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
