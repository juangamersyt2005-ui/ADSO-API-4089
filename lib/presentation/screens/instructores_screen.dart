import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../../core/services/instructor_service.dart';
import '../../core/services/persona_service.dart';
import '../../data/models/instructor.dart';
import '../../data/models/persona.dart';
import '../widgets/records_screen.dart';
import 'module_editor_configs.dart';
import 'related_collections.dart';

class InstructoresScreen extends StatefulWidget {
  const InstructoresScreen({super.key});

  @override
  State<InstructoresScreen> createState() => _InstructoresScreenState();
}

class _InstructoresScreenState extends State<InstructoresScreen> {
  final Map<int, String> _nombresPersonas = {};

  Future<ApiCollection<Instructor>> _cargarInstructores() async {
    final personasFuture = loadOptionalCollection(
      PersonaService().obtenerPersonas(),
    );
    final instructores = await InstructorService().obtenerInstructores();
    final personas = await personasFuture;

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

    return instructores;
  }

  @override
  Widget build(BuildContext context) {
    return RecordsScreen<Instructor>(
      title: 'Instructores',
      icon: Icons.co_present_outlined,
      loadRecords: _cargarInstructores,
      titleFor: (instructor) =>
          _nombresPersonas[instructor.personaId] ?? instructor.titulo,
      subtitleFor: (instructor) => instructor.especialidad?.isNotEmpty == true
          ? instructor.especialidad!
          : 'Especialidad no disponible',
      detailsFor: (instructor) => [
        RecordDetailField('Especialidad', instructor.especialidad),
        RecordDetailField('Persona', _nombresPersonas[instructor.personaId]),
      ],
      editorConfig: cargarEditorInstructor,
      createRecord: (values) => InstructorService().crearInstructor(values),
      updateRecord: (instructor, values) => InstructorService()
          .actualizarInstructor(instructor.uuid ?? '', values),
      canEdit: (instructor) => instructor.uuid?.trim().isNotEmpty == true,
      deleteRecord: (instructor) =>
          InstructorService().eliminarInstructor(instructor.uuid ?? ''),
      canDelete: (instructor) => instructor.uuid?.trim().isNotEmpty == true,
    );
  }
}
