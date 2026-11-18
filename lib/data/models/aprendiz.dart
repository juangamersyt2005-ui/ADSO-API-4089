import 'json_helpers.dart';

class Aprendiz {
  const Aprendiz({
    this.id,
    this.fechaNacimiento,
    this.uuid,
    this.persona,
  });

  final int? id;

  /// Se conserva el texto original que entrega la API, que no es ISO 8601.
  final String? fechaNacimiento;
  final String? uuid;
  final PersonaAprendiz? persona;

  String get titulo => persona?.nombreCompleto ?? 'Aprendiz ${id ?? ''}';

  String get subtitulo {
    final cedula = persona?.cedula;
    return cedula == null || cedula.isEmpty
        ? 'Cédula no disponible'
        : 'Cédula $cedula';
  }

  factory Aprendiz.fromJson(Map<String, dynamic> json) {
    final personaJson = json['APR_PER_ID'];

    return Aprendiz(
      id: parseJsonInt(json['APR_ID']),
      fechaNacimiento: parseJsonString(json['APR_FECHA_NAC']),
      uuid: parseJsonString(json['APR_UUID']),
      persona: personaJson is Map
          ? PersonaAprendiz.fromJson(Map<String, dynamic>.from(personaJson))
          : null,
    );
  }
}

class PersonaAprendiz {
  const PersonaAprendiz({
    this.nombres,
    this.apellidos,
    this.cedula,
  });

  final String? nombres;
  final String? apellidos;
  final String? cedula;

  String get nombreCompleto => [nombres, apellidos]
      .where((parte) => parte != null && parte.isNotEmpty)
      .join(' ');

  factory PersonaAprendiz.fromJson(Map<String, dynamic> json) {
    return PersonaAprendiz(
      nombres: parseJsonString(json['nombres']),
      apellidos: parseJsonString(json['apellidos']),
      cedula: parseJsonString(json['cedula']),
    );
  }
}
