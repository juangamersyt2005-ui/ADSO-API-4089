import 'package:material_ui/material_ui.dart';

import '../../core/services/curso_service.dart';
import '../../data/models/curso.dart';
import '../widgets/records_screen.dart';
import 'module_editor_configs.dart';

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
      editorConfig: cargarEditorCurso,
      createRecord: (values) => CursoService().crearCurso(values),
      updateRecord: (curso, values) =>
          CursoService().actualizarCurso(curso.uuid ?? '', values),
      canEdit: (curso) => curso.uuid?.trim().isNotEmpty == true,
      deleteRecord: (curso) => CursoService().eliminarCurso(curso.uuid ?? ''),
      canDelete: (curso) => curso.uuid?.trim().isNotEmpty == true,
    );
  }
}
