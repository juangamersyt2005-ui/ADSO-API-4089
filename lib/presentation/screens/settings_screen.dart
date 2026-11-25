import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/app_chrome.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _modules = <_SettingsModule>[
    _SettingsModule(
      title: 'Personas',
      subtitle: 'Datos de identificación y contacto',
      route: '/personas',
      icon: Icons.badge_outlined,
    ),
    _SettingsModule(
      title: 'Instructores',
      subtitle: 'Especialidades y datos relacionados',
      route: '/instructores',
      icon: Icons.co_present_outlined,
    ),
    _SettingsModule(
      title: 'Asignaciones',
      subtitle: 'Relaciones entre cursos e instructores',
      route: '/asignaciones',
      icon: Icons.assignment_outlined,
    ),
    _SettingsModule(
      title: 'Matrículas',
      subtitle: 'Personas inscritas en cada curso',
      route: '/matriculas',
      icon: Icons.how_to_reg_outlined,
    ),
    _SettingsModule(
      title: 'Evaluaciones',
      subtitle: 'Fechas, códigos y porcentajes',
      route: '/evaluaciones',
      icon: Icons.fact_check_outlined,
    ),
    _SettingsModule(
      title: 'Notas',
      subtitle: 'Calificaciones de las evaluaciones',
      route: '/notas',
      icon: Icons.grade_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandHeader(status: ApiConnectionStatus.unknown),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 3),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Text(
            'Configuración',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: AppTheme.text, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Accesos a los módulos de gestión académica.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppTheme.muted),
          ),
          const SizedBox(height: 22),
          Text(
            'Módulos adicionales',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          for (final module in _modules) ...[
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.cardHigh,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(module.icon, color: AppTheme.primarySoft),
                ),
                title: Text(
                  module.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  module.subtitle,
                  style: const TextStyle(color: AppTheme.muted),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed(module.route),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
          Card(
            color: AppTheme.surface,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.cloud_outlined, color: AppTheme.primarySoft),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Los registros se consultan y guardan mediante la API académica.',
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsModule {
  const _SettingsModule({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
}
