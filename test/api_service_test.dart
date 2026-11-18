import 'dart:convert';

import 'package:adso4089_mobile/core/services/api_service.dart';
import 'package:adso4089_mobile/core/services/aprendiz_service.dart';
import 'package:adso4089_mobile/core/services/asignacion_service.dart';
import 'package:adso4089_mobile/core/services/curso_service.dart';
import 'package:adso4089_mobile/core/services/evaluacion_service.dart';
import 'package:adso4089_mobile/core/services/instructor_service.dart';
import 'package:adso4089_mobile/core/services/matricula_service.dart';
import 'package:adso4089_mobile/core/services/nota_service.dart';
import 'package:adso4089_mobile/core/services/persona_service.dart';
import 'package:adso4089_mobile/data/models/aprendiz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiService y AprendizService', () {
    test(
      'lee arreglos JSON directos y cuenta los registros recibidos',
      () async {
        late final MockClient client;
        client = MockClient((request) async {
          expect(request.url.path, '/aprendices/');
          expect(request.headers['accept'], 'application/json');
          return http.Response(
            jsonEncode([
              {
                'APR_ID': 1,
                'APR_FECHA_NAC': 'Wed, 15 May 2002 00:00:00 GMT',
                'APR_PER_ID': {
                  'nombres': 'Juan Diego',
                  'apellidos': 'Martinez Lopez',
                  'cedula': '1001001001',
                },
              },
            ]),
            200,
          );
        });
        addTearDown(client.close);

        final service = AprendizService(apiService: ApiService(client: client));
        final result = await service.obtenerAprendices();

        expect(result.count, 1);
        expect(result.items, hasLength(1));
        expect(result.items.single, isA<Aprendiz>());
        expect(
          result.items.single.persona?.nombreCompleto,
          'Juan Diego Martinez Lopez',
        );
      },
    );

    test('cada servicio consulta la ruta configurada para su módulo', () async {
      final expectedPaths = {
        '/aprendices/',
        '/personas/',
        '/cursos/',
        '/instructores/',
        '/imparte/',
        '/matriculas/',
        '/evaluaciones/',
        '/materia-evalua/',
      };
      final receivedPaths = <String>[];
      final client = MockClient((request) async {
        receivedPaths.add(request.url.path);
        return http.Response('[]', 200);
      });
      final apiService = ApiService(client: client);
      addTearDown(client.close);

      await Future.wait([
        AprendizService(apiService: apiService).obtenerAprendices(),
        PersonaService(apiService: apiService).obtenerPersonas(),
        CursoService(apiService: apiService).obtenerCursos(),
        InstructorService(apiService: apiService).obtenerInstructores(),
        AsignacionService(apiService: apiService).obtenerAsignaciones(),
        MatriculaService(apiService: apiService).obtenerMatriculas(),
        EvaluacionService(apiService: apiService).obtenerEvaluaciones(),
        NotaService(apiService: apiService).obtenerNotas(),
      ]);

      expect(receivedPaths.toSet(), expectedPaths);
      expect(receivedPaths, hasLength(expectedPaths.length));
    });

    test(
      'conserva Count cuando la respuesta usa el envoltorio value',
      () async {
        final client = MockClient(
          (_) async => http.Response(
            jsonEncode({
              'value': [
                {
                  'APR_ID': 1,
                  'APR_PER_ID': {
                    'nombres': 'Juan',
                    'apellidos': 'Martinez',
                    'cedula': '1001001001',
                  },
                },
              ],
              'Count': 2,
            }),
            200,
          ),
        );
        final service = ApiService(client: client);
        addTearDown(client.close);

        final result = await service.getCollection(
          '/aprendices/',
          Aprendiz.fromJson,
        );

        expect(result.items, hasLength(1));
        expect(result.count, 2);
      },
    );

    test('envía DELETE al UUID del registro y acepta respuesta 204', () async {
      const uuid = 'aaaaaaaa-1111-1111-1111-aaaaaaaaaaaa';
      final client = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/aprendices/$uuid');
        return http.Response('', 204);
      });
      final service = AprendizService(apiService: ApiService(client: client));
      addTearDown(client.close);

      await service.eliminarAprendiz(uuid);
    });

    test('envía POST JSON con el contrato de aprendiz', () async {
      const payload = {'fecha_nac': '2002-05-15', 'per_id': 4};
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/aprendices/');
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body), payload);
        return http.Response('{"APR_ID":10}', 201);
      });
      final service = AprendizService(apiService: ApiService(client: client));
      addTearDown(client.close);

      await service.crearAprendiz(payload);
    });

    test('envía PUT JSON al UUID con el contrato de aprendiz', () async {
      const uuid = 'aaaaaaaa-1111-1111-1111-aaaaaaaaaaaa';
      const payload = {'fecha_nac': '2002-05-15', 'per_id': 4};
      final client = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.path, '/aprendices/$uuid');
        expect(jsonDecode(request.body), payload);
        return http.Response('{"mensaje":"Aprendiz actualizado"}', 200);
      });
      final service = AprendizService(apiService: ApiService(client: client));
      addTearDown(client.close);

      await service.actualizarAprendiz(uuid, payload);
    });

    test('normaliza errores HTTP a ApiException', () async {
      final client = MockClient((_) async => http.Response('error', 503));
      final service = ApiService(client: client);
      addTearDown(client.close);

      await expectLater(
        service.getJson('/aprendices/'),
        throwsA(isA<ApiException>()),
      );
    });

    test('incluye la validación enviada por la API en el error HTTP', () async {
      final client = MockClient(
        (_) async => http.Response('{"error":"Documento duplicado"}', 400),
      );
      final service = ApiService(client: client);
      addTearDown(client.close);

      await expectLater(
        service.postJson('/personas/', const {'documento': '1001'}),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            contains('Documento duplicado'),
          ),
        ),
      );
    });

    test('convierte el timeout en un error comprensible', () async {
      final client = MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return http.Response('[]', 200);
      });
      final service = ApiService(
        client: client,
        timeout: const Duration(milliseconds: 1),
      );
      addTearDown(client.close);

      await expectLater(
        service.getJson('/aprendices/'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            contains('tiempo de espera'),
          ),
        ),
      );
    });

    test('rechaza registros con forma JSON inesperada', () {
      final client = MockClient((_) async => http.Response('[]', 200));
      final service = ApiService(client: client);
      addTearDown(client.close);
      final invalid = {
        'value': ['no es un objeto'],
      };

      expect(
        () => service.parseCollection(invalid, Aprendiz.fromJson),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
