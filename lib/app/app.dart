import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/configuracoes/apresentacao/tela_configuracoes.dart';
import '../features/estoque/apresentacao/tela_estoque.dart';
import '../features/historico/apresentacao/tela_historico.dart';
import '../features/hoje/apresentacao/tela_hoje.dart';
import '../features/medicamentos/apresentacao/tela_medicamentos.dart';
import 'layout.dart';
import 'providers.dart';
import 'tema.dart';

class MinhaMedicacaoApp extends StatelessWidget {
  const MinhaMedicacaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minha Medicação',
      debugShowCheckedModeBanner: false,
      theme: criarTema(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _NavegacaoPrincipal(),
    );
  }
}

class _NavegacaoPrincipal extends ConsumerStatefulWidget {
  const _NavegacaoPrincipal();

  @override
  ConsumerState<_NavegacaoPrincipal> createState() =>
      _NavegacaoPrincipalState();
}

class _NavegacaoPrincipalState extends ConsumerState<_NavegacaoPrincipal>
    with WidgetsBindingObserver {
  var _index = 0;
  var _pronto = false;
  Object? _falhaInicializacao;
  Timer? _minuteTimer;

  static const _titles = ['Hoje', 'Medicamentos', 'Estoque', 'Histórico'];
  static const _pages = [
    TelaHoje(),
    TelaMedicamentos(),
    TelaEstoque(),
    TelaHistorico(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_inicializarAplicacao());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_pronto && state == AppLifecycleState.resumed) {
      ref.invalidate(agendaHojeProvider);
      ref.invalidate(estoquesComPrevisaoProvider);
      unawaited(_sincronizarAoRetomar());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _minuteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_pronto) {
      return Scaffold(
        appBar: AppBar(title: const Text('Minha Medicação')),
        body: Center(
          child: _falhaInicializacao == null
              ? Semantics(
                  label: 'Carregando dados locais',
                  child: const CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Não foi possível abrir os dados locais com segurança.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Nada foi apagado. Tente novamente antes de continuar.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _inicializarAplicacao,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }
    // Em telas largas a navegação vira uma trilha lateral; em celulares
    // permanece a barra inferior.
    final usarTrilha = larguraDaJanela(context) == LarguraJanela.expandida;
    final corpo = IndexedStack(index: _index, children: _pages);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TelaConfiguracoes(),
              ),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: usarTrilha
          ? Row(
              children: [
                _TrilhaNavegacao(indice: _index, aoSelecionar: _selecionarAba),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: corpo),
              ],
            )
          : corpo,
      bottomNavigationBar: usarTrilha
          ? null
          : _BarraNavegacao(indice: _index, aoSelecionar: _selecionarAba),
    );
  }

  void _selecionarAba(int indice) => setState(() => _index = indice);

  Future<void> _inicializarAplicacao() async {
    if (_falhaInicializacao != null) {
      ref.invalidate(recuperacaoInicialBackupProvider);
      setState(() => _falhaInicializacao = null);
    }
    try {
      await ref.read(recuperacaoInicialBackupProvider.future);
      await ref
          .read(medicamentoRepositoryProvider)
          .encerrarTratamentosVencidos();
      await _inicializarLembretes();
      if (!mounted) return;
      _minuteTimer ??= Timer.periodic(const Duration(minutes: 1), (_) {
        ref.invalidate(agendaHojeProvider);
        ref.invalidate(estoquesComPrevisaoProvider);
        unawaited(_encerrarTratamentosVencidos());
      });
      setState(() => _pronto = true);
    } on Object catch (error) {
      debugPrint('Falha ao preparar os dados locais: $error');
      if (mounted) setState(() => _falhaInicializacao = error);
    }
  }

  Future<void> _sincronizarAoRetomar() async {
    try {
      await _encerrarTratamentosVencidos(reconciliar: false);
      await ref.read(servicoNotificacaoProvider).aoRetomar();
      ref.invalidate(saudeNotificacoesProvider);
    } on Object catch (error) {
      debugPrint('Falha ao reconciliar dados ao retomar: $error');
    }
  }

  Future<void> _encerrarTratamentosVencidos({bool reconciliar = true}) async {
    try {
      final quantidade = await ref
          .read(medicamentoRepositoryProvider)
          .encerrarTratamentosVencidos();
      if (quantidade == 0) return;
      ref.invalidate(medicamentosProvider);
      ref.invalidate(agendaHojeProvider);
      ref.invalidate(estoquesComPrevisaoProvider);
      if (reconciliar) {
        await ref.read(servicoNotificacaoProvider).reconciliar();
        ref.invalidate(saudeNotificacoesProvider);
      }
    } on Object catch (error) {
      debugPrint('Falha ao encerrar tratamentos vencidos: $error');
    }
  }

  Future<void> _inicializarLembretes() async {
    try {
      final service = ref.read(servicoNotificacaoProvider);
      final result = await service.inicializar();
      ref.invalidate(saudeNotificacoesProvider);
      final configured = await ref
          .read(configuracaoRepositoryProvider)
          .obter('configuracaoInicialConcluida');
      if (configured == 'true' || !mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final accepted = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Habilitar lembretes?'),
            content: const Text(
              'As notificações e os alarmes exatos permitem avisar no horário '
              'cadastrado, inclusive com a tela bloqueada.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Agora não'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Configurar'),
              ),
            ],
          ),
        );
        if (accepted == true) {
          if (!result.saude.notificacoesHabilitadas) {
            await service.solicitarPermissaoNotificacoes();
          }
          if (!result.saude.alarmesExatosHabilitados) {
            await service.solicitarPermissaoAlarmesExatos();
          }
        }
        await ref
            .read(configuracaoRepositoryProvider)
            .definir('configuracaoInicialConcluida', 'true');
        ref.invalidate(saudeNotificacoesProvider);
      });
    } on Object catch (error) {
      debugPrint('Falha ao inicializar lembretes: $error');
    }
  }
}

/// Destinos compartilhados pela barra inferior e pela trilha lateral.
class _Destino {
  const _Destino(this.icone, this.iconeSelecionado, this.rotulo);

  final IconData icone;
  final IconData iconeSelecionado;
  final String rotulo;
}

const _destinos = [
  _Destino(Icons.today_outlined, Icons.today, 'Hoje'),
  _Destino(Icons.medication_outlined, Icons.medication, 'Medicamentos'),
  _Destino(Icons.inventory_2_outlined, Icons.inventory_2, 'Estoque'),
  _Destino(Icons.history_outlined, Icons.history, 'Histórico'),
];

class _BarraNavegacao extends StatelessWidget {
  const _BarraNavegacao({required this.indice, required this.aoSelecionar});

  final int indice;
  final ValueChanged<int> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    // A escala de fonte do sistema é respeitada no conteúdo, mas limitada nos
    // rótulos da barra para que "Medicamentos" não quebre em duas linhas.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.1,
      child: NavigationBar(
        selectedIndex: indice,
        onDestinationSelected: aoSelecionar,
        destinations: [
          for (final destino in _destinos)
            NavigationDestination(
              icon: Icon(destino.icone),
              selectedIcon: Icon(destino.iconeSelecionado),
              label: destino.rotulo,
              tooltip: destino.rotulo,
            ),
        ],
      ),
    );
  }
}

class _TrilhaNavegacao extends StatelessWidget {
  const _TrilhaNavegacao({required this.indice, required this.aoSelecionar});

  final int indice;
  final ValueChanged<int> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: indice,
      onDestinationSelected: aoSelecionar,
      labelType: NavigationRailLabelType.all,
      destinations: [
        for (final destino in _destinos)
          NavigationRailDestination(
            icon: Icon(destino.icone),
            selectedIcon: Icon(destino.iconeSelecionado),
            label: Text(destino.rotulo),
          ),
      ],
    );
  }
}
