import 'json_helpers.dart';

class Asignacion {
  const Asignacion({
    this.id,
    this.cursoId,
    this.fecha,
    this.fechaAsignacion,
    this.instructorId,
    this.rol,
    this.uuid,
  });

  final int? id;
  final int? cursoId;
  final String? fecha;
  final String? fechaAsignacion;
  final int? instructorId;
  final String? rol;
  final String? uuid;

  String get titulo => 'Asignación ${id ?? ''}';

  String get subtitulo =>
      'Curso ${cursoId ?? 'no disponible'} · Instructor '
      '${instructorId ?? 'no disponible'} · ${rol ?? 'Rol no disponible'}';

  factory Asignacion.fromJson(Map<String, dynamic> json) {
    return Asignacion(
      id: parseJsonInt(json['IMP_ID']),
      cursoId: parseJsonInt(json['IMP_CUR_ID']),
      fecha: parseJsonString(json['IMP_FECHA']),
      fechaAsignacion: parseJsonString(json['IMP_FECHA_ASIGNACION']),
      instructorId: parseJsonInt(json['IMP_INS_ID']),
      rol: parseJsonString(json['IMP_ROL']),
      uuid: parseJsonString(json['IMP_UUID']),
    );
  }
}
