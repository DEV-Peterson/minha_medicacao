import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/util/formatadores.dart';

void main() {
  group('concordância de unidade', () {
    test('mantém o singular quando a quantidade é 1', () {
      expect(formatarDose(1, 'comprimido'), '1 comprimido');
      expect(formatarDose(1, 'cápsula'), '1 cápsula');
    });

    test('pluraliza palavras comuns', () {
      expect(formatarDose(2, 'comprimido'), '2 comprimidos');
      expect(formatarDose(20, 'gota'), '20 gotas');
      expect(formatarDose(3, 'sachê'), '3 sachês');
      expect(formatarDose(2, 'dose'), '2 doses');
    });

    test('trata terminações irregulares do português', () {
      expect(formatarDose(2, 'aplicação'), '2 aplicações');
      expect(formatarDose(2, 'papel'), '2 papeis');
      expect(formatarDose(2, 'colher'), '2 colheres');
    });

    test('não pluraliza símbolo de medida', () {
      expect(formatarDose(5, 'mL'), '5 mL');
      expect(formatarDose(2, 'UI'), '2 UI');
      expect(formatarDose(500, 'mg'), '500 mg');
    });

    test('respeita unidade já no plural e fração', () {
      expect(formatarDose(4, 'comprimidos'), '4 comprimidos');
      expect(formatarDose(0.5, 'comprimido'), '0,5 comprimidos');
    });
  });
}
