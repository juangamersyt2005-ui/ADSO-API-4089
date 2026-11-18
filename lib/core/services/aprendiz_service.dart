
import '../../data/models/aprendiz.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class AprendizService {
  AprendizService({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  Future<ApiCollection<Aprendiz>> obtenerAprendices() {
    return _apiService.getCollection(
      ApiConstants.aprendices,
      Aprendiz.fromJson,
    );
  }

  Future<void> eliminarAprendiz(String uuid) async {
    final identifier = uuid.trim();
    if (identifier.isEmpty) {
      throw const ApiException('El aprendiz no tiene un UUID válido.');
    }
    await _apiService.delete(
      '${ApiConstants.aprendices}${Uri.encodeComponent(identifier)}',
    );
  }
}
