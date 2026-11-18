import 'json_helpers.dart';

class Nota {
  const Nota({
    this.id,
    this.evaluacionId,
    this.matriculaId,
    this.valor,
    this.uuid,
  });

  final int? id;
  final int? evaluacionId;
  final int? matriculaId;
  final String? valor;
  final String? uuid;

  String get titulo => valor == null ? 'Nota ${id ?? ''}' : 'Nota $valor';

  String get subtitulo =>
      'Evaluación ${evaluacionId ?? 'no disponible'} · Matrícula '
      '${matriculaId ?? 'no disponible'}';

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      id: parseJsonInt(json['MATE_ID']),
      evaluacionId: parseJsonInt(json['MATE_EVA_ID']),
      matriculaId: parseJsonInt(json['MATE_MAT_ID']),
      valor: parseJsonString(json['MATE_NOTA']),
      uuid: parseJsonString(json['MATE_UUID']),
    );
  }
}
