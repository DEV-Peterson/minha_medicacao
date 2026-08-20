import 'package:minha_medicacao/core/data_hora/data_hora_local.dart';
import 'package:minha_medicacao/features/hoje/dominio/dose_prevista.dart';
import 'package:minha_medicacao/features/hoje/dominio/identidade_dose.dart';
import 'package:minha_medicacao/features/tratamentos/dominio/modelos_agenda.dart';

/// Motor puro que projeta ocorrências a partir da regra persistida.
final class GeradorAgenda {
  const GeradorAgenda();

  List<DosePrevista> gerar({
    required TratamentoAgenda tratamento,
    required PeriodoAgenda periodo,
  }) {
    if (!tratamento.ativo) {
      return const [];
    }

    final inicio = DataHoraLocal.maisRecente(
      periodo.inicio,
      tratamento.dataInicio,
    );
    final fimDoTratamento = tratamento.fimExclusivo;
    final fim = fimDoTratamento == null
        ? periodo.fimExclusivo
        : DataHoraLocal.maisAntigo(periodo.fimExclusivo, fimDoTratamento);

    if (!fim.isAfter(inicio)) {
      return const [];
    }

    return switch (tratamento.regra) {
      RegraHorariosFixos regra => _gerarHorariosFixos(
        tratamento: tratamento,
        regra: regra,
        inicio: inicio,
        fimExclusivo: fim,
      ),
      RegraIntervaloAncorado regra => _gerarIntervalo(
        tratamento: tratamento,
        regra: regra,
        inicio: inicio,
        fimExclusivo: fim,
      ),
    };
  }

  List<DosePrevista> _gerarHorariosFixos({
    required TratamentoAgenda tratamento,
    required RegraHorariosFixos regra,
    required DateTime inicio,
    required DateTime fimExclusivo,
  }) {
    final doses = <DosePrevista>[];
    var data = DataHoraLocal.inicioDoDia(inicio);

    while (data.isBefore(fimExclusivo)) {
      if (!tratamento.recorrencia.incluiDia(data, tratamento.dataInicio)) {
        data = DataHoraLocal.adicionarDiasCalendario(data, 1);
        continue;
      }
      for (final horario in regra.horarios) {
        final programada = DataHoraLocal.combinar(
          data,
          hora: horario.hora,
          minuto: horario.minuto,
        );
        if (!programada.isBefore(inicio) && programada.isBefore(fimExclusivo)) {
          doses.add(
            _criarDose(
              tratamento: tratamento,
              regraId: horario.id,
              programada: programada,
            ),
          );
        }
      }
      data = DataHoraLocal.adicionarDiasCalendario(data, 1);
    }

    return List.unmodifiable(doses);
  }

  List<DosePrevista> _gerarIntervalo({
    required TratamentoAgenda tratamento,
    required RegraIntervaloAncorado regra,
    required DateTime inicio,
    required DateTime fimExclusivo,
  }) {
    final inicioEfetivo = DataHoraLocal.maisRecente(
      inicio,
      regra.dataHoraAncora,
    );
    if (!fimExclusivo.isAfter(inicioEfetivo)) {
      return const [];
    }

    final intervaloMicros = regra.intervalo.inMicroseconds;
    final distanciaMicros = inicioEfetivo
        .difference(regra.dataHoraAncora)
        .inMicroseconds;
    final saltos = (distanciaMicros + intervaloMicros - 1) ~/ intervaloMicros;

    var programada = regra.dataHoraAncora.add(
      Duration(microseconds: saltos * intervaloMicros),
    );
    final doses = <DosePrevista>[];
    while (programada.isBefore(fimExclusivo)) {
      doses.add(
        _criarDose(
          tratamento: tratamento,
          regraId: regra.id,
          programada: programada,
        ),
      );
      programada = programada.add(regra.intervalo);
    }

    return List.unmodifiable(doses);
  }

  DosePrevista _criarDose({
    required TratamentoAgenda tratamento,
    required String regraId,
    required DateTime programada,
  }) => DosePrevista(
    doseKey: criarDoseKey(
      tratamentoId: tratamento.id,
      regraId: regraId,
      dataHoraProgramada: programada,
    ),
    tratamentoId: tratamento.id,
    medicamentoId: tratamento.medicamentoId,
    regraId: regraId,
    dataHoraProgramada: programada,
    quantidadeDose: tratamento.quantidadeDose,
    unidadeDose: tratamento.unidadeDose,
    consumoEstoquePorDose: tratamento.consumoEstoquePorDose,
    instrucoes: tratamento.instrucoes,
  );
}
