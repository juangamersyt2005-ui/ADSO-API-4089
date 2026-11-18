import 'json_helpers.dart';

class Evaluacion {
  const Evaluacion({
    this.id,
    this.codigo,
    this.fecha,
    this.nombre,
    this.porcentaje,
    this.uuid,
  });

  final int? id;
  final String? codigo;
  final String? fecha;
  final String? nombre;
  final String? porcentaje;
  final String? uuid;

  String get titulo => nombre?.isNotEmpty == true ? nombre! : 'Evaluación ${id ?? ''}';

  String get subtitulo => [
        if (codigo?.isNotEmpty == true) 'Código $codigo',
        if (porcentaje?.isNotEmpty == true) '$porcentaje %',
      ].join(' · ');

  factory Evaluacion.fromJson(Map<String, dynamic> json) {
    return Evaluacion(
      id: parseJsonInt(json['EVA_ID']),
      codigo: parseJsonString(json['EVA_CODIGO']),
      fecha: parseJsonString(json['EVA_FECHA']),
      nombre: parseJsonString(json['EVA_NOMBRE']),
      porcentaje: parseJsonString(json['EVA_PORCENTAJE']),
      uuid: parseJsonString(json['EVA_UUID']),
    );
  }
}
