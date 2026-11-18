import 'package:flutter/material.dart';

import '../../core/services/persona_service.dart';
import '../../data/models/persona.dart';
import '../widgets/records_screen.dart';
import 'module_editor_configs.dart';

class PersonasScreen extends StatelessWidget {
  const PersonasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RecordsScreen<Persona>(
      title: 'Personas',
      icon: Icons.people_outline,
      loadRecords: () => PersonaService().obtenerPersonas(),
      titleFor: (persona) => persona.titulo,
      subtitleFor: (persona) => persona.subtitulo,
      detailsFor: (persona) => [
        RecordDetailField('Documento', persona.documento),
        RecordDetailField(
          'Nombres',
          [
            persona.primerNombre,
            persona.segundoNombre,
          ].whereType<String>().where((nombre) => nombre.isNotEmpty).join(' '),
        ),
        RecordDetailField(
          'Apellidos',
          [persona.primerApellido, persona.segundoApellido]
              .whereType<String>()
              .where((apellido) => apellido.isNotEmpty)
              .join(' '),
        ),
      ],
      editorConfig: cargarEditorPersona,
      createRecord: (values) => PersonaService().crearPersona(values),
      updateRecord: (persona, values) =>
          PersonaService().actualizarPersona(persona.uuid ?? '', values),
      canEdit: (persona) => persona.uuid?.trim().isNotEmpty == true,
      deleteRecord: (persona) =>
          PersonaService().eliminarPersona(persona.uuid ?? ''),
      canDelete: (persona) => persona.uuid?.trim().isNotEmpty == true,
    );
  }
}
