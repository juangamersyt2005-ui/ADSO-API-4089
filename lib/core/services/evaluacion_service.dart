import '../../data/models/evaluacion.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class EvaluacionService {
  EvaluacionService({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  Future<ApiCollection<Evaluacion>> obtenerEvaluaciones() {
    return _apiService.getCollection(
      ApiConstants.evaluaciones,
      Evaluacion.fromJson,
    );
  }

  Future<void> crearEvaluacion(Map<String, Object?> datos) async {
    await _apiService.postJson(ApiConstants.evaluaciones, datos);
  }

  Future<void> actualizarEvaluacion(
    String uuid,
    Map<String, Object?> datos,
  ) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('La evaluación no tiene un UUID válido.');
    }
    await _apiService.putJson(
      '${ApiConstants.evaluaciones}${Uri.encodeComponent(identifier)}',
      datos,
    );
  }

  Future<void> eliminarEvaluacion(String uuid) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('La evaluación no tiene un UUID válido.');
    }
    await _apiService.delete(
      '${ApiConstants.evaluaciones}${Uri.encodeComponent(identifier)}',
    );
  }
}
