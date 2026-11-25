import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/services/aprendiz_service.dart';
import '../../core/services/asignacion_service.dart';
import '../../core/services/curso_service.dart';
import '../../core/services/evaluacion_service.dart';
import '../../core/services/instructor_service.dart';
import '../../core/services/matricula_service.dart';
import '../../core/services/nota_service.dart';
import '../../core/services/persona_service.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_chrome.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final List<_DashboardModule> _modules = [
    _DashboardModule(
      title: 'Aprendices',
      icon: Icons.people_outline,
      route: AppRoutes.aprendices,
      accent: AppTheme.primary,
      loadCount: () async =>
          (await AprendizService().obtenerAprendices()).count,
    ),
    _DashboardModule(
      title: 'Cursos',
      icon: Icons.school_outlined,
      route: AppRoutes.cursos,
      accent: AppTheme.secondary,
      loadCount: () async => (await CursoService().obtenerCursos()).count,
    ),
    _DashboardModule(
      title: 'Instructores',
      icon: Icons.co_present_outlined,
      route: AppRoutes.instructores,
      accent: AppTheme.success,
      loadCount: () async =>
          (await InstructorService().obtenerInstructores()).count,
    ),
    _DashboardModule(
      title: 'Matrículas',
      icon: Icons.how_to_reg_outlined,
      route: AppRoutes.matriculas,
      accent: AppTheme.primarySoft,
      loadCount: () async =>
          (await MatriculaService().obtenerMatriculas()).count,
    ),
    _DashboardModule(
      title: 'Personas',
      icon: Icons.badge_outlined,
      route: AppRoutes.personas,
      accent: AppTheme.primarySoft,
      loadCount: () async => (await PersonaService().obtenerPersonas()).count,
    ),
    _DashboardModule(
      title: 'Asignaciones',
      icon: Icons.assignment_outlined,
      route: AppRoutes.asignaciones,
      accent: AppTheme.secondary,
      loadCount: () async =>
          (await AsignacionService().obtenerAsignaciones()).count,
    ),
    _DashboardModule(
      title: 'Evaluaciones',
      icon: Icons.fact_check_outlined,
      route: AppRoutes.evaluaciones,
      accent: AppTheme.danger,
      loadCount: () async =>
          (await EvaluacionService().obtenerEvaluaciones()).count,
    ),
    _DashboardModule(
      title: 'Notas',
      icon: Icons.edit_note_outlined,
      route: AppRoutes.notas,
      accent: AppTheme.primary,
      loadCount: () async => (await NotaService().obtenerNotas()).count,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  Map<String, _ModuleStatus> _statuses = const {};
  DateTime? _lastUpdated;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCounts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ApiConnectionStatus get _connectionStatus {
    if (_loading) return ApiConnectionStatus.connecting;
    if (_statuses.isEmpty) return ApiConnectionStatus.unknown;

    final failed = _statuses.values
        .where((status) => status.error != null)
        .length;
    if (failed == 0) return ApiConnectionStatus.connected;
    if (failed == _statuses.length) return ApiConnectionStatus.offline;
    return ApiConnectionStatus.partial;
  }

  Future<void> _loadCounts() async {
    if (mounted) setState(() => _loading = true);

    final results = await Future.wait(
      _modules.map((module) async {
        try {
          return MapEntry(
            module.route,
            _ModuleStatus(count: await module.loadCount()),
          );
        } catch (error) {
          return MapEntry(module.route, _ModuleStatus(error: error.toString()));
        }
      }),
    );

    if (!mounted) return;
    setState(() {
      _statuses = Map.fromEntries(results);
      _lastUpdated = DateTime.now();
      _loading = false;
    });
  }

  String get _updatedLabel {
    final lastUpdated = _lastUpdated;
    if (lastUpdated == null) return 'Consultando API';
    final minutes = DateTime.now().difference(lastUpdated).inMinutes;
    if (minutes < 1) return 'Actualizado ahora';
    if (minutes == 1) return 'Actualizado hace 1 min';
    return 'Actualizado hace $minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final moduleResults = _modules
        .where((module) => module.title.toLowerCase().contains(query))
        .toList(growable: false);

    return Scaffold(
      appBar: BrandHeader(
        status: _connectionStatus,
        onProfileTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.configuracion),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(selectedIndex: 0),
      body: RefreshIndicator(
        onRefresh: _loadCounts,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 4 : 2;
            final crossSpacing = 12.0;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Panel de Control',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: AppTheme.text,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sincronización con la base de datos académica',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.muted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Consultar API',
                        onPressed: _loading ? null : _loadCounts,
                        icon: _loading
                            ? const SizedBox.square(
                                dimension: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.bolt_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar módulo',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpiar búsqueda',
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _QuickAction(
                        label: 'Nuevo\nAprendiz',
                        icon: Icons.person_add_alt_1_outlined,
                        color: AppTheme.primary,
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AppRoutes.nuevoAprendiz);
                        },
                      ),
                      const SizedBox(width: 8),
                      _QuickAction(
                        label: 'Registrar\nNota',
                        icon: Icons.edit_note_outlined,
                        color: AppTheme.secondary,
                        foreground: Colors.white,
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.nuevaNota);
                        },
                      ),
                      const SizedBox(width: 8),
                      _QuickAction(
                        label: 'Consultar\nAPI',
                        icon: Icons.sync,
                        color: AppTheme.success,
                        foreground: Colors.white,
                        onTap: _loading ? null : _loadCounts,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Métricas Académicas',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Icon(
                        Icons.schedule,
                        size: 15,
                        color: AppTheme.primarySoft,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _updatedLabel,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AppTheme.primarySoft),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: crossSpacing,
                      mainAxisSpacing: crossSpacing,
                      childAspectRatio: 1.08,
                    ),
                    itemBuilder: (context, index) => _MetricCard(
                      module: _modules[index],
                      status: _statuses[_modules[index].route],
                      isLoading: _loading,
                      onTap: () =>
                          Navigator.of(context)
                              .pushNamed(_modules[index].route),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _EvaluationCard(
                    module: _modules[6],
                    status: _statuses[_modules[6].route],
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.evaluaciones),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          query.isEmpty ? 'Otros módulos' : 'Resultados',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (query.isEmpty)
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.configuracion),
                          child: const Text('Ver todos'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (query.isEmpty)
                    for (final module in _modules.skip(4))
                      _ModuleListTile(
                        module: module,
                        status: _statuses[module.route],
                        onTap: () =>
                            Navigator.of(context).pushNamed(module.route),
                      )
                  else if (moduleResults.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No hay módulos con ese nombre.',
                        style: TextStyle(color: AppTheme.muted),
                      ),
                    )
                  else
                    for (final module in moduleResults)
                      _ModuleListTile(
                        module: module,
                        status: _statuses[module.route],
                        onTap: () =>
                            Navigator.of(context).pushNamed(module.route),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.foreground = const Color(0xFF0D0096),
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 106,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 11),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: foreground, size: 22),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.module,
    required this.status,
    required this.isLoading,
    required this.onTap,
  });

  final _DashboardModule module;
  final _ModuleStatus? status;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      color: module.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      module.icon,
                      color: module.accent == AppTheme.primarySoft
                          ? const Color(0xFF1000A9)
                          : Colors.white,
                      size: 21,
                    ),
                  ),
                  const Spacer(),
                  if (status?.error != null)
                    const Icon(
                      Icons.error_outline,
                      size: 18,
                      color: Color(0xFFFFB4AB),
                    )
                  else if (status?.count != null)
                    Icon(
                      Icons.check_circle,
                      size: 17,
                      color: AppTheme.success.withValues(alpha: 0.95),
                    ),
                ],
              ),
              const Spacer(),
              if (isLoading && status?.count == null)
                const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  status?.count?.toString() ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 3),
              Text(
                module.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EvaluationCard extends StatelessWidget {
  const _EvaluationCard({
    required this.module,
    required this.status,
    required this.onTap,
  });

  final _DashboardModule module;
  final _ModuleStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.danger,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.fact_check_outlined, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evaluaciones registradas',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    status?.count == null
                        ? 'Consultando el módulo…'
                        : '${status!.count} registros disponibles',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppTheme.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(onPressed: onTap, child: const Text('Ver')),
          ],
        ),
      ),
    );
  }
}

class _ModuleListTile extends StatelessWidget {
  const _ModuleListTile({
    required this.module,
    required this.status,
    required this.onTap,
  });

  final _DashboardModule module;
  final _ModuleStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: module.accent.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(module.icon, color: module.accent, size: 21),
        ),
        title: Text(module.title),
        subtitle: Text(
          status?.error != null ? 'No disponible' : 'Registros en la API',
          style: const TextStyle(color: AppTheme.muted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status?.count?.toString() ?? '—',
              style: const TextStyle(
                color: AppTheme.primarySoft,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _DashboardModule {
  const _DashboardModule({
    required this.title,
    required this.icon,
    required this.route,
    required this.accent,
    required this.loadCount,
  });

  final String title;
  final IconData icon;
  final String route;
  final Color accent;
  final Future<int> Function() loadCount;
}

class _ModuleStatus {
  const _ModuleStatus({this.count, this.error});

  final int? count;
  final String? error;
}
