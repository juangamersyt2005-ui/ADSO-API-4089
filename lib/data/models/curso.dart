import 'json_helpers.dart';

class Curso {
  const Curso({
    this.id,
    this.codigo,
    this.costo,
    this.descripcion,
    this.duracion,
    this.nombre,
    this.uuid,
  });

  final int? id;
  final String? codigo;
  final String? costo;
  final String? descripcion;
  final int? duracion;
  final String? nombre;
  final String? uuid;

  String get titulo => nombre?.isNotEmpty == true ? nombre! : 'Curso ${codigo ?? id ?? ''}';

  String get subtitulo {
    final partes = <String>[];
    if (codigo?.isNotEmpty == true) partes.add('Código $codigo');
    if (duracion != null) partes.add('$duracion horas');
    if (costo?.isNotEmpty == true) partes.add('Costo $costo');
    return partes.isEmpty ? 'Información del curso' : partes.join(' · ');
  }

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: parseJsonInt(json['CUR_ID']),
      codigo: parseJsonString(json['CUR_CODIGO']),
      costo: parseJsonString(json['CUR_COSTO']),
      descripcion: parseJsonString(json['CUR_DESCRIPCION']),
      duracion: parseJsonInt(json['CUR_DURACION']),
      nombre: parseJsonString(json['CUR_NOMBRE']),
      uuid: parseJsonString(json['CUR_UUID']),
    );
  }
}
