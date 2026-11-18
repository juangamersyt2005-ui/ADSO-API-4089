import 'json_helpers.dart';

class Matricula {
  const Matricula({
    this.id,
    this.cursoId,
    this.estado,
    this.fecha,
    this.personaId,
    this.uuid,
  });

  final int? id;
  final int? cursoId;
  final String? estado;
  final String? fecha;
  final int? personaId;
  final String? uuid;

  String get titulo => 'Matrícula ${id ?? ''}';

  String get subtitulo =>
      'Curso ${cursoId ?? 'no disponible'} · Persona '
      '${personaId ?? 'no disponible'} · ${estado ?? 'Estado no disponible'}';

  factory Matricula.fromJson(Map<String, dynamic> json) {
    return Matricula(
      id: parseJsonInt(json['MAT_ID']),
      cursoId: parseJsonInt(json['MAT_CUR_ID']),
      estado: parseJsonString(json['MAT_ESTADO']),
      fecha: parseJsonString(json['MAT_FECHA']),
      personaId: parseJsonInt(json['MAT_PER_ID']),
      uuid: parseJsonString(json['MAT_UUID']),
    );
  }
}
