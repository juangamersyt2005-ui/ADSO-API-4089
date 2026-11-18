import 'package:flutter/material.dart';

import '../../core/services/aprendiz_service.dart';
import '../../data/models/aprendiz.dart';
import '../widgets/records_screen.dart';

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
      deleteRecord: (aprendiz) =>
          AprendizService().eliminarAprendiz(aprendiz.uuid ?? ''),
      canDelete: (aprendiz) => aprendiz.uuid?.trim().isNotEmpty == true,
    );
  }
}
