import '../../data/models/matricula.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class MatriculaService {
  MatriculaService({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  Future<ApiCollection<Matricula>> obtenerMatriculas() {
    return _apiService.getCollection(
      ApiConstants.matriculas,
      Matricula.fromJson,
    );
  }

  Future<void> crearMatricula(Map<String, Object?> datos) async {
    await _apiService.postJson(ApiConstants.matriculas, datos);
  }

  Future<void> actualizarMatricula(
    String uuid,
    Map<String, Object?> datos,
  ) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('La matrícula no tiene un UUID válido.');
    }
    await _apiService.putJson(
      '${ApiConstants.matriculas}${Uri.encodeComponent(identifier)}',
      datos,
    );
  }

  Future<void> eliminarMatricula(String uuid) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('La matrícula no tiene un UUID válido.');
    }
    await _apiService.delete(
      '${ApiConstants.matriculas}${Uri.encodeComponent(identifier)}',
    );
  }
}
