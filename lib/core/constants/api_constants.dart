
class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://adso3294089.onrender.com',
  );

  static const String aprendices = '/aprendices/';
  static const String personas = '/personas/';
  static const String cursos = '/cursos/';
  static const String instructores = '/instructores/';
  static const String asignaciones = '/imparte/';
  static const String matriculas = '/matriculas/';
  static const String evaluaciones = '/evaluaciones/';
  static const String notas = '/materia-evalua/';
}
