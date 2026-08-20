import 'package:flutter/material.dart';

import '../../../core/util/formatadores.dart';
import '../../tratamentos/dominio/modelos_agenda.dart';

/// Escolhe em quais dias os horários definidos valem.
///
/// Emite sempre uma recorrência válida: os campos numéricos são corrigidos
/// para o menor valor aceitável e ao menos um dia da semana fica marcado.
class SeletorRecorrencia extends StatefulWidget {
  const SeletorRecorrencia({
    required this.valor,
    required this.aoAlterar,
    super.key,
  });

  final RecorrenciaDias valor;
  final ValueChanged<RecorrenciaDias> aoAlterar;

  @override
  State<SeletorRecorrencia> createState() => _SeletorRecorrenciaState();
}

class _SeletorRecorrenciaState extends State<SeletorRecorrencia> {
  late final TextEditingController _dias;
  late final TextEditingController _semanas;
  late final TextEditingController _meses;
  late final TextEditingController _diaDoMes;
  late Set<int> _diasDaSemana;
  late String _tipo;

  static const _rotulos = {
    'diaria': 'Todos os dias',
    'cadaNDias': 'A cada alguns dias',
    'diasDaSemana': 'Em dias da semana',
    'mensal': 'Uma vez por mês',
  };

  static const _abreviacoesSemana = [
    (DateTime.sunday, 'D'),
    (DateTime.monday, 'S'),
    (DateTime.tuesday, 'T'),
    (DateTime.wednesday, 'Q'),
    (DateTime.thursday, 'Q'),
    (DateTime.friday, 'S'),
    (DateTime.saturday, 'S'),
  ];

  @override
  void initState() {
    super.initState();
    final valor = widget.valor;
    _tipo = valor.tipo;
    _dias = TextEditingController(
      text: valor is RecorrenciaCadaNDias ? '${valor.dias}' : '2',
    );
    _semanas = TextEditingController(
      text: valor is RecorrenciaDiasDaSemana ? '${valor.aCadaSemanas}' : '1',
    );
    _meses = TextEditingController(
      text: valor is RecorrenciaMensal ? '${valor.aCadaMeses}' : '1',
    );
    _diaDoMes = TextEditingController(
      text: valor is RecorrenciaMensal ? '${valor.diaDoMes}' : '1',
    );
    _diasDaSemana = valor is RecorrenciaDiasDaSemana
        ? {...valor.diasDaSemana}
        : {DateTime.monday};
  }

  @override
  void dispose() {
    _dias.dispose();
    _semanas.dispose();
    _meses.dispose();
    _diaDoMes.dispose();
    super.dispose();
  }

  int _inteiro(TextEditingController controlador, {required int minimo}) {
    final valor = int.tryParse(controlador.text.trim()) ?? minimo;
    return valor < minimo ? minimo : valor;
  }

  void _emitir() {
    final recorrencia = switch (_tipo) {
      'cadaNDias' => RecorrenciaCadaNDias(_inteiro(_dias, minimo: 1)),
      'diasDaSemana' => RecorrenciaDiasDaSemana(
        _diasDaSemana.isEmpty ? {DateTime.monday} : _diasDaSemana,
        aCadaSemanas: _inteiro(_semanas, minimo: 1),
      ),
      'mensal' => RecorrenciaMensal(
        _inteiro(_diaDoMes, minimo: 1).clamp(1, 31),
        aCadaMeses: _inteiro(_meses, minimo: 1),
      ),
      _ => const RecorrenciaDiaria(),
    };
    widget.aoAlterar(recorrencia);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: const Key('campo_recorrencia'),
          initialValue: _tipo,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Repetir'),
          items: [
            for (final item in _rotulos.entries)
              DropdownMenuItem(
                value: item.key,
                child: Text(item.value, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (valor) {
            if (valor == null) return;
            setState(() => _tipo = valor);
            _emitir();
          },
        ),
        if (_tipo == 'cadaNDias') ...[
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('campo_recorrencia_dias'),
            controller: _dias,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'A cada quantos dias? *',
              helperText: 'Contado a partir da data de início.',
              helperMaxLines: 2,
              errorMaxLines: 2,
            ),
            validator: (valor) => (int.tryParse((valor ?? '').trim()) ?? 0) < 1
                ? 'Mínimo 1.'
                : null,
            onChanged: (_) => _emitir(),
          ),
        ],
        if (_tipo == 'diasDaSemana') ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: [
              for (final (dia, abreviacao) in _abreviacoesSemana)
                FilterChip(
                  label: Text(abreviacao),
                  tooltip: nomeDoDiaDaSemana(dia),
                  selected: _diasDaSemana.contains(dia),
                  onSelected: (marcado) {
                    setState(() {
                      if (marcado) {
                        _diasDaSemana.add(dia);
                      } else if (_diasDaSemana.length > 1) {
                        _diasDaSemana.remove(dia);
                      }
                    });
                    _emitir();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('campo_recorrencia_semanas'),
            controller: _semanas,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'A cada quantas semanas? *',
              helperText: 'Use 1 para toda semana.',
              helperMaxLines: 2,
              errorMaxLines: 2,
            ),
            validator: (valor) => (int.tryParse((valor ?? '').trim()) ?? 0) < 1
                ? 'Mínimo 1.'
                : null,
            onChanged: (_) => _emitir(),
          ),
        ],
        if (_tipo == 'mensal') ...[
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('campo_recorrencia_dia_do_mes'),
            controller: _diaDoMes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Dia do mês *',
              helperText:
                  'Nos meses que não têm esse dia, a dose cai no último dia '
                  'do mês.',
              helperMaxLines: 3,
              errorMaxLines: 2,
            ),
            validator: (valor) {
              final dia = int.tryParse((valor ?? '').trim()) ?? 0;
              return dia < 1 || dia > 31 ? 'Entre 1 e 31.' : null;
            },
            onChanged: (_) => _emitir(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('campo_recorrencia_meses'),
            controller: _meses,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'A cada quantos meses? *',
              helperText: 'Use 1 para todo mês.',
              helperMaxLines: 2,
              errorMaxLines: 2,
            ),
            validator: (valor) => (int.tryParse((valor ?? '').trim()) ?? 0) < 1
                ? 'Mínimo 1.'
                : null,
            onChanged: (_) => _emitir(),
          ),
        ],
      ],
    );
  }
}
