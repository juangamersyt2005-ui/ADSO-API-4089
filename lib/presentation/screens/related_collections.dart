import '../../core/services/api_service.dart';

Future<ApiCollection<T>?> loadOptionalCollection<T>(
  Future<ApiCollection<T>> request,
) async {
  try {
    return await request;
  } catch (_) {
    return null;
  }
}
