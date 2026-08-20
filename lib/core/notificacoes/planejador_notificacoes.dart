import 'package:timezone/timezone.dart' as tz;

import '../../features/hoje/dados/agenda_repository.dart';
import '../../features/hoje/dominio/dose_prevista.dart';
import '../../features/tratamentos/dominio/modelos_agenda.dart';
import '../data_hora/data_hora_local.dart';
import 'identificador_notificacao.dart';
import 'modelos_notificacao.dart';
import 'payload_notificacao.dart';

typedef GerarIdentificadorNotificacao = int Function(String chaveEstavel);

final class ColisaoIdentificadorNotificacao implements Exception {
  const ColisaoIdentificadorNotificacao({
    required this.id,
    required this.primeiraDoseKey,
    required this.segundaDoseKey,
  });

  final int id;
  final String primeiraDoseKey;
  final String segundaDoseKey;

  @override
  String toString() =>
      'Colisao de ID de notificacao $id entre as doses '
      '$primeiraDoseKey e $segundaDoseKey.';
}

/// Mantida para compatibilidade com consumidores antigos. O planejador nao
/// lanca mais esta excecao: ele conserva as ocorrencias mais proximas e
/// informa o truncamento em [ResultadoPlanejamentoNotificacoes].
final class LimiteAgendamentosNotificacaoExcedido implements Exception {
  const LimiteAgendamentosNotificacaoExcedido(this.limite);

  final int limite;

  @override
  String toString() =>
      'A agenda excede o limite seguro de $limite alarmes Android.';
}

final class PlanejadorNotificacoes {
  PlanejadorNotificacoes(
    this._agendaRepository, {
    this.diasNoHorizonte = 7,
    this.maximoAgendamentos = limiteSeguroAgendamentosAndroid,
    GerarIdentificadorNotificacao? gerarIdentificador,
  }) : _gerarIdentificador =
           gerarIdentificador ?? IdentificadorNotificacao.paraChave {
    if (diasNoHorizonte <= 0) {
      throw ArgumentError.value(
        diasNoHorizonte,
        'diasNoHorizonte',
        'O horizonte deve ter ao menos um dia.',
      );
    }
    if (maximoAgendamentos <= 0) {
      throw ArgumentError.value(
        maximoAgendamentos,
        'maximoAgendamentos',
        'O limite deve ser positivo.',
      );
    }
  }

  final AgendaRepository _agendaRepository;

  /// Horizonte historico da API. Ocorrencias individuais agora usam uma
  /// janela rolante adaptativa que cresce ate ocupar [maximoAgendamentos].
  final int diasNoHorizonte;
  final int maximoAgendamentos;
  final GerarIdentificadorNotificacao _gerarIdentificador;

  static String chaveDaDose(String doseKey) => 'dose|$doseKey';

  static String chaveDoAdiamento(String doseKey) => 'adiamento|$doseKey';

  static String chaveDaRecorrencia(
    String tratamentoId,
    String regraId, {
    required int hora,
    required int minuto,
    int segundo = 0,
  }) =>
      'recorrencia-diaria|$tratamentoId|$regraId|'
      '${hora.toString().padLeft(2, '0')}:'
      '${minuto.toString().padLeft(2, '0')}:'
      '${segundo.toString().padLeft(2, '0')}';

  int idDaDose(String doseKey) => _gerarIdentificador(chaveDaDose(doseKey));

  int idDoAdiamento(String doseKey) =>
      _gerarIdentificador(chaveDoAdiamento(doseKey));

  int idDaRecorrencia(
    String tratamentoId,
    String regraId, {
    required int hora,
    required int minuto,
    int segundo = 0,
  }) => _gerarIdentificador(
    chaveDaRecorrencia(
      tratamentoId,
      regraId,
      hora: hora,
      minuto: minuto,
      segundo: segundo,
    ),
  );

  Future<List<AgendamentoNotificacao>> planejar({
    required DateTime agora,
    Set<String> dosesSuprimidas = const {},
    int? limiteAgendamentos,
  }) async {
    final resultado = await planejarComDiagnostico(
      agora: agora,
      dosesSuprimidas: dosesSuprimidas,
      limiteAgendamentos: limiteAgendamentos,
    );
    return resultado.agendamentos;
  }

  /// Planeja recorrencias diarias e uma janela rolante de one-shots.
  ///
  /// Horarios fixos continuos e intervalos continuos que dividem exatamente
  /// 24 horas ocupam um alarme por slot diario. Os demais intervalos mantem a
  /// sequencia absoluta da ancora e recebem as ocorrencias mais proximas ate o
  /// limite. Assim uma agenda extensa nunca derruba toda a reconciliacao.
  Future<ResultadoPlanejamentoNotificacoes> planejarComDiagnostico({
    required DateTime agora,
    Set<String> dosesSuprimidas = const {},
    int? limiteAgendamentos,
  }) async {
    final limite = limiteAgendamentos ?? maximoAgendamentos;
    if (limite < 0 || limite > maximoAgendamentos) {
      throw RangeError.range(
        limite,
        0,
        maximoAgendamentos,
        'limiteAgendamentos',
      );
    }

    final ids = <int, String>{};
    final recorrencias = <AgendamentoNotificacao>[];
    final fluxos = <_FluxoOcorrencias>[];
    final cacheAgenda = <String, Future<AgendaDoDia>>{};
    final completos = await _agendaRepository.obterTratamentosAtivos();

    for (final completo in completos) {
      final tratamento = _agendaRepository.converterTratamento(completo);
      final conteudo = _conteudoValores(
        nomeMedicamento: completo.medicamento.nome,
        concentracao: completo.medicamento.concentracao,
        quantidadeDose: tratamento.quantidadeDose,
        unidadeDose: tratamento.unidadeDose,
        instrucoes: tratamento.instrucoes,
      );
      final regra = tratamento.regra;

      // A notificacao diaria repetida so vale quando a agenda ocorre todo
      // dia. Recorrencias por dias, semanas ou meses caem nas ocorrencias
      // individuais logo abaixo, senao o aviso tocaria em dias sem dose.
      if (tratamento.usoContinuo &&
          regra is RegraHorariosFixos &&
          tratamento.recorrencia is RecorrenciaDiaria) {
        for (final horario in regra.horarios) {
          recorrencias.add(
            await _criarRecorrencia(
              agora: agora,
              tratamento: tratamento,
              regraId: horario.id,
              primeiraOcorrencia: _combinar(
                tratamento.dataInicio,
                hora: horario.hora,
                minuto: horario.minuto,
              ),
              hora: horario.hora,
              minuto: horario.minuto,
              segundo: 0,
              conteudo: conteudo,
              dosesSuprimidas: dosesSuprimidas,
              cacheAgenda: cacheAgenda,
              ids: ids,
            ),
          );
        }
        continue;
      }

      if (tratamento.usoContinuo &&
          regra is RegraIntervaloAncorado &&
          _divideExatamenteUmDia(regra.intervalo)) {
        final quantidadeSlots =
            const Duration(days: 1).inMicroseconds ~/
            regra.intervalo.inMicroseconds;
        for (var indice = 0; indice < quantidadeSlots; indice++) {
          final primeira = regra.dataHoraAncora.add(
            Duration(microseconds: indice * regra.intervalo.inMicroseconds),
          );
          recorrencias.add(
            await _criarRecorrencia(
              agora: agora,
              tratamento: tratamento,
              regraId: regra.id,
              primeiraOcorrencia: primeira,
              hora: primeira.hour,
              minuto: primeira.minute,
              segundo: primeira.second,
              conteudo: conteudo,
              dosesSuprimidas: dosesSuprimidas,
              cacheAgenda: cacheAgenda,
              ids: ids,
            ),
          );
        }
        continue;
      }

      switch (regra) {
        case RegraHorariosFixos():
          for (final horario in regra.horarios) {
            final fluxo = _criarFluxoHorario(
              agora: agora,
              tratamento: tratamento,
              horario: horario,
            );
            if (fluxo != null) fluxos.add(fluxo);
          }
        case RegraIntervaloAncorado():
          final fluxo = _criarFluxoIntervalo(
            agora: agora,
            tratamento: tratamento,
            regra: regra,
          );
          if (fluxo != null) fluxos.add(fluxo);
      }
    }

    recorrencias.sort(_compararAgendamentos);
    final agendamentos = recorrencias.take(limite).toList();
    var truncado = recorrencias.length > limite;
    DateTime? coberturaPlanejadaAte;

    while (agendamentos.length < limite && fluxos.isNotEmpty) {
      final candidato = _retirarProximaOcorrencia(fluxos);
      final item = await _obterItem(
        candidato,
        agora: agora,
        cacheAgenda: cacheAgenda,
      );
      if (!_deveAgendar(item, candidato, agora, dosesSuprimidas)) {
        continue;
      }

      final dose = item!.dose;
      final chave = chaveDaDose(dose.doseKey);
      final id = idDaDose(dose.doseKey);
      _registrarId(ids: ids, id: id, chave: chave);
      final conteudo = _conteudo(item);
      agendamentos.add(
        AgendamentoNotificacao(
          id: id,
          dataHoraLocal: dose.dataHoraProgramada,
          payload: PayloadNotificacao(
            tipo: TipoPayloadNotificacao.dose,
            doseKey: dose.doseKey,
            tratamentoId: dose.tratamentoId,
            medicamentoId: dose.medicamentoId,
            regraId: dose.regraId,
            dataHoraProgramadaUtc: dose.dataHoraProgramada.toUtc(),
            fusoHorario: tz.local.name,
            titulo: conteudo.$1,
            corpo: conteudo.$2,
          ),
        ),
      );
      coberturaPlanejadaAte = dose.dataHoraProgramada;
    }

    if (!truncado && agendamentos.length == limite && fluxos.isNotEmpty) {
      truncado = await _haOutraOcorrenciaPendente(
        fluxos,
        agora: agora,
        dosesSuprimidas: dosesSuprimidas,
        cacheAgenda: cacheAgenda,
      );
    }

    agendamentos.sort(_compararAgendamentos);
    return ResultadoPlanejamentoNotificacoes(
      agendamentos: List.unmodifiable(agendamentos),
      truncado: truncado,
      coberturaPlanejadaAte: truncado ? coberturaPlanejadaAte : null,
    );
  }

  static (String, String) conteudoDeDose(DoseComEstado item) => _conteudo(item);

  static (String, String) _conteudo(DoseComEstado item) {
    final dose = item.dose;
    return _conteudoValores(
      nomeMedicamento: item.medicamento.nome,
      concentracao: item.medicamento.concentracao,
      quantidadeDose: dose.quantidadeDose,
      unidadeDose: dose.unidadeDose,
      instrucoes: dose.instrucoes,
    );
  }

  static (String, String) _conteudoValores({
    required String nomeMedicamento,
    required String? concentracao,
    required double quantidadeDose,
    required String unidadeDose,
    required String? instrucoes,
  }) {
    final quantidade = quantidadeDose == quantidadeDose.truncate()
        ? quantidadeDose.truncate().toString()
        : quantidadeDose.toString();
    final concentracaoNormalizada = concentracao?.trim();
    final nomeCompleto =
        concentracaoNormalizada == null || concentracaoNormalizada.isEmpty
        ? nomeMedicamento
        : '$nomeMedicamento $concentracaoNormalizada';
    final linhas = <String>[nomeCompleto, 'Tomar $quantidade $unidadeDose'];
    final instrucao = instrucoes?.trim();
    if (instrucao != null && instrucao.isNotEmpty) {
      linhas.add(instrucao);
    }
    return ('Hora do medicamento', linhas.join('\n'));
  }

  Future<AgendamentoNotificacao> _criarRecorrencia({
    required DateTime agora,
    required TratamentoAgenda tratamento,
    required String regraId,
    required DateTime primeiraOcorrencia,
    required int hora,
    required int minuto,
    required int segundo,
    required (String, String) conteudo,
    required Set<String> dosesSuprimidas,
    required Map<String, Future<AgendaDoDia>> cacheAgenda,
    required Map<int, String> ids,
  }) async {
    final chave = chaveDaRecorrencia(
      tratamento.id,
      regraId,
      hora: hora,
      minuto: minuto,
      segundo: segundo,
    );
    final id = idDaRecorrencia(
      tratamento.id,
      regraId,
      hora: hora,
      minuto: minuto,
      segundo: segundo,
    );
    _registrarId(ids: ids, id: id, chave: chave);
    final proxima = await _proximaOcorrenciaDiariaDisponivel(
      agora: agora,
      primeiraOcorrencia: primeiraOcorrencia,
      hora: hora,
      minuto: minuto,
      segundo: segundo,
      tratamentoId: tratamento.id,
      regraId: regraId,
      dosesSuprimidas: dosesSuprimidas,
      cacheAgenda: cacheAgenda,
    );
    return AgendamentoNotificacao(
      id: id,
      dataHoraLocal: proxima,
      recorrenciaDiaria: true,
      payload: PayloadNotificacao(
        tipo: TipoPayloadNotificacao.recorrenciaDiaria,
        // Identidade do slot; o callback resolve a doseKey concreta na agenda.
        doseKey: chave,
        tratamentoId: tratamento.id,
        medicamentoId: tratamento.medicamentoId,
        regraId: regraId,
        dataHoraProgramadaUtc: proxima.toUtc(),
        fusoHorario: tz.local.name,
        titulo: conteudo.$1,
        corpo: conteudo.$2,
        horaRecorrencia: hora,
        minutoRecorrencia: minuto,
        segundoRecorrencia: segundo,
      ),
    );
  }

  Future<DateTime> _proximaOcorrenciaDiariaDisponivel({
    required DateTime agora,
    required DateTime primeiraOcorrencia,
    required int hora,
    required int minuto,
    required int segundo,
    required String tratamentoId,
    required String regraId,
    required Set<String> dosesSuprimidas,
    required Map<String, Future<AgendaDoDia>> cacheAgenda,
  }) async {
    var dia = DataHoraLocal.inicioDoDia(
      primeiraOcorrencia.isAfter(agora) ? primeiraOcorrencia : agora,
    );
    var ocorrencia = _combinar(
      dia,
      hora: hora,
      minuto: minuto,
      segundo: segundo,
    );
    if (ocorrencia.isBefore(primeiraOcorrencia) || !ocorrencia.isAfter(agora)) {
      ocorrencia = _combinar(
        DataHoraLocal.adicionarDiasCalendario(dia, 1),
        hora: hora,
        minuto: minuto,
        segundo: segundo,
      );
    }

    while (true) {
      final agenda = await _obterAgenda(
        ocorrencia,
        agora: agora,
        cache: cacheAgenda,
      );
      DoseComEstado? doseDoSlot;
      for (final item in agenda.doses) {
        final dose = item.dose;
        if (dose.tratamentoId == tratamentoId &&
            dose.regraId == regraId &&
            dose.dataHoraProgramada.hour == hora &&
            dose.dataHoraProgramada.minute == minuto &&
            dose.dataHoraProgramada.second == segundo) {
          doseDoSlot = item;
          break;
        }
      }
      if (doseDoSlot != null &&
          doseDoSlot.registro == null &&
          !dosesSuprimidas.contains(doseDoSlot.dose.doseKey)) {
        return doseDoSlot.dose.dataHoraProgramada;
      }

      dia = DataHoraLocal.adicionarDiasCalendario(ocorrencia, 1);
      ocorrencia = _combinar(dia, hora: hora, minuto: minuto, segundo: segundo);
    }
  }

  /// Maior salto possível entre duas ocorrências: uma recorrência anual mais
  /// a folga de fevereiro. Serve como trava contra laço infinito.
  static const int _maximoDiasSemOcorrencia = 400;

  static _FluxoOcorrencias? _criarFluxoHorario({
    required DateTime agora,
    required TratamentoAgenda tratamento,
    required HorarioTratamento horario,
  }) {
    var dia = DataHoraLocal.inicioDoDia(
      tratamento.dataInicio.isAfter(agora) ? tratamento.dataInicio : agora,
    );
    var primeira = _combinar(dia, hora: horario.hora, minuto: horario.minuto);
    if (primeira.isBefore(tratamento.dataInicio) || !primeira.isAfter(agora)) {
      dia = DataHoraLocal.adicionarDiasCalendario(dia, 1);
      primeira = _combinar(dia, hora: horario.hora, minuto: horario.minuto);
    }
    final primeiraValida = _ajustarParaDiaValido(tratamento, primeira);
    if (primeiraValida == null) return null;

    final fim = tratamento.fimExclusivo;
    if (fim != null && !primeiraValida.isBefore(fim)) return null;

    return _FluxoOcorrencias(
      tratamentoId: tratamento.id,
      regraId: horario.id,
      proxima: primeiraValida,
      avancar: (atual) {
        final seguinte = _combinar(
          DataHoraLocal.adicionarDiasCalendario(atual, 1),
          hora: horario.hora,
          minuto: horario.minuto,
        );
        final proxima = _ajustarParaDiaValido(tratamento, seguinte);
        if (proxima == null) return null;
        return fim == null || proxima.isBefore(fim) ? proxima : null;
      },
    );
  }

  /// Avança até o próximo dia que a recorrência aceita.
  ///
  /// Sem isso, uma dose semanal ou mensal faria o planejador percorrer dia a
  /// dia — e cada dia custa uma consulta de agenda ao banco.
  static DateTime? _ajustarParaDiaValido(
    TratamentoAgenda tratamento,
    DateTime candidata,
  ) {
    final recorrencia = tratamento.recorrencia;
    if (recorrencia is RecorrenciaDiaria) return candidata;

    var atual = candidata;
    for (var passo = 0; passo < _maximoDiasSemOcorrencia; passo++) {
      if (recorrencia.incluiDia(atual, tratamento.dataInicio)) return atual;
      atual = DataHoraLocal.adicionarDiasCalendario(atual, 1);
    }
    return null;
  }

  static _FluxoOcorrencias? _criarFluxoIntervalo({
    required DateTime agora,
    required TratamentoAgenda tratamento,
    required RegraIntervaloAncorado regra,
  }) {
    final intervaloMicros = regra.intervalo.inMicroseconds;
    var saltos = 0;
    final referencia = tratamento.dataInicio.isAfter(agora)
        ? tratamento.dataInicio
        : agora;
    if (referencia.isAfter(regra.dataHoraAncora)) {
      saltos =
          referencia.difference(regra.dataHoraAncora).inMicroseconds ~/
          intervaloMicros;
    }
    var primeira = regra.dataHoraAncora.add(
      Duration(microseconds: saltos * intervaloMicros),
    );
    while (primeira.isBefore(tratamento.dataInicio) ||
        !primeira.isAfter(agora)) {
      primeira = primeira.add(regra.intervalo);
    }
    final fim = tratamento.fimExclusivo;
    if (fim != null && !primeira.isBefore(fim)) return null;

    return _FluxoOcorrencias(
      tratamentoId: tratamento.id,
      regraId: regra.id,
      proxima: primeira,
      avancar: (atual) {
        final proxima = atual.add(regra.intervalo);
        return fim == null || proxima.isBefore(fim) ? proxima : null;
      },
    );
  }

  static _OcorrenciaCandidata _retirarProximaOcorrencia(
    List<_FluxoOcorrencias> fluxos,
  ) {
    fluxos.sort((a, b) => a.proxima.compareTo(b.proxima));
    final fluxo = fluxos.removeAt(0);
    final ocorrencia = _OcorrenciaCandidata(
      tratamentoId: fluxo.tratamentoId,
      regraId: fluxo.regraId,
      dataHora: fluxo.proxima,
    );
    fluxo.avancar();
    if (fluxo.temProxima) fluxos.add(fluxo);
    return ocorrencia;
  }

  Future<DoseComEstado?> _obterItem(
    _OcorrenciaCandidata candidato, {
    required DateTime agora,
    required Map<String, Future<AgendaDoDia>> cacheAgenda,
  }) async {
    final agenda = await _obterAgenda(
      candidato.dataHora,
      agora: agora,
      cache: cacheAgenda,
    );
    for (final item in agenda.doses) {
      final dose = item.dose;
      if (dose.tratamentoId == candidato.tratamentoId &&
          dose.regraId == candidato.regraId &&
          dose.dataHoraProgramada.isAtSameMomentAs(candidato.dataHora)) {
        return item;
      }
    }
    return null;
  }

  Future<bool> _haOutraOcorrenciaPendente(
    List<_FluxoOcorrencias> fluxos, {
    required DateTime agora,
    required Set<String> dosesSuprimidas,
    required Map<String, Future<AgendaDoDia>> cacheAgenda,
  }) async {
    while (fluxos.isNotEmpty) {
      final candidato = _retirarProximaOcorrencia(fluxos);
      final item = await _obterItem(
        candidato,
        agora: agora,
        cacheAgenda: cacheAgenda,
      );
      if (_deveAgendar(item, candidato, agora, dosesSuprimidas)) return true;
    }
    return false;
  }

  static bool _deveAgendar(
    DoseComEstado? item,
    _OcorrenciaCandidata candidato,
    DateTime agora,
    Set<String> dosesSuprimidas,
  ) =>
      item != null &&
      candidato.dataHora.isAfter(agora) &&
      item.registro == null &&
      item.status == StatusDose.pendente &&
      !dosesSuprimidas.contains(item.dose.doseKey);

  Future<AgendaDoDia> _obterAgenda(
    DateTime data, {
    required DateTime agora,
    required Map<String, Future<AgendaDoDia>> cache,
  }) {
    final local = data.isUtc ? data.toLocal() : data;
    final chave = '${local.year}-${local.month}-${local.day}';
    return cache.putIfAbsent(
      chave,
      () => _agendaRepository.obterDia(local, agora: agora),
    );
  }

  static bool _divideExatamenteUmDia(Duration intervalo) {
    final micros = intervalo.inMicroseconds;
    return micros > 0 && const Duration(days: 1).inMicroseconds % micros == 0;
  }

  static DateTime _combinar(
    DateTime data, {
    required int hora,
    required int minuto,
    int segundo = 0,
  }) {
    final local = data.isUtc ? data.toLocal() : data;
    return DateTime(local.year, local.month, local.day, hora, minuto, segundo);
  }

  static int _compararAgendamentos(
    AgendamentoNotificacao primeiro,
    AgendamentoNotificacao segundo,
  ) {
    final porData = primeiro.dataHoraLocal.compareTo(segundo.dataHoraLocal);
    return porData != 0 ? porData : primeiro.id.compareTo(segundo.id);
  }

  static void _registrarId({
    required Map<int, String> ids,
    required int id,
    required String chave,
  }) {
    final anterior = ids[id];
    if (anterior != null && anterior != chave) {
      throw ColisaoIdentificadorNotificacao(
        id: id,
        primeiraDoseKey: anterior,
        segundaDoseKey: chave,
      );
    }
    ids[id] = chave;
  }
}

final class _FluxoOcorrencias {
  _FluxoOcorrencias({
    required this.tratamentoId,
    required this.regraId,
    required DateTime this._proxima,
    required this._avancar,
  });

  final String tratamentoId;
  final String regraId;
  DateTime? _proxima;
  final DateTime? Function(DateTime atual) _avancar;

  DateTime get proxima => _proxima!;
  bool get temProxima => _proxima != null;

  void avancar() {
    _proxima = _avancar(proxima);
  }
}

final class _OcorrenciaCandidata {
  const _OcorrenciaCandidata({
    required this.tratamentoId,
    required this.regraId,
    required this.dataHora,
  });

  final String tratamentoId;
  final String regraId;
  final DateTime dataHora;
}
