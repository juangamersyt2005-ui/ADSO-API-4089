import 'package:adso4089_mobile/data/models/aprendiz.dart';
import 'package:adso4089_mobile/data/models/asignacion.dart';
import 'package:adso4089_mobile/data/models/curso.dart';
import 'package:adso4089_mobile/data/models/evaluacion.dart';
import 'package:adso4089_mobile/data/models/instructor.dart';
import 'package:adso4089_mobile/data/models/matricula.dart';
import 'package:adso4089_mobile/data/models/nota.dart';
import 'package:adso4089_mobile/data/models/persona.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Modelos basados en los campos GET observados', () {
    test('Aprendiz conserva la fecha y convierte APR_PER_ID anidado', () {
      final aprendiz = Aprendiz.fromJson({
        'APR_FECHA_NAC': 'Wed, 15 May 2002 00:00:00 GMT',
        'APR_ID': 1,
        'APR_PER_ID': {
          'apellidos': 'Martinez Lopez',
          'cedula': '1001001001',
          'nombres': 'Juan Diego',
        },
      });

      expect(aprendiz.id, 1);
      expect(aprendiz.fechaNacimiento, 'Wed, 15 May 2002 00:00:00 GMT');
      expect(aprendiz.persona?.nombreCompleto, 'Juan Diego Martinez Lopez');
      expect(aprendiz.persona?.cedula, '1001001001');
    });

    test('Persona interpreta los nombres reales del endpoint', () {
      final persona = Persona.fromJson({
        'PER_DOCUMENTO': '1001001001',
        'PER_ID': 4,
        'PER_PRI_APELLIDO': 'Martinez',
        'PER_PRI_NOMBRE': 'Juan',
        'PER_SEG_APELLIDO': 'Lopez',
        'PER_SEG_NOMBRE': 'Diego',
      });

      expect(persona.nombreCompleto, 'Juan Diego Martinez Lopez');
      expect(persona.documento, '1001001001');
    });

    test('Curso conserva costo texto y duración numérica', () {
      final curso = Curso.fromJson({
        'CUR_CODIGO': 'ADSO-01',
        'CUR_COSTO': '0',
        'CUR_DESCRIPCION': 'Curso de formación',
        'CUR_DURACION': 24,
        'CUR_ID': 2,
        'CUR_NOMBRE': 'Análisis de software',
      });

      expect(curso.nombre, 'Análisis de software');
      expect(curso.duracion, 24);
      expect(curso.costo, '0');
    });

    test('Instructor interpreta la referencia de persona como identificador', () {
      final instructor = Instructor.fromJson({
        'INS_ESPECIALIDAD': 'Desarrollo',
        'INS_ID': 3,
        'INS_PER_ID': 4,
      });

      expect(instructor.personaId, 4);
      expect(instructor.especialidad, 'Desarrollo');
    });

    test('Asignación interpreta curso, instructor y fechas', () {
      final asignacion = Asignacion.fromJson({
        'IMP_CUR_ID': 2,
        'IMP_FECHA': '2026-01-15',
        'IMP_FECHA_ASIGNACION': '2026-01-10',
        'IMP_ID': 1,
        'IMP_INS_ID': 3,
        'IMP_ROL': 'Principal',
      });

      expect(asignacion.cursoId, 2);
      expect(asignacion.instructorId, 3);
      expect(asignacion.rol, 'Principal');
    });

    test('Matrícula interpreta sus relaciones y estado', () {
      final matricula = Matricula.fromJson({
        'MAT_CUR_ID': 2,
        'MAT_ESTADO': 'Activa',
        'MAT_FECHA': '2026-01-12',
        'MAT_ID': 7,
        'MAT_PER_ID': 4,
      });

      expect(matricula.cursoId, 2);
      expect(matricula.personaId, 4);
      expect(matricula.estado, 'Activa');
    });

    test('Evaluación conserva porcentaje texto de la API', () {
      final evaluacion = Evaluacion.fromJson({
        'EVA_CODIGO': 'EV-01',
        'EVA_FECHA': '2026-02-01',
        'EVA_ID': 5,
        'EVA_NOMBRE': 'Proyecto',
        'EVA_PORCENTAJE': '30.00',
      });

      expect(evaluacion.porcentaje, '30.00');
      expect(evaluacion.titulo, 'Proyecto');
    });

    test('Nota interpreta evaluación, matrícula y valor', () {
      final nota = Nota.fromJson({
        'MATE_EVA_ID': 5,
        'MATE_ID': 11,
        'MATE_MAT_ID': 7,
        'MATE_NOTA': '4.5',
      });

      expect(nota.id, 11);
      expect(nota.evaluacionId, 5);
      expect(nota.matriculaId, 7);
      expect(nota.valor, '4.5');
    });
  });
}
