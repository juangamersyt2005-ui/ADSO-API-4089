import 'package:material_ui/material_ui.dart';

import '../../core/services/curso_service.dart';
import '../../data/models/curso.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_chrome.dart';
import '../widgets/records_screen.dart';
import 'module_editor_configs.dart';

class CursosScreen extends StatelessWidget {
  const CursosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RecordsScreen<Curso>(
      title: 'Gestión de Cursos',
      icon: Icons.school_outlined,
      loadRecords: () => CursoService().obtenerCursos(),
      titleFor: (curso) => curso.titulo,
      subtitleFor: (curso) => curso.subtitulo,
      headerSubtitle: 'Programas, códigos y duración',
      searchHint: 'Buscar por nombre o código',
      navigationIndex: 2,
      filters: [
        RecordFilter<Curso>(label: 'Todos', matches: (_) => true),
        RecordFilter<Curso>(
          label: 'Con código',
          matches: (curso) => curso.codigo?.trim().isNotEmpty == true,
        ),
        RecordFilter<Curso>(
          label: 'Con duración',
          matches: (curso) => curso.duracion != null,
        ),
      ],
      detailsFor: (curso) => [
        RecordDetailField('Código', curso.codigo),
        RecordDetailField(
          'Duración',
          curso.duracion == null ? null : '${curso.duracion} horas',
        ),
        RecordDetailField('Costo', curso.costo),
        RecordDetailField('Descripción', curso.descripcion),
      ],
      extraActionsFor: (context, _) => [
        RecordCardAction(
          label: 'Matrículas',
          icon: Icons.groups_outlined,
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.matriculas);
          },
        ),
        RecordCardAction(
          label: 'Asignaciones',
          icon: Icons.assignment_outlined,
          isPrimary: true,
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.asignaciones);
          },
        ),
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
