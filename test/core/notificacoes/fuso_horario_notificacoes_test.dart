import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:minha_medicacao/core/notificacoes/fuso_horario_notificacoes.dart';
import 'package:minha_medicacao/features/configuracoes/dados/configuracao_repository.dart';
import 'package:timezone/timezone.dart' as tz;

import '../banco/banco_teste.dart';

void main() {
  late AppDatabase db;
  late ConfiguracaoRepository configuracoes;

  setUp(() {
    db = criarBancoEmMemoria();
    configuracoes = ConfiguracaoRepository(db);
  });

  tearDown(() => db.close());

  test('persiste e detecta mudanca do fuso IANA do dispositivo', () async {
    final saoPaulo = FusoHorarioNotificacoes(
      obterIdentificador: () async => 'America/Sao_Paulo',
    );
    final utc = FusoHorarioNotificacoes(obterIdentificador: () async => 'UTC');

    final primeira = await saoPaulo.inicializar(configuracoes: configuracoes);
    final repetida = await saoPaulo.inicializar(configuracoes: configuracoes);
    final alterada = await utc.inicializar(configuracoes: configuracoes);

    expect(primeira.mudou, isFalse);
    expect(repetida.mudou, isFalse);
    expect(alterada.mudou, isTrue);
    expect(tz.local.name, 'UTC');
    expect(
      await configuracoes.obter(FusoHorarioNotificacoes.chaveConfiguracao),
      'UTC',
    );

    // Nao deixa o estado global contaminar outros testes deste processo.
    await saoPaulo.inicializar(configuracoes: configuracoes);
  });
}
