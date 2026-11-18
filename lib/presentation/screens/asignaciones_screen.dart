import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../../core/services/asignacion_service.dart';
import '../../core/services/curso_service.dart';
import '../../core/services/instructor_service.dart';
import '../../core/services/persona_service.dart';
import '../../data/models/asignacion.dart';
import '../../data/models/curso.dart';
import '../../data/models/instructor.dart';
import '../../data/models/persona.dart';
import '../widgets/records_screen.dart';
import 'related_collections.dart';

class AsignacionesScreen extends StatefulWidget {
  const AsignacionesScreen({super.key});

  @override
  State<AsignacionesScreen> createState() => _AsignacionesScreenState();
}

class _AsignacionesScreenState extends State<AsignacionesScreen> {
  final Map<int, String> _nombresCursos = {};
  final Map<int, String> _nombresInstructores = {};

  Future<ApiCollection<Asignacion>> _cargarAsignaciones() async {
    final cursosFuture = loadOptionalCollection(CursoService().obtenerCursos());
    final instructoresFuture =
        loadOptionalCollection(InstructorService().obtenerInstructores());
    final personasFuture = loadOptionalCollection(PersonaService().obtenerPersonas());
    final asignaciones = await AsignacionService().obtenerAsignaciones();
    final cursos = await cursosFuture;
    final instructores = await instructoresFuture;
    final personas = await personasFuture;

    _nombresCursos
      ..clear()
      ..addEntries(
        (cursos?.items ?? <Curso>[])
            .where((curso) => curso.id != null && curso.titulo.isNotEmpty)
            .map((curso) => MapEntry(curso.id!, curso.titulo)),
      );

    final nombresPersonas = {
      for (final persona in (personas?.items ?? <Persona>[]))
        if (persona.id != null && persona.nombreCompleto.isNotEmpty)
          persona.id!: persona.nombreCompleto,
    };
    _nombresInstructores
      ..clear()
      ..addEntries(
        (instructores?.items ?? <Instructor>[]).where((instructor) {
          return instructor.id != null &&
              nombresPersonas[instructor.personaId] != null;
        }).map(
          (instructor) => MapEntry(
            instructor.id!,
            nombresPersonas[instructor.personaId]!,
          ),
        ),
      );

    return asignaciones;
  }

  String _titulo(Asignacion asignacion) {
    final partes = [
      _nombresCursos[asignacion.cursoId],
      _nombresInstructores[asignacion.instructorId],
    ].whereType<String>().toList();
    return partes.isEmpty ? asignacion.titulo : partes.join(' · ');
  }

  String _subtitulo(Asignacion asignacion) {
    final partes = [
      asignacion.rol,
      if (asignacion.fechaAsignacion?.isNotEmpty == true)
        'Asignada ${asignacion.fechaAsignacion}',
    ].whereType<String>().toList();
    return partes.isEmpty ? 'Asignación académica' : partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return RecordsScreen<Asignacion>(
      title: 'Asignaciones',
      icon: Icons.assignment_outlined,
      loadRecords: _cargarAsignaciones,
      titleFor: _titulo,
      subtitleFor: _subtitulo,
      detailsFor: (asignacion) => [
        RecordDetailField('Rol', asignacion.rol),
        RecordDetailField('Fecha', asignacion.fecha),
        RecordDetailField('Fecha de asignación', asignacion.fechaAsignacion),
      ],
      deleteRecord: (asignacion) => AsignacionService()
          .eliminarAsignacion(asignacion.uuid ?? ''),
      canDelete: (asignacion) => asignacion.uuid?.trim().isNotEmpty == true,
    );
  }
}
