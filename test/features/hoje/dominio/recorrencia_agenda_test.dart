import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/features/hoje/dominio/gerador_agenda.dart';
import 'package:minha_medicacao/features/tratamentos/dominio/modelos_agenda.dart';

void main() {
  const gerador = GeradorAgenda();

  List<DateTime> gerarDatas(
    TratamentoAgenda tratamento, {
    required DateTime de,
    required DateTime ate,
  }) => gerador
      .gerar(
        tratamento: tratamento,
        periodo: PeriodoAgenda(inicio: de, fimExclusivo: ate),
      )
      .map((dose) => dose.dataHoraProgramada)
      .toList();

  group('recorrência a cada N dias', () {
    test('dia sim, dia não a partir do início', () {
      final tratamento = _tratamento(
        inicio: DateTime(2026, 8, 18),
        recorrencia: RecorrenciaCadaNDias(2),
      );

      expect(
        gerarDatas(
          tratamento,
          de: DateTime(2026, 8, 18),
          ate: DateTime(2026, 8, 25),
        ),
        [
          DateTime(2026, 8, 18, 8),
          DateTime(2026, 8, 20, 8),
          DateTime(2026, 8, 22, 8),
          DateTime(2026, 8, 24, 8),
        ],
      );
    });

    test('mantém a fase ao atravessar o ano', () {
      final tratamento = _tratamento(
        inicio: DateTime(2026, 12, 30),
        recorrencia: RecorrenciaCadaNDias(3),
      );

      expect(
        gerarDatas(
          tratamento,
          de: DateTime(2026, 12, 30),
          ate: DateTime(2027, 1, 8),
        ),
        [
          DateTime(2026, 12, 30, 8),
          DateTime(2027, 1, 2, 8),
          DateTime(2027, 1, 5, 8),
        ],
      );
    });

    test('consulta parcial não desloca a sequência', () {
      final tratamento = _tratamento(
        inicio: DateTime(2026, 8, 18),
        recorrencia: RecorrenciaCadaNDias(2),
      );

      expect(
        gerarDatas(
          tratamento,
          de: DateTime(2026, 8, 21),
          ate: DateTime(2026, 8, 23),
        ),
        [DateTime(2026, 8, 22, 8)],
      );
    });
  });

  group('recorrência por dias da semana', () {
    test('gera apenas nos dias escolhidos', () {
      // 17/08/2026 é uma segunda-feira.
      final tratamento = _tratamento(
        inicio: DateTime(2026, 8, 17),
        recorrencia: RecorrenciaDiasDaSemana({
          DateTime.monday,
          DateTime.thursday,
        }),
      );

      final datas = gerarDatas(
        tratamento,
        de: DateTime(2026, 8, 17),
        ate: DateTime(2026, 8, 31),
      );

      expect(datas, [
        DateTime(2026, 8, 17, 8),
        DateTime(2026, 8, 20, 8),
        DateTime(2026, 8, 24, 8),
        DateTime(2026, 8, 27, 8),
      ]);
      expect(datas.map((data) => data.weekday).toSet(), {
        DateTime.monday,
        DateTime.thursday,
      });
    });

    test('a cada duas semanas pula a semana intermediária', () {
      final tratamento = _tratamento(
        inicio: DateTime(2026, 8, 17),
        recorrencia: RecorrenciaDiasDaSemana({
          DateTime.wednesday,
        }, aCadaSemanas: 2),
      );

      expect(
        gerarDatas(
          tratamento,
          de: DateTime(2026, 8, 17),
          ate: DateTime(2026, 9, 28),
        ),
        [
          DateTime(2026, 8, 19, 8),
          DateTime(2026, 9, 2, 8),
          DateTime(2026, 9, 16, 8),
        ],
      );
    });

    test('início no meio da semana não adianta a primeira dose', () {
      // Sexta-feira; a primeira segunda válida é a seguinte.
      final tratamento = _tratamento(
        inicio: DateTime(2026, 8, 21),
        recorrencia: RecorrenciaDiasDaSemana({DateTime.monday}),
      );

      expect(
        gerarDatas(
          tratamento,
          de: DateTime(2026, 8, 21),
          ate: DateTime(2026, 9, 1),
        ),
        [DateTime(2026, 8, 24, 8), DateTime(2026, 8, 31, 8)],
      );
    });
  });

  group('recorrência mensal', () {
    test('todo dia 5', () {
      final tratamento = _tratamento(
        inicio: DateTime(2026, 8, 5),
        recorrencia: RecorrenciaMensal(5),
      );

      expect(
        gerarDatas(
          tratamento,
          de: DateTime(2026, 8, 1),
          ate: DateTime(2026, 11, 1),
        ),
        [
          DateTime(2026, 8, 5, 8),
          DateTime(2026, 9, 5, 8),
          DateTime(2026, 10, 5, 8),
        ],
      );
    });

    test('dia 31 cai no último dia dos meses curtos', () {
      final tratamento = _tratamento(
        inicio: DateTime(2027, 1, 31),
        recorrencia: RecorrenciaMensal(31),
      );

      expect(
        gerarDatas(
          tratamento,
          de: DateTime(2027, 1, 1),
          ate: DateTime(2027, 5, 1),
        ),
        [
          DateTime(2027, 1, 31, 8),
          DateTime(2027, 2, 28, 8),
          DateTime(2027, 3, 31, 8),
          DateTime(2027, 4, 30, 8),
        ],
      );
    });

    test('fevereiro de ano bissexto usa o dia 29', () {
      final tratamento = _tratamento(
        inicio: DateTime(2028, 1, 30),
        recorrencia: RecorrenciaMensal(30),
      );

      expect(
        gerarDatas(
          tratamento,
          de: DateTime(2028, 2, 1),
          ate: DateTime(2028, 3, 1),
        ),
        [DateTime(2028, 2, 29, 8)],
      );
    });

    test('a cada três meses conta a partir do início', () {
      final tratamento = _tratamento(
        inicio: DateTime(2026, 8, 10),
        recorrencia: RecorrenciaMensal(10, aCadaMeses: 3),
      );

      expect(
        gerarDatas(
          tratamento,
          de: DateTime(2026, 8, 1),
          ate: DateTime(2027, 3, 1),
        ),
        [
          DateTime(2026, 8, 10, 8),
          DateTime(2026, 11, 10, 8),
          DateTime(2027, 2, 10, 8),
        ],
      );
    });
  });

  test('recorrência diária mantém o comportamento anterior', () {
    final diario = _tratamento(inicio: DateTime(2026, 8, 18));
    final explicito = _tratamento(
      inicio: DateTime(2026, 8, 18),
      recorrencia: const RecorrenciaDiaria(),
    );

    final periodo = (de: DateTime(2026, 8, 18), ate: DateTime(2026, 8, 25));
    expect(
      gerarDatas(diario, de: periodo.de, ate: periodo.ate),
      gerarDatas(explicito, de: periodo.de, ate: periodo.ate),
    );
    expect(gerarDatas(diario, de: periodo.de, ate: periodo.ate), hasLength(7));
  });

  test('recorrência não diária é recusada com intervalo em horas', () {
    expect(
      () => TratamentoAgenda(
        id: 'tratamento-1',
        medicamentoId: 'medicamento-1',
        quantidadeDose: 1,
        unidadeDose: 'comprimido',
        dataInicio: DateTime(2026, 8, 18),
        usoContinuo: true,
        recorrencia: RecorrenciaCadaNDias(2),
        regra: RegraIntervaloAncorado(
          id: 'intervalo',
          dataHoraAncora: DateTime(2026, 8, 18, 6),
          intervalo: const Duration(hours: 8),
        ),
      ),
      throwsArgumentError,
    );
  });

  group('validação das recorrências', () {
    test('exige valores positivos e dias válidos', () {
      expect(() => RecorrenciaCadaNDias(0), throwsArgumentError);
      expect(() => RecorrenciaDiasDaSemana(const []), throwsArgumentError);
      expect(() => RecorrenciaDiasDaSemana(const [8]), throwsRangeError);
      expect(() => RecorrenciaMensal(0), throwsRangeError);
      expect(() => RecorrenciaMensal(32), throwsRangeError);
      expect(() => RecorrenciaMensal(10, aCadaMeses: 0), throwsArgumentError);
    });
  });
}

TratamentoAgenda _tratamento({
  required DateTime inicio,
  RecorrenciaDias recorrencia = const RecorrenciaDiaria(),
  DateTime? fim,
}) => TratamentoAgenda(
  id: 'tratamento-1',
  medicamentoId: 'medicamento-1',
  quantidadeDose: 1,
  unidadeDose: 'comprimido',
  dataInicio: inicio,
  dataFim: fim,
  usoContinuo: fim == null,
  recorrencia: recorrencia,
  regra: RegraHorariosFixos([
    HorarioTratamento(id: 'h-08', hora: 8, minuto: 0),
  ]),
);
