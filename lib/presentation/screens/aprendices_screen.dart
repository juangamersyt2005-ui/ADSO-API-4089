import 'package:material_ui/material_ui.dart';

import '../../core/services/aprendiz_service.dart';
import '../../data/models/aprendiz.dart';
import '../widgets/records_screen.dart';
import 'module_editor_configs.dart';

class AprendicesScreen extends StatelessWidget {
  const AprendicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RecordsScreen<Aprendiz>(
      title: 'Aprendices',
      icon: Icons.school_outlined,
      loadRecords: () => AprendizService().obtenerAprendices(),
      titleFor: (aprendiz) => aprendiz.titulo,
      subtitleFor: (aprendiz) => aprendiz.subtitulo,
      detailsFor: (aprendiz) => [
        RecordDetailField('Cédula', aprendiz.persona?.cedula),
        RecordDetailField('Fecha de nacimiento', aprendiz.fechaNacimiento),
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
