import 'dart:convert';

enum TipoPayloadNotificacao { dose, adiamento, recorrenciaDiaria }

/// Contrato persistido no agendamento nativo.
///
/// O payload carrega a identidade imutavel da ocorrencia para que callbacks
/// executados em outro isolate nunca precisem inferir a dose pelo horario do
/// toque. Mudancas incompatíveis devem criar uma nova versao.
final class PayloadNotificacao {
  PayloadNotificacao({
    required this.tipo,
    required this.doseKey,
    required this.tratamentoId,
    required this.medicamentoId,
    required this.regraId,
    required this.dataHoraProgramadaUtc,
    required this.fusoHorario,
    required this.titulo,
    required this.corpo,
    this.horaRecorrencia,
    this.minutoRecorrencia,
    this.segundoRecorrencia,
    this.lembrarEmUtc,
  }) {
    _exigirTexto(doseKey, 'doseKey');
    _exigirTexto(tratamentoId, 'tratamentoId');
    _exigirTexto(medicamentoId, 'medicamentoId');
    _exigirTexto(regraId, 'regraId');
    _exigirTexto(fusoHorario, 'fusoHorario');
    _exigirTexto(titulo, 'titulo');
    _exigirTexto(corpo, 'corpo');
    if (!dataHoraProgramadaUtc.isUtc) {
      throw ArgumentError.value(
        dataHoraProgramadaUtc,
        'dataHoraProgramadaUtc',
        'A data programada deve estar em UTC.',
      );
    }
    if (tipo == TipoPayloadNotificacao.recorrenciaDiaria) {
      final hora = horaRecorrencia;
      final minuto = minutoRecorrencia;
      final segundo = segundoRecorrencia;
      if (hora == null) {
        throw ArgumentError.notNull('horaRecorrencia');
      }
      if (hora < 0 || hora > 23) {
        throw RangeError.range(hora, 0, 23, 'horaRecorrencia');
      }
      if (minuto == null) {
        throw ArgumentError.notNull('minutoRecorrencia');
      }
      if (minuto < 0 || minuto > 59) {
        throw RangeError.range(minuto, 0, 59, 'minutoRecorrencia');
      }
      if (segundo == null) {
        throw ArgumentError.notNull('segundoRecorrencia');
      }
      if (segundo < 0 || segundo > 59) {
        throw RangeError.range(segundo, 0, 59, 'segundoRecorrencia');
      }
    } else if (horaRecorrencia != null ||
        minutoRecorrencia != null ||
        segundoRecorrencia != null) {
      throw ArgumentError(
        'Somente uma recorrencia diaria pode definir hora, minuto e segundo.',
      );
    }
    if (tipo == TipoPayloadNotificacao.adiamento) {
      final lembrarEm = lembrarEmUtc;
      if (lembrarEm == null || !lembrarEm.isUtc) {
        throw ArgumentError.value(
          lembrarEm,
          'lembrarEmUtc',
          'O horario do adiamento deve estar em UTC.',
        );
      }
    } else if (lembrarEmUtc != null) {
      throw ArgumentError('Somente um adiamento pode definir lembrarEmUtc.');
    }
  }

  static const int versaoAtual = 1;
  static const int revisaoTemplateAtual = 1;
  static const String _origem = 'minha_medicacao';

  final TipoPayloadNotificacao tipo;
  final String doseKey;
  final String tratamentoId;
  final String medicamentoId;
  final String regraId;
  final DateTime dataHoraProgramadaUtc;
  final String fusoHorario;
  final String titulo;
  final String corpo;
  final int? horaRecorrencia;
  final int? minutoRecorrencia;
  final int? segundoRecorrencia;
  final DateTime? lembrarEmUtc;

  DateTime get dataHoraProgramadaLocal => dataHoraProgramadaUtc.toLocal();

  PayloadNotificacao comoAdiamento({required DateTime lembrarEm}) {
    if (tipo == TipoPayloadNotificacao.recorrenciaDiaria) {
      throw StateError(
        'Resolva a ocorrencia concreta antes de criar um adiamento.',
      );
    }
    return PayloadNotificacao(
      tipo: TipoPayloadNotificacao.adiamento,
      doseKey: doseKey,
      tratamentoId: tratamentoId,
      medicamentoId: medicamentoId,
      regraId: regraId,
      dataHoraProgramadaUtc: dataHoraProgramadaUtc,
      fusoHorario: fusoHorario,
      titulo: titulo,
      corpo: corpo,
      lembrarEmUtc: lembrarEm.toUtc(),
    );
  }

  String codificar() {
    final json = <String, Object>{
      'origem': _origem,
      'versao': versaoAtual,
      'tipo': tipo.name,
      'doseKey': doseKey,
      'tratamentoId': tratamentoId,
      'medicamentoId': medicamentoId,
      'regraId': regraId,
      'programadaUtc': dataHoraProgramadaUtc.toIso8601String(),
      'fusoHorario': fusoHorario,
      'revisaoTemplate': revisaoTemplateAtual,
      'titulo': titulo,
      'corpo': corpo,
    };
    if (tipo == TipoPayloadNotificacao.recorrenciaDiaria) {
      json['horaRecorrencia'] = horaRecorrencia!;
      json['minutoRecorrencia'] = minutoRecorrencia!;
      json['segundoRecorrencia'] = segundoRecorrencia!;
    }
    if (tipo == TipoPayloadNotificacao.adiamento) {
      json['lembrarEmUtc'] = lembrarEmUtc!.toIso8601String();
    }
    return jsonEncode(json);
  }

  static PayloadNotificacao decodificar(String valor) {
    try {
      final decoded = jsonDecode(valor);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('O payload deve ser um objeto JSON.');
      }
      if (decoded['origem'] != _origem) {
        throw const FormatException('Payload de outra origem.');
      }
      if (decoded['versao'] != versaoAtual) {
        throw const FormatException('Versao de payload nao suportada.');
      }
      if (decoded['revisaoTemplate'] != revisaoTemplateAtual) {
        throw const FormatException('Revisao de template nao suportada.');
      }

      final tipoTexto = decoded['tipo'];
      final tipo = TipoPayloadNotificacao.values
          .where((item) => item.name == tipoTexto)
          .firstOrNull;
      if (tipo == null) {
        throw const FormatException('Tipo de notificacao desconhecido.');
      }

      final programada = DateTime.parse(_lerTexto(decoded, 'programadaUtc'));
      if (!programada.isUtc) {
        throw const FormatException('programadaUtc deve conter o sufixo UTC.');
      }

      return PayloadNotificacao(
        tipo: tipo,
        doseKey: _lerTexto(decoded, 'doseKey'),
        tratamentoId: _lerTexto(decoded, 'tratamentoId'),
        medicamentoId: _lerTexto(decoded, 'medicamentoId'),
        regraId: _lerTexto(decoded, 'regraId'),
        dataHoraProgramadaUtc: programada,
        fusoHorario: _lerTexto(decoded, 'fusoHorario'),
        titulo: _lerTexto(decoded, 'titulo'),
        corpo: _lerTexto(decoded, 'corpo'),
        horaRecorrencia: tipo == TipoPayloadNotificacao.recorrenciaDiaria
            ? _lerInteiro(decoded, 'horaRecorrencia')
            : null,
        minutoRecorrencia: tipo == TipoPayloadNotificacao.recorrenciaDiaria
            ? _lerInteiro(decoded, 'minutoRecorrencia')
            : null,
        // Payloads v1 criados antes deste campo usavam implicitamente zero.
        segundoRecorrencia: tipo == TipoPayloadNotificacao.recorrenciaDiaria
            ? _lerInteiroOpcional(decoded, 'segundoRecorrencia') ?? 0
            : null,
        lembrarEmUtc: tipo == TipoPayloadNotificacao.adiamento
            // Adiamentos v1 anteriores ao fingerprint do horario continuam
            // acionaveis; a proxima reconciliacao grava o campo explicito.
            ? decoded['lembrarEmUtc'] == null
                  ? programada
                  : _lerDataUtc(decoded, 'lembrarEmUtc')
            : null,
      );
    } on FormatException {
      rethrow;
    } on Object catch (erro) {
      throw FormatException('Payload de notificacao invalido.', erro);
    }
  }

  static PayloadNotificacao? tentarDecodificar(String? valor) {
    if (valor == null || valor.isEmpty) return null;
    try {
      return decodificar(valor);
    } on FormatException {
      return null;
    }
  }

  /// Reconhece inclusive versoes antigas ou corrompidas que ainda pertencem
  /// ao aplicativo, permitindo que a reconciliacao remova alarmes obsoletos.
  static bool pertenceAoAplicativo(String? valor) {
    if (valor == null || valor.isEmpty) return false;
    try {
      final decoded = jsonDecode(valor);
      return decoded is Map<String, dynamic> && decoded['origem'] == _origem;
    } on FormatException {
      return false;
    }
  }

  static String _lerTexto(Map<String, dynamic> json, String chave) {
    final valor = json[chave];
    if (valor is! String || valor.trim().isEmpty) {
      throw FormatException('Campo obrigatorio invalido: $chave.');
    }
    return valor;
  }

  static int _lerInteiro(Map<String, dynamic> json, String chave) {
    final valor = json[chave];
    if (valor is! int) {
      throw FormatException('Campo obrigatorio invalido: $chave.');
    }
    return valor;
  }

  static int? _lerInteiroOpcional(Map<String, dynamic> json, String chave) {
    final valor = json[chave];
    if (valor == null) return null;
    if (valor is! int) {
      throw FormatException('Campo opcional invalido: $chave.');
    }
    return valor;
  }

  static DateTime _lerDataUtc(Map<String, dynamic> json, String chave) {
    final data = DateTime.parse(_lerTexto(json, chave));
    if (!data.isUtc) {
      throw FormatException('$chave deve conter o sufixo UTC.');
    }
    return data;
  }
}

void _exigirTexto(String valor, String nome) {
  if (valor.trim().isEmpty) {
    throw ArgumentError.value(valor, nome, 'O valor nao pode ser vazio.');
  }
}
