import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/util/formatadores.dart';
import '../dominio/cadastro_medicamento.dart';

class FormularioMedicamento extends ConsumerStatefulWidget {
  const FormularioMedicamento({super.key});

  @override
  ConsumerState<FormularioMedicamento> createState() =>
      _FormularioMedicamentoState();
}

class _FormularioMedicamentoState extends ConsumerState<FormularioMedicamento> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _concentracao = TextEditingController();
  final _formaOutro = TextEditingController();
  final _quantidadeDose = TextEditingController(text: '1');
  final _unidadeOutro = TextEditingController();
  final _intervaloHoras = TextEditingController(text: '8');
  final _estoqueInicial = TextEditingController(text: '0');
  final _unidadeEstoque = TextEditingController(text: 'comprimido');
  final _consumoEstoque = TextEditingController(text: '1');
  final _observacoes = TextEditingController();
  final _instrucoes = TextEditingController();

  var _step = 0;
  var _forma = 'Comprimido';
  var _unidadeDose = 'comprimido';
  var _continuo = true;
  late DateTime _dataInicio;
  DateTime? _dataFim;
  var _tipo = TipoAgendamentoCadastro.horariosFixos;
  final _horarios = <TimeOfDay>[const TimeOfDay(hour: 8, minute: 0)];
  late DateTime _ancora;
  var _controlarEstoque = false;
  var _saving = false;

  static const _formas = [
    'Comprimido',
    'Cápsula',
    'Gotas',
    'Solução',
    'Xarope',
    'Sachê',
    'Pomada',
    'Spray',
    'Inalação',
    'Aplicação',
    'Outro',
  ];

  static const _unidades = [
    'comprimido',
    'cápsula',
    'gota',
    'mL',
    'sachê',
    'aplicação',
    'dose',
    'jato',
    'outro',
  ];

  @override
  void initState() {
    super.initState();
    final now = ref.read(relogioProvider).agora();
    _dataInicio = DateTime(now.year, now.month, now.day);
    _ancora = DateTime(now.year, now.month, now.day, 8);
  }

  @override
  void dispose() {
    for (final controller in [
      _nome,
      _concentracao,
      _formaOutro,
      _quantidadeDose,
      _unidadeOutro,
      _intervaloHoras,
      _estoqueInicial,
      _unidadeEstoque,
      _consumoEstoque,
      _observacoes,
      _instrucoes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo medicamento')),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _step,
          onStepTapped: (value) => setState(() => _step = value),
          controlsBuilder: (context, details) => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: _saving ? null : details.onStepContinue,
                  child: Text(
                    _step == 5
                        ? _saving
                              ? 'Salvando...'
                              : 'Salvar'
                        : 'Continuar',
                  ),
                ),
                if (_step > 0)
                  TextButton(
                    onPressed: _saving ? null : details.onStepCancel,
                    child: const Text('Voltar'),
                  ),
              ],
            ),
          ),
          onStepContinue: () {
            if (_step < 5) {
              setState(() => _step++);
            } else {
              _salvar();
            }
          },
          onStepCancel: () => setState(() => _step--),
          steps: [
            Step(
              title: const Text('Medicamento'),
              isActive: _step >= 0,
              content: _etapaMedicamento(),
            ),
            Step(
              title: const Text('Tratamento'),
              isActive: _step >= 1,
              content: _etapaTratamento(),
            ),
            Step(
              title: const Text('Horários'),
              isActive: _step >= 2,
              content: _etapaHorarios(),
            ),
            Step(
              title: const Text('Estoque'),
              isActive: _step >= 3,
              content: _etapaEstoque(),
            ),
            Step(
              title: const Text('Observações'),
              isActive: _step >= 4,
              content: _etapaObservacoes(),
            ),
            Step(
              title: const Text('Revisão'),
              isActive: _step >= 5,
              content: _etapaRevisao(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _etapaMedicamento() {
    return Column(
      children: [
        TextFormField(
          key: const Key('campo_nome_medicamento'),
          controller: _nome,
          decoration: const InputDecoration(labelText: 'Nome *'),
          textCapitalization: TextCapitalization.words,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Informe o nome do medicamento.'
              : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _concentracao,
          decoration: const InputDecoration(
            labelText: 'Concentração/dosagem',
            hintText: 'Ex.: 50 mg',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _forma,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Forma farmacêutica'),
          items: [
            for (final item in _formas)
              DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (value) => setState(() => _forma = value!),
        ),
        if (_forma == 'Outro') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _formaOutro,
            decoration: const InputDecoration(labelText: 'Qual forma? *'),
            validator: (value) =>
                _forma == 'Outro' && (value == null || value.trim().isEmpty)
                ? 'Informe a forma farmacêutica.'
                : null,
          ),
        ],
      ],
    );
  }

  Widget _etapaTratamento() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _quantidadeDose,
                decoration: const InputDecoration(
                  labelText: 'Quantidade *',
                  errorMaxLines: 3,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    (lerDecimal(value ?? '') ?? 0) <= 0 ? 'Maior que 0.' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: DropdownButtonFormField<String>(
                initialValue: _unidadeDose,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Unidade *'),
                items: [
                  for (final item in _unidades)
                    DropdownMenuItem(
                      value: item,
                      child: Text(item, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) => setState(() => _unidadeDose = value!),
              ),
            ),
          ],
        ),
        if (_unidadeDose == 'outro') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _unidadeOutro,
            decoration: const InputDecoration(labelText: 'Qual unidade? *'),
            validator: (value) =>
                _unidadeDose == 'outro' &&
                    (value == null || value.trim().isEmpty)
                ? 'Informe a unidade.'
                : null,
          ),
        ],
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Uso contínuo'),
          value: _continuo,
          onChanged: (value) => setState(() {
            _continuo = value;
            if (!value) {
              _dataFim ??= _dataInicio.add(const Duration(days: 7));
            }
          }),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Data de início'),
          subtitle: Text(formatarData(_dataInicio)),
          trailing: const Icon(Icons.calendar_month),
          onTap: () => _selecionarData(
            initial: _dataInicio,
            onSelected: (date) => setState(() {
              _dataInicio = date;
              _ancora = DateTime(
                date.year,
                date.month,
                date.day,
                _ancora.hour,
                _ancora.minute,
              );
              if (_dataFim?.isBefore(date) ?? false) _dataFim = date;
            }),
          ),
        ),
        if (!_continuo)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Data de término'),
            subtitle: Text(
              _dataFim == null ? 'Selecione' : formatarData(_dataFim!),
            ),
            trailing: const Icon(Icons.event_available),
            onTap: () => _selecionarData(
              initial: _dataFim ?? _dataInicio,
              first: _dataInicio,
              onSelected: (date) => setState(() => _dataFim = date),
            ),
          ),
      ],
    );
  }

  Widget _etapaHorarios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          onSelectionChanged: (value) => setState(() => _tipo = value.single),
        ),
        const SizedBox(height: 12),
        if (_tipo == TipoAgendamentoCadastro.horariosFixos) ...[
          for (final time in [..._horarios]..sort(_compararHorarios))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: Text(_formatarTime(time)),
              trailing: IconButton(
                tooltip: 'Remover horário',
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
            controller: _intervaloHoras,
            decoration: const InputDecoration(
              labelText: 'A cada quantas horas? *',
              suffixText: 'horas',
            ),
            keyboardType: TextInputType.number,
            validator: (value) =>
                _tipo == TipoAgendamentoCadastro.intervalo &&
                    (int.tryParse(value ?? '') ?? 0) <= 0
                ? 'Informe um intervalo maior que zero.'
                : null,
          ),
          const SizedBox(height: 8),
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
      ],
    );
  }

  Widget _etapaEstoque() {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Controlar estoque'),
          subtitle: const Text('A baixa ocorre ao confirmar uma dose.'),
          value: _controlarEstoque,
          onChanged: (value) => setState(() => _controlarEstoque = value),
        ),
        if (_controlarEstoque) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _estoqueInicial,
            decoration: const InputDecoration(labelText: 'Estoque inicial *'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) =>
                _controlarEstoque && ((lerDecimal(value ?? '') ?? -1) < 0)
                ? 'Informe um valor igual ou maior que zero.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _unidadeEstoque,
            decoration: const InputDecoration(
              labelText: 'Unidade do estoque *',
              hintText: 'Ex.: comprimido, mL',
            ),
            validator: (value) =>
                _controlarEstoque && (value == null || value.trim().isEmpty)
                ? 'Informe a unidade do estoque.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _consumoEstoque,
            decoration: const InputDecoration(
              labelText: 'Consumo de estoque por dose *',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) =>
                _controlarEstoque && (lerDecimal(value ?? '') ?? 0) <= 0
                ? 'Informe um consumo maior que zero.'
                : null,
          ),
          const SizedBox(height: 8),
          const Text(
            'Se a unidade da dose e a do estoque forem diferentes, informe '
            'explicitamente o consumo estimado. O aplicativo não converte gotas em mL.',
          ),
        ],
      ],
    );
  }

  Widget _etapaObservacoes() {
    return Column(
      children: [
        TextFormField(
          controller: _instrucoes,
          decoration: const InputDecoration(
            labelText: 'Instruções',
            hintText: 'Ex.: após alimentação',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _observacoes,
          decoration: const InputDecoration(labelText: 'Observações'),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Fotos do medicamento e da receita podem ser adicionadas depois '
            'na tela de detalhes.',
          ),
        ),
      ],
    );
  }

  Widget _etapaRevisao() {
    final unit = _unidadeDose == 'outro'
        ? _unidadeOutro.text.trim()
        : _unidadeDose;
    final times = _tipo == TipoAgendamentoCadastro.horariosFixos
        ? ([
            ..._horarios,
          ]..sort(_compararHorarios)).map(_formatarTime).join(' / ')
        : 'A cada ${_intervaloHoras.text} horas';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nomeMedicamento(_nome.text.trim(), _concentracao.text.trim()),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('${_quantidadeDose.text} $unit'),
            Text(times),
            Text(
              _continuo
                  ? 'Uso contínuo'
                  : 'Até ${_dataFim == null ? 'data não informada' : formatarData(_dataFim!)}',
            ),
            if (_controlarEstoque)
              Text(
                'Estoque inicial: ${_estoqueInicial.text} ${_unidadeEstoque.text}',
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _step = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revise os campos destacados.')),
      );
      return;
    }
    final cadastro = CadastroMedicamento(
      nome: _nome.text,
      concentracao: _concentracao.text,
      formaFarmaceutica: _forma == 'Outro' ? _formaOutro.text : _forma,
      unidadeDosePadrao: _unidadeDose == 'outro'
          ? _unidadeOutro.text
          : _unidadeDose,
      observacoes: _observacoes.text,
      quantidadeDose: lerDecimal(_quantidadeDose.text) ?? 0,
      unidadeDose: _unidadeDose == 'outro' ? _unidadeOutro.text : _unidadeDose,
      dataInicio: _dataInicio,
      dataFim: _dataFim,
      usoContinuo: _continuo,
      tipoAgendamento: _tipo,
      horarios: [
        for (final time in _horarios) HorarioCadastro(time.hour, time.minute),
      ],
      dataHoraAncora: _tipo == TipoAgendamentoCadastro.intervalo
          ? _ancora
          : null,
      intervaloMinutos: _tipo == TipoAgendamentoCadastro.intervalo
          ? (int.tryParse(_intervaloHoras.text) ?? 0) * 60
          : null,
      instrucoes: _instrucoes.text,
      controlarEstoque: _controlarEstoque,
      unidadeEstoque: _unidadeEstoque.text,
      estoqueInicial: lerDecimal(_estoqueInicial.text),
      consumoEstoquePorDose: lerDecimal(_consumoEstoque.text),
    );
    try {
      cadastro.validar();
      setState(() => _saving = true);
      await ref.read(medicamentoRepositoryProvider).cadastrar(cadastro);
      try {
        await ref.read(servicoNotificacaoProvider).reconciliar();
      } on Object {
        // O banco é a fonte de verdade; a abertura seguinte reconcilia.
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Medicamento cadastrado.')));
    } on FormularioInvalido catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.mensagem)));
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o medicamento.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _selecionarData({
    required DateTime initial,
    required ValueChanged<DateTime> onSelected,
    DateTime? first,
  }) async {
    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first ?? DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result != null) onSelected(result);
  }

  Future<void> _adicionarHorario() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _horarios.last,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (result == null) return;
    if (_horarios.any(
      (time) => time.hour == result.hour && time.minute == result.minute,
    )) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este horário já foi adicionado.')),
      );
      return;
    }
    setState(() => _horarios.add(result));
  }

  Future<void> _selecionarAncora() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _ancora,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_ancora),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time != null) {
      setState(() {
        _ancora = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }
}

int _compararHorarios(TimeOfDay a, TimeOfDay b) =>
    (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);

String _formatarTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:'
    '${time.minute.toString().padLeft(2, '0')}';
