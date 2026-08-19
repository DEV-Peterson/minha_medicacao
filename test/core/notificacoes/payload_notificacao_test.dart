import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/notificacoes/payload_notificacao.dart';

void main() {
  PayloadNotificacao criarPayload({
    TipoPayloadNotificacao tipo = TipoPayloadNotificacao.dose,
  }) => PayloadNotificacao(
    tipo: tipo,
    doseKey: tipo == TipoPayloadNotificacao.recorrenciaDiaria
        ? 'recorrencia-diaria|tratamento-1|horario-1|08:00:00'
        : 'dose-v1',
    tratamentoId: 'tratamento-1',
    medicamentoId: 'medicamento-1',
    regraId: 'horario-1',
    dataHoraProgramadaUtc: DateTime.utc(2026, 8, 18, 11),
    fusoHorario: 'America/Sao_Paulo',
    titulo: 'Hora do medicamento',
    corpo: 'Medicamento teste\nTomar 1 comprimido',
    horaRecorrencia: tipo == TipoPayloadNotificacao.recorrenciaDiaria
        ? 8
        : null,
    minutoRecorrencia: tipo == TipoPayloadNotificacao.recorrenciaDiaria
        ? 0
        : null,
    segundoRecorrencia: tipo == TipoPayloadNotificacao.recorrenciaDiaria
        ? 0
        : null,
    lembrarEmUtc: tipo == TipoPayloadNotificacao.adiamento
        ? DateTime.utc(2026, 8, 18, 11, 10)
        : null,
  );

  test('faz round-trip do payload concreto versionado', () {
    final original = criarPayload();

    final restaurado = PayloadNotificacao.decodificar(original.codificar());

    expect(restaurado.tipo, TipoPayloadNotificacao.dose);
    expect(restaurado.doseKey, original.doseKey);
    expect(restaurado.dataHoraProgramadaUtc, original.dataHoraProgramadaUtc);
    expect(restaurado.codificar(), original.codificar());
  });

  test('faz round-trip da regra de recorrencia diaria', () {
    final original = criarPayload(
      tipo: TipoPayloadNotificacao.recorrenciaDiaria,
    );

    final restaurado = PayloadNotificacao.decodificar(original.codificar());

    expect(restaurado.tipo, TipoPayloadNotificacao.recorrenciaDiaria);
    expect(restaurado.horaRecorrencia, 8);
    expect(restaurado.minutoRecorrencia, 0);
    expect(restaurado.segundoRecorrencia, 0);
  });

  test('horario do adiamento participa do payload persistido', () {
    final dezMinutos = criarPayload(tipo: TipoPayloadNotificacao.adiamento);
    final trintaMinutos = PayloadNotificacao(
      tipo: TipoPayloadNotificacao.adiamento,
      doseKey: dezMinutos.doseKey,
      tratamentoId: dezMinutos.tratamentoId,
      medicamentoId: dezMinutos.medicamentoId,
      regraId: dezMinutos.regraId,
      dataHoraProgramadaUtc: dezMinutos.dataHoraProgramadaUtc,
      fusoHorario: dezMinutos.fusoHorario,
      titulo: dezMinutos.titulo,
      corpo: dezMinutos.corpo,
      lembrarEmUtc: DateTime.utc(2026, 8, 18, 11, 30),
    );

    expect(dezMinutos.codificar(), isNot(trintaMinutos.codificar()));
    expect(
      PayloadNotificacao.decodificar(dezMinutos.codificar()).lembrarEmUtc,
      DateTime.utc(2026, 8, 18, 11, 10),
    );
  });

  test('aceita adiamento v1 anterior ao fingerprint do horario', () {
    final json =
        jsonDecode(
              criarPayload(tipo: TipoPayloadNotificacao.adiamento).codificar(),
            )
            as Map<String, dynamic>;
    json.remove('lembrarEmUtc');

    final restaurado = PayloadNotificacao.decodificar(jsonEncode(json));

    expect(restaurado.tipo, TipoPayloadNotificacao.adiamento);
    expect(restaurado.lembrarEmUtc, restaurado.dataHoraProgramadaUtc);
  });

  test('rejeita versao desconhecida mas reconhece que pertence ao app', () {
    final json = jsonDecode(criarPayload().codificar()) as Map<String, dynamic>;
    json['versao'] = 99;
    final codificado = jsonEncode(json);

    expect(PayloadNotificacao.tentarDecodificar(codificado), isNull);
    expect(PayloadNotificacao.pertenceAoAplicativo(codificado), isTrue);
    expect(
      () => PayloadNotificacao.decodificar(codificado),
      throwsFormatException,
    );
  });

  test('nao aceita JSON de outra origem', () {
    const valor = '{"origem":"outro_app","versao":1}';

    expect(PayloadNotificacao.tentarDecodificar(valor), isNull);
    expect(PayloadNotificacao.pertenceAoAplicativo(valor), isFalse);
  });
}
