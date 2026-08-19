import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/features/hoje/dominio/dose_prevista.dart';

void main() {
  final programada = DateTime(2026, 8, 18, 8);

  group('derivarStatusDose', () {
    test('é pendente antes e exatamente no horário', () {
      expect(
        derivarStatusDose(
          dataHoraProgramada: programada,
          agora: DateTime(2026, 8, 18, 7, 59),
        ),
        StatusDose.pendente,
      );
      expect(
        derivarStatusDose(dataHoraProgramada: programada, agora: programada),
        StatusDose.pendente,
      );
    });

    test('é em atraso somente depois do horário sem registro', () {
      expect(
        derivarStatusDose(
          dataHoraProgramada: programada,
          agora: DateTime(2026, 8, 18, 8, 0, 0, 0, 1),
        ),
        StatusDose.emAtraso,
      );
    });

    test('registro persistido prevalece sobre o relógio', () {
      expect(
        derivarStatusDose(
          dataHoraProgramada: programada,
          agora: DateTime(2026, 8, 19),
          registro: StatusRegistroDose.tomada,
        ),
        StatusDose.tomada,
      );
      expect(
        derivarStatusDose(
          dataHoraProgramada: programada,
          agora: DateTime(2026, 8, 18, 7),
          registro: StatusRegistroDose.naoTomada,
        ),
        StatusDose.naoTomada,
      );
    });
  });
}
