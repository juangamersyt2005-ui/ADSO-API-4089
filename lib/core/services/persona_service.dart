import '../../data/models/persona.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class PersonaService {
  PersonaService({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  Future<ApiCollection<Persona>> obtenerPersonas() {
    return _apiService.getCollection(ApiConstants.personas, Persona.fromJson);
  }

  Future<void> crearPersona(Map<String, Object?> datos) async {
    await _apiService.postJson(ApiConstants.personas, datos);
  }

  Future<void> actualizarPersona(
    String uuid,
    Map<String, Object?> datos,
  ) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('La persona no tiene un UUID válido.');
    }
    await _apiService.putJson(
      '${ApiConstants.personas}${Uri.encodeComponent(identifier)}',
      datos,
    );
  }

  Future<void> eliminarPersona(String uuid) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('La persona no tiene un UUID válido.');
    }
    await _apiService.delete(
      '${ApiConstants.personas}${Uri.encodeComponent(identifier)}',
    );
  }
}
