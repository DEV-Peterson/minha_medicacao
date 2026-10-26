import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/notificacoes/identificador_notificacao.dart';

void main() {
  test('usa um hash estável com valor de referência', () {
    // FNV-1a 32 bits conhecido para "abc".
    expect(IdentificadorNotificacao.paraChave('abc'), 0x1a47e90b);
    expect(
      IdentificadorNotificacao.paraChave('abc'),
      IdentificadorNotificacao.paraChave('abc'),
    );
  });

  test('chaves distintas produzem IDs distintos no intervalo do Android', () {
    final ids = <int>{
      IdentificadorNotificacao.paraChave('dose|dose-v1'),
      IdentificadorNotificacao.paraChave('dose|dose-v2'),
      IdentificadorNotificacao.paraChave('medicação-ç-ã'),
    };

    expect(ids, hasLength(3));
    for (final id in ids) {
      expect(id, inInclusiveRange(1, 0x7fffffff));
    }
  });

  test('rejeita chave vazia', () {
    expect(() => IdentificadorNotificacao.paraChave(''), throwsArgumentError);
  });
}
