import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../../core/services/curso_service.dart';
import '../../core/services/matricula_service.dart';
import '../../core/services/persona_service.dart';
import '../../data/models/curso.dart';
import '../../data/models/matricula.dart';
import '../../data/models/persona.dart';
import '../widgets/records_screen.dart';
import 'module_editor_configs.dart';
import 'related_collections.dart';

class MatriculasScreen extends StatefulWidget {
  const MatriculasScreen({super.key});

  @override
  State<MatriculasScreen> createState() => _MatriculasScreenState();
}

class _MatriculasScreenState extends State<MatriculasScreen> {
  final Map<int, String> _nombresCursos = {};
  final Map<int, String> _nombresPersonas = {};

  Future<ApiCollection<Matricula>> _cargarMatriculas() async {
    final cursosFuture = loadOptionalCollection(CursoService().obtenerCursos());
    final personasFuture = loadOptionalCollection(
      PersonaService().obtenerPersonas(),
    );
    final matriculas = await MatriculaService().obtenerMatriculas();
    final cursos = await cursosFuture;
    final personas = await personasFuture;

    _nombresCursos
      ..clear()
      ..addEntries(
        (cursos?.items ?? <Curso>[])
            .where((curso) => curso.id != null && curso.titulo.isNotEmpty)
            .map((curso) => MapEntry(curso.id!, curso.titulo)),
      );
    _nombresPersonas
      ..clear()
      ..addEntries(
        (personas?.items ?? <Persona>[])
            .where(
              (persona) =>
                  persona.id != null && persona.nombreCompleto.isNotEmpty,
            )
            .map((persona) => MapEntry(persona.id!, persona.nombreCompleto)),
      );

    return matriculas;
  }

  String _titulo(Matricula matricula) =>
      _nombresPersonas[matricula.personaId] ?? matricula.titulo;

  String _subtitulo(Matricula matricula) {
    final partes = [
      _nombresCursos[matricula.cursoId],
      matricula.estado,
      if (matricula.fecha?.isNotEmpty == true) 'Fecha ${matricula.fecha}',
    ].whereType<String>().toList();
    return partes.isEmpty ? 'Matrícula académica' : partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return RecordsScreen<Matricula>(
      title: 'Matrículas',
      icon: Icons.assignment_ind_outlined,
      loadRecords: _cargarMatriculas,
      titleFor: _titulo,
      subtitleFor: _subtitulo,
      detailsFor: (matricula) => [
        RecordDetailField('Curso', _nombresCursos[matricula.cursoId]),
        RecordDetailField('Estado', matricula.estado),
        RecordDetailField('Fecha', matricula.fecha),
      ],
      editorConfig: cargarEditorMatricula,
      createRecord: (values) => MatriculaService().crearMatricula(values),
      updateRecord: (matricula, values) =>
          MatriculaService().actualizarMatricula(matricula.uuid ?? '', values),
      canEdit: (matricula) => matricula.uuid?.trim().isNotEmpty == true,
      deleteRecord: (matricula) =>
          MatriculaService().eliminarMatricula(matricula.uuid ?? ''),
      canDelete: (matricula) => matricula.uuid?.trim().isNotEmpty == true,
    );
  }
}
