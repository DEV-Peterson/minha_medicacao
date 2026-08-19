import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/notificacoes/identificador_notificacao.dart';

void main() {
  test('a mesma chave sempre produz o mesmo ID Android positivo', () {
    final primeiro = IdentificadorNotificacao.paraChave('dose|dose-v1');
    final segundo = IdentificadorNotificacao.paraChave('dose|dose-v1');

    expect(segundo, primeiro);
    expect(primeiro, inInclusiveRange(1, 0x7fffffff));
  });

  test('chaves usuais distintas produzem IDs distintos', () {
    expect(
      IdentificadorNotificacao.paraChave('dose|dose-v1'),
      isNot(IdentificadorNotificacao.paraChave('dose|dose-v2')),
    );
  });

  test('chave vazia e rejeitada', () {
    expect(() => IdentificadorNotificacao.paraChave(''), throwsArgumentError);
  });
}
