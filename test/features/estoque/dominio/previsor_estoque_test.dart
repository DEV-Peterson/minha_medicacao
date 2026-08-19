import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/features/estoque/dominio/previsor_estoque.dart';
import 'package:minha_medicacao/features/tratamentos/dominio/modelos_agenda.dart';

void main() {
  const previsor = PrevisorEstoque();
  final agora = DateTime(2026, 8, 18, 7);

  TratamentoAgenda tratamento({double? consumo = 1}) => TratamentoAgenda(
    id: 'tratamento-1',
    medicamentoId: 'medicamento-1',
    quantidadeDose: 1,
    unidadeDose: 'comprimido',
    consumoEstoquePorDose: consumo,
    dataInicio: DateTime(2026, 8, 1),
    usoContinuo: true,
    regra: RegraHorariosFixos([
      HorarioTratamento(id: '08', hora: 8, minuto: 0),
      HorarioTratamento(id: '20', hora: 20, minuto: 0),
    ]),
  );

  test('simula doses futuras até o estoque ser insuficiente', () {
    final result = previsor.calcular(
      saldoAtual: 3,
      tratamentos: [tratamento()],
      agora: agora,
    );

    expect(result.dataInsuficiente, DateTime(2026, 8, 19, 20));
    expect(result.consumoProximosSeteDias, 14);
    expect(result.diasAproximadosEm(agora), 1);
  });

  test('soma consumos de tratamentos simultâneos em ordem cronológica', () {
    final second = TratamentoAgenda(
      id: 'tratamento-2',
      medicamentoId: 'medicamento-1',
      quantidadeDose: 5,
      unidadeDose: 'mL',
      consumoEstoquePorDose: 2,
      dataInicio: DateTime(2026, 8, 18),
      dataFim: DateTime(2026, 8, 18),
      usoContinuo: false,
      regra: RegraHorariosFixos([
        HorarioTratamento(id: '12', hora: 12, minuto: 0),
      ]),
    );
    final result = previsor.calcular(
      saldoAtual: 2,
      tratamentos: [tratamento(), second],
      agora: agora,
    );

    expect(result.dataInsuficiente, DateTime(2026, 8, 18, 12));
  });

  test('sem consumo configurado não inventa conversão nem término', () {
    final result = previsor.calcular(
      saldoAtual: 10,
      tratamentos: [tratamento(consumo: null)],
      agora: agora,
    );

    expect(result.dataInsuficiente, isNull);
    expect(result.consumoProximosSeteDias, 0);
  });
}
