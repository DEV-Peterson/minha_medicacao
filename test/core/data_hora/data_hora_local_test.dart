import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/data_hora/data_hora_local.dart';
import 'package:minha_medicacao/core/data_hora/relogio.dart';

void main() {
  group('DataHoraLocal', () {
    test('calcula os limites locais do dia', () {
      final instante = DateTime(2026, 8, 18, 13, 47, 12, 345, 678);

      expect(DataHoraLocal.inicioDoDia(instante), DateTime(2026, 8, 18));
      expect(
        DataHoraLocal.fimDoDia(instante),
        DateTime(2026, 8, 18, 23, 59, 59, 999, 999),
      );
      expect(DataHoraLocal.inicioDoProximoDia(instante), DateTime(2026, 8, 19));
    });

    test('avança pelo calendário nas viradas de mês e ano', () {
      expect(
        DataHoraLocal.adicionarDiasCalendario(
          DateTime(2026, 12, 31, 23, 59),
          1,
        ),
        DateTime(2027, 1, 1, 23, 59),
      );
      expect(
        DataHoraLocal.adicionarDiasCalendario(DateTime(2027, 1, 31), 1),
        DateTime(2027, 2, 1),
      );
    });

    test('combina uma data com os horários extremos', () {
      final data = DateTime(2026, 8, 18, 15, 30);

      expect(
        DataHoraLocal.combinar(data, hora: 0, minuto: 0),
        DateTime(2026, 8, 18),
      );
      expect(
        DataHoraLocal.combinar(data, hora: 23, minuto: 59),
        DateTime(2026, 8, 18, 23, 59),
      );
    });

    test('rejeita hora ou minuto fora do domínio', () {
      expect(
        () => DataHoraLocal.combinar(DateTime(2026), hora: 24, minuto: 0),
        throwsRangeError,
      );
      expect(
        () => DataHoraLocal.combinar(DateTime(2026), hora: 0, minuto: 60),
        throwsRangeError,
      );
    });

    test('compara somente a data local', () {
      expect(
        DataHoraLocal.mesmaData(
          DateTime(2026, 8, 18, 0, 1),
          DateTime(2026, 8, 18, 23, 59),
        ),
        isTrue,
      );
      expect(
        DataHoraLocal.mesmaData(
          DateTime(2026, 8, 18, 23, 59),
          DateTime(2026, 8, 19),
        ),
        isFalse,
      );
    });
  });

  test('Relogio permite injetar um instante previsível', () {
    final esperado = DateTime(2026, 8, 18, 20, 30);
    final relogio = _RelogioFalso(esperado);

    expect(relogio.agora(), esperado);
  });
}

final class _RelogioFalso implements Relogio {
  const _RelogioFalso(this.instante);

  final DateTime instante;

  @override
  DateTime agora() => instante;
}
