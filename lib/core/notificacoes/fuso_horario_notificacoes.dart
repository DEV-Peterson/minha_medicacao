import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as dados_tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/configuracoes/dados/configuracao_repository.dart';

typedef ObterIdentificadorFuso = Future<String> Function();

final class ResultadoFusoHorario {
  const ResultadoFusoHorario({
    required this.identificador,
    required this.mudou,
  });

  final String identificador;
  final bool mudou;
}

final class FusoHorarioNotificacoes {
  FusoHorarioNotificacoes({ObterIdentificadorFuso? obterIdentificador})
    : _obterIdentificador =
          obterIdentificador ??
          (() async => (await FlutterTimezone.getLocalTimezone()).identifier);

  static const String chaveConfiguracao = 'fusoHorarioNotificacoes';

  final ObterIdentificadorFuso _obterIdentificador;

  Future<ResultadoFusoHorario> inicializar({
    ConfiguracaoRepository? configuracoes,
  }) async {
    dados_tz.initializeTimeZones();
    final identificador = (await _obterIdentificador()).trim();
    if (identificador.isEmpty) {
      throw StateError('O dispositivo retornou um fuso horario vazio.');
    }

    try {
      tz.setLocalLocation(tz.getLocation(identificador));
    } on Object catch (erro) {
      throw StateError(
        'Fuso horario nao reconhecido pelo pacote timezone: '
        '$identificador ($erro).',
      );
    }

    final salvo = await configuracoes?.obter(chaveConfiguracao);
    final mudou = salvo != null && salvo != identificador;
    if (configuracoes != null && salvo != identificador) {
      await configuracoes.definir(chaveConfiguracao, identificador);
    }
    return ResultadoFusoHorario(identificador: identificador, mudou: mudou);
  }
}
