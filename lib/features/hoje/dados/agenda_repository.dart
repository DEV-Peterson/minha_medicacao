import 'package:drift/drift.dart';

import '../../../core/banco/app_database.dart';
import '../../../core/data_hora/data_hora_local.dart';
import '../../../core/data_hora/relogio.dart';
import '../../medicamentos/dados/medicamento_repository.dart';
import '../../tratamentos/dominio/modelos_agenda.dart';
import '../dominio/dose_prevista.dart';
import '../dominio/gerador_agenda.dart';

class DoseComEstado {
  const DoseComEstado({
    required this.dose,
    required this.medicamento,
    required this.status,
    this.registro,
  });

  final DosePrevista dose;
  final MedicamentoDb medicamento;
  final StatusDose status;
  final RegistroDoseDb? registro;
}

class AgendaDoDia {
  const AgendaDoDia({required this.data, required this.doses});

  final DateTime data;
  final List<DoseComEstado> doses;

  int get total => doses.length;
  int get tomadas =>
      doses.where((item) => item.status == StatusDose.tomada).length;
  int get restantes => doses
      .where(
        (item) =>
            item.status == StatusDose.pendente ||
            item.status == StatusDose.emAtraso,
      )
      .length;

  DoseComEstado? get proxima {
    for (final dose in doses) {
      if (dose.status == StatusDose.emAtraso ||
          dose.status == StatusDose.pendente) {
        return dose;
      }
    }
    return null;
  }
}

class AgendaRepository {
  const AgendaRepository(
    this._db, {
    this.gerador = const GeradorAgenda(),
    this.relogio = const RelogioSistema(),
  });

  final AppDatabase _db;
  final GeradorAgenda gerador;
  final Relogio relogio;

  Stream<AgendaDoDia> observarDia(DateTime data, {DateTime Function()? agora}) {
    final inicio = DataHoraLocal.inicioDoDia(data);
    final fim = DataHoraLocal.inicioDoProximoDia(data);
    final query =
        _db.select(_db.tratamentos).join([
            innerJoin(
              _db.medicamentos,
              _db.medicamentos.id.equalsExp(_db.tratamentos.medicamentoId),
            ),
            leftOuterJoin(
              _db.horariosTratamento,
              _db.horariosTratamento.tratamentoId.equalsExp(_db.tratamentos.id),
            ),
            leftOuterJoin(
              _db.registrosDose,
              _db.registrosDose.tratamentoId.equalsExp(_db.tratamentos.id) &
                  _db.registrosDose.dataHoraProgramada.isBiggerOrEqualValue(
                    inicio,
                  ) &
                  _db.registrosDose.dataHoraProgramada.isSmallerThanValue(fim),
            ),
          ])
          ..where(
            _db.tratamentos.ativo.equals(true) &
                _db.medicamentos.ativo.equals(true),
          )
          ..orderBy([
            OrderingTerm.asc(_db.tratamentos.dataInicio),
            OrderingTerm.asc(_db.horariosTratamento.ordem),
          ]);

    return query.watch().map(
      (rows) => _montarAgenda(
        data: inicio,
        rows: rows,
        agora: (agora ?? relogio.agora)(),
      ),
    );
  }

  Future<AgendaDoDia> obterDia(DateTime data, {DateTime? agora}) async {
    return observarDia(data, agora: () => agora ?? relogio.agora()).first;
  }

  Future<List<TratamentoCompletoDb>> obterTratamentosAtivos() =>
      MedicamentoRepository(_db).obterTratamentosAtivos();

  TratamentoAgenda converterTratamento(TratamentoCompletoDb item) {
    final tratamento = item.tratamento;
    final regra = tratamento.tipoAgendamento == 'intervalo'
        ? RegraIntervaloAncorado(
            id: 'intervalo:${tratamento.id}',
            dataHoraAncora: tratamento.dataHoraAncora!,
            intervalo: Duration(minutes: tratamento.intervaloMinutos!),
          )
        : RegraHorariosFixos(
            item.horarios.map(
              (horario) => HorarioTratamento(
                id: horario.id,
                hora: horario.hora,
                minuto: horario.minuto,
              ),
            ),
          );
    return TratamentoAgenda(
      id: tratamento.id,
      medicamentoId: tratamento.medicamentoId,
      quantidadeDose: tratamento.quantidadeDose,
      unidadeDose: tratamento.unidadeDose,
      consumoEstoquePorDose: tratamento.consumoEstoquePorDose,
      dataInicio: tratamento.dataInicio,
      dataFim: tratamento.dataFim,
      usoContinuo: tratamento.usoContinuo,
      instrucoes: tratamento.instrucoes,
      ativo: tratamento.ativo,
      regra: regra,
    );
  }

  AgendaDoDia _montarAgenda({
    required DateTime data,
    required List<TypedResult> rows,
    required DateTime agora,
  }) {
    final groups = <String, _TratamentoLinhas>{};
    for (final row in rows) {
      final tratamento = row.readTable(_db.tratamentos);
      final medicamento = row.readTable(_db.medicamentos);
      final horario = row.readTableOrNull(_db.horariosTratamento);
      final registro = row.readTableOrNull(_db.registrosDose);
      final group = groups.putIfAbsent(
        tratamento.id,
        () =>
            _TratamentoLinhas(medicamento: medicamento, tratamento: tratamento),
      );
      if (horario != null) group.horarios[horario.id] = horario;
      if (registro != null) group.registros[registro.doseKey] = registro;
    }

    final result = <DoseComEstado>[];
    for (final group in groups.values) {
      final complete = TratamentoCompletoDb(
        medicamento: group.medicamento,
        tratamento: group.tratamento,
        horarios: group.horarios.values.toList()
          ..sort((a, b) => a.ordem.compareTo(b.ordem)),
      );
      final domain = converterTratamento(complete);
      for (final dose in gerador.gerar(
        tratamento: domain,
        periodo: PeriodoAgenda.dia(data),
      )) {
        final registro = group.registros[dose.doseKey];
        final registroStatus = switch (registro?.status) {
          'tomada' => StatusRegistroDose.tomada,
          'naoTomada' => StatusRegistroDose.naoTomada,
          _ => null,
        };
        result.add(
          DoseComEstado(
            dose: dose,
            medicamento: group.medicamento,
            registro: registro,
            status: dose.statusEm(agora, registro: registroStatus),
          ),
        );
      }
    }
    result.sort(
      (a, b) => a.dose.dataHoraProgramada.compareTo(b.dose.dataHoraProgramada),
    );
    return AgendaDoDia(data: data, doses: List.unmodifiable(result));
  }
}

class _TratamentoLinhas {
  _TratamentoLinhas({required this.medicamento, required this.tratamento});

  final MedicamentoDb medicamento;
  final TratamentoDb tratamento;
  final Map<String, HorarioTratamentoDb> horarios = {};
  final Map<String, RegistroDoseDb> registros = {};
}
