import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class HalamanLayanan extends StatelessWidget {
  const HalamanLayanan({super.key, this.mahasiswa = true});
  final bool mahasiswa;

  Widget _menu(
    BuildContext context,
    IconData ikon,
    String judul,
    String keterangan,
    String tujuan,
  ) => ListTile(
    leading: Icon(ikon),
    title: Text(judul),
    subtitle: Text(keterangan),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.push(tujuan),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Layanan')),
      body: ListView(
        children: [
          if (mahasiswa) ...[
            _menu(
              context,
              Icons.account_balance_wallet_outlined,
              'Keuangan',
              'Tagihan dan riwayat pembayaran',
              '/layanan/keuangan',
            ),
            _menu(
              context,
              Icons.local_library_outlined,
              'Perpustakaan',
              'Cari buku, pinjaman, dan denda',
              '/layanan/perpustakaan',
            ),
            _menu(
              context,
              Icons.qr_code_2,
              'Kartu Anggota',
              'Kode QR perpustakaan',
              '/layanan/kartu',
            ),
          ],
          _menu(
            context,
            Icons.newspaper_outlined,
            'Berita Kampus',
            'Informasi dan pengumuman kampus',
            '/layanan/berita',
          ),
        ],
      ),
    );
  }
}
