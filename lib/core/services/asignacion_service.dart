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
