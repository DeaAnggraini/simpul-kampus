import 'package:material_ui/material_ui.dart';

import 'akademik.dart';
import 'auth_service.dart';
import 'pemuat_data.dart';

class HalamanAkun extends StatelessWidget {
  const HalamanAkun({super.key, required this.repo, required this.auth});
  final AkademikRepository repo;
  final AuthService auth;

  Widget _baris(IconData ikon, String judul, String isi) =>
      ListTile(leading: Icon(ikon), title: Text(judul), subtitle: Text(isi));

  Widget _keluar() => Padding(
    padding: const EdgeInsets.all(16),
    child: OutlinedButton.icon(
      onPressed: auth.keluar,
      icon: const Icon(Icons.logout),
      label: const Text('Keluar'),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final pengguna = auth.pengguna;
    if (pengguna != null && pengguna.peran != 'mahasiswa') {
      final peran =
          '${pengguna.peran[0].toUpperCase()}${pengguna.peran.substring(1)}';
      return Scaffold(
        appBar: AppBar(title: const Text('Akun')),
        body: ListView(
          children: [
            _baris(Icons.person_outline, 'Nama', pengguna.nama),
            _baris(Icons.badge_outlined, 'Peran', peran),
            _keluar(),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Akun')),
      body: PemuatData<ProfilLengkap>(
        ambil: repo.ambilProfil,
        builder: (context, p) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _baris(Icons.person_outline, 'Nama', p.nama),
            _baris(Icons.badge_outlined, 'NIM', p.nim),
            _baris(Icons.email_outlined, 'Email', p.email),
            _baris(Icons.apartment, 'Fakultas', p.fakultas),
            _baris(Icons.school_outlined, 'Program studi', p.prodi),
            _baris(Icons.menu_book_outlined, 'Kurikulum', p.kurikulum),
            _baris(Icons.event_outlined, 'Angkatan', '${p.angkatan}'),
            _baris(
              Icons.supervisor_account_outlined,
              'Dosen PA',
              p.dosenPa ?? '-',
            ),
            _keluar(),
          ],
        ),
      ),
    );
  }
}
