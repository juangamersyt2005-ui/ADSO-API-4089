import '../../data/models/nota.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class NotaService {
  NotaService({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  Future<ApiCollection<Nota>> obtenerNotas() {
    return _apiService.getCollection(ApiConstants.notas, Nota.fromJson);
  }

  Future<void> crearNota(Map<String, Object?> datos) async {
    await _apiService.postJson(ApiConstants.notas, datos);
  }

  Future<void> actualizarNota(String uuid, Map<String, Object?> datos) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('La nota no tiene un UUID válido.');
    }
    await _apiService.putJson(
      '${ApiConstants.notas}${Uri.encodeComponent(identifier)}',
      datos,
    );
  }

  Future<void> eliminarNota(String uuid) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('La nota no tiene un UUID válido.');
    }
    await _apiService.delete(
      '${ApiConstants.notas}${Uri.encodeComponent(identifier)}',
    );
  }
}
