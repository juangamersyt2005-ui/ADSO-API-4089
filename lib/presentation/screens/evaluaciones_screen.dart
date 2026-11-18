import 'package:flutter/material.dart';

import '../../core/services/evaluacion_service.dart';
import '../../data/models/evaluacion.dart';
import '../widgets/records_screen.dart';

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
      deleteRecord: (evaluacion) =>
          EvaluacionService().eliminarEvaluacion(evaluacion.uuid ?? ''),
      canDelete: (evaluacion) => evaluacion.uuid?.trim().isNotEmpty == true,
    );
  }
}
