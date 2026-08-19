import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/banco/app_database.dart';
import '../core/backup/servico_backup.dart';
import '../core/backup/servico_restauracao_backup.dart';
import '../core/backup/transporte_backup.dart';
import '../core/data_hora/relogio.dart';
import '../core/notificacoes/modelos_notificacao.dart';
import '../core/notificacoes/servico_notificacao.dart';
import '../features/configuracoes/dados/configuracao_repository.dart';
import '../features/doses/dados/dose_repository.dart';
import '../features/estoque/dados/estoque_repository.dart';
import '../features/estoque/dominio/previsor_estoque.dart';
import '../features/historico/dados/historico_repository.dart';
import '../features/hoje/dados/agenda_repository.dart';
import '../features/medicamentos/dados/anexo_repository.dart';
import '../features/medicamentos/dados/medicamento_repository.dart';

class ControladorBanco extends StateNotifier<AppDatabase> {
  ControladorBanco() : super(AppDatabase());

  var _fechado = false;

  AppDatabase get banco => state;

  Future<void> fechar() async {
    if (_fechado) return;
    await state.close();
    _fechado = true;
  }

  Future<AppDatabase> reabrir() async {
    if (!_fechado) await fechar();
    state = AppDatabase();
    _fechado = false;
    return state;
  }

  @override
  void dispose() {
    if (!_fechado) unawaited(state.close());
    super.dispose();
  }
}

final controladorBancoProvider =
    StateNotifierProvider<ControladorBanco, AppDatabase>(
      (ref) => ControladorBanco(),
    );

final databaseProvider = Provider<AppDatabase>(
  (ref) => ref.watch(controladorBancoProvider),
);

final relogioProvider = Provider<Relogio>((ref) => const RelogioSistema());

final medicamentoRepositoryProvider = Provider<MedicamentoRepository>(
  (ref) => MedicamentoRepository(
    ref.watch(databaseProvider),
    relogio: ref.watch(relogioProvider),
  ),
);

final anexoRepositoryProvider = Provider<AnexoRepository>(
  (ref) => AnexoRepository(
    ref.watch(databaseProvider),
    relogio: ref.watch(relogioProvider),
  ),
);

final doseRepositoryProvider = Provider<DoseRepository>(
  (ref) => DoseRepository(
    ref.watch(databaseProvider),
    relogio: ref.watch(relogioProvider),
  ),
);

final estoqueRepositoryProvider = Provider<EstoqueRepository>(
  (ref) => EstoqueRepository(
    ref.watch(databaseProvider),
    relogio: ref.watch(relogioProvider),
  ),
);

final historicoRepositoryProvider = Provider<HistoricoRepository>(
  (ref) => HistoricoRepository(ref.watch(databaseProvider)),
);

final configuracaoRepositoryProvider = Provider<ConfiguracaoRepository>(
  (ref) => ConfiguracaoRepository(
    ref.watch(databaseProvider),
    relogio: ref.watch(relogioProvider),
  ),
);

final agendaRepositoryProvider = Provider<AgendaRepository>(
  (ref) => AgendaRepository(
    ref.watch(databaseProvider),
    relogio: ref.watch(relogioProvider),
  ),
);

final servicoNotificacaoProvider = Provider<ServicoNotificacao>(
  (ref) => ServicoNotificacao(
    banco: ref.watch(databaseProvider),
    agendaRepository: ref.watch(agendaRepositoryProvider),
    doseRepository: ref.watch(doseRepositoryProvider),
    configuracaoRepository: ref.watch(configuracaoRepositoryProvider),
    agora: ref.watch(relogioProvider).agora,
  ),
);

final saudeNotificacoesProvider = FutureProvider<SaudeNotificacoes>(
  (ref) => ref.watch(servicoNotificacaoProvider).verificarSaude(),
);

final medicamentosProvider = StreamProvider<List<MedicamentoResumo>>(
  (ref) => ref.watch(medicamentoRepositoryProvider).observarTodos(),
);

final agendaHojeProvider = StreamProvider<AgendaDoDia>((ref) {
  final clock = ref.watch(relogioProvider);
  return ref
      .watch(agendaRepositoryProvider)
      .observarDia(clock.agora(), agora: clock.agora);
});

final saldosEstoqueProvider = StreamProvider<List<SaldoEstoque>>(
  (ref) => ref.watch(estoqueRepositoryProvider).observarSaldos(),
);

final configuracoesProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(configuracaoRepositoryProvider).observarTodas(),
);

final servicoBackupProvider = Provider<ServicoBackup>(
  (ref) => ServicoBackup(
    ref.watch(databaseProvider),
    agora: ref.watch(relogioProvider).agora,
  ),
);

final servicoSelecaoBackupProvider = Provider<ServicoSelecaoBackup>(
  (ref) => ServicoSelecaoBackup(),
);

final servicoCompartilhamentoBackupProvider =
    Provider<ServicoCompartilhamentoBackup>(
      (ref) => const ServicoCompartilhamentoBackup(),
    );

/// Mantém o ciclo de troca do arquivo SQLite centralizado. Este provider não
/// observa o banco: durante uma restauração o [ControladorBanco] troca a
/// instância, mas a operação em andamento precisa continuar viva até o fim.
final servicoRestauracaoBackupProvider = Provider<ServicoRestauracaoBackup>((
  ref,
) {
  final controlador = ref.read(controladorBancoProvider.notifier);
  final relogio = ref.read(relogioProvider);

  return ServicoRestauracaoBackup(
    agora: relogio.agora,
    criarBackupSeguranca: () async {
      final resultado = await ServicoBackup(
        controlador.banco,
        agora: relogio.agora,
      ).criar();
      return resultado.arquivo;
    },
    ciclo: CicloRestauracaoBackup(
      fecharBanco: controlador.fechar,
      reabrirBanco: () async {
        await controlador.reabrir();
      },
      validarBancoReaberto: () => controlador.banco.verificarIntegridade(),
      migrarBanco: migrarArquivoBanco,
      cancelarNotificacoes: () =>
          ref.read(servicoNotificacaoProvider).cancelarTodosAgendamentos(),
      reconstruirNotificacoes: () async {
        await ref.read(servicoNotificacaoProvider).inicializar();
      },
      atualizarEstado: () async {
        ref.invalidate(medicamentosProvider);
        ref.invalidate(agendaHojeProvider);
        ref.invalidate(saldosEstoqueProvider);
        ref.invalidate(configuracoesProvider);
        ref.invalidate(estoquesComPrevisaoProvider);
        ref.invalidate(saudeNotificacoesProvider);
      },
    ),
  );
});

/// Deve terminar antes de a interface consultar o banco. Em testes de widget
/// pode ser sobrescrito, mantendo o bootstrap livre de plugins de plataforma.
final recuperacaoInicialBackupProvider = FutureProvider<bool>(
  (ref) => ref.watch(servicoRestauracaoBackupProvider).recuperarSeNecessario(),
);

class EstoqueComPrevisao {
  const EstoqueComPrevisao({required this.saldo, this.previsao});

  final SaldoEstoque saldo;
  final PrevisaoEstoque? previsao;
}

final estoquesComPrevisaoProvider = FutureProvider<List<EstoqueComPrevisao>>((
  ref,
) async {
  final saldos = await ref.watch(saldosEstoqueProvider.future);
  final completos = await ref
      .watch(agendaRepositoryProvider)
      .obterTratamentosAtivos();
  final agenda = ref.watch(agendaRepositoryProvider);
  final now = ref.watch(relogioProvider).agora();
  const predictor = PrevisorEstoque();
  return [
    for (final saldo in saldos)
      EstoqueComPrevisao(
        saldo: saldo,
        previsao: saldo.medicamento.controleEstoque
            ? predictor.calcular(
                saldoAtual: saldo.quantidade,
                tratamentos: completos
                    .where(
                      (item) => item.medicamento.id == saldo.medicamento.id,
                    )
                    .map(agenda.converterTratamento)
                    .toList(growable: false),
                agora: now,
              )
            : null,
      ),
  ];
});
