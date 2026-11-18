import '../../core/services/curso_service.dart';
import '../../core/services/evaluacion_service.dart';
import '../../core/services/instructor_service.dart';
import '../../core/services/matricula_service.dart';
import '../../core/services/persona_service.dart';
import '../../data/models/aprendiz.dart';
import '../../data/models/asignacion.dart';
import '../../data/models/curso.dart';
import '../../data/models/evaluacion.dart';
import '../../data/models/instructor.dart';
import '../../data/models/matricula.dart';
import '../../data/models/nota.dart';
import '../../data/models/persona.dart';
import '../widgets/record_editor.dart';
import 'related_collections.dart';

Future<RecordEditorConfig> cargarEditorAprendiz(Aprendiz? aprendiz) async {
  final personas = await loadOptionalCollection(
    PersonaService().obtenerPersonas(),
  );
  final opcionesPersonas = _opcionesPersonas(personas?.items ?? const []);
  final personaId = _personaIdPorCedula(
    personas?.items ?? const [],
    aprendiz?.persona?.cedula,
  );

  return RecordEditorConfig(
    fields: [
      RecordEditorField(
        name: 'per_id',
        label: 'Persona',
        type: RecordEditorFieldType.selection,
        options: opcionesPersonas,
        emptyOptionsMessage:
            'Primero debe existir una persona para seleccionar.',
      ),
      const RecordEditorField(
        name: 'fecha_nac',
        label: 'Fecha de nacimiento',
        type: RecordEditorFieldType.date,
      ),
    ],
    initialValues: {
      if (personaId != null) 'per_id': personaId.toString(),
      if (aprendiz != null)
        'fecha_nac': dateForEditor(aprendiz.fechaNacimiento),
    },
  );
}

RecordEditorConfig cargarEditorPersona(Persona? persona) {
  return RecordEditorConfig(
    fields: const [
      RecordEditorField(
        name: 'pri_nombre',
        label: 'Primer nombre',
        type: RecordEditorFieldType.text,
      ),
      RecordEditorField(
        name: 'seg_nombre',
        label: 'Segundo nombre',
        type: RecordEditorFieldType.text,
        isRequired: false,
        nullable: true,
      ),
      RecordEditorField(
        name: 'pri_apellido',
        label: 'Primer apellido',
        type: RecordEditorFieldType.text,
      ),
      RecordEditorField(
        name: 'seg_apellido',
        label: 'Segundo apellido',
        type: RecordEditorFieldType.text,
        isRequired: false,
        nullable: true,
      ),
      RecordEditorField(
        name: 'documento',
        label: 'Documento',
        type: RecordEditorFieldType.text,
      ),
    ],
    initialValues: {
      if (persona != null) ...{
        'pri_nombre': persona.primerNombre ?? '',
        'seg_nombre': persona.segundoNombre ?? '',
        'pri_apellido': persona.primerApellido ?? '',
        'seg_apellido': persona.segundoApellido ?? '',
        'documento': persona.documento ?? '',
      },
    },
  );
}

RecordEditorConfig cargarEditorCurso(Curso? curso) {
  return RecordEditorConfig(
    fields: const [
      RecordEditorField(
        name: 'nombre',
        label: 'Nombre',
        type: RecordEditorFieldType.text,
      ),
      RecordEditorField(
        name: 'codigo',
        label: 'Código',
        type: RecordEditorFieldType.text,
      ),
      RecordEditorField(
        name: 'duracion',
        label: 'Duración en horas',
        type: RecordEditorFieldType.integer,
        minimum: 1,
      ),
      RecordEditorField(
        name: 'costo',
        label: 'Costo',
        type: RecordEditorFieldType.decimal,
        minimum: 0,
      ),
      RecordEditorField(
        name: 'descripcion',
        label: 'Descripción',
        type: RecordEditorFieldType.text,
        isRequired: false,
        nullable: true,
      ),
    ],
    initialValues: {
      if (curso != null) ...{
        'nombre': curso.nombre ?? '',
        'codigo': curso.codigo ?? '',
        'duracion': curso.duracion?.toString() ?? '',
        'costo': curso.costo ?? '',
        'descripcion': curso.descripcion ?? '',
      },
    },
  );
}

Future<RecordEditorConfig> cargarEditorInstructor(
  Instructor? instructor,
) async {
  final personas = await loadOptionalCollection(
    PersonaService().obtenerPersonas(),
  );
  final opcionesPersonas = _opcionesPersonas(personas?.items ?? const []);
  _agregarOpcionActual(
    opcionesPersonas,
    instructor?.personaId,
    instructor?.personaId == null
        ? null
        : 'Persona relacionada ${instructor!.personaId}',
  );

  return RecordEditorConfig(
    fields: [
      const RecordEditorField(
        name: 'especialidad',
        label: 'Especialidad',
        type: RecordEditorFieldType.text,
      ),
      RecordEditorField(
        name: 'per_id',
        label: 'Persona',
        type: RecordEditorFieldType.selection,
        options: opcionesPersonas,
        emptyOptionsMessage: 'No hay personas disponibles para seleccionar.',
      ),
    ],
    initialValues: {
      if (instructor?.personaId != null)
        'per_id': instructor!.personaId.toString(),
      if (instructor != null) 'especialidad': instructor.especialidad ?? '',
    },
  );
}

Future<RecordEditorConfig> cargarEditorAsignacion(
  Asignacion? asignacion,
) async {
  final cursosFuture = loadOptionalCollection(CursoService().obtenerCursos());
  final instructoresFuture = loadOptionalCollection(
    InstructorService().obtenerInstructores(),
  );
  final personasFuture = loadOptionalCollection(
    PersonaService().obtenerPersonas(),
  );
  final cursos = await cursosFuture;
  final instructores = await instructoresFuture;
  final personas = await personasFuture;

  final nombresPersonas = {
    for (final persona in personas?.items ?? const <Persona>[])
      if (persona.id != null) persona.id!: persona.nombreCompleto,
  };
  final opcionesCursos = _opcionesCursos(cursos?.items ?? const []);
  final opcionesInstructores = [
    for (final instructor in instructores?.items ?? const <Instructor>[])
      if (instructor.id != null)
        RecordEditorOption(
          value: instructor.id.toString(),
          label: nombresPersonas[instructor.personaId]?.isNotEmpty == true
              ? nombresPersonas[instructor.personaId]!
              : 'Instructor ${instructor.id}',
        ),
  ];
  _agregarOpcionActual(
    opcionesCursos,
    asignacion?.cursoId,
    asignacion?.cursoId == null ? null : 'Curso actual ${asignacion!.cursoId}',
  );
  _agregarOpcionActual(
    opcionesInstructores,
    asignacion?.instructorId,
    asignacion?.instructorId == null
        ? null
        : 'Instructor actual ${asignacion!.instructorId}',
  );

  return RecordEditorConfig(
    fields: [
      const RecordEditorField(
        name: 'rol',
        label: 'Rol',
        type: RecordEditorFieldType.text,
      ),
      const RecordEditorField(
        name: 'fecha',
        label: 'Fecha',
        type: RecordEditorFieldType.date,
      ),
      const RecordEditorField(
        name: 'fecha_asignacion',
        label: 'Fecha de asignación',
        type: RecordEditorFieldType.date,
      ),
      RecordEditorField(
        name: 'cur_id',
        label: 'Curso',
        type: RecordEditorFieldType.selection,
        options: opcionesCursos,
        emptyOptionsMessage: 'No hay cursos disponibles para seleccionar.',
      ),
      RecordEditorField(
        name: 'ins_id',
        label: 'Instructor',
        type: RecordEditorFieldType.selection,
        options: opcionesInstructores,
        emptyOptionsMessage:
            'No hay instructores disponibles para seleccionar.',
      ),
    ],
    initialValues: {
      if (asignacion != null) ...{
        'rol': asignacion.rol ?? '',
        'fecha': dateForEditor(asignacion.fecha),
        'fecha_asignacion': dateForEditor(asignacion.fechaAsignacion),
        if (asignacion.cursoId != null) 'cur_id': asignacion.cursoId.toString(),
        if (asignacion.instructorId != null)
          'ins_id': asignacion.instructorId.toString(),
      },
    },
  );
}

Future<RecordEditorConfig> cargarEditorMatricula(Matricula? matricula) async {
  final personasFuture = loadOptionalCollection(
    PersonaService().obtenerPersonas(),
  );
  final cursosFuture = loadOptionalCollection(CursoService().obtenerCursos());
  final personas = await personasFuture;
  final cursos = await cursosFuture;
  final opcionesPersonas = _opcionesPersonas(personas?.items ?? const []);
  final opcionesCursos = _opcionesCursos(cursos?.items ?? const []);
  _agregarOpcionActual(
    opcionesPersonas,
    matricula?.personaId,
    matricula?.personaId == null
        ? null
        : 'Persona actual ${matricula!.personaId}',
  );
  _agregarOpcionActual(
    opcionesCursos,
    matricula?.cursoId,
    matricula?.cursoId == null ? null : 'Curso actual ${matricula!.cursoId}',
  );

  return RecordEditorConfig(
    fields: [
      const RecordEditorField(
        name: 'fecha',
        label: 'Fecha',
        type: RecordEditorFieldType.date,
      ),
      const RecordEditorField(
        name: 'estado',
        label: 'Estado',
        type: RecordEditorFieldType.text,
      ),
      RecordEditorField(
        name: 'per_id',
        label: 'Persona',
        type: RecordEditorFieldType.selection,
        options: opcionesPersonas,
        emptyOptionsMessage: 'No hay personas disponibles para seleccionar.',
      ),
      RecordEditorField(
        name: 'cur_id',
        label: 'Curso',
        type: RecordEditorFieldType.selection,
        options: opcionesCursos,
        emptyOptionsMessage: 'No hay cursos disponibles para seleccionar.',
      ),
    ],
    initialValues: {
      if (matricula != null) ...{
        'fecha': dateForEditor(matricula.fecha),
        'estado': matricula.estado ?? '',
        if (matricula.personaId != null)
          'per_id': matricula.personaId.toString(),
        if (matricula.cursoId != null) 'cur_id': matricula.cursoId.toString(),
      },
    },
  );
}

RecordEditorConfig cargarEditorEvaluacion(Evaluacion? evaluacion) {
  return RecordEditorConfig(
    fields: const [
      RecordEditorField(
        name: 'nombre',
        label: 'Nombre',
        type: RecordEditorFieldType.text,
      ),
      RecordEditorField(
        name: 'codigo',
        label: 'Código',
        type: RecordEditorFieldType.text,
      ),
      RecordEditorField(
        name: 'porcentaje',
        label: 'Porcentaje',
        type: RecordEditorFieldType.decimal,
        minimum: 0,
        maximum: 100,
      ),
      RecordEditorField(
        name: 'fecha',
        label: 'Fecha',
        type: RecordEditorFieldType.date,
      ),
    ],
    initialValues: {
      if (evaluacion != null) ...{
        'nombre': evaluacion.nombre ?? '',
        'codigo': evaluacion.codigo ?? '',
        'porcentaje': evaluacion.porcentaje ?? '',
        'fecha': dateForEditor(evaluacion.fecha),
      },
    },
  );
}

Future<RecordEditorConfig> cargarEditorNota(Nota? nota) async {
  final evaluacionesFuture = loadOptionalCollection(
    EvaluacionService().obtenerEvaluaciones(),
  );
  final matriculasFuture = loadOptionalCollection(
    MatriculaService().obtenerMatriculas(),
  );
  final evaluaciones = await evaluacionesFuture;
  final matriculas = await matriculasFuture;
  final opcionesEvaluaciones = [
    for (final evaluacion in evaluaciones?.items ?? const <Evaluacion>[])
      if (evaluacion.id != null)
        RecordEditorOption(
          value: evaluacion.id.toString(),
          label: evaluacion.titulo,
        ),
  ];
  final opcionesMatriculas = [
    for (final matricula in matriculas?.items ?? const <Matricula>[])
      if (matricula.id != null)
        RecordEditorOption(
          value: matricula.id.toString(),
          label:
              'Matrícula ${matricula.id} · ${matricula.estado ?? 'Sin estado'}',
        ),
  ];
  _agregarOpcionActual(
    opcionesEvaluaciones,
    nota?.evaluacionId,
    nota?.evaluacionId == null
        ? null
        : 'Evaluación actual ${nota!.evaluacionId}',
  );
  _agregarOpcionActual(
    opcionesMatriculas,
    nota?.matriculaId,
    nota?.matriculaId == null ? null : 'Matrícula actual ${nota!.matriculaId}',
  );

  return RecordEditorConfig(
    fields: [
      const RecordEditorField(
        name: 'nota',
        label: 'Calificación (0 a 5)',
        type: RecordEditorFieldType.decimal,
        minimum: 0,
        maximum: 5,
      ),
      RecordEditorField(
        name: 'eva_id',
        label: 'Evaluación',
        type: RecordEditorFieldType.selection,
        options: opcionesEvaluaciones,
        emptyOptionsMessage:
            'No hay evaluaciones disponibles para seleccionar.',
      ),
      RecordEditorField(
        name: 'mat_id',
        label: 'Matrícula',
        type: RecordEditorFieldType.selection,
        options: opcionesMatriculas,
        emptyOptionsMessage: 'No hay matrículas disponibles para seleccionar.',
      ),
    ],
    initialValues: {
      if (nota != null) ...{
        if (nota.valor != null) 'nota': nota.valor!,
        if (nota.evaluacionId != null) 'eva_id': nota.evaluacionId.toString(),
        if (nota.matriculaId != null) 'mat_id': nota.matriculaId.toString(),
      },
    },
  );
}

List<RecordEditorOption> _opcionesPersonas(Iterable<Persona> personas) => [
  for (final persona in personas)
    if (persona.id != null)
      RecordEditorOption(
        value: persona.id.toString(),
        label: persona.documento?.isNotEmpty == true
            ? '${persona.nombreCompleto} · ${persona.documento}'
            : persona.nombreCompleto,
      ),
];

List<RecordEditorOption> _opcionesCursos(Iterable<Curso> cursos) => [
  for (final curso in cursos)
    if (curso.id != null)
      RecordEditorOption(
        value: curso.id.toString(),
        label: curso.codigo?.isNotEmpty == true
            ? '${curso.titulo} · ${curso.codigo}'
            : curso.titulo,
      ),
];

int? _personaIdPorCedula(Iterable<Persona> personas, String? cedula) {
  if (cedula == null || cedula.isEmpty) return null;
  for (final persona in personas) {
    if (persona.documento == cedula) return persona.id;
  }
  return null;
}

void _agregarOpcionActual(
  List<RecordEditorOption> opciones,
  int? id,
  String? etiqueta,
) {
  if (id == null || opciones.any((opcion) => opcion.value == id.toString())) {
    return;
  }
  opciones.insert(
    0,
    RecordEditorOption(value: id.toString(), label: etiqueta ?? 'Registro $id'),
  );
}
