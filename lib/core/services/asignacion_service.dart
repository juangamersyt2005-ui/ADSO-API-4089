import '../../data/models/asignacion.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class AsignacionService {
  AsignacionService({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  Future<ApiCollection<Asignacion>> obtenerAsignaciones() {
    return _apiService.getCollection(
      ApiConstants.asignaciones,
      Asignacion.fromJson,
    );
  }

  Future<void> crearAsignacion(Map<String, Object?> datos) async {
    await _apiService.postJson(ApiConstants.asignaciones, datos);
  }

  Future<void> actualizarAsignacion(
    String uuid,
    Map<String, Object?> datos,
  ) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('La asignación no tiene un UUID válido.');
    }
    await _apiService.putJson(
      '${ApiConstants.asignaciones}${Uri.encodeComponent(identifier)}',
      datos,
    );
  }

  Future<void> eliminarAsignacion(String uuid) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('La asignación no tiene un UUID válido.');
    }
    await _apiService.delete(
      '${ApiConstants.asignaciones}${Uri.encodeComponent(identifier)}',
    );
  }
}
