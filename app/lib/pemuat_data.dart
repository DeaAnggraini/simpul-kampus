import 'package:material_ui/material_ui.dart';

class PemuatData<T> extends StatefulWidget {
  const PemuatData({super.key, required this.ambil, required this.builder});
  final Future<T> Function() ambil;
  final Widget Function(BuildContext context, T data) builder;
  @override
  State<PemuatData<T>> createState() => _PemuatDataState<T>();
}

class _PemuatDataState<T> extends State<PemuatData<T>> {
  late Future<T> _future; // dibuat di initState, bukan di build()

  @override
  void initState() {
    super.initState();
    _future = widget.ambil();
  }

  void _muatUlang() {
    setState(() {
      _future = widget.ambil();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48),
                  const SizedBox(height: 12),
                  Text('${snap.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _muatUlang,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () async => _muatUlang(),
          child: widget.builder(context, snap.data as T),
        );
      },
    );
  }
}
