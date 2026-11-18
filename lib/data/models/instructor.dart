import 'json_helpers.dart';

class Instructor {
  const Instructor({
    this.id,
    this.especialidad,
    this.personaId,
    this.uuid,
  });

  final int? id;
  final String? especialidad;
  final int? personaId;
  final String? uuid;

  String get titulo => 'Instructor ${id ?? ''}';

  String get subtitulo {
    final especialidadTexto = especialidad?.isNotEmpty == true
        ? especialidad!
        : 'Especialidad no disponible';
    return '$especialidadTexto · Persona relacionada ${personaId ?? 'no disponible'}';
  }

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: parseJsonInt(json['INS_ID']),
      especialidad: parseJsonString(json['INS_ESPECIALIDAD']),
      personaId: parseJsonInt(json['INS_PER_ID']),
      uuid: parseJsonString(json['INS_UUID']),
    );
  }
}
