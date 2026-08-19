import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/conversor_data_civil.dart';

void main() {
  const conversor = ConversorDataCivil();

  group('ConversorDataCivil', () {
    test('codifica somente os componentes civis em YYYYMMDD', () {
      expect(conversor.toSql(DateTime(2026, 8, 18, 23, 59, 59)), 20260818);
      expect(conversor.toSql(DateTime.utc(2026, 12, 31, 23, 59, 59)), 20261231);
    });

    test('decodifica para meia-noite local sem carregar um fuso salvo', () {
      final data = conversor.fromSql(20240229);

      expect(data, DateTime(2024, 2, 29));
      expect(data.isUtc, isFalse);
      expect((data.hour, data.minute, data.second), (0, 0, 0));
    });

    test('round-trip preserva a data, inclusive nos limites de ano', () {
      for (final original in <DateTime>[
        DateTime(1, 1, 1, 12),
        DateTime(2024, 2, 29, 23, 59),
        DateTime.utc(9999, 12, 31, 6),
      ]) {
        final restaurada = conversor.fromSql(conversor.toSql(original));
        expect(
          (restaurada.year, restaurada.month, restaurada.day),
          (original.year, original.month, original.day),
        );
      }
    });

    test('rejeita inteiros que não representam uma data civil válida', () {
      for (final invalida in <int>[
        0,
        20240010,
        20241301,
        20260229,
        20260431,
        100000101,
      ]) {
        expect(
          () => conversor.fromSql(invalida),
          throwsA(isA<FormatException>()),
          reason: '$invalida deveria ser rejeitada',
        );
      }
    });

    test('rejeita ano fora da representação YYYYMMDD', () {
      expect(() => conversor.toSql(DateTime(10000, 1, 1)), throwsArgumentError);
    });
  });
}
