import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/features/hoje/dominio/gerador_agenda.dart';
import 'package:minha_medicacao/features/tratamentos/dominio/modelos_agenda.dart';

void main() {
  const gerador = GeradorAgenda();

  group('GeradorAgenda com horários fixos', () {
    test('inclui início e fim do tratamento temporário', () {
      final tratamento = _tratamentoFixo(
        inicio: DateTime(2026, 8, 18),
        fim: DateTime(2026, 8, 19),
        horarios: [
          HorarioTratamento(id: 'fim-dia', hora: 23, minuto: 59),
          HorarioTratamento(id: 'meia-noite', hora: 0, minuto: 0),
        ],
      );

      final doses = gerador.gerar(
        tratamento: tratamento,
        periodo: PeriodoAgenda(
          inicio: DateTime(2026, 8, 17),
          fimExclusivo: DateTime(2026, 8, 21),
        ),
      );

      expect(doses.map((dose) => dose.dataHoraProgramada), [
        DateTime(2026, 8, 18),
        DateTime(2026, 8, 18, 23, 59),
        DateTime(2026, 8, 19),
        DateTime(2026, 8, 19, 23, 59),
      ]);
      expect(doses.map((dose) => dose.regraId), [
        'meia-noite',
        'fim-dia',
        'meia-noite',
        'fim-dia',
      ]);
    });

    test('tratamento contínuo atravessa mês e ano', () {
      final tratamento = _tratamentoFixo(
        inicio: DateTime(2026, 12, 31),
        continuo: true,
        horarios: [HorarioTratamento(id: 'h-08', hora: 8, minuto: 0)],
      );

      final doses = gerador.gerar(
        tratamento: tratamento,
        periodo: PeriodoAgenda(
          inicio: DateTime(2026, 12, 30),
          fimExclusivo: DateTime(2027, 2, 2),
        ),
      );

      expect(doses, hasLength(33));
      expect(doses.first.dataHoraProgramada, DateTime(2026, 12, 31, 8));
      expect(doses[1].dataHoraProgramada, DateTime(2027, 1, 1, 8));
      expect(doses.last.dataHoraProgramada, DateTime(2027, 2, 1, 8));
    });

    test('respeita os limites semiabertos do período consultado', () {
      final tratamento = _tratamentoFixo(
        inicio: DateTime(2026, 8, 1),
        continuo: true,
        horarios: [
          HorarioTratamento(id: 'h-08', hora: 8, minuto: 0),
          HorarioTratamento(id: 'h-20', hora: 20, minuto: 0),
        ],
      );

      final doses = gerador.gerar(
        tratamento: tratamento,
        periodo: PeriodoAgenda(
          inicio: DateTime(2026, 8, 18, 8),
          fimExclusivo: DateTime(2026, 8, 19, 8),
        ),
      );

      expect(doses.map((dose) => dose.dataHoraProgramada), [
        DateTime(2026, 8, 18, 8),
        DateTime(2026, 8, 18, 20),
      ]);
    });

    test('tratamento inativo não projeta ocorrências', () {
      final tratamento = _tratamentoFixo(
        inicio: DateTime(2026, 8, 18),
        continuo: true,
        ativo: false,
        horarios: [HorarioTratamento(id: 'h-08', hora: 8, minuto: 0)],
      );

      expect(
        gerador.gerar(
          tratamento: tratamento,
          periodo: PeriodoAgenda.dia(DateTime(2026, 8, 18)),
        ),
        isEmpty,
      );
    });

    test('copia os dados clínicos sem interpretá-los', () {
      final tratamento = _tratamentoFixo(
        inicio: DateTime(2026, 8, 18),
        continuo: true,
        quantidadeDose: 0.5,
        consumoEstoquePorDose: 1,
        instrucoes: 'Após alimentação',
        horarios: [HorarioTratamento(id: 'h-08', hora: 8, minuto: 0)],
      );

      final dose = gerador
          .gerar(
            tratamento: tratamento,
            periodo: PeriodoAgenda.dia(DateTime(2026, 8, 18)),
          )
          .single;

      expect(dose.quantidadeDose, 0.5);
      expect(dose.consumoEstoquePorDose, 1);
      expect(dose.instrucoes, 'Após alimentação');
      expect(dose.doseKey, isNotEmpty);
    });
  });

  group('GeradorAgenda com intervalo ancorado', () {
    test('atravessa a meia-noite sem reiniciar a sequência', () {
      final tratamento = _tratamentoIntervalo(
        inicio: DateTime(2026, 8, 18),
        continuo: true,
        ancora: DateTime(2026, 8, 18, 22),
        intervalo: const Duration(hours: 8),
      );

      final doses = gerador.gerar(
        tratamento: tratamento,
        periodo: PeriodoAgenda(
          inicio: DateTime(2026, 8, 18),
          fimExclusivo: DateTime(2026, 8, 20),
        ),
      );

      expect(doses.map((dose) => dose.dataHoraProgramada), [
        DateTime(2026, 8, 18, 22),
        DateTime(2026, 8, 19, 6),
        DateTime(2026, 8, 19, 14),
        DateTime(2026, 8, 19, 22),
      ]);
    });

    test('consulta parcial continua calculando desde a âncora original', () {
      final tratamento = _tratamentoIntervalo(
        inicio: DateTime(2026, 8, 18),
        continuo: true,
        ancora: DateTime(2026, 8, 18, 6),
        intervalo: const Duration(hours: 8),
      );

      final doses = gerador.gerar(
        tratamento: tratamento,
        periodo: PeriodoAgenda(
          inicio: DateTime(2026, 8, 19, 7),
          fimExclusivo: DateTime(2026, 8, 20),
        ),
      );

      expect(doses.map((dose) => dose.dataHoraProgramada), [
        DateTime(2026, 8, 19, 14),
        DateTime(2026, 8, 19, 22),
      ]);
    });

    test('âncora anterior ao início preserva a fase do intervalo', () {
      final tratamento = _tratamentoIntervalo(
        inicio: DateTime(2026, 8, 18),
        fim: DateTime(2026, 8, 18),
        ancora: DateTime(2026, 8, 17, 22),
        intervalo: const Duration(hours: 8),
      );

      final doses = gerador.gerar(
        tratamento: tratamento,
        periodo: PeriodoAgenda.dia(DateTime(2026, 8, 18)),
      );

      expect(doses.map((dose) => dose.dataHoraProgramada), [
        DateTime(2026, 8, 18, 6),
        DateTime(2026, 8, 18, 14),
        DateTime(2026, 8, 18, 22),
      ]);
    });

    test('data final é inclusiva, mas a madrugada seguinte é excluída', () {
      final tratamento = _tratamentoIntervalo(
        inicio: DateTime(2026, 8, 18),
        fim: DateTime(2026, 8, 19),
        ancora: DateTime(2026, 8, 18, 23),
        intervalo: const Duration(hours: 12),
      );

      final doses = gerador.gerar(
        tratamento: tratamento,
        periodo: PeriodoAgenda(
          inicio: DateTime(2026, 8, 18),
          fimExclusivo: DateTime(2026, 8, 21),
        ),
      );

      expect(doses.map((dose) => dose.dataHoraProgramada), [
        DateTime(2026, 8, 18, 23),
        DateTime(2026, 8, 19, 11),
        DateTime(2026, 8, 19, 23),
      ]);
    });

    test('atravessa virada de ano em 23:59 e 00:00', () {
      final tratamento = _tratamentoIntervalo(
        inicio: DateTime(2026, 12, 31),
        continuo: true,
        ancora: DateTime(2026, 12, 31, 23, 59),
        intervalo: const Duration(minutes: 1),
      );

      final doses = gerador.gerar(
        tratamento: tratamento,
        periodo: PeriodoAgenda(
          inicio: DateTime(2026, 12, 31, 23, 59),
          fimExclusivo: DateTime(2027, 1, 1, 0, 2),
        ),
      );

      expect(doses.map((dose) => dose.dataHoraProgramada), [
        DateTime(2026, 12, 31, 23, 59),
        DateTime(2027, 1, 1),
        DateTime(2027, 1, 1, 0, 1),
      ]);
    });

    test('não gera antes da primeira dose ancorada', () {
      final tratamento = _tratamentoIntervalo(
        inicio: DateTime(2026, 8, 18),
        continuo: true,
        ancora: DateTime(2026, 8, 20, 6),
        intervalo: const Duration(hours: 8),
      );

      expect(
        gerador.gerar(
          tratamento: tratamento,
          periodo: PeriodoAgenda(
            inicio: DateTime(2026, 8, 18),
            fimExclusivo: DateTime(2026, 8, 20),
          ),
        ),
        isEmpty,
      );
    });
  });

  group('validações dos modelos', () {
    test('horários fixos rejeitam horário e id duplicados', () {
      expect(
        () => RegraHorariosFixos([
          HorarioTratamento(id: 'a', hora: 8, minuto: 0),
          HorarioTratamento(id: 'b', hora: 8, minuto: 0),
        ]),
        throwsArgumentError,
      );
      expect(
        () => RegraHorariosFixos([
          HorarioTratamento(id: 'a', hora: 8, minuto: 0),
          HorarioTratamento(id: 'a', hora: 20, minuto: 0),
        ]),
        throwsArgumentError,
      );
    });

    test('tratamento temporário exige fim válido', () {
      expect(
        () => _tratamentoFixo(
          inicio: DateTime(2026, 8, 18),
          horarios: [HorarioTratamento(id: 'h', hora: 8, minuto: 0)],
        ),
        throwsArgumentError,
      );
      expect(
        () => _tratamentoFixo(
          inicio: DateTime(2026, 8, 18),
          fim: DateTime(2026, 8, 17),
          horarios: [HorarioTratamento(id: 'h', hora: 8, minuto: 0)],
        ),
        throwsArgumentError,
      );
    });

    test('intervalo deve ser positivo', () {
      expect(
        () => RegraIntervaloAncorado(
          id: 'intervalo',
          dataHoraAncora: DateTime(2026, 8, 18),
          intervalo: Duration.zero,
        ),
        throwsArgumentError,
      );
    });
  });
}

TratamentoAgenda _tratamentoFixo({
  required DateTime inicio,
  required List<HorarioTratamento> horarios,
  DateTime? fim,
  bool continuo = false,
  bool ativo = true,
  double quantidadeDose = 1,
  double? consumoEstoquePorDose,
  String? instrucoes,
}) => TratamentoAgenda(
  id: 'tratamento-1',
  medicamentoId: 'medicamento-1',
  quantidadeDose: quantidadeDose,
  unidadeDose: 'comprimido',
  consumoEstoquePorDose: consumoEstoquePorDose,
  dataInicio: inicio,
  dataFim: fim,
  usoContinuo: continuo,
  instrucoes: instrucoes,
  ativo: ativo,
  regra: RegraHorariosFixos(horarios),
);

TratamentoAgenda _tratamentoIntervalo({
  required DateTime inicio,
  required DateTime ancora,
  required Duration intervalo,
  DateTime? fim,
  bool continuo = false,
}) => TratamentoAgenda(
  id: 'tratamento-1',
  medicamentoId: 'medicamento-1',
  quantidadeDose: 1,
  unidadeDose: 'cápsula',
  dataInicio: inicio,
  dataFim: fim,
  usoContinuo: continuo,
  regra: RegraIntervaloAncorado(
    id: 'intervalo-1',
    dataHoraAncora: ancora,
    intervalo: intervalo,
  ),
);
