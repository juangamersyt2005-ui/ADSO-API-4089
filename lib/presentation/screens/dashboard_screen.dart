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
import '../widgets/module_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final List<_ModuleDefinition> _modules = [
    _ModuleDefinition(
      title: 'Aprendices',
      icon: Icons.school_outlined,
      route: AppRoutes.aprendices,
      loadCount: () async => (await AprendizService().obtenerAprendices()).count,
    ),
    _ModuleDefinition(
      title: 'Personas',
      icon: Icons.people_outline,
      route: AppRoutes.personas,
      loadCount: () async => (await PersonaService().obtenerPersonas()).count,
    ),
    _ModuleDefinition(
      title: 'Cursos',
      icon: Icons.menu_book_outlined,
      route: AppRoutes.cursos,
      loadCount: () async => (await CursoService().obtenerCursos()).count,
    ),
    _ModuleDefinition(
      title: 'Instructores',
      icon: Icons.co_present_outlined,
      route: AppRoutes.instructores,
      loadCount: () async => (await InstructorService().obtenerInstructores()).count,
    ),
    _ModuleDefinition(
      title: 'Asignaciones',
      icon: Icons.assignment_outlined,
      route: AppRoutes.asignaciones,
      loadCount: () async => (await AsignacionService().obtenerAsignaciones()).count,
    ),
    _ModuleDefinition(
      title: 'Matrículas',
      icon: Icons.assignment_ind_outlined,
      route: AppRoutes.matriculas,
      loadCount: () async => (await MatriculaService().obtenerMatriculas()).count,
    ),
    _ModuleDefinition(
      title: 'Evaluaciones',
      icon: Icons.fact_check_outlined,
      route: AppRoutes.evaluaciones,
      loadCount: () async =>
          (await EvaluacionService().obtenerEvaluaciones()).count,
    ),
    _ModuleDefinition(
      title: 'Notas',
      icon: Icons.grade_outlined,
      route: AppRoutes.notas,
      loadCount: () async => (await NotaService().obtenerNotas()).count,
    ),
  ];

  Map<String, _ModuleStatus> _statuses = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCounts());
  }

  Future<void> _loadCounts({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() => _loading = true);
    }

    final results = await Future.wait(
      _modules.map((module) async {
        try {
          return MapEntry(
            module.route,
            _ModuleStatus(count: await module.loadCount()),
          );
        } catch (error) {
          return MapEntry(
            module.route,
            _ModuleStatus(error: error.toString()),
          );
        }
      }),
    );

    if (!mounted) return;
    setState(() {
      _statuses = Map.fromEntries(results);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADSO4089'),
        actions: [
          IconButton(
            tooltip: 'Actualizar cantidades',
            onPressed: () => unawaited(_loadCounts(showLoading: true)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCounts,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760
                ? 3
                : constraints.maxWidth >= 390
                    ? 2
                    : 1;
            final childAspectRatio = columns == 1 ? 2.1 : 1.1;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panel principal',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.dark,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gestión académica',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                  const SizedBox(height: 20),
                  if (!_loading && _statuses.values.any((status) => status.error != null))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Algunas cantidades no están disponibles. Puedes actualizar para intentarlo de nuevo.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _modules.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final module = _modules[index];
                      final status = _statuses[module.route];
                      return ModuleCard(
                        title: module.title,
                        icon: module.icon,
                        count: status?.count,
                        isLoading: _loading || status == null,
                        hasError: status?.error != null,
                        onTap: () => Navigator.of(context).pushNamed(module.route),
                      );
                    },
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

class _ModuleDefinition {
  const _ModuleDefinition({
    required this.title,
    required this.icon,
    required this.route,
    required this.loadCount,
  });

  final String title;
  final IconData icon;
  final String route;
  final Future<int> Function() loadCount;
}

class _ModuleStatus {
  const _ModuleStatus({
    this.count,
    this.error,
  });

  final int? count;
  final String? error;
}
