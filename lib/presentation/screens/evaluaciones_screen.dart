import 'package:material_ui/material_ui.dart';

import '../../core/services/evaluacion_service.dart';
import '../../data/models/evaluacion.dart';
import '../widgets/records_screen.dart';
import 'module_editor_configs.dart';

class EvaluacionesScreen extends StatelessWidget {
  const EvaluacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RecordsScreen<Evaluacion>(
      title: 'Evaluaciones',
      icon: Icons.fact_check_outlined,
      loadRecords: () => EvaluacionService().obtenerEvaluaciones(),
      titleFor: (evaluacion) => evaluacion.titulo,
      subtitleFor: (evaluacion) => evaluacion.subtitulo,
      detailsFor: (evaluacion) => [
        RecordDetailField('Código', evaluacion.codigo),
        RecordDetailField('Fecha', evaluacion.fecha),
        RecordDetailField('Porcentaje', evaluacion.porcentaje),
      ],
      editorConfig: cargarEditorEvaluacion,
      createRecord: (values) => EvaluacionService().crearEvaluacion(values),
      updateRecord: (evaluacion, values) => EvaluacionService()
          .actualizarEvaluacion(evaluacion.uuid ?? '', values),
      canEdit: (evaluacion) => evaluacion.uuid?.trim().isNotEmpty == true,
      deleteRecord: (evaluacion) =>
          EvaluacionService().eliminarEvaluacion(evaluacion.uuid ?? ''),
      canDelete: (evaluacion) => evaluacion.uuid?.trim().isNotEmpty == true,
    );
  }
}
