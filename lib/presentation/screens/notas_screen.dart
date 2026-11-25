import 'package:material_ui/material_ui.dart';

import '../../core/services/api_service.dart';
import '../../core/services/curso_service.dart';
import '../../core/services/evaluacion_service.dart';
import '../../core/services/matricula_service.dart';
import '../../core/services/nota_service.dart';
import '../../core/services/persona_service.dart';
import '../../data/models/curso.dart';
import '../../data/models/evaluacion.dart';
import '../../data/models/matricula.dart';
import '../../data/models/nota.dart';
import '../../data/models/persona.dart';
import '../widgets/records_screen.dart';
import 'module_editor_configs.dart';
import 'related_collections.dart';

class NotasScreen extends StatefulWidget {
  const NotasScreen({this.openEditorOnStart = false, super.key});

  final bool openEditorOnStart;

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  final Map<int, String> _nombresEvaluaciones = {};
  final Map<int, String> _descripcionesMatriculas = {};

  Future<ApiCollection<Nota>> _cargarNotas() async {
    final evaluacionesFuture = loadOptionalCollection(
      EvaluacionService().obtenerEvaluaciones(),
    );
    final matriculasFuture = loadOptionalCollection(
      MatriculaService().obtenerMatriculas(),
    );
    final personasFuture = loadOptionalCollection(
      PersonaService().obtenerPersonas(),
    );
    final cursosFuture = loadOptionalCollection(CursoService().obtenerCursos());
    final notas = await NotaService().obtenerNotas();
    final evaluaciones = await evaluacionesFuture;
    final matriculas = await matriculasFuture;
    final personas = await personasFuture;
    final cursos = await cursosFuture;

    _nombresEvaluaciones
      ..clear()
      ..addEntries(
        (evaluaciones?.items ?? <Evaluacion>[])
            .where(
              (evaluacion) =>
                  evaluacion.id != null && evaluacion.titulo.isNotEmpty,
            )
            .map((evaluacion) => MapEntry(evaluacion.id!, evaluacion.titulo)),
      );

    final nombresPersonas = {
      for (final persona in (personas?.items ?? <Persona>[]))
        if (persona.id != null && persona.nombreCompleto.isNotEmpty)
          persona.id!: persona.nombreCompleto,
    };
    final nombresCursos = {
      for (final curso in (cursos?.items ?? <Curso>[]))
        if (curso.id != null && curso.titulo.isNotEmpty)
          curso.id!: curso.titulo,
    };
    _descripcionesMatriculas
      ..clear()
      ..addEntries(
        (matriculas?.items ?? <Matricula>[])
            .where((matricula) => matricula.id != null)
            .map((matricula) {
              final partes = [
                nombresPersonas[matricula.personaId],
                nombresCursos[matricula.cursoId],
              ].whereType<String>().toList();
              return MapEntry(
                matricula.id!,
                partes.isEmpty ? 'Matrícula académica' : partes.join(' · '),
              );
            }),
      );

    return notas;
  }

  String _titulo(Nota nota) =>
      _nombresEvaluaciones[nota.evaluacionId] ?? nota.titulo;

  String _subtitulo(Nota nota) {
    final partes = [
      if (nota.valor?.isNotEmpty == true) 'Nota ${nota.valor}',
      _descripcionesMatriculas[nota.matriculaId],
    ].whereType<String>().toList();
    return partes.isEmpty ? 'Calificación registrada' : partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return RecordsScreen<Nota>(
      title: 'Notas',
      icon: Icons.grade_outlined,
      openEditorOnStart: widget.openEditorOnStart,
      loadRecords: _cargarNotas,
      titleFor: _titulo,
      subtitleFor: _subtitulo,
      detailsFor: (nota) => [
        RecordDetailField(
          'Evaluación',
          _nombresEvaluaciones[nota.evaluacionId],
        ),
        RecordDetailField('Calificación', nota.valor),
        RecordDetailField(
          'Matrícula relacionada',
          _descripcionesMatriculas[nota.matriculaId],
        ),
      ],
      editorConfig: cargarEditorNota,
      createRecord: (values) => NotaService().crearNota(values),
      updateRecord: (nota, values) =>
          NotaService().actualizarNota(nota.uuid ?? '', values),
      canEdit: (nota) => nota.uuid?.trim().isNotEmpty == true,
      deleteRecord: (nota) => NotaService().eliminarNota(nota.uuid ?? ''),
      canDelete: (nota) => nota.uuid?.trim().isNotEmpty == true,
    );
  }
}
