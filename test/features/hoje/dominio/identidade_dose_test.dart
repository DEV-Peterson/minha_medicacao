import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/features/hoje/dominio/identidade_dose.dart';

void main() {
  group('criarDoseKey', () {
    test('a mesma ocorrência sempre produz a mesma chave', () {
      final programada = DateTime(2026, 8, 18, 8);

      final primeira = criarDoseKey(
        tratamentoId: 'tratamento-1',
        regraId: 'horario-08',
        dataHoraProgramada: programada,
      );
      final segunda = criarDoseKey(
        tratamentoId: 'tratamento-1',
        regraId: 'horario-08',
        dataHoraProgramada: programada,
      );

      expect(segunda, primeira);
      expect(
        primeira,
        'dose:v1|12:tratamento-1|10:horario-08|'
        '${programada.toUtc().microsecondsSinceEpoch}',
      );
    });

    test('representações local e UTC do mesmo instante são equivalentes', () {
      final local = DateTime(2026, 8, 18, 8);

      expect(
        criarDoseKey(
          tratamentoId: 't',
          regraId: 'r',
          dataHoraProgramada: local,
        ),
        criarDoseKey(
          tratamentoId: 't',
          regraId: 'r',
          dataHoraProgramada: local.toUtc(),
        ),
      );
    });

    test('tratamento, regra e instante participam da identidade', () {
      final programada = DateTime(2026, 8, 18, 8);
      String chave(String tratamento, String regra, DateTime dataHora) =>
          criarDoseKey(
            tratamentoId: tratamento,
            regraId: regra,
            dataHoraProgramada: dataHora,
          );

      final chaves = {
        chave('t-1', 'r-1', programada),
        chave('t-2', 'r-1', programada),
        chave('t-1', 'r-2', programada),
        chave('t-1', 'r-1', programada.add(const Duration(minutes: 1))),
      };

      expect(chaves, hasLength(4));
    });
  });
}
