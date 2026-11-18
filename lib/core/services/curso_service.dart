import '../../data/models/curso.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class CursoService {
  CursoService({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  Future<ApiCollection<Curso>> obtenerCursos() {
    return _apiService.getCollection(ApiConstants.cursos, Curso.fromJson);
  }

  Future<void> crearCurso(Map<String, Object?> datos) async {
    await _apiService.postJson(ApiConstants.cursos, datos);
  }

  Future<void> actualizarCurso(String uuid, Map<String, Object?> datos) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('El curso no tiene un UUID válido.');
    }
    await _apiService.putJson(
      '${ApiConstants.cursos}${Uri.encodeComponent(identifier)}',
      datos,
    );
  }

  Future<void> eliminarCurso(String uuid) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('El curso no tiene un UUID válido.');
    }
    await _apiService.delete(
      '${ApiConstants.cursos}${Uri.encodeComponent(identifier)}',
    );
  }
}
