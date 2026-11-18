import 'json_helpers.dart';

class Persona {
  const Persona({
    this.id,
    this.documento,
    this.primerNombre,
    this.segundoNombre,
    this.primerApellido,
    this.segundoApellido,
    this.uuid,
  });

  final int? id;
  final String? documento;
  final String? primerNombre;
  final String? segundoNombre;
  final String? primerApellido;
  final String? segundoApellido;
  final String? uuid;

  String get nombreCompleto => [
        primerNombre,
        segundoNombre,
        primerApellido,
        segundoApellido,
      ].where((parte) => parte != null && parte.isNotEmpty).join(' ');

  String get titulo => nombreCompleto.isEmpty ? 'Persona ${id ?? ''}' : nombreCompleto;

  String get subtitulo => documento == null || documento!.isEmpty
      ? 'Documento no disponible'
      : 'Documento $documento';

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      id: parseJsonInt(json['PER_ID']),
      documento: parseJsonString(json['PER_DOCUMENTO']),
      primerNombre: parseJsonString(json['PER_PRI_NOMBRE']),
      segundoNombre: parseJsonString(json['PER_SEG_NOMBRE']),
      primerApellido: parseJsonString(json['PER_PRI_APELLIDO']),
      segundoApellido: parseJsonString(json['PER_SEG_APELLIDO']),
      uuid: parseJsonString(json['PER_UUID']),
    );
  }
}
