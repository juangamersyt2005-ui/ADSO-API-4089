import '../../data/models/instructor.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class InstructorService {
  InstructorService({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  Future<ApiCollection<Instructor>> obtenerInstructores() {
    return _apiService.getCollection(
      ApiConstants.instructores,
      Instructor.fromJson,
    );
  }

  Future<void> crearInstructor(Map<String, Object?> datos) async {
    await _apiService.postJson(ApiConstants.instructores, datos);
  }

  Future<void> actualizarInstructor(
    String uuid,
    Map<String, Object?> datos,
  ) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('El instructor no tiene un UUID válido.');
    }
    await _apiService.putJson(
      '${ApiConstants.instructores}${Uri.encodeComponent(identifier)}',
      datos,
    );
  }

  Future<void> eliminarInstructor(String uuid) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('El instructor no tiene un UUID válido.');
    }
    await _apiService.delete(
      '${ApiConstants.instructores}${Uri.encodeComponent(identifier)}',
    );
  }
}
