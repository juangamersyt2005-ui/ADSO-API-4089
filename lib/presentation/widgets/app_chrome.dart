import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';

enum ApiConnectionStatus { connecting, connected, partial, offline, unknown }

class BrandHeader extends StatelessWidget implements PreferredSizeWidget {
  const BrandHeader({required this.status, this.onProfileTap, super.key});

  final ApiConnectionStatus status;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final badge = switch (status) {
      ApiConnectionStatus.connecting => (
        'Sincronizando',
        Icons.sync,
        AppTheme.cardHigh,
        AppTheme.text,
      ),
      ApiConnectionStatus.connected => (
        'En línea',
        Icons.cloud_done_outlined,
        AppTheme.success,
        const Color(0xFF001F18),
      ),
      ApiConnectionStatus.partial => (
        'Revisar API',
        Icons.cloud_sync_outlined,
        const Color(0xFF6A4B08),
        const Color(0xFFFFE5A3),
      ),
      ApiConnectionStatus.offline => (
        'Sin conexión',
        Icons.cloud_off_outlined,
        AppTheme.danger,
        Colors.white,
      ),
      ApiConnectionStatus.unknown => (
        'ADSO API',
        Icons.cloud_outlined,
        AppTheme.cardHigh,
        AppTheme.muted,
      ),
    };

    return AppBar(
      toolbarHeight: preferredSize.height,
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ADSO4089',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.text,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 9),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: badge.$3,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badge.$2, size: 14, color: badge.$4),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      badge.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: badge.$4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: IconButton.filledTonal(
            tooltip: 'Configuración',
            onPressed: onProfileTap,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.primarySoft,
              foregroundColor: const Color(0xFF1000A9),
              fixedSize: const Size(42, 42),
            ),
            icon: const Icon(Icons.person_outline),
          ),
        ),
      ],
    );
  }
}

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({required this.selectedIndex, super.key});

  final int selectedIndex;

  static const _routes = [null, '/aprendices', '/cursos', '/configuracion'];

  void _select(BuildContext context, int index) {
    if (index == 0) {
      if (selectedIndex != 0) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      return;
    }

    final routeName = _routes[index]!;
    if (ModalRoute.of(context)?.settings.name == routeName) return;

    Navigator.of(context)
        .pushNamedAndRemoveUntil(routeName, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _select(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Aprendices',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: 'Cursos',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Config',
        ),
      ],
    );
  }
}

class RecordFilter<T> {
  const RecordFilter({required this.label, required this.matches});

  final String label;
  final bool Function(T record) matches;
}

class RecordCardAction {
  const RecordCardAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
}
