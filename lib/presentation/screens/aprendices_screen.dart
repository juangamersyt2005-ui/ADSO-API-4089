import 'package:material_ui/material_ui.dart';

import '../../core/services/aprendiz_service.dart';
import '../../data/models/aprendiz.dart';
import '../widgets/app_chrome.dart';
import '../widgets/records_screen.dart';
import 'module_editor_configs.dart';

class AprendicesScreen extends StatelessWidget {
  const AprendicesScreen({this.openEditorOnStart = false, super.key});

  final bool openEditorOnStart;

  @override
  Widget build(BuildContext context) {
    return RecordsScreen<Aprendiz>(
      title: 'Aprendices',
      icon: Icons.school_outlined,
      loadRecords: () => AprendizService().obtenerAprendices(),
      titleFor: (aprendiz) => aprendiz.titulo,
      subtitleFor: (aprendiz) => aprendiz.subtitulo,
      headerSubtitle: 'Registros de aprendices',
      searchHint: 'Buscar por nombre o cédula',
      navigationIndex: 1,
      openEditorOnStart: openEditorOnStart,
      filters: [
        RecordFilter<Aprendiz>(label: 'Todos', matches: (_) => true),
        RecordFilter<Aprendiz>(
          label: 'Con cédula',
          matches: (aprendiz) =>
              aprendiz.persona?.cedula?.trim().isNotEmpty == true,
        ),
        RecordFilter<Aprendiz>(
          label: 'Sin cédula',
          matches: (aprendiz) =>
              aprendiz.persona?.cedula?.trim().isNotEmpty != true,
        ),
      ],
      detailsFor: (aprendiz) => [
        RecordDetailField('Cédula', aprendiz.persona?.cedula),
        RecordDetailField('Fecha de nacimiento', aprendiz.fechaNacimiento),
        RecordDetailField('Registro', aprendiz.id?.toString()),
      ],
      editorConfig: cargarEditorAprendiz,
      createRecord: (values) => AprendizService().crearAprendiz(values),
      updateRecord: (aprendiz, values) =>
          AprendizService().actualizarAprendiz(aprendiz.uuid ?? '', values),
      canEdit: (aprendiz) => aprendiz.uuid?.trim().isNotEmpty == true,
      deleteRecord: (aprendiz) =>
          AprendizService().eliminarAprendiz(aprendiz.uuid ?? ''),
      canDelete: (aprendiz) => aprendiz.uuid?.trim().isNotEmpty == true,
    );
  }
}
