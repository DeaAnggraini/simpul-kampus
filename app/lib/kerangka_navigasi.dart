import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class KerangkaNavigasi extends StatelessWidget {
  const KerangkaNavigasi({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const _tujuan = [
    (ikon: Icons.home_outlined, aktif: Icons.home, label: 'Beranda'),
    (ikon: Icons.school_outlined, aktif: Icons.school, label: 'Akademik'),
    (ikon: Icons.person_outline, aktif: Icons.person, label: 'Akun'),
  ];

  void _pilih(int i) =>
      shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final lebar = MediaQuery.sizeOf(context).width;
    if (lebar >= 840) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _pilih,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final t in _tujuan)
                  NavigationRailDestination(
                    icon: Icon(t.ikon),
                    selectedIcon: Icon(t.aktif),
                    label: Text(t.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: shell),
          ],
        ),
      );
    }
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _pilih,
        destinations: [
          for (final t in _tujuan)
            NavigationDestination(
              icon: Icon(t.ikon),
              selectedIcon: Icon(t.aktif),
              label: t.label,
            ),
        ],
      ),
    );
  }
}