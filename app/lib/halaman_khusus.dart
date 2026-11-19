import 'package:material_ui/material_ui.dart';

class HalamanKhusus extends StatelessWidget {
  const HalamanKhusus({super.key, required this.judul, required this.peran});
  final String judul;
  final Set<String> peran;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(judul)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Halaman ini hanya untuk ${peran.join(' dan ')}.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
