import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/banco/app_database.dart';
import '../../../core/banco/conversor_data_civil.dart';
import '../../../core/data_hora/relogio.dart';
import '../../tratamentos/dominio/recorrencia_persistida.dart';
import '../dominio/cadastro_medicamento.dart';

class MedicamentoResumo {
  const MedicamentoResumo({
    required this.medicamento,
    this.tratamento,
    this.horarios = const [],
  });

  final MedicamentoDb medicamento;
  final TratamentoDb? tratamento;
  final List<HorarioTratamentoDb> horarios;
}

class TratamentoCompletoDb {
  const TratamentoCompletoDb({
    required this.medicamento,
    required this.tratamento,
    required this.horarios,
  });

  final MedicamentoDb medicamento;
  final TratamentoDb tratamento;
  final List<HorarioTratamentoDb> horarios;
}

class MedicamentoRepository {
  MedicamentoRepository(
    this._db, {
    Uuid? uuid,
    this.relogio = const RelogioSistema(),
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;
  final Relogio relogio;

  Stream<List<MedicamentoResumo>> observarTodos() {
    final query =
        _db.select(_db.medicamentos).join([
          leftOuterJoin(
            _db.tratamentos,
            _db.tratamentos.medicamentoId.equalsExp(_db.medicamentos.id) &
                _db.tratamentos.ativo.equals(true),
          ),
          leftOuterJoin(
            _db.horariosTratamento,
            _db.horariosTratamento.tratamentoId.equalsExp(_db.tratamentos.id),
          ),
        ])..orderBy([
          OrderingTerm.asc(_db.medicamentos.nome),
          OrderingTerm.asc(_db.horariosTratamento.ordem),
        ]);

    return query.watch().map(_agruparResumos);
  }

  Future<List<TratamentoCompletoDb>> obterTratamentosAtivos() async {
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
          ])
          ..where(
            _db.tratamentos.ativo.equals(true) &
                _db.medicamentos.ativo.equals(true),
          )
          ..orderBy([
            OrderingTerm.asc(_db.tratamentos.dataInicio),
            OrderingTerm.asc(_db.horariosTratamento.ordem),
          ]);
    final rows = await query.get();
    final grouped = <String, TratamentoCompletoDb>{};
    for (final row in rows) {
      final tratamento = row.readTable(_db.tratamentos);
      final medicamento = row.readTable(_db.medicamentos);
      final horario = row.readTableOrNull(_db.horariosTratamento);
      final current = grouped[tratamento.id];
      grouped[tratamento.id] = TratamentoCompletoDb(
        medicamento: medicamento,
        tratamento: tratamento,
        horarios: [...?current?.horarios, ?horario],
      );
    }
    return grouped.values.toList(growable: false);
  }

  Future<MedicamentoResumo?> obterPorId(String id) async {
    final medicamento = await (_db.select(
      _db.medicamentos,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (medicamento == null) return null;
    final tratamento =
        await (_db.select(_db.tratamentos)
              ..where(
                (table) =>
                    table.medicamentoId.equals(id) & table.ativo.equals(true),
              )
              ..orderBy([(table) => OrderingTerm.desc(table.criadoEm)])
              ..limit(1))
            .getSingleOrNull();
    final horarios = tratamento == null
        ? const <HorarioTratamentoDb>[]
        : await (_db.select(_db.horariosTratamento)
                ..where((table) => table.tratamentoId.equals(tratamento.id))
                ..orderBy([(table) => OrderingTerm.asc(table.ordem)]))
              .get();
    return MedicamentoResumo(
      medicamento: medicamento,
      tratamento: tratamento,
      horarios: horarios,
    );
  }

  Future<String> cadastrar(
    CadastroMedicamento cadastro, {
    DateTime? agora,
  }) async {
    cadastro.validar();
    final now = agora ?? relogio.agora();
    final medicamentoId = _uuid.v4();
    final tratamentoId = _uuid.v4();
    final sortedHours = [...cadastro.horarios]..sort();
    final recorrencia = RecorrenciaPersistida.colunas(cadastro.recorrencia);

    await _db.transaction(() async {
      await _db
          .into(_db.medicamentos)
          .insert(
            MedicamentosCompanion.insert(
              id: medicamentoId,
              nome: cadastro.nome.trim(),
              concentracao: Value(_vazioParaNulo(cadastro.concentracao)),
              formaFarmaceutica: Value(cadastro.formaFarmaceutica),
              unidadeDosePadrao: Value(cadastro.unidadeDosePadrao),
              unidadeEstoque: Value(
                cadastro.controlarEstoque
                    ? _vazioParaNulo(cadastro.unidadeEstoque)
                    : null,
              ),
              observacoes: Value(_vazioParaNulo(cadastro.observacoes)),
              controleEstoque: Value(cadastro.controlarEstoque),
              criadoEm: now,
              atualizadoEm: now,
            ),
          );
      await _db
          .into(_db.tratamentos)
          .insert(
            TratamentosCompanion.insert(
              id: tratamentoId,
              medicamentoId: medicamentoId,
              quantidadeDose: cadastro.quantidadeDose,
              unidadeDose: cadastro.unidadeDose.trim(),
              consumoEstoquePorDose: Value(
                cadastro.controlarEstoque
                    ? cadastro.consumoEstoquePorDose
                    : null,
              ),
              dataInicio: _somenteData(cadastro.dataInicio),
              dataFim: Value(
                cadastro.usoContinuo || cadastro.dataFim == null
                    ? null
                    : _somenteData(cadastro.dataFim!),
              ),
              usoContinuo: cadastro.usoContinuo,
              tipoAgendamento: cadastro.tipoAgendamento.name,
              dataHoraAncora: Value(cadastro.dataHoraAncora),
              intervaloMinutos: Value(cadastro.intervaloMinutos),
              recorrencia: Value(recorrencia.tipo),
              recorrenciaIntervalo: Value(recorrencia.intervalo),
              recorrenciaDiasSemana: Value(recorrencia.diasSemana),
              recorrenciaDiaDoMes: Value(recorrencia.diaDoMes),
              instrucoes: Value(_vazioParaNulo(cadastro.instrucoes)),
              criadoEm: now,
              atualizadoEm: now,
            ),
          );
      if (cadastro.tipoAgendamento == TipoAgendamentoCadastro.horariosFixos) {
        await _db.batch((batch) {
          batch.insertAll(_db.horariosTratamento, [
            for (var index = 0; index < sortedHours.length; index++)
              HorariosTratamentoCompanion.insert(
                id: _uuid.v4(),
                tratamentoId: tratamentoId,
                hora: sortedHours[index].hora,
                minuto: sortedHours[index].minuto,
                ordem: index,
              ),
          ]);
        });
      }
      final initial = cadastro.estoqueInicial ?? 0;
      if (cadastro.controlarEstoque && initial > 0) {
        await _db
            .into(_db.movimentacoesEstoque)
            .insert(
              MovimentacoesEstoqueCompanion.insert(
                id: _uuid.v4(),
                medicamentoId: medicamentoId,
                tipo: 'entradaReposicao',
                quantidade: initial,
                unidade: cadastro.unidadeEstoque!.trim(),
                dataHora: now,
                observacao: const Value('Estoque inicial'),
              ),
            );
      }
    });
    return medicamentoId;
  }

  /// Cria uma nova configuração para um medicamento que não possui tratamento
  /// ativo, preservando integralmente tratamentos e registros anteriores.
  Future<String> criarTratamento({
    required String medicamentoId,
    required EdicaoTratamento edicao,
    DateTime? agora,
  }) async {
    final now = agora ?? relogio.agora();
    final medicamento = await (_db.select(
      _db.medicamentos,
    )..where((table) => table.id.equals(medicamentoId))).getSingleOrNull();
    if (medicamento == null || !medicamento.ativo) {
      throw StateError('Medicamento ativo não encontrado.');
    }
    final existente =
        await (_db.select(_db.tratamentos)
              ..where(
                (table) =>
                    table.medicamentoId.equals(medicamentoId) &
                    table.ativo.equals(true),
              )
              ..limit(1))
            .getSingleOrNull();
    if (existente != null) {
      throw StateError('O medicamento já possui um tratamento ativo.');
    }
    edicao.validar(controlaEstoque: medicamento.controleEstoque);
    final today = _somenteData(now);
    final start = _somenteData(edicao.dataInicio);
    if (start.isBefore(today)) {
      throw const FormularioInvalido(
        'O tratamento não pode começar em uma data passada.',
      );
    }

    final tratamentoId = _uuid.v4();
    final sortedHours = [...edicao.horarios]..sort();
    final recorrencia = RecorrenciaPersistida.colunas(edicao.recorrencia);
    await _db.transaction(() async {
      await _db
          .into(_db.tratamentos)
          .insert(
            TratamentosCompanion.insert(
              id: tratamentoId,
              medicamentoId: medicamentoId,
              quantidadeDose: edicao.quantidadeDose,
              unidadeDose: edicao.unidadeDose.trim(),
              consumoEstoquePorDose: Value(
                medicamento.controleEstoque
                    ? edicao.consumoEstoquePorDose
                    : null,
              ),
              dataInicio: start,
              dataFim: Value(
                edicao.usoContinuo || edicao.dataFim == null
                    ? null
                    : _somenteData(edicao.dataFim!),
              ),
              usoContinuo: edicao.usoContinuo,
              tipoAgendamento: edicao.tipoAgendamento.name,
              dataHoraAncora: Value(edicao.dataHoraAncora),
              intervaloMinutos: Value(edicao.intervaloMinutos),
              recorrencia: Value(recorrencia.tipo),
              recorrenciaIntervalo: Value(recorrencia.intervalo),
              recorrenciaDiasSemana: Value(recorrencia.diasSemana),
              recorrenciaDiaDoMes: Value(recorrencia.diaDoMes),
              instrucoes: Value(_vazioParaNulo(edicao.instrucoes)),
              criadoEm: now,
              atualizadoEm: now,
            ),
          );
      if (edicao.tipoAgendamento == TipoAgendamentoCadastro.horariosFixos) {
        await _db.batch((batch) {
          batch.insertAll(_db.horariosTratamento, [
            for (var index = 0; index < sortedHours.length; index++)
              HorariosTratamentoCompanion.insert(
                id: _uuid.v4(),
                tratamentoId: tratamentoId,
                hora: sortedHours[index].hora,
                minuto: sortedHours[index].minuto,
                ordem: index,
              ),
          ]);
        });
      }
    });
    return tratamentoId;
  }

  /// Encerra a configuração atual e cria uma nova somente para o futuro.
  Future<String> substituirTratamento({
    required String tratamentoAtualId,
    required EdicaoTratamento edicao,
    DateTime? agora,
  }) async {
    final now = agora ?? relogio.agora();
    final atual = await (_db.select(
      _db.tratamentos,
    )..where((table) => table.id.equals(tratamentoAtualId))).getSingleOrNull();
    if (atual == null || !atual.ativo) {
      throw StateError('Tratamento ativo não encontrado.');
    }
    final medicamento = await (_db.select(
      _db.medicamentos,
    )..where((table) => table.id.equals(atual.medicamentoId))).getSingle();
    edicao.validar(controlaEstoque: medicamento.controleEstoque);
    final today = DateTime(now.year, now.month, now.day);
    final newStart = _somenteData(edicao.dataInicio);
    if (!newStart.isAfter(today)) {
      throw const FormularioInvalido(
        'A nova configuração deve começar a partir de amanhã.',
      );
    }
    final novoId = _uuid.v4();
    final sortedHours = [...edicao.horarios]..sort();
    final recorrencia = RecorrenciaPersistida.colunas(edicao.recorrencia);
    await _db.transaction(() async {
      await (_db.update(
        _db.tratamentos,
      )..where((table) => table.id.equals(tratamentoAtualId))).write(
        TratamentosCompanion(
          usoContinuo: const Value(false),
          dataFim: Value(newStart.subtract(const Duration(days: 1))),
          atualizadoEm: Value(now),
        ),
      );
      await _db
          .into(_db.tratamentos)
          .insert(
            TratamentosCompanion.insert(
              id: novoId,
              medicamentoId: atual.medicamentoId,
              quantidadeDose: edicao.quantidadeDose,
              unidadeDose: edicao.unidadeDose.trim(),
              consumoEstoquePorDose: Value(
                medicamento.controleEstoque
                    ? edicao.consumoEstoquePorDose
                    : null,
              ),
              dataInicio: _somenteData(edicao.dataInicio),
              dataFim: Value(
                edicao.usoContinuo || edicao.dataFim == null
                    ? null
                    : _somenteData(edicao.dataFim!),
              ),
              usoContinuo: edicao.usoContinuo,
              tipoAgendamento: edicao.tipoAgendamento.name,
              dataHoraAncora: Value(edicao.dataHoraAncora),
              intervaloMinutos: Value(edicao.intervaloMinutos),
              recorrencia: Value(recorrencia.tipo),
              recorrenciaIntervalo: Value(recorrencia.intervalo),
              recorrenciaDiasSemana: Value(recorrencia.diasSemana),
              recorrenciaDiaDoMes: Value(recorrencia.diaDoMes),
              instrucoes: Value(_vazioParaNulo(edicao.instrucoes)),
              criadoEm: now,
              atualizadoEm: now,
            ),
          );
      if (edicao.tipoAgendamento == TipoAgendamentoCadastro.horariosFixos) {
        await _db.batch((batch) {
          batch.insertAll(_db.horariosTratamento, [
            for (var index = 0; index < sortedHours.length; index++)
              HorariosTratamentoCompanion.insert(
                id: _uuid.v4(),
                tratamentoId: novoId,
                hora: sortedHours[index].hora,
                minuto: sortedHours[index].minuto,
                ordem: index,
              ),
          ]);
        });
      }
      await (_db.delete(
        _db.adiamentosDose,
      )..where((table) => table.tratamentoId.equals(tratamentoAtualId))).go();
    });
    return novoId;
  }

  Future<void> atualizarDados({
    required String id,
    required String nome,
    String? concentracao,
    String? formaFarmaceutica,
    String? unidadeDosePadrao,
    String? observacoes,
    DateTime? agora,
  }) async {
    if (nome.trim().isEmpty) {
      throw const FormularioInvalido('Informe o nome do medicamento.');
    }
    final count =
        await (_db.update(
          _db.medicamentos,
        )..where((table) => table.id.equals(id))).write(
          MedicamentosCompanion(
            nome: Value(nome.trim()),
            concentracao: Value(_vazioParaNulo(concentracao)),
            formaFarmaceutica: Value(_vazioParaNulo(formaFarmaceutica)),
            unidadeDosePadrao: Value(_vazioParaNulo(unidadeDosePadrao)),
            observacoes: Value(_vazioParaNulo(observacoes)),
            atualizadoEm: Value(agora ?? relogio.agora()),
          ),
        );
    if (count == 0) throw StateError('Medicamento não encontrado.');
  }

  /// Ativa o controle de estoque de um medicamento cadastrado sem ele.
  ///
  /// A quantidade informada vira uma movimentação no ledger: entrada inicial
  /// quando não existe saldo anterior e ajuste quando o controle já foi usado
  /// antes, preservando todas as movimentações existentes.
  Future<void> ativarControleEstoque({
    required String medicamentoId,
    required String unidadeEstoque,
    required double quantidadeAtual,
    double? consumoEstoquePorDose,
    DateTime? agora,
  }) async {
    final unidade = _vazioParaNulo(unidadeEstoque);
    if (unidade == null) {
      throw const FormularioInvalido('Informe a unidade usada no estoque.');
    }
    if (quantidadeAtual < 0) {
      throw const FormularioInvalido(
        'A quantidade disponível não pode ser negativa.',
      );
    }
    final now = agora ?? relogio.agora();
    await _db.transaction(() async {
      final medicamento = await (_db.select(
        _db.medicamentos,
      )..where((table) => table.id.equals(medicamentoId))).getSingleOrNull();
      if (medicamento == null || !medicamento.ativo) {
        throw StateError('Medicamento ativo não encontrado.');
      }
      if (medicamento.controleEstoque) {
        throw StateError('O controle de estoque já está ativo.');
      }
      final tratamento =
          await (_db.select(_db.tratamentos)
                ..where(
                  (table) =>
                      table.medicamentoId.equals(medicamentoId) &
                      table.ativo.equals(true),
                )
                ..limit(1))
              .getSingleOrNull();
      if (tratamento != null && (consumoEstoquePorDose ?? 0) <= 0) {
        throw const FormularioInvalido(
          'Informe um consumo de estoque por dose maior que zero.',
        );
      }

      await (_db.update(
        _db.medicamentos,
      )..where((table) => table.id.equals(medicamentoId))).write(
        MedicamentosCompanion(
          controleEstoque: const Value(true),
          unidadeEstoque: Value(unidade),
          atualizadoEm: Value(now),
        ),
      );
      if (tratamento != null) {
        await (_db.update(
          _db.tratamentos,
        )..where((table) => table.id.equals(tratamento.id))).write(
          TratamentosCompanion(
            consumoEstoquePorDose: Value(consumoEstoquePorDose),
            atualizadoEm: Value(now),
          ),
        );
      }

      final saldo = await _saldoDeEstoque(medicamentoId);
      final diferenca = quantidadeAtual - saldo;
      if (diferenca.abs() < 0.000001) return;
      final primeiraEntrada = saldo.abs() < 0.000001 && diferenca > 0;
      await _db
          .into(_db.movimentacoesEstoque)
          .insert(
            MovimentacoesEstoqueCompanion.insert(
              id: _uuid.v4(),
              medicamentoId: medicamentoId,
              tipo: primeiraEntrada
                  ? 'entradaReposicao'
                  : diferenca > 0
                  ? 'ajusteEntrada'
                  : 'ajusteSaida',
              quantidade: diferenca.abs(),
              unidade: unidade,
              dataHora: now,
              observacao: Value(
                primeiraEntrada
                    ? 'Estoque inicial'
                    : 'Ajuste ao ativar o controle de estoque',
              ),
            ),
          );
    });
  }

  /// Desativa o controle de estoque sem apagar o ledger: as movimentações
  /// continuam disponíveis caso o controle seja ativado novamente.
  Future<void> desativarControleEstoque(
    String medicamentoId, {
    DateTime? agora,
  }) async {
    final now = agora ?? relogio.agora();
    await _db.transaction(() async {
      final count =
          await (_db.update(
            _db.medicamentos,
          )..where((table) => table.id.equals(medicamentoId))).write(
            MedicamentosCompanion(
              controleEstoque: const Value(false),
              atualizadoEm: Value(now),
            ),
          );
      if (count == 0) throw StateError('Medicamento não encontrado.');
      await (_db.update(_db.tratamentos)..where(
            (table) =>
                table.medicamentoId.equals(medicamentoId) &
                table.ativo.equals(true),
          ))
          .write(
            TratamentosCompanion(
              consumoEstoquePorDose: const Value<double?>(null),
              atualizadoEm: Value(now),
            ),
          );
    });
  }

  /// Reativa um medicamento inativado. Os tratamentos encerrados continuam
  /// encerrados: uma nova configuração precisa ser criada explicitamente.
  Future<void> reativar(String id, {DateTime? agora}) async {
    final count =
        await (_db.update(
          _db.medicamentos,
        )..where((table) => table.id.equals(id))).write(
          MedicamentosCompanion(
            ativo: const Value(true),
            atualizadoEm: Value(agora ?? relogio.agora()),
          ),
        );
    if (count == 0) throw StateError('Medicamento não encontrado.');
  }

  Future<double> _saldoDeEstoque(String medicamentoId) async {
    final movimentos = await (_db.select(
      _db.movimentacoesEstoque,
    )..where((table) => table.medicamentoId.equals(medicamentoId))).get();
    return movimentos.fold<double>(
      0,
      (total, movimento) =>
          total +
          (movimento.tipo == 'entradaReposicao' ||
                  movimento.tipo == 'ajusteEntrada'
              ? movimento.quantidade
              : -movimento.quantidade),
    );
  }

  Future<int> contarRegistrosDose(String medicamentoId) async {
    final consulta = _db.selectOnly(_db.registrosDose)
      ..addColumns([_db.registrosDose.id.count()])
      ..where(_db.registrosDose.medicamentoId.equals(medicamentoId));
    final linha = await consulta.getSingle();
    return linha.read(_db.registrosDose.id.count()) ?? 0;
  }

  /// Apaga definitivamente um medicamento que ainda não tem histórico.
  ///
  /// Serve para corrigir cadastro errado. As chaves estrangeiras são
  /// `RESTRICT`, então a ordem importa: adiamentos e movimentações saem antes
  /// dos registros e dos tratamentos que as originaram.
  ///
  /// Devolve os caminhos dos anexos, que precisam ser removidos do disco fora
  /// da transação.
  Future<List<String>> excluir(String medicamentoId) async {
    return _db.transaction(() async {
      final medicamento = await (_db.select(
        _db.medicamentos,
      )..where((tabela) => tabela.id.equals(medicamentoId))).getSingleOrNull();
      if (medicamento == null) {
        throw StateError('Medicamento não encontrado.');
      }

      final registros = await contarRegistrosDose(medicamentoId);
      if (registros > 0) {
        throw ExclusaoBloqueadaPorHistorico(registros);
      }

      final anexos = await (_db.select(
        _db.anexos,
      )..where((tabela) => tabela.medicamentoId.equals(medicamentoId))).get();
      final tratamentos = await (_db.select(
        _db.tratamentos,
      )..where((tabela) => tabela.medicamentoId.equals(medicamentoId))).get();
      final tratamentoIds = [
        for (final tratamento in tratamentos) tratamento.id,
      ];

      await (_db.delete(
        _db.adiamentosDose,
      )..where((tabela) => tabela.medicamentoId.equals(medicamentoId))).go();
      await (_db.delete(
        _db.movimentacoesEstoque,
      )..where((tabela) => tabela.medicamentoId.equals(medicamentoId))).go();
      if (tratamentoIds.isNotEmpty) {
        await (_db.delete(
          _db.horariosTratamento,
        )..where((tabela) => tabela.tratamentoId.isIn(tratamentoIds))).go();
      }
      await (_db.delete(
        _db.tratamentos,
      )..where((tabela) => tabela.medicamentoId.equals(medicamentoId))).go();
      await (_db.delete(
        _db.anexos,
      )..where((tabela) => tabela.medicamentoId.equals(medicamentoId))).go();
      await (_db.delete(
        _db.medicamentos,
      )..where((tabela) => tabela.id.equals(medicamentoId))).go();

      return [for (final anexo in anexos) anexo.caminhoRelativo];
    });
  }

  Future<void> inativar(String id, {DateTime? agora}) async {
    final now = agora ?? relogio.agora();
    await _db.transaction(() async {
      await (_db.update(
        _db.medicamentos,
      )..where((table) => table.id.equals(id))).write(
        MedicamentosCompanion(
          ativo: const Value(false),
          atualizadoEm: Value(now),
        ),
      );
      await (_db.update(_db.tratamentos)..where(
            (table) =>
                table.medicamentoId.equals(id) & table.ativo.equals(true),
          ))
          .write(
            TratamentosCompanion(
              ativo: const Value(false),
              encerradoEm: Value(now),
              atualizadoEm: Value(now),
            ),
          );
      await (_db.delete(
        _db.adiamentosDose,
      )..where((table) => table.medicamentoId.equals(id))).go();
    });
  }

  Future<void> encerrarTratamento(
    String tratamentoId, {
    DateTime? agora,
  }) async {
    final now = agora ?? relogio.agora();
    await _db.transaction(() async {
      final count =
          await (_db.update(
            _db.tratamentos,
          )..where((table) => table.id.equals(tratamentoId))).write(
            TratamentosCompanion(
              ativo: const Value(false),
              encerradoEm: Value(now),
              atualizadoEm: Value(now),
            ),
          );
      if (count == 0) throw StateError('Tratamento não encontrado.');
      await (_db.delete(
        _db.adiamentosDose,
      )..where((table) => table.tratamentoId.equals(tratamentoId))).go();
    });
  }

  /// Encerra regras temporárias cujo último dia já passou, sem remover dados.
  Future<int> encerrarTratamentosVencidos({DateTime? agora}) async {
    final now = agora ?? relogio.agora();
    final today = DateTime(now.year, now.month, now.day);
    return (_db.update(_db.tratamentos)..where(
          (table) =>
              table.ativo.equals(true) &
              table.usoContinuo.equals(false) &
              table.dataFim.isNotNull() &
              table.dataFim.isSmallerThanValue(
                const ConversorDataCivil().toSql(today),
              ),
        ))
        .write(
          TratamentosCompanion(
            ativo: const Value(false),
            encerradoEm: Value(now),
            atualizadoEm: Value(now),
          ),
        );
  }

  List<MedicamentoResumo> _agruparResumos(List<TypedResult> rows) {
    final grouped = <String, MedicamentoResumo>{};
    for (final row in rows) {
      final medicamento = row.readTable(_db.medicamentos);
      final tratamento = row.readTableOrNull(_db.tratamentos);
      final horario = row.readTableOrNull(_db.horariosTratamento);
      final current = grouped[medicamento.id];
      final isNewer =
          tratamento != null &&
          (current?.tratamento == null ||
              tratamento.dataInicio.isAfter(current!.tratamento!.dataInicio));
      final sameTreatment =
          tratamento != null && current?.tratamento?.id == tratamento.id;
      grouped[medicamento.id] = MedicamentoResumo(
        medicamento: medicamento,
        tratamento: isNewer ? tratamento : current?.tratamento ?? tratamento,
        horarios: isNewer
            ? [?horario]
            : sameTreatment
            ? [...?current?.horarios, ?horario]
            : current?.horarios ?? const [],
      );
    }
    return grouped.values.toList(growable: false);
  }
}

String? _vazioParaNulo(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}

DateTime _somenteData(DateTime value) =>
    DateTime(value.year, value.month, value.day);
