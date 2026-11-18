import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

typedef JsonModelFactory<T> = T Function(Map<String, dynamic> json);

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiCollection<T> {
  const ApiCollection({required this.items, required this.count});

  final List<T> items;

  /// Es el Count informado por la API o, si no existe, el número recibido.
  final int count;
}

class ApiService {
  ApiService({http.Client? client, this.timeout = const Duration(seconds: 20)})
    : _client = client ?? http.Client();

  static final ApiService instance = ApiService();

  final http.Client _client;
  final Duration timeout;

  static const _jsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<dynamic> getJson(String endpoint) {
    return _request(
      endpoint,
      (url) => _client.get(url, headers: const {'Accept': 'application/json'}),
    );
  }

  Future<dynamic> postJson(String endpoint, Map<String, Object?> body) {
    return _request(
      endpoint,
      (url) => _client.post(url, headers: _jsonHeaders, body: jsonEncode(body)),
    );
  }

  Future<dynamic> putJson(String endpoint, Map<String, Object?> body) {
    return _request(
      endpoint,
      (url) => _client.put(url, headers: _jsonHeaders, body: jsonEncode(body)),
    );
  }

  Future<void> delete(String endpoint) async {
    await _request(
      endpoint,
      (url) =>
          _client.delete(url, headers: const {'Accept': 'application/json'}),
      decodeJson: false,
    );
  }

  Future<dynamic> _request(
    String endpoint,
    Future<http.Response> Function(Uri url) send, {
    bool decodeJson = true,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await send(url).timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final detail = _errorDetail(response);
        throw ApiException(
          'Error HTTP ${response.statusCode} al realizar la solicitud a '
          '$endpoint${detail == null ? '.' : ': $detail'}',
        );
      }

      if (!decodeJson || response.bodyBytes.isEmpty) {
        return null;
      }

      return jsonDecode(utf8.decode(response.bodyBytes));
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        'La solicitud a la API excedió el tiempo de espera de '
        '${timeout.inSeconds} segundos.',
      );
    } on FormatException catch (error) {
      throw ApiException('La URL o la respuesta JSON no es válida: $error');
    } on http.ClientException catch (error) {
      throw ApiException(
        'Error de red al comunicarse con la API: ${error.message}',
      );
    } catch (error) {
      throw ApiException('No se pudo completar la solicitud a la API: $error');
    }
  }

  String? _errorDetail(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;

    final body = utf8.decode(response.bodyBytes, allowMalformed: true).trim();
    if (body.isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        for (final key in const ['error', 'mensaje', 'message', 'detail']) {
          final value = decoded[key]?.toString().trim();
          if (value != null && value.isNotEmpty) return value;
        }
      }
    } on FormatException {
      // Algunas respuestas de error son texto plano.
    }

    return body.length <= 240 ? body : '${body.substring(0, 237)}...';
  }

  Future<ApiCollection<T>> getCollection<T>(
    String endpoint,
    JsonModelFactory<T> fromJson,
  ) async {
    final payload = await getJson(endpoint);
    return parseCollection(payload, fromJson);
  }

  ApiCollection<T> parseCollection<T>(
    dynamic payload,
    JsonModelFactory<T> fromJson,
  ) {
    late final List<dynamic> records;
    int? reportedCount;

    if (payload is List) {
      records = payload;
    } else if (payload is Map<String, dynamic>) {
      final value = payload['value'];
      final data = payload['data'];
      if (value is List) {
        records = value;
      } else if (data is List) {
        records = data;
      } else {
        throw const FormatException(
          'La respuesta de la API no contiene una lista de registros.',
        );
      }

      final rawCount = payload['Count'] ?? payload['count'];
      if (rawCount is num) {
        reportedCount = rawCount.toInt();
      } else {
        reportedCount = int.tryParse(rawCount?.toString() ?? '');
      }
    } else {
      throw const FormatException(
        'La respuesta de la API debe ser una lista o un objeto con una lista.',
      );
    }

    final items = <T>[];
    for (final record in records) {
      if (record is! Map) {
        throw const FormatException(
          'Un registro de la respuesta no tiene el formato de objeto JSON.',
        );
      }
      items.add(fromJson(Map<String, dynamic>.from(record)));
    }

    return ApiCollection<T>(
      items: List.unmodifiable(items),
      count: reportedCount ?? items.length,
    );
  }
}
