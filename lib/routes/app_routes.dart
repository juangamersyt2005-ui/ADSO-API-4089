import 'package:material_ui/material_ui.dart';

import '../presentation/screens/aprendices_screen.dart';
import '../presentation/screens/asignaciones_screen.dart';
import '../presentation/screens/cursos_screen.dart';
import '../presentation/screens/evaluaciones_screen.dart';
import '../presentation/screens/instructores_screen.dart';
import '../presentation/screens/matriculas_screen.dart';
import '../presentation/screens/notas_screen.dart';
import '../presentation/screens/personas_screen.dart';
import '../presentation/screens/asistencia_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String aprendices = '/aprendices';
  static const String personas = '/personas';
  static const String cursos = '/cursos';
  static const String instructores = '/instructores';
  static const String asignaciones = '/asignaciones';
  static const String matriculas = '/matriculas';
  static const String evaluaciones = '/evaluaciones';
  static const String notas = '/notas';
  static const String asistencias = '/asistencias';

  static final Map<String, WidgetBuilder> _routes = {
    aprendices: (_) => const AprendicesScreen(),
    personas: (_) => const PersonasScreen(),
    cursos: (_) => const CursosScreen(),
    instructores: (_) => const InstructoresScreen(),
    asignaciones: (_) => const AsignacionesScreen(),
    matriculas: (_) => const MatriculasScreen(),
    evaluaciones: (_) => const EvaluacionesScreen(),
    notas: (_) => const NotasScreen(),
    asistencias: (_) => const AsistenciaScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = _routes[settings.name];
    if (builder == null) return null;
    return MaterialPageRoute<void>(
      builder: builder,
      settings: settings,
    );
  }
}
