import 'package:flutter/material.dart';

import '../../core/services/curso_service.dart';
import '../../data/models/curso.dart';
import '../widgets/records_screen.dart';

class CursosScreen extends StatelessWidget {
  const CursosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RecordsScreen<Curso>(
      title: 'Cursos',
      icon: Icons.menu_book_outlined,
      loadRecords: () => CursoService().obtenerCursos(),
      titleFor: (curso) => curso.titulo,
      subtitleFor: (curso) => curso.subtitulo,
      detailsFor: (curso) => [
        RecordDetailField('Código', curso.codigo),
        RecordDetailField('Descripción', curso.descripcion),
        RecordDetailField('Duración', curso.duracion?.toString()),
        RecordDetailField('Costo', curso.costo),
      ],
      deleteRecord: (curso) => CursoService().eliminarCurso(curso.uuid ?? ''),
      canDelete: (curso) => curso.uuid?.trim().isNotEmpty == true,
    );
  }
}
