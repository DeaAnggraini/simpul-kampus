import 'package:material_ui/material_ui.dart';

import 'api_client.dart';
import 'auth_service.dart';

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key, required this.auth});
  final AuthService auth;
  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final _form = GlobalKey<FormState>();
  final _nim = TextEditingController();
  final _sandi = TextEditingController();
  bool _memuat = false;
  String? _galat;

  @override
  void dispose() {
    _nim.dispose();
    _sandi.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _memuat = true;
      _galat = null;
    });
    try {
      await widget.auth.masuk(_nim.text.trim(), _sandi.text);
      // Berhasil: ListenableBuilder di main.dart pindah ke beranda
    } on ApiGagal catch (e) {
      if (mounted) setState(() => _galat = e.pesan);
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Simpul Kampus',
                      style: teks.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Masuk untuk melanjutkan',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nim,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'NIM atau NIP',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'NIM atau NIP wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sandi,
                      obscureText: true,
                      onFieldSubmitted: (_) => _kirim(),
                      decoration: const InputDecoration(
                        labelText: 'Kata sandi',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v ?? '').isEmpty ? 'Kata sandi wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    if (_galat != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _galat!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    FilledButton(
                      onPressed: _memuat ? null : _kirim,
                      child: _memuat
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Masuk'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
