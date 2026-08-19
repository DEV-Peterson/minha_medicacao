import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/util/formatadores.dart';
import '../dados/medicamento_repository.dart';
import '../dominio/cadastro_medicamento.dart';

class FormularioTratamento extends ConsumerStatefulWidget {
  const FormularioTratamento({required this.item, super.key});

  final MedicamentoResumo item;

  @override
  ConsumerState<FormularioTratamento> createState() =>
      _FormularioTratamentoState();
}

class _FormularioTratamentoState extends ConsumerState<FormularioTratamento> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _quantidade;
  late final TextEditingController _unidade;
  late final TextEditingController _intervalo;
  late final TextEditingController _instrucoes;
  late final TextEditingController _consumo;
  late bool _continuo;
  late DateTime _inicio;
  DateTime? _fim;
  late TipoAgendamentoCadastro _tipo;
  late DateTime _ancora;
  late List<TimeOfDay> _horarios;
  late final bool _criando;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final treatment = widget.item.tratamento;
    _criando = treatment == null;
    final now = ref.read(relogioProvider).agora();
    _inicio = DateTime(now.year, now.month, now.day + (_criando ? 0 : 1));
    _continuo = treatment?.usoContinuo ?? true;
    _fim = _continuo
        ? null
        : treatment?.dataFim != null && !treatment!.dataFim!.isBefore(_inicio)
        ? treatment.dataFim
        : _inicio.add(const Duration(days: 7));
    _tipo = treatment?.tipoAgendamento == 'intervalo'
        ? TipoAgendamentoCadastro.intervalo
        : TipoAgendamentoCadastro.horariosFixos;
    _horarios = [
      for (final item in widget.item.horarios)
        TimeOfDay(hour: item.hora, minute: item.minuto),
    ];
    if (_horarios.isEmpty) _horarios = [const TimeOfDay(hour: 8, minute: 0)];
    final oldAnchor = treatment?.dataHoraAncora;
    _ancora = DateTime(
      _inicio.year,
      _inicio.month,
      _inicio.day,
      oldAnchor?.hour ?? 8,
      oldAnchor?.minute ?? 0,
    );
    _quantidade = TextEditingController(
      text: formatarQuantidade(treatment?.quantidadeDose ?? 1),
    );
    _unidade = TextEditingController(
      text:
          treatment?.unidadeDose ??
          widget.item.medicamento.unidadeDosePadrao ??
          'comprimido',
    );
    _intervalo = TextEditingController(
      text: formatarQuantidade((treatment?.intervaloMinutos ?? 480) / 60),
    );
    _instrucoes = TextEditingController(text: treatment?.instrucoes);
    _consumo = TextEditingController(
      text: treatment?.consumoEstoquePorDose == null
          ? widget.item.medicamento.controleEstoque
                ? '1'
                : ''
          : formatarQuantidade(treatment!.consumoEstoquePorDose!),
    );
  }

  @override
  void dispose() {
    _quantidade.dispose();
    _unidade.dispose();
    _intervalo.dispose();
    _instrucoes.dispose();
    _consumo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stockControlled = widget.item.medicamento.controleEstoque;
    return Scaffold(
      appBar: AppBar(
        title: Text(_criando ? 'Novo tratamento' : 'Alterar tratamento'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _criando
                      ? 'O novo tratamento será associado a este medicamento. '
                            'O histórico de tratamentos anteriores será preservado.'
                      : 'A configuração atual será encerrada. A nova valerá apenas '
                            'a partir da data escolhida, preservando o histórico anterior.',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantidade,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade *',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) => (lerDecimal(value ?? '') ?? 0) <= 0
                        ? 'Informe um valor positivo.'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unidade,
                    decoration: const InputDecoration(labelText: 'Unidade *'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe a unidade.'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _criando ? 'Data de início' : 'Nova configuração a partir de',
              ),
              subtitle: Text(formatarData(_inicio)),
              trailing: const Icon(Icons.calendar_month),
              onTap: _selecionarInicio,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Uso contínuo'),
              value: _continuo,
              onChanged: (value) => setState(() {
                _continuo = value;
                _fim = value
                    ? null
                    : _fim ?? _inicio.add(const Duration(days: 7));
              }),
            ),
            if (!_continuo)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data de término'),
                subtitle: Text(
                  _fim == null ? 'Selecione' : formatarData(_fim!),
                ),
                trailing: const Icon(Icons.event_available),
                onTap: _selecionarFim,
              ),
            const SizedBox(height: 12),
            SegmentedButton<TipoAgendamentoCadastro>(
              segments: const [
                ButtonSegment(
                  value: TipoAgendamentoCadastro.horariosFixos,
                  label: Text('Horários'),
                  icon: Icon(Icons.schedule),
                ),
                ButtonSegment(
                  value: TipoAgendamentoCadastro.intervalo,
                  label: Text('Intervalo'),
                  icon: Icon(Icons.repeat),
                ),
              ],
              selected: {_tipo},
              onSelectionChanged: (value) =>
                  setState(() => _tipo = value.single),
            ),
            const SizedBox(height: 12),
            if (_tipo == TipoAgendamentoCadastro.horariosFixos) ...[
              for (final time in [..._horarios]..sort(_compareTimes))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: Text(_timeText(time)),
                  trailing: IconButton(
                    onPressed: _horarios.length == 1
                        ? null
                        : () => setState(() => _horarios.remove(time)),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _adicionarHorario,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar horário'),
              ),
            ] else ...[
              TextFormField(
                controller: _intervalo,
                decoration: const InputDecoration(
                  labelText: 'Intervalo *',
                  suffixText: 'horas',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    _tipo == TipoAgendamentoCadastro.intervalo &&
                        (lerDecimal(value ?? '') ?? 0) <= 0
                    ? 'Informe um intervalo positivo.'
                    : null,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Primeira dose'),
                subtitle: Text(
                  '${formatarData(_ancora)} às ${formatarHora(_ancora)}',
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _selecionarAncora,
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _instrucoes,
              decoration: const InputDecoration(labelText: 'Instruções'),
              maxLines: 2,
            ),
            if (stockControlled) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _consumo,
                decoration: const InputDecoration(
                  labelText: 'Consumo de estoque por dose *',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => (lerDecimal(value ?? '') ?? 0) <= 0
                    ? 'Informe um consumo positivo.'
                    : null,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _salvar,
              icon: const Icon(Icons.save_outlined),
              label: Text(
                _saving
                    ? 'Salvando...'
                    : _criando
                    ? 'Salvar tratamento'
                    : 'Salvar nova configuração',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    final intervalHours = lerDecimal(_intervalo.text) ?? 0;
    final input = EdicaoTratamento(
      quantidadeDose: lerDecimal(_quantidade.text) ?? 0,
      unidadeDose: _unidade.text,
      dataInicio: _inicio,
      dataFim: _fim,
      usoContinuo: _continuo,
      tipoAgendamento: _tipo,
      horarios: [
        for (final time in _horarios) HorarioCadastro(time.hour, time.minute),
      ],
      dataHoraAncora: _tipo == TipoAgendamentoCadastro.intervalo
          ? _ancora
          : null,
      intervaloMinutos: _tipo == TipoAgendamentoCadastro.intervalo
          ? (intervalHours * 60).round()
          : null,
      instrucoes: _instrucoes.text,
      consumoEstoquePorDose: widget.item.medicamento.controleEstoque
          ? lerDecimal(_consumo.text)
          : null,
    );
    try {
      input.validar(controlaEstoque: widget.item.medicamento.controleEstoque);
      setState(() => _saving = true);
      final repository = ref.read(medicamentoRepositoryProvider);
      if (_criando) {
        await repository.criarTratamento(
          medicamentoId: widget.item.medicamento.id,
          edicao: input,
        );
      } else {
        await repository.substituirTratamento(
          tratamentoAtualId: widget.item.tratamento!.id,
          edicao: input,
        );
      }
      try {
        await ref.read(servicoNotificacaoProvider).reconciliar();
      } on Object {
        // O banco é a fonte de verdade; a abertura seguinte reconcilia.
      }
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _criando
                ? 'Tratamento salvo.'
                : 'Nova configuração de tratamento salva.',
          ),
        ),
      );
    } on FormularioInvalido catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.mensagem)));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível alterar o tratamento.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _selecionarInicio() async {
    final now = ref.read(relogioProvider).agora();
    final primeiroDia = DateTime(
      now.year,
      now.month,
      now.day + (_criando ? 0 : 1),
    );
    final result = await showDatePicker(
      context: context,
      initialDate: _inicio,
      firstDate: primeiroDia,
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() {
        _inicio = result;
        _ancora = DateTime(
          result.year,
          result.month,
          result.day,
          _ancora.hour,
          _ancora.minute,
        );
        if (_fim?.isBefore(result) ?? false) _fim = result;
      });
    }
  }

  Future<void> _selecionarFim() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _fim ?? _inicio,
      firstDate: _inicio,
      lastDate: DateTime(2100),
    );
    if (result != null) setState(() => _fim = result);
  }

  Future<void> _adicionarHorario() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _horarios.last,
      builder: _relogio24Horas,
    );
    if (result == null) return;
    if (_horarios.any(
      (item) => item.hour == result.hour && item.minute == result.minute,
    )) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este horário já foi adicionado.')),
        );
      }
      return;
    }
    setState(() => _horarios.add(result));
  }

  Future<void> _selecionarAncora() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_ancora),
      builder: _relogio24Horas,
    );
    if (time != null) {
      setState(() {
        _ancora = DateTime(
          _inicio.year,
          _inicio.month,
          _inicio.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Widget _relogio24Horas(BuildContext context, Widget? child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
    child: child!,
  );
}

int _compareTimes(TimeOfDay a, TimeOfDay b) =>
    (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);

String _timeText(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';
