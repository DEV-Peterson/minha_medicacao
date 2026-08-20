// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MedicamentosTable extends Medicamentos
    with TableInfo<$MedicamentosTable, MedicamentoDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicamentosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _concentracaoMeta = const VerificationMeta(
    'concentracao',
  );
  @override
  late final GeneratedColumn<String> concentracao = GeneratedColumn<String>(
    'concentracao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formaFarmaceuticaMeta = const VerificationMeta(
    'formaFarmaceutica',
  );
  @override
  late final GeneratedColumn<String> formaFarmaceutica =
      GeneratedColumn<String>(
        'forma_farmaceutica',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _unidadeDosePadraoMeta = const VerificationMeta(
    'unidadeDosePadrao',
  );
  @override
  late final GeneratedColumn<String> unidadeDosePadrao =
      GeneratedColumn<String>(
        'unidade_dose_padrao',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _unidadeEstoqueMeta = const VerificationMeta(
    'unidadeEstoque',
  );
  @override
  late final GeneratedColumn<String> unidadeEstoque = GeneratedColumn<String>(
    'unidade_estoque',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observacoesMeta = const VerificationMeta(
    'observacoes',
  );
  @override
  late final GeneratedColumn<String> observacoes = GeneratedColumn<String>(
    'observacoes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _controleEstoqueMeta = const VerificationMeta(
    'controleEstoque',
  );
  @override
  late final GeneratedColumn<bool> controleEstoque = GeneratedColumn<bool>(
    'controle_estoque',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("controle_estoque" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ativoMeta = const VerificationMeta('ativo');
  @override
  late final GeneratedColumn<bool> ativo = GeneratedColumn<bool>(
    'ativo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    concentracao,
    formaFarmaceutica,
    unidadeDosePadrao,
    unidadeEstoque,
    observacoes,
    controleEstoque,
    ativo,
    criadoEm,
    atualizadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicamentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicamentoDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('concentracao')) {
      context.handle(
        _concentracaoMeta,
        concentracao.isAcceptableOrUnknown(
          data['concentracao']!,
          _concentracaoMeta,
        ),
      );
    }
    if (data.containsKey('forma_farmaceutica')) {
      context.handle(
        _formaFarmaceuticaMeta,
        formaFarmaceutica.isAcceptableOrUnknown(
          data['forma_farmaceutica']!,
          _formaFarmaceuticaMeta,
        ),
      );
    }
    if (data.containsKey('unidade_dose_padrao')) {
      context.handle(
        _unidadeDosePadraoMeta,
        unidadeDosePadrao.isAcceptableOrUnknown(
          data['unidade_dose_padrao']!,
          _unidadeDosePadraoMeta,
        ),
      );
    }
    if (data.containsKey('unidade_estoque')) {
      context.handle(
        _unidadeEstoqueMeta,
        unidadeEstoque.isAcceptableOrUnknown(
          data['unidade_estoque']!,
          _unidadeEstoqueMeta,
        ),
      );
    }
    if (data.containsKey('observacoes')) {
      context.handle(
        _observacoesMeta,
        observacoes.isAcceptableOrUnknown(
          data['observacoes']!,
          _observacoesMeta,
        ),
      );
    }
    if (data.containsKey('controle_estoque')) {
      context.handle(
        _controleEstoqueMeta,
        controleEstoque.isAcceptableOrUnknown(
          data['controle_estoque']!,
          _controleEstoqueMeta,
        ),
      );
    }
    if (data.containsKey('ativo')) {
      context.handle(
        _ativoMeta,
        ativo.isAcceptableOrUnknown(data['ativo']!, _ativoMeta),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicamentoDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicamentoDb(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      concentracao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concentracao'],
      ),
      formaFarmaceutica: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}forma_farmaceutica'],
      ),
      unidadeDosePadrao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidade_dose_padrao'],
      ),
      unidadeEstoque: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidade_estoque'],
      ),
      observacoes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacoes'],
      ),
      controleEstoque: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}controle_estoque'],
      )!,
      ativo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativo'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
    );
  }

  @override
  $MedicamentosTable createAlias(String alias) {
    return $MedicamentosTable(attachedDatabase, alias);
  }
}

class MedicamentoDb extends DataClass implements Insertable<MedicamentoDb> {
  final String id;
  final String nome;
  final String? concentracao;
  final String? formaFarmaceutica;
  final String? unidadeDosePadrao;
  final String? unidadeEstoque;
  final String? observacoes;
  final bool controleEstoque;
  final bool ativo;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  const MedicamentoDb({
    required this.id,
    required this.nome,
    this.concentracao,
    this.formaFarmaceutica,
    this.unidadeDosePadrao,
    this.unidadeEstoque,
    this.observacoes,
    required this.controleEstoque,
    required this.ativo,
    required this.criadoEm,
    required this.atualizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || concentracao != null) {
      map['concentracao'] = Variable<String>(concentracao);
    }
    if (!nullToAbsent || formaFarmaceutica != null) {
      map['forma_farmaceutica'] = Variable<String>(formaFarmaceutica);
    }
    if (!nullToAbsent || unidadeDosePadrao != null) {
      map['unidade_dose_padrao'] = Variable<String>(unidadeDosePadrao);
    }
    if (!nullToAbsent || unidadeEstoque != null) {
      map['unidade_estoque'] = Variable<String>(unidadeEstoque);
    }
    if (!nullToAbsent || observacoes != null) {
      map['observacoes'] = Variable<String>(observacoes);
    }
    map['controle_estoque'] = Variable<bool>(controleEstoque);
    map['ativo'] = Variable<bool>(ativo);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    return map;
  }

  MedicamentosCompanion toCompanion(bool nullToAbsent) {
    return MedicamentosCompanion(
      id: Value(id),
      nome: Value(nome),
      concentracao: concentracao == null && nullToAbsent
          ? const Value.absent()
          : Value(concentracao),
      formaFarmaceutica: formaFarmaceutica == null && nullToAbsent
          ? const Value.absent()
          : Value(formaFarmaceutica),
      unidadeDosePadrao: unidadeDosePadrao == null && nullToAbsent
          ? const Value.absent()
          : Value(unidadeDosePadrao),
      unidadeEstoque: unidadeEstoque == null && nullToAbsent
          ? const Value.absent()
          : Value(unidadeEstoque),
      observacoes: observacoes == null && nullToAbsent
          ? const Value.absent()
          : Value(observacoes),
      controleEstoque: Value(controleEstoque),
      ativo: Value(ativo),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory MedicamentoDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicamentoDb(
      id: serializer.fromJson<String>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      concentracao: serializer.fromJson<String?>(json['concentracao']),
      formaFarmaceutica: serializer.fromJson<String?>(
        json['formaFarmaceutica'],
      ),
      unidadeDosePadrao: serializer.fromJson<String?>(
        json['unidadeDosePadrao'],
      ),
      unidadeEstoque: serializer.fromJson<String?>(json['unidadeEstoque']),
      observacoes: serializer.fromJson<String?>(json['observacoes']),
      controleEstoque: serializer.fromJson<bool>(json['controleEstoque']),
      ativo: serializer.fromJson<bool>(json['ativo']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nome': serializer.toJson<String>(nome),
      'concentracao': serializer.toJson<String?>(concentracao),
      'formaFarmaceutica': serializer.toJson<String?>(formaFarmaceutica),
      'unidadeDosePadrao': serializer.toJson<String?>(unidadeDosePadrao),
      'unidadeEstoque': serializer.toJson<String?>(unidadeEstoque),
      'observacoes': serializer.toJson<String?>(observacoes),
      'controleEstoque': serializer.toJson<bool>(controleEstoque),
      'ativo': serializer.toJson<bool>(ativo),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
    };
  }

  MedicamentoDb copyWith({
    String? id,
    String? nome,
    Value<String?> concentracao = const Value.absent(),
    Value<String?> formaFarmaceutica = const Value.absent(),
    Value<String?> unidadeDosePadrao = const Value.absent(),
    Value<String?> unidadeEstoque = const Value.absent(),
    Value<String?> observacoes = const Value.absent(),
    bool? controleEstoque,
    bool? ativo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) => MedicamentoDb(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    concentracao: concentracao.present ? concentracao.value : this.concentracao,
    formaFarmaceutica: formaFarmaceutica.present
        ? formaFarmaceutica.value
        : this.formaFarmaceutica,
    unidadeDosePadrao: unidadeDosePadrao.present
        ? unidadeDosePadrao.value
        : this.unidadeDosePadrao,
    unidadeEstoque: unidadeEstoque.present
        ? unidadeEstoque.value
        : this.unidadeEstoque,
    observacoes: observacoes.present ? observacoes.value : this.observacoes,
    controleEstoque: controleEstoque ?? this.controleEstoque,
    ativo: ativo ?? this.ativo,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
  );
  MedicamentoDb copyWithCompanion(MedicamentosCompanion data) {
    return MedicamentoDb(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      concentracao: data.concentracao.present
          ? data.concentracao.value
          : this.concentracao,
      formaFarmaceutica: data.formaFarmaceutica.present
          ? data.formaFarmaceutica.value
          : this.formaFarmaceutica,
      unidadeDosePadrao: data.unidadeDosePadrao.present
          ? data.unidadeDosePadrao.value
          : this.unidadeDosePadrao,
      unidadeEstoque: data.unidadeEstoque.present
          ? data.unidadeEstoque.value
          : this.unidadeEstoque,
      observacoes: data.observacoes.present
          ? data.observacoes.value
          : this.observacoes,
      controleEstoque: data.controleEstoque.present
          ? data.controleEstoque.value
          : this.controleEstoque,
      ativo: data.ativo.present ? data.ativo.value : this.ativo,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicamentoDb(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('concentracao: $concentracao, ')
          ..write('formaFarmaceutica: $formaFarmaceutica, ')
          ..write('unidadeDosePadrao: $unidadeDosePadrao, ')
          ..write('unidadeEstoque: $unidadeEstoque, ')
          ..write('observacoes: $observacoes, ')
          ..write('controleEstoque: $controleEstoque, ')
          ..write('ativo: $ativo, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    concentracao,
    formaFarmaceutica,
    unidadeDosePadrao,
    unidadeEstoque,
    observacoes,
    controleEstoque,
    ativo,
    criadoEm,
    atualizadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicamentoDb &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.concentracao == this.concentracao &&
          other.formaFarmaceutica == this.formaFarmaceutica &&
          other.unidadeDosePadrao == this.unidadeDosePadrao &&
          other.unidadeEstoque == this.unidadeEstoque &&
          other.observacoes == this.observacoes &&
          other.controleEstoque == this.controleEstoque &&
          other.ativo == this.ativo &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm);
}

class MedicamentosCompanion extends UpdateCompanion<MedicamentoDb> {
  final Value<String> id;
  final Value<String> nome;
  final Value<String?> concentracao;
  final Value<String?> formaFarmaceutica;
  final Value<String?> unidadeDosePadrao;
  final Value<String?> unidadeEstoque;
  final Value<String?> observacoes;
  final Value<bool> controleEstoque;
  final Value<bool> ativo;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<int> rowid;
  const MedicamentosCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.concentracao = const Value.absent(),
    this.formaFarmaceutica = const Value.absent(),
    this.unidadeDosePadrao = const Value.absent(),
    this.unidadeEstoque = const Value.absent(),
    this.observacoes = const Value.absent(),
    this.controleEstoque = const Value.absent(),
    this.ativo = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicamentosCompanion.insert({
    required String id,
    required String nome,
    this.concentracao = const Value.absent(),
    this.formaFarmaceutica = const Value.absent(),
    this.unidadeDosePadrao = const Value.absent(),
    this.unidadeEstoque = const Value.absent(),
    this.observacoes = const Value.absent(),
    this.controleEstoque = const Value.absent(),
    this.ativo = const Value.absent(),
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nome = Value(nome),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm);
  static Insertable<MedicamentoDb> custom({
    Expression<String>? id,
    Expression<String>? nome,
    Expression<String>? concentracao,
    Expression<String>? formaFarmaceutica,
    Expression<String>? unidadeDosePadrao,
    Expression<String>? unidadeEstoque,
    Expression<String>? observacoes,
    Expression<bool>? controleEstoque,
    Expression<bool>? ativo,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (concentracao != null) 'concentracao': concentracao,
      if (formaFarmaceutica != null) 'forma_farmaceutica': formaFarmaceutica,
      if (unidadeDosePadrao != null) 'unidade_dose_padrao': unidadeDosePadrao,
      if (unidadeEstoque != null) 'unidade_estoque': unidadeEstoque,
      if (observacoes != null) 'observacoes': observacoes,
      if (controleEstoque != null) 'controle_estoque': controleEstoque,
      if (ativo != null) 'ativo': ativo,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicamentosCompanion copyWith({
    Value<String>? id,
    Value<String>? nome,
    Value<String?>? concentracao,
    Value<String?>? formaFarmaceutica,
    Value<String?>? unidadeDosePadrao,
    Value<String?>? unidadeEstoque,
    Value<String?>? observacoes,
    Value<bool>? controleEstoque,
    Value<bool>? ativo,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<int>? rowid,
  }) {
    return MedicamentosCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      concentracao: concentracao ?? this.concentracao,
      formaFarmaceutica: formaFarmaceutica ?? this.formaFarmaceutica,
      unidadeDosePadrao: unidadeDosePadrao ?? this.unidadeDosePadrao,
      unidadeEstoque: unidadeEstoque ?? this.unidadeEstoque,
      observacoes: observacoes ?? this.observacoes,
      controleEstoque: controleEstoque ?? this.controleEstoque,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (concentracao.present) {
      map['concentracao'] = Variable<String>(concentracao.value);
    }
    if (formaFarmaceutica.present) {
      map['forma_farmaceutica'] = Variable<String>(formaFarmaceutica.value);
    }
    if (unidadeDosePadrao.present) {
      map['unidade_dose_padrao'] = Variable<String>(unidadeDosePadrao.value);
    }
    if (unidadeEstoque.present) {
      map['unidade_estoque'] = Variable<String>(unidadeEstoque.value);
    }
    if (observacoes.present) {
      map['observacoes'] = Variable<String>(observacoes.value);
    }
    if (controleEstoque.present) {
      map['controle_estoque'] = Variable<bool>(controleEstoque.value);
    }
    if (ativo.present) {
      map['ativo'] = Variable<bool>(ativo.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicamentosCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('concentracao: $concentracao, ')
          ..write('formaFarmaceutica: $formaFarmaceutica, ')
          ..write('unidadeDosePadrao: $unidadeDosePadrao, ')
          ..write('unidadeEstoque: $unidadeEstoque, ')
          ..write('observacoes: $observacoes, ')
          ..write('controleEstoque: $controleEstoque, ')
          ..write('ativo: $ativo, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TratamentosTable extends Tratamentos
    with TableInfo<$TratamentosTable, TratamentoDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TratamentosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicamentoIdMeta = const VerificationMeta(
    'medicamentoId',
  );
  @override
  late final GeneratedColumn<String> medicamentoId = GeneratedColumn<String>(
    'medicamento_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicamentos (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _quantidadeDoseMeta = const VerificationMeta(
    'quantidadeDose',
  );
  @override
  late final GeneratedColumn<double> quantidadeDose = GeneratedColumn<double>(
    'quantidade_dose',
    aliasedName,
    false,
    check: () => const CustomExpression('quantidade_dose > 0'),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unidadeDoseMeta = const VerificationMeta(
    'unidadeDose',
  );
  @override
  late final GeneratedColumn<String> unidadeDose = GeneratedColumn<String>(
    'unidade_dose',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consumoEstoquePorDoseMeta =
      const VerificationMeta('consumoEstoquePorDose');
  @override
  late final GeneratedColumn<double> consumoEstoquePorDose =
      GeneratedColumn<double>(
        'consumo_estoque_por_dose',
        aliasedName,
        true,
        check: () => const CustomExpression(
          'consumo_estoque_por_dose IS NULL OR consumo_estoque_por_dose > 0',
        ),
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> dataInicio =
      GeneratedColumn<int>(
        'data_inicio',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TratamentosTable.$converterdataInicio);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> dataFim =
      GeneratedColumn<int>(
        'data_fim',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($TratamentosTable.$converterdataFimn);
  static const VerificationMeta _usoContinuoMeta = const VerificationMeta(
    'usoContinuo',
  );
  @override
  late final GeneratedColumn<bool> usoContinuo = GeneratedColumn<bool>(
    'uso_continuo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uso_continuo" IN (0, 1))',
    ),
  );
  static const VerificationMeta _tipoAgendamentoMeta = const VerificationMeta(
    'tipoAgendamento',
  );
  @override
  late final GeneratedColumn<String> tipoAgendamento = GeneratedColumn<String>(
    'tipo_agendamento',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataHoraAncoraMeta = const VerificationMeta(
    'dataHoraAncora',
  );
  @override
  late final GeneratedColumn<DateTime> dataHoraAncora =
      GeneratedColumn<DateTime>(
        'data_hora_ancora',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _intervaloMinutosMeta = const VerificationMeta(
    'intervaloMinutos',
  );
  @override
  late final GeneratedColumn<int> intervaloMinutos = GeneratedColumn<int>(
    'intervalo_minutos',
    aliasedName,
    true,
    check: () => const CustomExpression(
      'intervalo_minutos IS NULL OR intervalo_minutos > 0',
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recorrenciaMeta = const VerificationMeta(
    'recorrencia',
  );
  @override
  late final GeneratedColumn<String> recorrencia = GeneratedColumn<String>(
    'recorrencia',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('diaria'),
  );
  static const VerificationMeta _recorrenciaIntervaloMeta =
      const VerificationMeta('recorrenciaIntervalo');
  @override
  late final GeneratedColumn<int> recorrenciaIntervalo = GeneratedColumn<int>(
    'recorrencia_intervalo',
    aliasedName,
    true,
    check: () => const CustomExpression(
      'recorrencia_intervalo IS NULL OR recorrencia_intervalo > 0',
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recorrenciaDiasSemanaMeta =
      const VerificationMeta('recorrenciaDiasSemana');
  @override
  late final GeneratedColumn<String> recorrenciaDiasSemana =
      GeneratedColumn<String>(
        'recorrencia_dias_semana',
        aliasedName,
        true,
        additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 1,
          maxTextLength: 20,
        ),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recorrenciaDiaDoMesMeta =
      const VerificationMeta('recorrenciaDiaDoMes');
  @override
  late final GeneratedColumn<int> recorrenciaDiaDoMes = GeneratedColumn<int>(
    'recorrencia_dia_do_mes',
    aliasedName,
    true,
    check: () => const CustomExpression(
      'recorrencia_dia_do_mes IS NULL OR '
      '(recorrencia_dia_do_mes >= 1 AND recorrencia_dia_do_mes <= 31)',
    ),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instrucoesMeta = const VerificationMeta(
    'instrucoes',
  );
  @override
  late final GeneratedColumn<String> instrucoes = GeneratedColumn<String>(
    'instrucoes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ativoMeta = const VerificationMeta('ativo');
  @override
  late final GeneratedColumn<bool> ativo = GeneratedColumn<bool>(
    'ativo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _encerradoEmMeta = const VerificationMeta(
    'encerradoEm',
  );
  @override
  late final GeneratedColumn<DateTime> encerradoEm = GeneratedColumn<DateTime>(
    'encerrado_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicamentoId,
    quantidadeDose,
    unidadeDose,
    consumoEstoquePorDose,
    dataInicio,
    dataFim,
    usoContinuo,
    tipoAgendamento,
    dataHoraAncora,
    intervaloMinutos,
    recorrencia,
    recorrenciaIntervalo,
    recorrenciaDiasSemana,
    recorrenciaDiaDoMes,
    instrucoes,
    ativo,
    encerradoEm,
    criadoEm,
    atualizadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tratamentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<TratamentoDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medicamento_id')) {
      context.handle(
        _medicamentoIdMeta,
        medicamentoId.isAcceptableOrUnknown(
          data['medicamento_id']!,
          _medicamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicamentoIdMeta);
    }
    if (data.containsKey('quantidade_dose')) {
      context.handle(
        _quantidadeDoseMeta,
        quantidadeDose.isAcceptableOrUnknown(
          data['quantidade_dose']!,
          _quantidadeDoseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantidadeDoseMeta);
    }
    if (data.containsKey('unidade_dose')) {
      context.handle(
        _unidadeDoseMeta,
        unidadeDose.isAcceptableOrUnknown(
          data['unidade_dose']!,
          _unidadeDoseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unidadeDoseMeta);
    }
    if (data.containsKey('consumo_estoque_por_dose')) {
      context.handle(
        _consumoEstoquePorDoseMeta,
        consumoEstoquePorDose.isAcceptableOrUnknown(
          data['consumo_estoque_por_dose']!,
          _consumoEstoquePorDoseMeta,
        ),
      );
    }
    if (data.containsKey('uso_continuo')) {
      context.handle(
        _usoContinuoMeta,
        usoContinuo.isAcceptableOrUnknown(
          data['uso_continuo']!,
          _usoContinuoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_usoContinuoMeta);
    }
    if (data.containsKey('tipo_agendamento')) {
      context.handle(
        _tipoAgendamentoMeta,
        tipoAgendamento.isAcceptableOrUnknown(
          data['tipo_agendamento']!,
          _tipoAgendamentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tipoAgendamentoMeta);
    }
    if (data.containsKey('data_hora_ancora')) {
      context.handle(
        _dataHoraAncoraMeta,
        dataHoraAncora.isAcceptableOrUnknown(
          data['data_hora_ancora']!,
          _dataHoraAncoraMeta,
        ),
      );
    }
    if (data.containsKey('intervalo_minutos')) {
      context.handle(
        _intervaloMinutosMeta,
        intervaloMinutos.isAcceptableOrUnknown(
          data['intervalo_minutos']!,
          _intervaloMinutosMeta,
        ),
      );
    }
    if (data.containsKey('recorrencia')) {
      context.handle(
        _recorrenciaMeta,
        recorrencia.isAcceptableOrUnknown(
          data['recorrencia']!,
          _recorrenciaMeta,
        ),
      );
    }
    if (data.containsKey('recorrencia_intervalo')) {
      context.handle(
        _recorrenciaIntervaloMeta,
        recorrenciaIntervalo.isAcceptableOrUnknown(
          data['recorrencia_intervalo']!,
          _recorrenciaIntervaloMeta,
        ),
      );
    }
    if (data.containsKey('recorrencia_dias_semana')) {
      context.handle(
        _recorrenciaDiasSemanaMeta,
        recorrenciaDiasSemana.isAcceptableOrUnknown(
          data['recorrencia_dias_semana']!,
          _recorrenciaDiasSemanaMeta,
        ),
      );
    }
    if (data.containsKey('recorrencia_dia_do_mes')) {
      context.handle(
        _recorrenciaDiaDoMesMeta,
        recorrenciaDiaDoMes.isAcceptableOrUnknown(
          data['recorrencia_dia_do_mes']!,
          _recorrenciaDiaDoMesMeta,
        ),
      );
    }
    if (data.containsKey('instrucoes')) {
      context.handle(
        _instrucoesMeta,
        instrucoes.isAcceptableOrUnknown(data['instrucoes']!, _instrucoesMeta),
      );
    }
    if (data.containsKey('ativo')) {
      context.handle(
        _ativoMeta,
        ativo.isAcceptableOrUnknown(data['ativo']!, _ativoMeta),
      );
    }
    if (data.containsKey('encerrado_em')) {
      context.handle(
        _encerradoEmMeta,
        encerradoEm.isAcceptableOrUnknown(
          data['encerrado_em']!,
          _encerradoEmMeta,
        ),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TratamentoDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TratamentoDb(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      medicamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicamento_id'],
      )!,
      quantidadeDose: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantidade_dose'],
      )!,
      unidadeDose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidade_dose'],
      )!,
      consumoEstoquePorDose: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}consumo_estoque_por_dose'],
      ),
      dataInicio: $TratamentosTable.$converterdataInicio.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}data_inicio'],
        )!,
      ),
      dataFim: $TratamentosTable.$converterdataFimn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}data_fim'],
        ),
      ),
      usoContinuo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uso_continuo'],
      )!,
      tipoAgendamento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_agendamento'],
      )!,
      dataHoraAncora: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_hora_ancora'],
      ),
      intervaloMinutos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intervalo_minutos'],
      ),
      recorrencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorrencia'],
      )!,
      recorrenciaIntervalo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorrencia_intervalo'],
      ),
      recorrenciaDiasSemana: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recorrencia_dias_semana'],
      ),
      recorrenciaDiaDoMes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorrencia_dia_do_mes'],
      ),
      instrucoes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrucoes'],
      ),
      ativo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativo'],
      )!,
      encerradoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}encerrado_em'],
      ),
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
    );
  }

  @override
  $TratamentosTable createAlias(String alias) {
    return $TratamentosTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterdataInicio =
      const ConversorDataCivil();
  static TypeConverter<DateTime, int> $converterdataFim =
      const ConversorDataCivil();
  static TypeConverter<DateTime?, int?> $converterdataFimn =
      NullAwareTypeConverter.wrap($converterdataFim);
}

class TratamentoDb extends DataClass implements Insertable<TratamentoDb> {
  final String id;
  final String medicamentoId;
  final double quantidadeDose;
  final String unidadeDose;
  final double? consumoEstoquePorDose;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final bool usoContinuo;
  final String tipoAgendamento;
  final DateTime? dataHoraAncora;
  final int? intervaloMinutos;

  /// Em quais dias os horários fixos valem: diaria, cadaNDias, diasDaSemana
  /// ou mensal. Tratamentos criados antes desta coluna continuam diários.
  final String recorrencia;

  /// Multiplicador da recorrência: dias, semanas ou meses, conforme o tipo.
  final int? recorrenciaIntervalo;

  /// Dias da semana no padrão de `DateTime.weekday`, separados por vírgula.
  final String? recorrenciaDiasSemana;
  final int? recorrenciaDiaDoMes;
  final String? instrucoes;
  final bool ativo;
  final DateTime? encerradoEm;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  const TratamentoDb({
    required this.id,
    required this.medicamentoId,
    required this.quantidadeDose,
    required this.unidadeDose,
    this.consumoEstoquePorDose,
    required this.dataInicio,
    this.dataFim,
    required this.usoContinuo,
    required this.tipoAgendamento,
    this.dataHoraAncora,
    this.intervaloMinutos,
    required this.recorrencia,
    this.recorrenciaIntervalo,
    this.recorrenciaDiasSemana,
    this.recorrenciaDiaDoMes,
    this.instrucoes,
    required this.ativo,
    this.encerradoEm,
    required this.criadoEm,
    required this.atualizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medicamento_id'] = Variable<String>(medicamentoId);
    map['quantidade_dose'] = Variable<double>(quantidadeDose);
    map['unidade_dose'] = Variable<String>(unidadeDose);
    if (!nullToAbsent || consumoEstoquePorDose != null) {
      map['consumo_estoque_por_dose'] = Variable<double>(consumoEstoquePorDose);
    }
    {
      map['data_inicio'] = Variable<int>(
        $TratamentosTable.$converterdataInicio.toSql(dataInicio),
      );
    }
    if (!nullToAbsent || dataFim != null) {
      map['data_fim'] = Variable<int>(
        $TratamentosTable.$converterdataFimn.toSql(dataFim),
      );
    }
    map['uso_continuo'] = Variable<bool>(usoContinuo);
    map['tipo_agendamento'] = Variable<String>(tipoAgendamento);
    if (!nullToAbsent || dataHoraAncora != null) {
      map['data_hora_ancora'] = Variable<DateTime>(dataHoraAncora);
    }
    if (!nullToAbsent || intervaloMinutos != null) {
      map['intervalo_minutos'] = Variable<int>(intervaloMinutos);
    }
    map['recorrencia'] = Variable<String>(recorrencia);
    if (!nullToAbsent || recorrenciaIntervalo != null) {
      map['recorrencia_intervalo'] = Variable<int>(recorrenciaIntervalo);
    }
    if (!nullToAbsent || recorrenciaDiasSemana != null) {
      map['recorrencia_dias_semana'] = Variable<String>(recorrenciaDiasSemana);
    }
    if (!nullToAbsent || recorrenciaDiaDoMes != null) {
      map['recorrencia_dia_do_mes'] = Variable<int>(recorrenciaDiaDoMes);
    }
    if (!nullToAbsent || instrucoes != null) {
      map['instrucoes'] = Variable<String>(instrucoes);
    }
    map['ativo'] = Variable<bool>(ativo);
    if (!nullToAbsent || encerradoEm != null) {
      map['encerrado_em'] = Variable<DateTime>(encerradoEm);
    }
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    return map;
  }

  TratamentosCompanion toCompanion(bool nullToAbsent) {
    return TratamentosCompanion(
      id: Value(id),
      medicamentoId: Value(medicamentoId),
      quantidadeDose: Value(quantidadeDose),
      unidadeDose: Value(unidadeDose),
      consumoEstoquePorDose: consumoEstoquePorDose == null && nullToAbsent
          ? const Value.absent()
          : Value(consumoEstoquePorDose),
      dataInicio: Value(dataInicio),
      dataFim: dataFim == null && nullToAbsent
          ? const Value.absent()
          : Value(dataFim),
      usoContinuo: Value(usoContinuo),
      tipoAgendamento: Value(tipoAgendamento),
      dataHoraAncora: dataHoraAncora == null && nullToAbsent
          ? const Value.absent()
          : Value(dataHoraAncora),
      intervaloMinutos: intervaloMinutos == null && nullToAbsent
          ? const Value.absent()
          : Value(intervaloMinutos),
      recorrencia: Value(recorrencia),
      recorrenciaIntervalo: recorrenciaIntervalo == null && nullToAbsent
          ? const Value.absent()
          : Value(recorrenciaIntervalo),
      recorrenciaDiasSemana: recorrenciaDiasSemana == null && nullToAbsent
          ? const Value.absent()
          : Value(recorrenciaDiasSemana),
      recorrenciaDiaDoMes: recorrenciaDiaDoMes == null && nullToAbsent
          ? const Value.absent()
          : Value(recorrenciaDiaDoMes),
      instrucoes: instrucoes == null && nullToAbsent
          ? const Value.absent()
          : Value(instrucoes),
      ativo: Value(ativo),
      encerradoEm: encerradoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(encerradoEm),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory TratamentoDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TratamentoDb(
      id: serializer.fromJson<String>(json['id']),
      medicamentoId: serializer.fromJson<String>(json['medicamentoId']),
      quantidadeDose: serializer.fromJson<double>(json['quantidadeDose']),
      unidadeDose: serializer.fromJson<String>(json['unidadeDose']),
      consumoEstoquePorDose: serializer.fromJson<double?>(
        json['consumoEstoquePorDose'],
      ),
      dataInicio: serializer.fromJson<DateTime>(json['dataInicio']),
      dataFim: serializer.fromJson<DateTime?>(json['dataFim']),
      usoContinuo: serializer.fromJson<bool>(json['usoContinuo']),
      tipoAgendamento: serializer.fromJson<String>(json['tipoAgendamento']),
      dataHoraAncora: serializer.fromJson<DateTime?>(json['dataHoraAncora']),
      intervaloMinutos: serializer.fromJson<int?>(json['intervaloMinutos']),
      recorrencia: serializer.fromJson<String>(json['recorrencia']),
      recorrenciaIntervalo: serializer.fromJson<int?>(
        json['recorrenciaIntervalo'],
      ),
      recorrenciaDiasSemana: serializer.fromJson<String?>(
        json['recorrenciaDiasSemana'],
      ),
      recorrenciaDiaDoMes: serializer.fromJson<int?>(
        json['recorrenciaDiaDoMes'],
      ),
      instrucoes: serializer.fromJson<String?>(json['instrucoes']),
      ativo: serializer.fromJson<bool>(json['ativo']),
      encerradoEm: serializer.fromJson<DateTime?>(json['encerradoEm']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicamentoId': serializer.toJson<String>(medicamentoId),
      'quantidadeDose': serializer.toJson<double>(quantidadeDose),
      'unidadeDose': serializer.toJson<String>(unidadeDose),
      'consumoEstoquePorDose': serializer.toJson<double?>(
        consumoEstoquePorDose,
      ),
      'dataInicio': serializer.toJson<DateTime>(dataInicio),
      'dataFim': serializer.toJson<DateTime?>(dataFim),
      'usoContinuo': serializer.toJson<bool>(usoContinuo),
      'tipoAgendamento': serializer.toJson<String>(tipoAgendamento),
      'dataHoraAncora': serializer.toJson<DateTime?>(dataHoraAncora),
      'intervaloMinutos': serializer.toJson<int?>(intervaloMinutos),
      'recorrencia': serializer.toJson<String>(recorrencia),
      'recorrenciaIntervalo': serializer.toJson<int?>(recorrenciaIntervalo),
      'recorrenciaDiasSemana': serializer.toJson<String?>(
        recorrenciaDiasSemana,
      ),
      'recorrenciaDiaDoMes': serializer.toJson<int?>(recorrenciaDiaDoMes),
      'instrucoes': serializer.toJson<String?>(instrucoes),
      'ativo': serializer.toJson<bool>(ativo),
      'encerradoEm': serializer.toJson<DateTime?>(encerradoEm),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
    };
  }

  TratamentoDb copyWith({
    String? id,
    String? medicamentoId,
    double? quantidadeDose,
    String? unidadeDose,
    Value<double?> consumoEstoquePorDose = const Value.absent(),
    DateTime? dataInicio,
    Value<DateTime?> dataFim = const Value.absent(),
    bool? usoContinuo,
    String? tipoAgendamento,
    Value<DateTime?> dataHoraAncora = const Value.absent(),
    Value<int?> intervaloMinutos = const Value.absent(),
    String? recorrencia,
    Value<int?> recorrenciaIntervalo = const Value.absent(),
    Value<String?> recorrenciaDiasSemana = const Value.absent(),
    Value<int?> recorrenciaDiaDoMes = const Value.absent(),
    Value<String?> instrucoes = const Value.absent(),
    bool? ativo,
    Value<DateTime?> encerradoEm = const Value.absent(),
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) => TratamentoDb(
    id: id ?? this.id,
    medicamentoId: medicamentoId ?? this.medicamentoId,
    quantidadeDose: quantidadeDose ?? this.quantidadeDose,
    unidadeDose: unidadeDose ?? this.unidadeDose,
    consumoEstoquePorDose: consumoEstoquePorDose.present
        ? consumoEstoquePorDose.value
        : this.consumoEstoquePorDose,
    dataInicio: dataInicio ?? this.dataInicio,
    dataFim: dataFim.present ? dataFim.value : this.dataFim,
    usoContinuo: usoContinuo ?? this.usoContinuo,
    tipoAgendamento: tipoAgendamento ?? this.tipoAgendamento,
    dataHoraAncora: dataHoraAncora.present
        ? dataHoraAncora.value
        : this.dataHoraAncora,
    intervaloMinutos: intervaloMinutos.present
        ? intervaloMinutos.value
        : this.intervaloMinutos,
    recorrencia: recorrencia ?? this.recorrencia,
    recorrenciaIntervalo: recorrenciaIntervalo.present
        ? recorrenciaIntervalo.value
        : this.recorrenciaIntervalo,
    recorrenciaDiasSemana: recorrenciaDiasSemana.present
        ? recorrenciaDiasSemana.value
        : this.recorrenciaDiasSemana,
    recorrenciaDiaDoMes: recorrenciaDiaDoMes.present
        ? recorrenciaDiaDoMes.value
        : this.recorrenciaDiaDoMes,
    instrucoes: instrucoes.present ? instrucoes.value : this.instrucoes,
    ativo: ativo ?? this.ativo,
    encerradoEm: encerradoEm.present ? encerradoEm.value : this.encerradoEm,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
  );
  TratamentoDb copyWithCompanion(TratamentosCompanion data) {
    return TratamentoDb(
      id: data.id.present ? data.id.value : this.id,
      medicamentoId: data.medicamentoId.present
          ? data.medicamentoId.value
          : this.medicamentoId,
      quantidadeDose: data.quantidadeDose.present
          ? data.quantidadeDose.value
          : this.quantidadeDose,
      unidadeDose: data.unidadeDose.present
          ? data.unidadeDose.value
          : this.unidadeDose,
      consumoEstoquePorDose: data.consumoEstoquePorDose.present
          ? data.consumoEstoquePorDose.value
          : this.consumoEstoquePorDose,
      dataInicio: data.dataInicio.present
          ? data.dataInicio.value
          : this.dataInicio,
      dataFim: data.dataFim.present ? data.dataFim.value : this.dataFim,
      usoContinuo: data.usoContinuo.present
          ? data.usoContinuo.value
          : this.usoContinuo,
      tipoAgendamento: data.tipoAgendamento.present
          ? data.tipoAgendamento.value
          : this.tipoAgendamento,
      dataHoraAncora: data.dataHoraAncora.present
          ? data.dataHoraAncora.value
          : this.dataHoraAncora,
      intervaloMinutos: data.intervaloMinutos.present
          ? data.intervaloMinutos.value
          : this.intervaloMinutos,
      recorrencia: data.recorrencia.present
          ? data.recorrencia.value
          : this.recorrencia,
      recorrenciaIntervalo: data.recorrenciaIntervalo.present
          ? data.recorrenciaIntervalo.value
          : this.recorrenciaIntervalo,
      recorrenciaDiasSemana: data.recorrenciaDiasSemana.present
          ? data.recorrenciaDiasSemana.value
          : this.recorrenciaDiasSemana,
      recorrenciaDiaDoMes: data.recorrenciaDiaDoMes.present
          ? data.recorrenciaDiaDoMes.value
          : this.recorrenciaDiaDoMes,
      instrucoes: data.instrucoes.present
          ? data.instrucoes.value
          : this.instrucoes,
      ativo: data.ativo.present ? data.ativo.value : this.ativo,
      encerradoEm: data.encerradoEm.present
          ? data.encerradoEm.value
          : this.encerradoEm,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TratamentoDb(')
          ..write('id: $id, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('quantidadeDose: $quantidadeDose, ')
          ..write('unidadeDose: $unidadeDose, ')
          ..write('consumoEstoquePorDose: $consumoEstoquePorDose, ')
          ..write('dataInicio: $dataInicio, ')
          ..write('dataFim: $dataFim, ')
          ..write('usoContinuo: $usoContinuo, ')
          ..write('tipoAgendamento: $tipoAgendamento, ')
          ..write('dataHoraAncora: $dataHoraAncora, ')
          ..write('intervaloMinutos: $intervaloMinutos, ')
          ..write('recorrencia: $recorrencia, ')
          ..write('recorrenciaIntervalo: $recorrenciaIntervalo, ')
          ..write('recorrenciaDiasSemana: $recorrenciaDiasSemana, ')
          ..write('recorrenciaDiaDoMes: $recorrenciaDiaDoMes, ')
          ..write('instrucoes: $instrucoes, ')
          ..write('ativo: $ativo, ')
          ..write('encerradoEm: $encerradoEm, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicamentoId,
    quantidadeDose,
    unidadeDose,
    consumoEstoquePorDose,
    dataInicio,
    dataFim,
    usoContinuo,
    tipoAgendamento,
    dataHoraAncora,
    intervaloMinutos,
    recorrencia,
    recorrenciaIntervalo,
    recorrenciaDiasSemana,
    recorrenciaDiaDoMes,
    instrucoes,
    ativo,
    encerradoEm,
    criadoEm,
    atualizadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TratamentoDb &&
          other.id == this.id &&
          other.medicamentoId == this.medicamentoId &&
          other.quantidadeDose == this.quantidadeDose &&
          other.unidadeDose == this.unidadeDose &&
          other.consumoEstoquePorDose == this.consumoEstoquePorDose &&
          other.dataInicio == this.dataInicio &&
          other.dataFim == this.dataFim &&
          other.usoContinuo == this.usoContinuo &&
          other.tipoAgendamento == this.tipoAgendamento &&
          other.dataHoraAncora == this.dataHoraAncora &&
          other.intervaloMinutos == this.intervaloMinutos &&
          other.recorrencia == this.recorrencia &&
          other.recorrenciaIntervalo == this.recorrenciaIntervalo &&
          other.recorrenciaDiasSemana == this.recorrenciaDiasSemana &&
          other.recorrenciaDiaDoMes == this.recorrenciaDiaDoMes &&
          other.instrucoes == this.instrucoes &&
          other.ativo == this.ativo &&
          other.encerradoEm == this.encerradoEm &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm);
}

class TratamentosCompanion extends UpdateCompanion<TratamentoDb> {
  final Value<String> id;
  final Value<String> medicamentoId;
  final Value<double> quantidadeDose;
  final Value<String> unidadeDose;
  final Value<double?> consumoEstoquePorDose;
  final Value<DateTime> dataInicio;
  final Value<DateTime?> dataFim;
  final Value<bool> usoContinuo;
  final Value<String> tipoAgendamento;
  final Value<DateTime?> dataHoraAncora;
  final Value<int?> intervaloMinutos;
  final Value<String> recorrencia;
  final Value<int?> recorrenciaIntervalo;
  final Value<String?> recorrenciaDiasSemana;
  final Value<int?> recorrenciaDiaDoMes;
  final Value<String?> instrucoes;
  final Value<bool> ativo;
  final Value<DateTime?> encerradoEm;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<int> rowid;
  const TratamentosCompanion({
    this.id = const Value.absent(),
    this.medicamentoId = const Value.absent(),
    this.quantidadeDose = const Value.absent(),
    this.unidadeDose = const Value.absent(),
    this.consumoEstoquePorDose = const Value.absent(),
    this.dataInicio = const Value.absent(),
    this.dataFim = const Value.absent(),
    this.usoContinuo = const Value.absent(),
    this.tipoAgendamento = const Value.absent(),
    this.dataHoraAncora = const Value.absent(),
    this.intervaloMinutos = const Value.absent(),
    this.recorrencia = const Value.absent(),
    this.recorrenciaIntervalo = const Value.absent(),
    this.recorrenciaDiasSemana = const Value.absent(),
    this.recorrenciaDiaDoMes = const Value.absent(),
    this.instrucoes = const Value.absent(),
    this.ativo = const Value.absent(),
    this.encerradoEm = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TratamentosCompanion.insert({
    required String id,
    required String medicamentoId,
    required double quantidadeDose,
    required String unidadeDose,
    this.consumoEstoquePorDose = const Value.absent(),
    required DateTime dataInicio,
    this.dataFim = const Value.absent(),
    required bool usoContinuo,
    required String tipoAgendamento,
    this.dataHoraAncora = const Value.absent(),
    this.intervaloMinutos = const Value.absent(),
    this.recorrencia = const Value.absent(),
    this.recorrenciaIntervalo = const Value.absent(),
    this.recorrenciaDiasSemana = const Value.absent(),
    this.recorrenciaDiaDoMes = const Value.absent(),
    this.instrucoes = const Value.absent(),
    this.ativo = const Value.absent(),
    this.encerradoEm = const Value.absent(),
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicamentoId = Value(medicamentoId),
       quantidadeDose = Value(quantidadeDose),
       unidadeDose = Value(unidadeDose),
       dataInicio = Value(dataInicio),
       usoContinuo = Value(usoContinuo),
       tipoAgendamento = Value(tipoAgendamento),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm);
  static Insertable<TratamentoDb> custom({
    Expression<String>? id,
    Expression<String>? medicamentoId,
    Expression<double>? quantidadeDose,
    Expression<String>? unidadeDose,
    Expression<double>? consumoEstoquePorDose,
    Expression<int>? dataInicio,
    Expression<int>? dataFim,
    Expression<bool>? usoContinuo,
    Expression<String>? tipoAgendamento,
    Expression<DateTime>? dataHoraAncora,
    Expression<int>? intervaloMinutos,
    Expression<String>? recorrencia,
    Expression<int>? recorrenciaIntervalo,
    Expression<String>? recorrenciaDiasSemana,
    Expression<int>? recorrenciaDiaDoMes,
    Expression<String>? instrucoes,
    Expression<bool>? ativo,
    Expression<DateTime>? encerradoEm,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicamentoId != null) 'medicamento_id': medicamentoId,
      if (quantidadeDose != null) 'quantidade_dose': quantidadeDose,
      if (unidadeDose != null) 'unidade_dose': unidadeDose,
      if (consumoEstoquePorDose != null)
        'consumo_estoque_por_dose': consumoEstoquePorDose,
      if (dataInicio != null) 'data_inicio': dataInicio,
      if (dataFim != null) 'data_fim': dataFim,
      if (usoContinuo != null) 'uso_continuo': usoContinuo,
      if (tipoAgendamento != null) 'tipo_agendamento': tipoAgendamento,
      if (dataHoraAncora != null) 'data_hora_ancora': dataHoraAncora,
      if (intervaloMinutos != null) 'intervalo_minutos': intervaloMinutos,
      if (recorrencia != null) 'recorrencia': recorrencia,
      if (recorrenciaIntervalo != null)
        'recorrencia_intervalo': recorrenciaIntervalo,
      if (recorrenciaDiasSemana != null)
        'recorrencia_dias_semana': recorrenciaDiasSemana,
      if (recorrenciaDiaDoMes != null)
        'recorrencia_dia_do_mes': recorrenciaDiaDoMes,
      if (instrucoes != null) 'instrucoes': instrucoes,
      if (ativo != null) 'ativo': ativo,
      if (encerradoEm != null) 'encerrado_em': encerradoEm,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TratamentosCompanion copyWith({
    Value<String>? id,
    Value<String>? medicamentoId,
    Value<double>? quantidadeDose,
    Value<String>? unidadeDose,
    Value<double?>? consumoEstoquePorDose,
    Value<DateTime>? dataInicio,
    Value<DateTime?>? dataFim,
    Value<bool>? usoContinuo,
    Value<String>? tipoAgendamento,
    Value<DateTime?>? dataHoraAncora,
    Value<int?>? intervaloMinutos,
    Value<String>? recorrencia,
    Value<int?>? recorrenciaIntervalo,
    Value<String?>? recorrenciaDiasSemana,
    Value<int?>? recorrenciaDiaDoMes,
    Value<String?>? instrucoes,
    Value<bool>? ativo,
    Value<DateTime?>? encerradoEm,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<int>? rowid,
  }) {
    return TratamentosCompanion(
      id: id ?? this.id,
      medicamentoId: medicamentoId ?? this.medicamentoId,
      quantidadeDose: quantidadeDose ?? this.quantidadeDose,
      unidadeDose: unidadeDose ?? this.unidadeDose,
      consumoEstoquePorDose:
          consumoEstoquePorDose ?? this.consumoEstoquePorDose,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      usoContinuo: usoContinuo ?? this.usoContinuo,
      tipoAgendamento: tipoAgendamento ?? this.tipoAgendamento,
      dataHoraAncora: dataHoraAncora ?? this.dataHoraAncora,
      intervaloMinutos: intervaloMinutos ?? this.intervaloMinutos,
      recorrencia: recorrencia ?? this.recorrencia,
      recorrenciaIntervalo: recorrenciaIntervalo ?? this.recorrenciaIntervalo,
      recorrenciaDiasSemana:
          recorrenciaDiasSemana ?? this.recorrenciaDiasSemana,
      recorrenciaDiaDoMes: recorrenciaDiaDoMes ?? this.recorrenciaDiaDoMes,
      instrucoes: instrucoes ?? this.instrucoes,
      ativo: ativo ?? this.ativo,
      encerradoEm: encerradoEm ?? this.encerradoEm,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicamentoId.present) {
      map['medicamento_id'] = Variable<String>(medicamentoId.value);
    }
    if (quantidadeDose.present) {
      map['quantidade_dose'] = Variable<double>(quantidadeDose.value);
    }
    if (unidadeDose.present) {
      map['unidade_dose'] = Variable<String>(unidadeDose.value);
    }
    if (consumoEstoquePorDose.present) {
      map['consumo_estoque_por_dose'] = Variable<double>(
        consumoEstoquePorDose.value,
      );
    }
    if (dataInicio.present) {
      map['data_inicio'] = Variable<int>(
        $TratamentosTable.$converterdataInicio.toSql(dataInicio.value),
      );
    }
    if (dataFim.present) {
      map['data_fim'] = Variable<int>(
        $TratamentosTable.$converterdataFimn.toSql(dataFim.value),
      );
    }
    if (usoContinuo.present) {
      map['uso_continuo'] = Variable<bool>(usoContinuo.value);
    }
    if (tipoAgendamento.present) {
      map['tipo_agendamento'] = Variable<String>(tipoAgendamento.value);
    }
    if (dataHoraAncora.present) {
      map['data_hora_ancora'] = Variable<DateTime>(dataHoraAncora.value);
    }
    if (intervaloMinutos.present) {
      map['intervalo_minutos'] = Variable<int>(intervaloMinutos.value);
    }
    if (recorrencia.present) {
      map['recorrencia'] = Variable<String>(recorrencia.value);
    }
    if (recorrenciaIntervalo.present) {
      map['recorrencia_intervalo'] = Variable<int>(recorrenciaIntervalo.value);
    }
    if (recorrenciaDiasSemana.present) {
      map['recorrencia_dias_semana'] = Variable<String>(
        recorrenciaDiasSemana.value,
      );
    }
    if (recorrenciaDiaDoMes.present) {
      map['recorrencia_dia_do_mes'] = Variable<int>(recorrenciaDiaDoMes.value);
    }
    if (instrucoes.present) {
      map['instrucoes'] = Variable<String>(instrucoes.value);
    }
    if (ativo.present) {
      map['ativo'] = Variable<bool>(ativo.value);
    }
    if (encerradoEm.present) {
      map['encerrado_em'] = Variable<DateTime>(encerradoEm.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TratamentosCompanion(')
          ..write('id: $id, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('quantidadeDose: $quantidadeDose, ')
          ..write('unidadeDose: $unidadeDose, ')
          ..write('consumoEstoquePorDose: $consumoEstoquePorDose, ')
          ..write('dataInicio: $dataInicio, ')
          ..write('dataFim: $dataFim, ')
          ..write('usoContinuo: $usoContinuo, ')
          ..write('tipoAgendamento: $tipoAgendamento, ')
          ..write('dataHoraAncora: $dataHoraAncora, ')
          ..write('intervaloMinutos: $intervaloMinutos, ')
          ..write('recorrencia: $recorrencia, ')
          ..write('recorrenciaIntervalo: $recorrenciaIntervalo, ')
          ..write('recorrenciaDiasSemana: $recorrenciaDiasSemana, ')
          ..write('recorrenciaDiaDoMes: $recorrenciaDiaDoMes, ')
          ..write('instrucoes: $instrucoes, ')
          ..write('ativo: $ativo, ')
          ..write('encerradoEm: $encerradoEm, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HorariosTratamentoTable extends HorariosTratamento
    with TableInfo<$HorariosTratamentoTable, HorarioTratamentoDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HorariosTratamentoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tratamentoIdMeta = const VerificationMeta(
    'tratamentoId',
  );
  @override
  late final GeneratedColumn<String> tratamentoId = GeneratedColumn<String>(
    'tratamento_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tratamentos (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _horaMeta = const VerificationMeta('hora');
  @override
  late final GeneratedColumn<int> hora = GeneratedColumn<int>(
    'hora',
    aliasedName,
    false,
    check: () => const CustomExpression('hora BETWEEN 0 AND 23'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutoMeta = const VerificationMeta('minuto');
  @override
  late final GeneratedColumn<int> minuto = GeneratedColumn<int>(
    'minuto',
    aliasedName,
    false,
    check: () => const CustomExpression('minuto BETWEEN 0 AND 59'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    check: () => const CustomExpression('ordem >= 0'),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, tratamentoId, hora, minuto, ordem];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'horarios_tratamento';
  @override
  VerificationContext validateIntegrity(
    Insertable<HorarioTratamentoDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tratamento_id')) {
      context.handle(
        _tratamentoIdMeta,
        tratamentoId.isAcceptableOrUnknown(
          data['tratamento_id']!,
          _tratamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tratamentoIdMeta);
    }
    if (data.containsKey('hora')) {
      context.handle(
        _horaMeta,
        hora.isAcceptableOrUnknown(data['hora']!, _horaMeta),
      );
    } else if (isInserting) {
      context.missing(_horaMeta);
    }
    if (data.containsKey('minuto')) {
      context.handle(
        _minutoMeta,
        minuto.isAcceptableOrUnknown(data['minuto']!, _minutoMeta),
      );
    } else if (isInserting) {
      context.missing(_minutoMeta);
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    } else if (isInserting) {
      context.missing(_ordemMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tratamentoId, hora, minuto},
  ];
  @override
  HorarioTratamentoDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HorarioTratamentoDb(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tratamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tratamento_id'],
      )!,
      hora: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hora'],
      )!,
      minuto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minuto'],
      )!,
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
    );
  }

  @override
  $HorariosTratamentoTable createAlias(String alias) {
    return $HorariosTratamentoTable(attachedDatabase, alias);
  }
}

class HorarioTratamentoDb extends DataClass
    implements Insertable<HorarioTratamentoDb> {
  final String id;
  final String tratamentoId;
  final int hora;
  final int minuto;
  final int ordem;
  const HorarioTratamentoDb({
    required this.id,
    required this.tratamentoId,
    required this.hora,
    required this.minuto,
    required this.ordem,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tratamento_id'] = Variable<String>(tratamentoId);
    map['hora'] = Variable<int>(hora);
    map['minuto'] = Variable<int>(minuto);
    map['ordem'] = Variable<int>(ordem);
    return map;
  }

  HorariosTratamentoCompanion toCompanion(bool nullToAbsent) {
    return HorariosTratamentoCompanion(
      id: Value(id),
      tratamentoId: Value(tratamentoId),
      hora: Value(hora),
      minuto: Value(minuto),
      ordem: Value(ordem),
    );
  }

  factory HorarioTratamentoDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HorarioTratamentoDb(
      id: serializer.fromJson<String>(json['id']),
      tratamentoId: serializer.fromJson<String>(json['tratamentoId']),
      hora: serializer.fromJson<int>(json['hora']),
      minuto: serializer.fromJson<int>(json['minuto']),
      ordem: serializer.fromJson<int>(json['ordem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tratamentoId': serializer.toJson<String>(tratamentoId),
      'hora': serializer.toJson<int>(hora),
      'minuto': serializer.toJson<int>(minuto),
      'ordem': serializer.toJson<int>(ordem),
    };
  }

  HorarioTratamentoDb copyWith({
    String? id,
    String? tratamentoId,
    int? hora,
    int? minuto,
    int? ordem,
  }) => HorarioTratamentoDb(
    id: id ?? this.id,
    tratamentoId: tratamentoId ?? this.tratamentoId,
    hora: hora ?? this.hora,
    minuto: minuto ?? this.minuto,
    ordem: ordem ?? this.ordem,
  );
  HorarioTratamentoDb copyWithCompanion(HorariosTratamentoCompanion data) {
    return HorarioTratamentoDb(
      id: data.id.present ? data.id.value : this.id,
      tratamentoId: data.tratamentoId.present
          ? data.tratamentoId.value
          : this.tratamentoId,
      hora: data.hora.present ? data.hora.value : this.hora,
      minuto: data.minuto.present ? data.minuto.value : this.minuto,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HorarioTratamentoDb(')
          ..write('id: $id, ')
          ..write('tratamentoId: $tratamentoId, ')
          ..write('hora: $hora, ')
          ..write('minuto: $minuto, ')
          ..write('ordem: $ordem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tratamentoId, hora, minuto, ordem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HorarioTratamentoDb &&
          other.id == this.id &&
          other.tratamentoId == this.tratamentoId &&
          other.hora == this.hora &&
          other.minuto == this.minuto &&
          other.ordem == this.ordem);
}

class HorariosTratamentoCompanion extends UpdateCompanion<HorarioTratamentoDb> {
  final Value<String> id;
  final Value<String> tratamentoId;
  final Value<int> hora;
  final Value<int> minuto;
  final Value<int> ordem;
  final Value<int> rowid;
  const HorariosTratamentoCompanion({
    this.id = const Value.absent(),
    this.tratamentoId = const Value.absent(),
    this.hora = const Value.absent(),
    this.minuto = const Value.absent(),
    this.ordem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HorariosTratamentoCompanion.insert({
    required String id,
    required String tratamentoId,
    required int hora,
    required int minuto,
    required int ordem,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tratamentoId = Value(tratamentoId),
       hora = Value(hora),
       minuto = Value(minuto),
       ordem = Value(ordem);
  static Insertable<HorarioTratamentoDb> custom({
    Expression<String>? id,
    Expression<String>? tratamentoId,
    Expression<int>? hora,
    Expression<int>? minuto,
    Expression<int>? ordem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tratamentoId != null) 'tratamento_id': tratamentoId,
      if (hora != null) 'hora': hora,
      if (minuto != null) 'minuto': minuto,
      if (ordem != null) 'ordem': ordem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HorariosTratamentoCompanion copyWith({
    Value<String>? id,
    Value<String>? tratamentoId,
    Value<int>? hora,
    Value<int>? minuto,
    Value<int>? ordem,
    Value<int>? rowid,
  }) {
    return HorariosTratamentoCompanion(
      id: id ?? this.id,
      tratamentoId: tratamentoId ?? this.tratamentoId,
      hora: hora ?? this.hora,
      minuto: minuto ?? this.minuto,
      ordem: ordem ?? this.ordem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tratamentoId.present) {
      map['tratamento_id'] = Variable<String>(tratamentoId.value);
    }
    if (hora.present) {
      map['hora'] = Variable<int>(hora.value);
    }
    if (minuto.present) {
      map['minuto'] = Variable<int>(minuto.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HorariosTratamentoCompanion(')
          ..write('id: $id, ')
          ..write('tratamentoId: $tratamentoId, ')
          ..write('hora: $hora, ')
          ..write('minuto: $minuto, ')
          ..write('ordem: $ordem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RegistrosDoseTable extends RegistrosDose
    with TableInfo<$RegistrosDoseTable, RegistroDoseDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegistrosDoseTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseKeyMeta = const VerificationMeta(
    'doseKey',
  );
  @override
  late final GeneratedColumn<String> doseKey = GeneratedColumn<String>(
    'dose_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tratamentoIdMeta = const VerificationMeta(
    'tratamentoId',
  );
  @override
  late final GeneratedColumn<String> tratamentoId = GeneratedColumn<String>(
    'tratamento_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tratamentos (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _medicamentoIdMeta = const VerificationMeta(
    'medicamentoId',
  );
  @override
  late final GeneratedColumn<String> medicamentoId = GeneratedColumn<String>(
    'medicamento_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicamentos (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _dataHoraProgramadaMeta =
      const VerificationMeta('dataHoraProgramada');
  @override
  late final GeneratedColumn<DateTime> dataHoraProgramada =
      GeneratedColumn<DateTime>(
        'data_hora_programada',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dataHoraAcaoMeta = const VerificationMeta(
    'dataHoraAcao',
  );
  @override
  late final GeneratedColumn<DateTime> dataHoraAcao = GeneratedColumn<DateTime>(
    'data_hora_acao',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantidadeDoseMeta = const VerificationMeta(
    'quantidadeDose',
  );
  @override
  late final GeneratedColumn<double> quantidadeDose = GeneratedColumn<double>(
    'quantidade_dose',
    aliasedName,
    false,
    check: () => const CustomExpression('quantidade_dose > 0'),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unidadeDoseMeta = const VerificationMeta(
    'unidadeDose',
  );
  @override
  late final GeneratedColumn<String> unidadeDose = GeneratedColumn<String>(
    'unidade_dose',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => const CustomExpression("status IN ('tomada', 'naoTomada')"),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observacaoMeta = const VerificationMeta(
    'observacao',
  );
  @override
  late final GeneratedColumn<String> observacao = GeneratedColumn<String>(
    'observacao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    doseKey,
    tratamentoId,
    medicamentoId,
    dataHoraProgramada,
    dataHoraAcao,
    quantidadeDose,
    unidadeDose,
    status,
    observacao,
    criadoEm,
    atualizadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'registros_dose';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegistroDoseDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dose_key')) {
      context.handle(
        _doseKeyMeta,
        doseKey.isAcceptableOrUnknown(data['dose_key']!, _doseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_doseKeyMeta);
    }
    if (data.containsKey('tratamento_id')) {
      context.handle(
        _tratamentoIdMeta,
        tratamentoId.isAcceptableOrUnknown(
          data['tratamento_id']!,
          _tratamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tratamentoIdMeta);
    }
    if (data.containsKey('medicamento_id')) {
      context.handle(
        _medicamentoIdMeta,
        medicamentoId.isAcceptableOrUnknown(
          data['medicamento_id']!,
          _medicamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicamentoIdMeta);
    }
    if (data.containsKey('data_hora_programada')) {
      context.handle(
        _dataHoraProgramadaMeta,
        dataHoraProgramada.isAcceptableOrUnknown(
          data['data_hora_programada']!,
          _dataHoraProgramadaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataHoraProgramadaMeta);
    }
    if (data.containsKey('data_hora_acao')) {
      context.handle(
        _dataHoraAcaoMeta,
        dataHoraAcao.isAcceptableOrUnknown(
          data['data_hora_acao']!,
          _dataHoraAcaoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataHoraAcaoMeta);
    }
    if (data.containsKey('quantidade_dose')) {
      context.handle(
        _quantidadeDoseMeta,
        quantidadeDose.isAcceptableOrUnknown(
          data['quantidade_dose']!,
          _quantidadeDoseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantidadeDoseMeta);
    }
    if (data.containsKey('unidade_dose')) {
      context.handle(
        _unidadeDoseMeta,
        unidadeDose.isAcceptableOrUnknown(
          data['unidade_dose']!,
          _unidadeDoseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unidadeDoseMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('observacao')) {
      context.handle(
        _observacaoMeta,
        observacao.isAcceptableOrUnknown(data['observacao']!, _observacaoMeta),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegistroDoseDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegistroDoseDb(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      doseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_key'],
      )!,
      tratamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tratamento_id'],
      )!,
      medicamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicamento_id'],
      )!,
      dataHoraProgramada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_hora_programada'],
      )!,
      dataHoraAcao: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_hora_acao'],
      )!,
      quantidadeDose: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantidade_dose'],
      )!,
      unidadeDose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidade_dose'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      observacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacao'],
      ),
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
    );
  }

  @override
  $RegistrosDoseTable createAlias(String alias) {
    return $RegistrosDoseTable(attachedDatabase, alias);
  }
}

class RegistroDoseDb extends DataClass implements Insertable<RegistroDoseDb> {
  final String id;
  final String doseKey;
  final String tratamentoId;
  final String medicamentoId;
  final DateTime dataHoraProgramada;
  final DateTime dataHoraAcao;
  final double quantidadeDose;
  final String unidadeDose;
  final String status;
  final String? observacao;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  const RegistroDoseDb({
    required this.id,
    required this.doseKey,
    required this.tratamentoId,
    required this.medicamentoId,
    required this.dataHoraProgramada,
    required this.dataHoraAcao,
    required this.quantidadeDose,
    required this.unidadeDose,
    required this.status,
    this.observacao,
    required this.criadoEm,
    required this.atualizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dose_key'] = Variable<String>(doseKey);
    map['tratamento_id'] = Variable<String>(tratamentoId);
    map['medicamento_id'] = Variable<String>(medicamentoId);
    map['data_hora_programada'] = Variable<DateTime>(dataHoraProgramada);
    map['data_hora_acao'] = Variable<DateTime>(dataHoraAcao);
    map['quantidade_dose'] = Variable<double>(quantidadeDose);
    map['unidade_dose'] = Variable<String>(unidadeDose);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || observacao != null) {
      map['observacao'] = Variable<String>(observacao);
    }
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    return map;
  }

  RegistrosDoseCompanion toCompanion(bool nullToAbsent) {
    return RegistrosDoseCompanion(
      id: Value(id),
      doseKey: Value(doseKey),
      tratamentoId: Value(tratamentoId),
      medicamentoId: Value(medicamentoId),
      dataHoraProgramada: Value(dataHoraProgramada),
      dataHoraAcao: Value(dataHoraAcao),
      quantidadeDose: Value(quantidadeDose),
      unidadeDose: Value(unidadeDose),
      status: Value(status),
      observacao: observacao == null && nullToAbsent
          ? const Value.absent()
          : Value(observacao),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory RegistroDoseDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegistroDoseDb(
      id: serializer.fromJson<String>(json['id']),
      doseKey: serializer.fromJson<String>(json['doseKey']),
      tratamentoId: serializer.fromJson<String>(json['tratamentoId']),
      medicamentoId: serializer.fromJson<String>(json['medicamentoId']),
      dataHoraProgramada: serializer.fromJson<DateTime>(
        json['dataHoraProgramada'],
      ),
      dataHoraAcao: serializer.fromJson<DateTime>(json['dataHoraAcao']),
      quantidadeDose: serializer.fromJson<double>(json['quantidadeDose']),
      unidadeDose: serializer.fromJson<String>(json['unidadeDose']),
      status: serializer.fromJson<String>(json['status']),
      observacao: serializer.fromJson<String?>(json['observacao']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'doseKey': serializer.toJson<String>(doseKey),
      'tratamentoId': serializer.toJson<String>(tratamentoId),
      'medicamentoId': serializer.toJson<String>(medicamentoId),
      'dataHoraProgramada': serializer.toJson<DateTime>(dataHoraProgramada),
      'dataHoraAcao': serializer.toJson<DateTime>(dataHoraAcao),
      'quantidadeDose': serializer.toJson<double>(quantidadeDose),
      'unidadeDose': serializer.toJson<String>(unidadeDose),
      'status': serializer.toJson<String>(status),
      'observacao': serializer.toJson<String?>(observacao),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
    };
  }

  RegistroDoseDb copyWith({
    String? id,
    String? doseKey,
    String? tratamentoId,
    String? medicamentoId,
    DateTime? dataHoraProgramada,
    DateTime? dataHoraAcao,
    double? quantidadeDose,
    String? unidadeDose,
    String? status,
    Value<String?> observacao = const Value.absent(),
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) => RegistroDoseDb(
    id: id ?? this.id,
    doseKey: doseKey ?? this.doseKey,
    tratamentoId: tratamentoId ?? this.tratamentoId,
    medicamentoId: medicamentoId ?? this.medicamentoId,
    dataHoraProgramada: dataHoraProgramada ?? this.dataHoraProgramada,
    dataHoraAcao: dataHoraAcao ?? this.dataHoraAcao,
    quantidadeDose: quantidadeDose ?? this.quantidadeDose,
    unidadeDose: unidadeDose ?? this.unidadeDose,
    status: status ?? this.status,
    observacao: observacao.present ? observacao.value : this.observacao,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
  );
  RegistroDoseDb copyWithCompanion(RegistrosDoseCompanion data) {
    return RegistroDoseDb(
      id: data.id.present ? data.id.value : this.id,
      doseKey: data.doseKey.present ? data.doseKey.value : this.doseKey,
      tratamentoId: data.tratamentoId.present
          ? data.tratamentoId.value
          : this.tratamentoId,
      medicamentoId: data.medicamentoId.present
          ? data.medicamentoId.value
          : this.medicamentoId,
      dataHoraProgramada: data.dataHoraProgramada.present
          ? data.dataHoraProgramada.value
          : this.dataHoraProgramada,
      dataHoraAcao: data.dataHoraAcao.present
          ? data.dataHoraAcao.value
          : this.dataHoraAcao,
      quantidadeDose: data.quantidadeDose.present
          ? data.quantidadeDose.value
          : this.quantidadeDose,
      unidadeDose: data.unidadeDose.present
          ? data.unidadeDose.value
          : this.unidadeDose,
      status: data.status.present ? data.status.value : this.status,
      observacao: data.observacao.present
          ? data.observacao.value
          : this.observacao,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegistroDoseDb(')
          ..write('id: $id, ')
          ..write('doseKey: $doseKey, ')
          ..write('tratamentoId: $tratamentoId, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('dataHoraProgramada: $dataHoraProgramada, ')
          ..write('dataHoraAcao: $dataHoraAcao, ')
          ..write('quantidadeDose: $quantidadeDose, ')
          ..write('unidadeDose: $unidadeDose, ')
          ..write('status: $status, ')
          ..write('observacao: $observacao, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    doseKey,
    tratamentoId,
    medicamentoId,
    dataHoraProgramada,
    dataHoraAcao,
    quantidadeDose,
    unidadeDose,
    status,
    observacao,
    criadoEm,
    atualizadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegistroDoseDb &&
          other.id == this.id &&
          other.doseKey == this.doseKey &&
          other.tratamentoId == this.tratamentoId &&
          other.medicamentoId == this.medicamentoId &&
          other.dataHoraProgramada == this.dataHoraProgramada &&
          other.dataHoraAcao == this.dataHoraAcao &&
          other.quantidadeDose == this.quantidadeDose &&
          other.unidadeDose == this.unidadeDose &&
          other.status == this.status &&
          other.observacao == this.observacao &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm);
}

class RegistrosDoseCompanion extends UpdateCompanion<RegistroDoseDb> {
  final Value<String> id;
  final Value<String> doseKey;
  final Value<String> tratamentoId;
  final Value<String> medicamentoId;
  final Value<DateTime> dataHoraProgramada;
  final Value<DateTime> dataHoraAcao;
  final Value<double> quantidadeDose;
  final Value<String> unidadeDose;
  final Value<String> status;
  final Value<String?> observacao;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<int> rowid;
  const RegistrosDoseCompanion({
    this.id = const Value.absent(),
    this.doseKey = const Value.absent(),
    this.tratamentoId = const Value.absent(),
    this.medicamentoId = const Value.absent(),
    this.dataHoraProgramada = const Value.absent(),
    this.dataHoraAcao = const Value.absent(),
    this.quantidadeDose = const Value.absent(),
    this.unidadeDose = const Value.absent(),
    this.status = const Value.absent(),
    this.observacao = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RegistrosDoseCompanion.insert({
    required String id,
    required String doseKey,
    required String tratamentoId,
    required String medicamentoId,
    required DateTime dataHoraProgramada,
    required DateTime dataHoraAcao,
    required double quantidadeDose,
    required String unidadeDose,
    required String status,
    this.observacao = const Value.absent(),
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       doseKey = Value(doseKey),
       tratamentoId = Value(tratamentoId),
       medicamentoId = Value(medicamentoId),
       dataHoraProgramada = Value(dataHoraProgramada),
       dataHoraAcao = Value(dataHoraAcao),
       quantidadeDose = Value(quantidadeDose),
       unidadeDose = Value(unidadeDose),
       status = Value(status),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm);
  static Insertable<RegistroDoseDb> custom({
    Expression<String>? id,
    Expression<String>? doseKey,
    Expression<String>? tratamentoId,
    Expression<String>? medicamentoId,
    Expression<DateTime>? dataHoraProgramada,
    Expression<DateTime>? dataHoraAcao,
    Expression<double>? quantidadeDose,
    Expression<String>? unidadeDose,
    Expression<String>? status,
    Expression<String>? observacao,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (doseKey != null) 'dose_key': doseKey,
      if (tratamentoId != null) 'tratamento_id': tratamentoId,
      if (medicamentoId != null) 'medicamento_id': medicamentoId,
      if (dataHoraProgramada != null)
        'data_hora_programada': dataHoraProgramada,
      if (dataHoraAcao != null) 'data_hora_acao': dataHoraAcao,
      if (quantidadeDose != null) 'quantidade_dose': quantidadeDose,
      if (unidadeDose != null) 'unidade_dose': unidadeDose,
      if (status != null) 'status': status,
      if (observacao != null) 'observacao': observacao,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RegistrosDoseCompanion copyWith({
    Value<String>? id,
    Value<String>? doseKey,
    Value<String>? tratamentoId,
    Value<String>? medicamentoId,
    Value<DateTime>? dataHoraProgramada,
    Value<DateTime>? dataHoraAcao,
    Value<double>? quantidadeDose,
    Value<String>? unidadeDose,
    Value<String>? status,
    Value<String?>? observacao,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<int>? rowid,
  }) {
    return RegistrosDoseCompanion(
      id: id ?? this.id,
      doseKey: doseKey ?? this.doseKey,
      tratamentoId: tratamentoId ?? this.tratamentoId,
      medicamentoId: medicamentoId ?? this.medicamentoId,
      dataHoraProgramada: dataHoraProgramada ?? this.dataHoraProgramada,
      dataHoraAcao: dataHoraAcao ?? this.dataHoraAcao,
      quantidadeDose: quantidadeDose ?? this.quantidadeDose,
      unidadeDose: unidadeDose ?? this.unidadeDose,
      status: status ?? this.status,
      observacao: observacao ?? this.observacao,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (doseKey.present) {
      map['dose_key'] = Variable<String>(doseKey.value);
    }
    if (tratamentoId.present) {
      map['tratamento_id'] = Variable<String>(tratamentoId.value);
    }
    if (medicamentoId.present) {
      map['medicamento_id'] = Variable<String>(medicamentoId.value);
    }
    if (dataHoraProgramada.present) {
      map['data_hora_programada'] = Variable<DateTime>(
        dataHoraProgramada.value,
      );
    }
    if (dataHoraAcao.present) {
      map['data_hora_acao'] = Variable<DateTime>(dataHoraAcao.value);
    }
    if (quantidadeDose.present) {
      map['quantidade_dose'] = Variable<double>(quantidadeDose.value);
    }
    if (unidadeDose.present) {
      map['unidade_dose'] = Variable<String>(unidadeDose.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (observacao.present) {
      map['observacao'] = Variable<String>(observacao.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosDoseCompanion(')
          ..write('id: $id, ')
          ..write('doseKey: $doseKey, ')
          ..write('tratamentoId: $tratamentoId, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('dataHoraProgramada: $dataHoraProgramada, ')
          ..write('dataHoraAcao: $dataHoraAcao, ')
          ..write('quantidadeDose: $quantidadeDose, ')
          ..write('unidadeDose: $unidadeDose, ')
          ..write('status: $status, ')
          ..write('observacao: $observacao, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovimentacoesEstoqueTable extends MovimentacoesEstoque
    with TableInfo<$MovimentacoesEstoqueTable, MovimentacaoEstoqueDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimentacoesEstoqueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicamentoIdMeta = const VerificationMeta(
    'medicamentoId',
  );
  @override
  late final GeneratedColumn<String> medicamentoId = GeneratedColumn<String>(
    'medicamento_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicamentos (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _registroDoseIdMeta = const VerificationMeta(
    'registroDoseId',
  );
  @override
  late final GeneratedColumn<String> registroDoseId = GeneratedColumn<String>(
    'registro_dose_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES registros_dose (id) ON UPDATE CASCADE ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _movimentacaoOrigemIdMeta =
      const VerificationMeta('movimentacaoOrigemId');
  @override
  late final GeneratedColumn<String> movimentacaoOrigemId =
      GeneratedColumn<String>(
        'movimentacao_origem_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    check: () => const CustomExpression(
      "tipo IN ('entradaReposicao', 'saidaDose', "
      "'ajusteEntrada', 'ajusteSaida')",
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantidadeMeta = const VerificationMeta(
    'quantidade',
  );
  @override
  late final GeneratedColumn<double> quantidade = GeneratedColumn<double>(
    'quantidade',
    aliasedName,
    false,
    check: () => const CustomExpression('quantidade > 0'),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unidadeMeta = const VerificationMeta(
    'unidade',
  );
  @override
  late final GeneratedColumn<String> unidade = GeneratedColumn<String>(
    'unidade',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataHoraMeta = const VerificationMeta(
    'dataHora',
  );
  @override
  late final GeneratedColumn<DateTime> dataHora = GeneratedColumn<DateTime>(
    'data_hora',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observacaoMeta = const VerificationMeta(
    'observacao',
  );
  @override
  late final GeneratedColumn<String> observacao = GeneratedColumn<String>(
    'observacao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicamentoId,
    registroDoseId,
    movimentacaoOrigemId,
    tipo,
    quantidade,
    unidade,
    dataHora,
    observacao,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimentacoes_estoque';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovimentacaoEstoqueDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medicamento_id')) {
      context.handle(
        _medicamentoIdMeta,
        medicamentoId.isAcceptableOrUnknown(
          data['medicamento_id']!,
          _medicamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicamentoIdMeta);
    }
    if (data.containsKey('registro_dose_id')) {
      context.handle(
        _registroDoseIdMeta,
        registroDoseId.isAcceptableOrUnknown(
          data['registro_dose_id']!,
          _registroDoseIdMeta,
        ),
      );
    }
    if (data.containsKey('movimentacao_origem_id')) {
      context.handle(
        _movimentacaoOrigemIdMeta,
        movimentacaoOrigemId.isAcceptableOrUnknown(
          data['movimentacao_origem_id']!,
          _movimentacaoOrigemIdMeta,
        ),
      );
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('quantidade')) {
      context.handle(
        _quantidadeMeta,
        quantidade.isAcceptableOrUnknown(data['quantidade']!, _quantidadeMeta),
      );
    } else if (isInserting) {
      context.missing(_quantidadeMeta);
    }
    if (data.containsKey('unidade')) {
      context.handle(
        _unidadeMeta,
        unidade.isAcceptableOrUnknown(data['unidade']!, _unidadeMeta),
      );
    } else if (isInserting) {
      context.missing(_unidadeMeta);
    }
    if (data.containsKey('data_hora')) {
      context.handle(
        _dataHoraMeta,
        dataHora.isAcceptableOrUnknown(data['data_hora']!, _dataHoraMeta),
      );
    } else if (isInserting) {
      context.missing(_dataHoraMeta);
    }
    if (data.containsKey('observacao')) {
      context.handle(
        _observacaoMeta,
        observacao.isAcceptableOrUnknown(data['observacao']!, _observacaoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovimentacaoEstoqueDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovimentacaoEstoqueDb(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      medicamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicamento_id'],
      )!,
      registroDoseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registro_dose_id'],
      ),
      movimentacaoOrigemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movimentacao_origem_id'],
      ),
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      quantidade: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantidade'],
      )!,
      unidade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidade'],
      )!,
      dataHora: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_hora'],
      )!,
      observacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacao'],
      ),
    );
  }

  @override
  $MovimentacoesEstoqueTable createAlias(String alias) {
    return $MovimentacoesEstoqueTable(attachedDatabase, alias);
  }
}

class MovimentacaoEstoqueDb extends DataClass
    implements Insertable<MovimentacaoEstoqueDb> {
  final String id;
  final String medicamentoId;
  final String? registroDoseId;
  final String? movimentacaoOrigemId;
  final String tipo;
  final double quantidade;
  final String unidade;
  final DateTime dataHora;
  final String? observacao;
  const MovimentacaoEstoqueDb({
    required this.id,
    required this.medicamentoId,
    this.registroDoseId,
    this.movimentacaoOrigemId,
    required this.tipo,
    required this.quantidade,
    required this.unidade,
    required this.dataHora,
    this.observacao,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medicamento_id'] = Variable<String>(medicamentoId);
    if (!nullToAbsent || registroDoseId != null) {
      map['registro_dose_id'] = Variable<String>(registroDoseId);
    }
    if (!nullToAbsent || movimentacaoOrigemId != null) {
      map['movimentacao_origem_id'] = Variable<String>(movimentacaoOrigemId);
    }
    map['tipo'] = Variable<String>(tipo);
    map['quantidade'] = Variable<double>(quantidade);
    map['unidade'] = Variable<String>(unidade);
    map['data_hora'] = Variable<DateTime>(dataHora);
    if (!nullToAbsent || observacao != null) {
      map['observacao'] = Variable<String>(observacao);
    }
    return map;
  }

  MovimentacoesEstoqueCompanion toCompanion(bool nullToAbsent) {
    return MovimentacoesEstoqueCompanion(
      id: Value(id),
      medicamentoId: Value(medicamentoId),
      registroDoseId: registroDoseId == null && nullToAbsent
          ? const Value.absent()
          : Value(registroDoseId),
      movimentacaoOrigemId: movimentacaoOrigemId == null && nullToAbsent
          ? const Value.absent()
          : Value(movimentacaoOrigemId),
      tipo: Value(tipo),
      quantidade: Value(quantidade),
      unidade: Value(unidade),
      dataHora: Value(dataHora),
      observacao: observacao == null && nullToAbsent
          ? const Value.absent()
          : Value(observacao),
    );
  }

  factory MovimentacaoEstoqueDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovimentacaoEstoqueDb(
      id: serializer.fromJson<String>(json['id']),
      medicamentoId: serializer.fromJson<String>(json['medicamentoId']),
      registroDoseId: serializer.fromJson<String?>(json['registroDoseId']),
      movimentacaoOrigemId: serializer.fromJson<String?>(
        json['movimentacaoOrigemId'],
      ),
      tipo: serializer.fromJson<String>(json['tipo']),
      quantidade: serializer.fromJson<double>(json['quantidade']),
      unidade: serializer.fromJson<String>(json['unidade']),
      dataHora: serializer.fromJson<DateTime>(json['dataHora']),
      observacao: serializer.fromJson<String?>(json['observacao']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicamentoId': serializer.toJson<String>(medicamentoId),
      'registroDoseId': serializer.toJson<String?>(registroDoseId),
      'movimentacaoOrigemId': serializer.toJson<String?>(movimentacaoOrigemId),
      'tipo': serializer.toJson<String>(tipo),
      'quantidade': serializer.toJson<double>(quantidade),
      'unidade': serializer.toJson<String>(unidade),
      'dataHora': serializer.toJson<DateTime>(dataHora),
      'observacao': serializer.toJson<String?>(observacao),
    };
  }

  MovimentacaoEstoqueDb copyWith({
    String? id,
    String? medicamentoId,
    Value<String?> registroDoseId = const Value.absent(),
    Value<String?> movimentacaoOrigemId = const Value.absent(),
    String? tipo,
    double? quantidade,
    String? unidade,
    DateTime? dataHora,
    Value<String?> observacao = const Value.absent(),
  }) => MovimentacaoEstoqueDb(
    id: id ?? this.id,
    medicamentoId: medicamentoId ?? this.medicamentoId,
    registroDoseId: registroDoseId.present
        ? registroDoseId.value
        : this.registroDoseId,
    movimentacaoOrigemId: movimentacaoOrigemId.present
        ? movimentacaoOrigemId.value
        : this.movimentacaoOrigemId,
    tipo: tipo ?? this.tipo,
    quantidade: quantidade ?? this.quantidade,
    unidade: unidade ?? this.unidade,
    dataHora: dataHora ?? this.dataHora,
    observacao: observacao.present ? observacao.value : this.observacao,
  );
  MovimentacaoEstoqueDb copyWithCompanion(MovimentacoesEstoqueCompanion data) {
    return MovimentacaoEstoqueDb(
      id: data.id.present ? data.id.value : this.id,
      medicamentoId: data.medicamentoId.present
          ? data.medicamentoId.value
          : this.medicamentoId,
      registroDoseId: data.registroDoseId.present
          ? data.registroDoseId.value
          : this.registroDoseId,
      movimentacaoOrigemId: data.movimentacaoOrigemId.present
          ? data.movimentacaoOrigemId.value
          : this.movimentacaoOrigemId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      quantidade: data.quantidade.present
          ? data.quantidade.value
          : this.quantidade,
      unidade: data.unidade.present ? data.unidade.value : this.unidade,
      dataHora: data.dataHora.present ? data.dataHora.value : this.dataHora,
      observacao: data.observacao.present
          ? data.observacao.value
          : this.observacao,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovimentacaoEstoqueDb(')
          ..write('id: $id, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('registroDoseId: $registroDoseId, ')
          ..write('movimentacaoOrigemId: $movimentacaoOrigemId, ')
          ..write('tipo: $tipo, ')
          ..write('quantidade: $quantidade, ')
          ..write('unidade: $unidade, ')
          ..write('dataHora: $dataHora, ')
          ..write('observacao: $observacao')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicamentoId,
    registroDoseId,
    movimentacaoOrigemId,
    tipo,
    quantidade,
    unidade,
    dataHora,
    observacao,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovimentacaoEstoqueDb &&
          other.id == this.id &&
          other.medicamentoId == this.medicamentoId &&
          other.registroDoseId == this.registroDoseId &&
          other.movimentacaoOrigemId == this.movimentacaoOrigemId &&
          other.tipo == this.tipo &&
          other.quantidade == this.quantidade &&
          other.unidade == this.unidade &&
          other.dataHora == this.dataHora &&
          other.observacao == this.observacao);
}

class MovimentacoesEstoqueCompanion
    extends UpdateCompanion<MovimentacaoEstoqueDb> {
  final Value<String> id;
  final Value<String> medicamentoId;
  final Value<String?> registroDoseId;
  final Value<String?> movimentacaoOrigemId;
  final Value<String> tipo;
  final Value<double> quantidade;
  final Value<String> unidade;
  final Value<DateTime> dataHora;
  final Value<String?> observacao;
  final Value<int> rowid;
  const MovimentacoesEstoqueCompanion({
    this.id = const Value.absent(),
    this.medicamentoId = const Value.absent(),
    this.registroDoseId = const Value.absent(),
    this.movimentacaoOrigemId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.quantidade = const Value.absent(),
    this.unidade = const Value.absent(),
    this.dataHora = const Value.absent(),
    this.observacao = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovimentacoesEstoqueCompanion.insert({
    required String id,
    required String medicamentoId,
    this.registroDoseId = const Value.absent(),
    this.movimentacaoOrigemId = const Value.absent(),
    required String tipo,
    required double quantidade,
    required String unidade,
    required DateTime dataHora,
    this.observacao = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicamentoId = Value(medicamentoId),
       tipo = Value(tipo),
       quantidade = Value(quantidade),
       unidade = Value(unidade),
       dataHora = Value(dataHora);
  static Insertable<MovimentacaoEstoqueDb> custom({
    Expression<String>? id,
    Expression<String>? medicamentoId,
    Expression<String>? registroDoseId,
    Expression<String>? movimentacaoOrigemId,
    Expression<String>? tipo,
    Expression<double>? quantidade,
    Expression<String>? unidade,
    Expression<DateTime>? dataHora,
    Expression<String>? observacao,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicamentoId != null) 'medicamento_id': medicamentoId,
      if (registroDoseId != null) 'registro_dose_id': registroDoseId,
      if (movimentacaoOrigemId != null)
        'movimentacao_origem_id': movimentacaoOrigemId,
      if (tipo != null) 'tipo': tipo,
      if (quantidade != null) 'quantidade': quantidade,
      if (unidade != null) 'unidade': unidade,
      if (dataHora != null) 'data_hora': dataHora,
      if (observacao != null) 'observacao': observacao,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovimentacoesEstoqueCompanion copyWith({
    Value<String>? id,
    Value<String>? medicamentoId,
    Value<String?>? registroDoseId,
    Value<String?>? movimentacaoOrigemId,
    Value<String>? tipo,
    Value<double>? quantidade,
    Value<String>? unidade,
    Value<DateTime>? dataHora,
    Value<String?>? observacao,
    Value<int>? rowid,
  }) {
    return MovimentacoesEstoqueCompanion(
      id: id ?? this.id,
      medicamentoId: medicamentoId ?? this.medicamentoId,
      registroDoseId: registroDoseId ?? this.registroDoseId,
      movimentacaoOrigemId: movimentacaoOrigemId ?? this.movimentacaoOrigemId,
      tipo: tipo ?? this.tipo,
      quantidade: quantidade ?? this.quantidade,
      unidade: unidade ?? this.unidade,
      dataHora: dataHora ?? this.dataHora,
      observacao: observacao ?? this.observacao,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicamentoId.present) {
      map['medicamento_id'] = Variable<String>(medicamentoId.value);
    }
    if (registroDoseId.present) {
      map['registro_dose_id'] = Variable<String>(registroDoseId.value);
    }
    if (movimentacaoOrigemId.present) {
      map['movimentacao_origem_id'] = Variable<String>(
        movimentacaoOrigemId.value,
      );
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (quantidade.present) {
      map['quantidade'] = Variable<double>(quantidade.value);
    }
    if (unidade.present) {
      map['unidade'] = Variable<String>(unidade.value);
    }
    if (dataHora.present) {
      map['data_hora'] = Variable<DateTime>(dataHora.value);
    }
    if (observacao.present) {
      map['observacao'] = Variable<String>(observacao.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovimentacoesEstoqueCompanion(')
          ..write('id: $id, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('registroDoseId: $registroDoseId, ')
          ..write('movimentacaoOrigemId: $movimentacaoOrigemId, ')
          ..write('tipo: $tipo, ')
          ..write('quantidade: $quantidade, ')
          ..write('unidade: $unidade, ')
          ..write('dataHora: $dataHora, ')
          ..write('observacao: $observacao, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnexosTable extends Anexos with TableInfo<$AnexosTable, AnexoDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnexosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicamentoIdMeta = const VerificationMeta(
    'medicamentoId',
  );
  @override
  late final GeneratedColumn<String> medicamentoId = GeneratedColumn<String>(
    'medicamento_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicamentos (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    check: () =>
        const CustomExpression("tipo IN ('fotoMedicamento', 'receita')"),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caminhoRelativoMeta = const VerificationMeta(
    'caminhoRelativo',
  );
  @override
  late final GeneratedColumn<String> caminhoRelativo = GeneratedColumn<String>(
    'caminho_relativo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeOriginalMeta = const VerificationMeta(
    'nomeOriginal',
  );
  @override
  late final GeneratedColumn<String> nomeOriginal = GeneratedColumn<String>(
    'nome_original',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicamentoId,
    tipo,
    caminhoRelativo,
    nomeOriginal,
    criadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anexos';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnexoDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medicamento_id')) {
      context.handle(
        _medicamentoIdMeta,
        medicamentoId.isAcceptableOrUnknown(
          data['medicamento_id']!,
          _medicamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicamentoIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('caminho_relativo')) {
      context.handle(
        _caminhoRelativoMeta,
        caminhoRelativo.isAcceptableOrUnknown(
          data['caminho_relativo']!,
          _caminhoRelativoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_caminhoRelativoMeta);
    }
    if (data.containsKey('nome_original')) {
      context.handle(
        _nomeOriginalMeta,
        nomeOriginal.isAcceptableOrUnknown(
          data['nome_original']!,
          _nomeOriginalMeta,
        ),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnexoDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnexoDb(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      medicamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicamento_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      caminhoRelativo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caminho_relativo'],
      )!,
      nomeOriginal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome_original'],
      ),
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
    );
  }

  @override
  $AnexosTable createAlias(String alias) {
    return $AnexosTable(attachedDatabase, alias);
  }
}

class AnexoDb extends DataClass implements Insertable<AnexoDb> {
  final String id;
  final String medicamentoId;
  final String tipo;
  final String caminhoRelativo;
  final String? nomeOriginal;
  final DateTime criadoEm;
  const AnexoDb({
    required this.id,
    required this.medicamentoId,
    required this.tipo,
    required this.caminhoRelativo,
    this.nomeOriginal,
    required this.criadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medicamento_id'] = Variable<String>(medicamentoId);
    map['tipo'] = Variable<String>(tipo);
    map['caminho_relativo'] = Variable<String>(caminhoRelativo);
    if (!nullToAbsent || nomeOriginal != null) {
      map['nome_original'] = Variable<String>(nomeOriginal);
    }
    map['criado_em'] = Variable<DateTime>(criadoEm);
    return map;
  }

  AnexosCompanion toCompanion(bool nullToAbsent) {
    return AnexosCompanion(
      id: Value(id),
      medicamentoId: Value(medicamentoId),
      tipo: Value(tipo),
      caminhoRelativo: Value(caminhoRelativo),
      nomeOriginal: nomeOriginal == null && nullToAbsent
          ? const Value.absent()
          : Value(nomeOriginal),
      criadoEm: Value(criadoEm),
    );
  }

  factory AnexoDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnexoDb(
      id: serializer.fromJson<String>(json['id']),
      medicamentoId: serializer.fromJson<String>(json['medicamentoId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      caminhoRelativo: serializer.fromJson<String>(json['caminhoRelativo']),
      nomeOriginal: serializer.fromJson<String?>(json['nomeOriginal']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicamentoId': serializer.toJson<String>(medicamentoId),
      'tipo': serializer.toJson<String>(tipo),
      'caminhoRelativo': serializer.toJson<String>(caminhoRelativo),
      'nomeOriginal': serializer.toJson<String?>(nomeOriginal),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
    };
  }

  AnexoDb copyWith({
    String? id,
    String? medicamentoId,
    String? tipo,
    String? caminhoRelativo,
    Value<String?> nomeOriginal = const Value.absent(),
    DateTime? criadoEm,
  }) => AnexoDb(
    id: id ?? this.id,
    medicamentoId: medicamentoId ?? this.medicamentoId,
    tipo: tipo ?? this.tipo,
    caminhoRelativo: caminhoRelativo ?? this.caminhoRelativo,
    nomeOriginal: nomeOriginal.present ? nomeOriginal.value : this.nomeOriginal,
    criadoEm: criadoEm ?? this.criadoEm,
  );
  AnexoDb copyWithCompanion(AnexosCompanion data) {
    return AnexoDb(
      id: data.id.present ? data.id.value : this.id,
      medicamentoId: data.medicamentoId.present
          ? data.medicamentoId.value
          : this.medicamentoId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      caminhoRelativo: data.caminhoRelativo.present
          ? data.caminhoRelativo.value
          : this.caminhoRelativo,
      nomeOriginal: data.nomeOriginal.present
          ? data.nomeOriginal.value
          : this.nomeOriginal,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnexoDb(')
          ..write('id: $id, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('tipo: $tipo, ')
          ..write('caminhoRelativo: $caminhoRelativo, ')
          ..write('nomeOriginal: $nomeOriginal, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicamentoId,
    tipo,
    caminhoRelativo,
    nomeOriginal,
    criadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnexoDb &&
          other.id == this.id &&
          other.medicamentoId == this.medicamentoId &&
          other.tipo == this.tipo &&
          other.caminhoRelativo == this.caminhoRelativo &&
          other.nomeOriginal == this.nomeOriginal &&
          other.criadoEm == this.criadoEm);
}

class AnexosCompanion extends UpdateCompanion<AnexoDb> {
  final Value<String> id;
  final Value<String> medicamentoId;
  final Value<String> tipo;
  final Value<String> caminhoRelativo;
  final Value<String?> nomeOriginal;
  final Value<DateTime> criadoEm;
  final Value<int> rowid;
  const AnexosCompanion({
    this.id = const Value.absent(),
    this.medicamentoId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.caminhoRelativo = const Value.absent(),
    this.nomeOriginal = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnexosCompanion.insert({
    required String id,
    required String medicamentoId,
    required String tipo,
    required String caminhoRelativo,
    this.nomeOriginal = const Value.absent(),
    required DateTime criadoEm,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicamentoId = Value(medicamentoId),
       tipo = Value(tipo),
       caminhoRelativo = Value(caminhoRelativo),
       criadoEm = Value(criadoEm);
  static Insertable<AnexoDb> custom({
    Expression<String>? id,
    Expression<String>? medicamentoId,
    Expression<String>? tipo,
    Expression<String>? caminhoRelativo,
    Expression<String>? nomeOriginal,
    Expression<DateTime>? criadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicamentoId != null) 'medicamento_id': medicamentoId,
      if (tipo != null) 'tipo': tipo,
      if (caminhoRelativo != null) 'caminho_relativo': caminhoRelativo,
      if (nomeOriginal != null) 'nome_original': nomeOriginal,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnexosCompanion copyWith({
    Value<String>? id,
    Value<String>? medicamentoId,
    Value<String>? tipo,
    Value<String>? caminhoRelativo,
    Value<String?>? nomeOriginal,
    Value<DateTime>? criadoEm,
    Value<int>? rowid,
  }) {
    return AnexosCompanion(
      id: id ?? this.id,
      medicamentoId: medicamentoId ?? this.medicamentoId,
      tipo: tipo ?? this.tipo,
      caminhoRelativo: caminhoRelativo ?? this.caminhoRelativo,
      nomeOriginal: nomeOriginal ?? this.nomeOriginal,
      criadoEm: criadoEm ?? this.criadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicamentoId.present) {
      map['medicamento_id'] = Variable<String>(medicamentoId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (caminhoRelativo.present) {
      map['caminho_relativo'] = Variable<String>(caminhoRelativo.value);
    }
    if (nomeOriginal.present) {
      map['nome_original'] = Variable<String>(nomeOriginal.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnexosCompanion(')
          ..write('id: $id, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('tipo: $tipo, ')
          ..write('caminhoRelativo: $caminhoRelativo, ')
          ..write('nomeOriginal: $nomeOriginal, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConfiguracoesTable extends Configuracoes
    with TableInfo<$ConfiguracoesTable, ConfiguracaoDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfiguracoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  @override
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
    'chave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [chave, valor, atualizadoEm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuracoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfiguracaoDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chave')) {
      context.handle(
        _chaveMeta,
        chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chaveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chave};
  @override
  ConfiguracaoDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfiguracaoDb(
      chave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
    );
  }

  @override
  $ConfiguracoesTable createAlias(String alias) {
    return $ConfiguracoesTable(attachedDatabase, alias);
  }
}

class ConfiguracaoDb extends DataClass implements Insertable<ConfiguracaoDb> {
  final String chave;
  final String valor;
  final DateTime atualizadoEm;
  const ConfiguracaoDb({
    required this.chave,
    required this.valor,
    required this.atualizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chave'] = Variable<String>(chave);
    map['valor'] = Variable<String>(valor);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    return map;
  }

  ConfiguracoesCompanion toCompanion(bool nullToAbsent) {
    return ConfiguracoesCompanion(
      chave: Value(chave),
      valor: Value(valor),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory ConfiguracaoDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfiguracaoDb(
      chave: serializer.fromJson<String>(json['chave']),
      valor: serializer.fromJson<String>(json['valor']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chave': serializer.toJson<String>(chave),
      'valor': serializer.toJson<String>(valor),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
    };
  }

  ConfiguracaoDb copyWith({
    String? chave,
    String? valor,
    DateTime? atualizadoEm,
  }) => ConfiguracaoDb(
    chave: chave ?? this.chave,
    valor: valor ?? this.valor,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
  );
  ConfiguracaoDb copyWithCompanion(ConfiguracoesCompanion data) {
    return ConfiguracaoDb(
      chave: data.chave.present ? data.chave.value : this.chave,
      valor: data.valor.present ? data.valor.value : this.valor,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracaoDb(')
          ..write('chave: $chave, ')
          ..write('valor: $valor, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chave, valor, atualizadoEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfiguracaoDb &&
          other.chave == this.chave &&
          other.valor == this.valor &&
          other.atualizadoEm == this.atualizadoEm);
}

class ConfiguracoesCompanion extends UpdateCompanion<ConfiguracaoDb> {
  final Value<String> chave;
  final Value<String> valor;
  final Value<DateTime> atualizadoEm;
  final Value<int> rowid;
  const ConfiguracoesCompanion({
    this.chave = const Value.absent(),
    this.valor = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfiguracoesCompanion.insert({
    required String chave,
    required String valor,
    required DateTime atualizadoEm,
    this.rowid = const Value.absent(),
  }) : chave = Value(chave),
       valor = Value(valor),
       atualizadoEm = Value(atualizadoEm);
  static Insertable<ConfiguracaoDb> custom({
    Expression<String>? chave,
    Expression<String>? valor,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chave != null) 'chave': chave,
      if (valor != null) 'valor': valor,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfiguracoesCompanion copyWith({
    Value<String>? chave,
    Value<String>? valor,
    Value<DateTime>? atualizadoEm,
    Value<int>? rowid,
  }) {
    return ConfiguracoesCompanion(
      chave: chave ?? this.chave,
      valor: valor ?? this.valor,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracoesCompanion(')
          ..write('chave: $chave, ')
          ..write('valor: $valor, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdiamentosDoseTable extends AdiamentosDose
    with TableInfo<$AdiamentosDoseTable, AdiamentoDoseDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdiamentosDoseTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseKeyMeta = const VerificationMeta(
    'doseKey',
  );
  @override
  late final GeneratedColumn<String> doseKey = GeneratedColumn<String>(
    'dose_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _tratamentoIdMeta = const VerificationMeta(
    'tratamentoId',
  );
  @override
  late final GeneratedColumn<String> tratamentoId = GeneratedColumn<String>(
    'tratamento_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tratamentos (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _medicamentoIdMeta = const VerificationMeta(
    'medicamentoId',
  );
  @override
  late final GeneratedColumn<String> medicamentoId = GeneratedColumn<String>(
    'medicamento_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicamentos (id) ON UPDATE CASCADE ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dataHoraProgramadaMeta =
      const VerificationMeta('dataHoraProgramada');
  @override
  late final GeneratedColumn<DateTime> dataHoraProgramada =
      GeneratedColumn<DateTime>(
        'data_hora_programada',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lembrarEmMeta = const VerificationMeta(
    'lembrarEm',
  );
  @override
  late final GeneratedColumn<DateTime> lembrarEm = GeneratedColumn<DateTime>(
    'lembrar_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificacaoIdMeta = const VerificationMeta(
    'notificacaoId',
  );
  @override
  late final GeneratedColumn<int> notificacaoId = GeneratedColumn<int>(
    'notificacao_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    doseKey,
    tratamentoId,
    medicamentoId,
    dataHoraProgramada,
    lembrarEm,
    notificacaoId,
    criadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adiamentos_dose';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdiamentoDoseDb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dose_key')) {
      context.handle(
        _doseKeyMeta,
        doseKey.isAcceptableOrUnknown(data['dose_key']!, _doseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_doseKeyMeta);
    }
    if (data.containsKey('tratamento_id')) {
      context.handle(
        _tratamentoIdMeta,
        tratamentoId.isAcceptableOrUnknown(
          data['tratamento_id']!,
          _tratamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tratamentoIdMeta);
    }
    if (data.containsKey('medicamento_id')) {
      context.handle(
        _medicamentoIdMeta,
        medicamentoId.isAcceptableOrUnknown(
          data['medicamento_id']!,
          _medicamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicamentoIdMeta);
    }
    if (data.containsKey('data_hora_programada')) {
      context.handle(
        _dataHoraProgramadaMeta,
        dataHoraProgramada.isAcceptableOrUnknown(
          data['data_hora_programada']!,
          _dataHoraProgramadaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataHoraProgramadaMeta);
    }
    if (data.containsKey('lembrar_em')) {
      context.handle(
        _lembrarEmMeta,
        lembrarEm.isAcceptableOrUnknown(data['lembrar_em']!, _lembrarEmMeta),
      );
    } else if (isInserting) {
      context.missing(_lembrarEmMeta);
    }
    if (data.containsKey('notificacao_id')) {
      context.handle(
        _notificacaoIdMeta,
        notificacaoId.isAcceptableOrUnknown(
          data['notificacao_id']!,
          _notificacaoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificacaoIdMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdiamentoDoseDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdiamentoDoseDb(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      doseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_key'],
      )!,
      tratamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tratamento_id'],
      )!,
      medicamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicamento_id'],
      )!,
      dataHoraProgramada: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_hora_programada'],
      )!,
      lembrarEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lembrar_em'],
      )!,
      notificacaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notificacao_id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
    );
  }

  @override
  $AdiamentosDoseTable createAlias(String alias) {
    return $AdiamentosDoseTable(attachedDatabase, alias);
  }
}

class AdiamentoDoseDb extends DataClass implements Insertable<AdiamentoDoseDb> {
  final String id;
  final String doseKey;
  final String tratamentoId;
  final String medicamentoId;
  final DateTime dataHoraProgramada;
  final DateTime lembrarEm;
  final int notificacaoId;
  final DateTime criadoEm;
  const AdiamentoDoseDb({
    required this.id,
    required this.doseKey,
    required this.tratamentoId,
    required this.medicamentoId,
    required this.dataHoraProgramada,
    required this.lembrarEm,
    required this.notificacaoId,
    required this.criadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dose_key'] = Variable<String>(doseKey);
    map['tratamento_id'] = Variable<String>(tratamentoId);
    map['medicamento_id'] = Variable<String>(medicamentoId);
    map['data_hora_programada'] = Variable<DateTime>(dataHoraProgramada);
    map['lembrar_em'] = Variable<DateTime>(lembrarEm);
    map['notificacao_id'] = Variable<int>(notificacaoId);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    return map;
  }

  AdiamentosDoseCompanion toCompanion(bool nullToAbsent) {
    return AdiamentosDoseCompanion(
      id: Value(id),
      doseKey: Value(doseKey),
      tratamentoId: Value(tratamentoId),
      medicamentoId: Value(medicamentoId),
      dataHoraProgramada: Value(dataHoraProgramada),
      lembrarEm: Value(lembrarEm),
      notificacaoId: Value(notificacaoId),
      criadoEm: Value(criadoEm),
    );
  }

  factory AdiamentoDoseDb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdiamentoDoseDb(
      id: serializer.fromJson<String>(json['id']),
      doseKey: serializer.fromJson<String>(json['doseKey']),
      tratamentoId: serializer.fromJson<String>(json['tratamentoId']),
      medicamentoId: serializer.fromJson<String>(json['medicamentoId']),
      dataHoraProgramada: serializer.fromJson<DateTime>(
        json['dataHoraProgramada'],
      ),
      lembrarEm: serializer.fromJson<DateTime>(json['lembrarEm']),
      notificacaoId: serializer.fromJson<int>(json['notificacaoId']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'doseKey': serializer.toJson<String>(doseKey),
      'tratamentoId': serializer.toJson<String>(tratamentoId),
      'medicamentoId': serializer.toJson<String>(medicamentoId),
      'dataHoraProgramada': serializer.toJson<DateTime>(dataHoraProgramada),
      'lembrarEm': serializer.toJson<DateTime>(lembrarEm),
      'notificacaoId': serializer.toJson<int>(notificacaoId),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
    };
  }

  AdiamentoDoseDb copyWith({
    String? id,
    String? doseKey,
    String? tratamentoId,
    String? medicamentoId,
    DateTime? dataHoraProgramada,
    DateTime? lembrarEm,
    int? notificacaoId,
    DateTime? criadoEm,
  }) => AdiamentoDoseDb(
    id: id ?? this.id,
    doseKey: doseKey ?? this.doseKey,
    tratamentoId: tratamentoId ?? this.tratamentoId,
    medicamentoId: medicamentoId ?? this.medicamentoId,
    dataHoraProgramada: dataHoraProgramada ?? this.dataHoraProgramada,
    lembrarEm: lembrarEm ?? this.lembrarEm,
    notificacaoId: notificacaoId ?? this.notificacaoId,
    criadoEm: criadoEm ?? this.criadoEm,
  );
  AdiamentoDoseDb copyWithCompanion(AdiamentosDoseCompanion data) {
    return AdiamentoDoseDb(
      id: data.id.present ? data.id.value : this.id,
      doseKey: data.doseKey.present ? data.doseKey.value : this.doseKey,
      tratamentoId: data.tratamentoId.present
          ? data.tratamentoId.value
          : this.tratamentoId,
      medicamentoId: data.medicamentoId.present
          ? data.medicamentoId.value
          : this.medicamentoId,
      dataHoraProgramada: data.dataHoraProgramada.present
          ? data.dataHoraProgramada.value
          : this.dataHoraProgramada,
      lembrarEm: data.lembrarEm.present ? data.lembrarEm.value : this.lembrarEm,
      notificacaoId: data.notificacaoId.present
          ? data.notificacaoId.value
          : this.notificacaoId,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdiamentoDoseDb(')
          ..write('id: $id, ')
          ..write('doseKey: $doseKey, ')
          ..write('tratamentoId: $tratamentoId, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('dataHoraProgramada: $dataHoraProgramada, ')
          ..write('lembrarEm: $lembrarEm, ')
          ..write('notificacaoId: $notificacaoId, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    doseKey,
    tratamentoId,
    medicamentoId,
    dataHoraProgramada,
    lembrarEm,
    notificacaoId,
    criadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdiamentoDoseDb &&
          other.id == this.id &&
          other.doseKey == this.doseKey &&
          other.tratamentoId == this.tratamentoId &&
          other.medicamentoId == this.medicamentoId &&
          other.dataHoraProgramada == this.dataHoraProgramada &&
          other.lembrarEm == this.lembrarEm &&
          other.notificacaoId == this.notificacaoId &&
          other.criadoEm == this.criadoEm);
}

class AdiamentosDoseCompanion extends UpdateCompanion<AdiamentoDoseDb> {
  final Value<String> id;
  final Value<String> doseKey;
  final Value<String> tratamentoId;
  final Value<String> medicamentoId;
  final Value<DateTime> dataHoraProgramada;
  final Value<DateTime> lembrarEm;
  final Value<int> notificacaoId;
  final Value<DateTime> criadoEm;
  final Value<int> rowid;
  const AdiamentosDoseCompanion({
    this.id = const Value.absent(),
    this.doseKey = const Value.absent(),
    this.tratamentoId = const Value.absent(),
    this.medicamentoId = const Value.absent(),
    this.dataHoraProgramada = const Value.absent(),
    this.lembrarEm = const Value.absent(),
    this.notificacaoId = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdiamentosDoseCompanion.insert({
    required String id,
    required String doseKey,
    required String tratamentoId,
    required String medicamentoId,
    required DateTime dataHoraProgramada,
    required DateTime lembrarEm,
    required int notificacaoId,
    required DateTime criadoEm,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       doseKey = Value(doseKey),
       tratamentoId = Value(tratamentoId),
       medicamentoId = Value(medicamentoId),
       dataHoraProgramada = Value(dataHoraProgramada),
       lembrarEm = Value(lembrarEm),
       notificacaoId = Value(notificacaoId),
       criadoEm = Value(criadoEm);
  static Insertable<AdiamentoDoseDb> custom({
    Expression<String>? id,
    Expression<String>? doseKey,
    Expression<String>? tratamentoId,
    Expression<String>? medicamentoId,
    Expression<DateTime>? dataHoraProgramada,
    Expression<DateTime>? lembrarEm,
    Expression<int>? notificacaoId,
    Expression<DateTime>? criadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (doseKey != null) 'dose_key': doseKey,
      if (tratamentoId != null) 'tratamento_id': tratamentoId,
      if (medicamentoId != null) 'medicamento_id': medicamentoId,
      if (dataHoraProgramada != null)
        'data_hora_programada': dataHoraProgramada,
      if (lembrarEm != null) 'lembrar_em': lembrarEm,
      if (notificacaoId != null) 'notificacao_id': notificacaoId,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdiamentosDoseCompanion copyWith({
    Value<String>? id,
    Value<String>? doseKey,
    Value<String>? tratamentoId,
    Value<String>? medicamentoId,
    Value<DateTime>? dataHoraProgramada,
    Value<DateTime>? lembrarEm,
    Value<int>? notificacaoId,
    Value<DateTime>? criadoEm,
    Value<int>? rowid,
  }) {
    return AdiamentosDoseCompanion(
      id: id ?? this.id,
      doseKey: doseKey ?? this.doseKey,
      tratamentoId: tratamentoId ?? this.tratamentoId,
      medicamentoId: medicamentoId ?? this.medicamentoId,
      dataHoraProgramada: dataHoraProgramada ?? this.dataHoraProgramada,
      lembrarEm: lembrarEm ?? this.lembrarEm,
      notificacaoId: notificacaoId ?? this.notificacaoId,
      criadoEm: criadoEm ?? this.criadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (doseKey.present) {
      map['dose_key'] = Variable<String>(doseKey.value);
    }
    if (tratamentoId.present) {
      map['tratamento_id'] = Variable<String>(tratamentoId.value);
    }
    if (medicamentoId.present) {
      map['medicamento_id'] = Variable<String>(medicamentoId.value);
    }
    if (dataHoraProgramada.present) {
      map['data_hora_programada'] = Variable<DateTime>(
        dataHoraProgramada.value,
      );
    }
    if (lembrarEm.present) {
      map['lembrar_em'] = Variable<DateTime>(lembrarEm.value);
    }
    if (notificacaoId.present) {
      map['notificacao_id'] = Variable<int>(notificacaoId.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdiamentosDoseCompanion(')
          ..write('id: $id, ')
          ..write('doseKey: $doseKey, ')
          ..write('tratamentoId: $tratamentoId, ')
          ..write('medicamentoId: $medicamentoId, ')
          ..write('dataHoraProgramada: $dataHoraProgramada, ')
          ..write('lembrarEm: $lembrarEm, ')
          ..write('notificacaoId: $notificacaoId, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MedicamentosTable medicamentos = $MedicamentosTable(this);
  late final $TratamentosTable tratamentos = $TratamentosTable(this);
  late final $HorariosTratamentoTable horariosTratamento =
      $HorariosTratamentoTable(this);
  late final $RegistrosDoseTable registrosDose = $RegistrosDoseTable(this);
  late final $MovimentacoesEstoqueTable movimentacoesEstoque =
      $MovimentacoesEstoqueTable(this);
  late final $AnexosTable anexos = $AnexosTable(this);
  late final $ConfiguracoesTable configuracoes = $ConfiguracoesTable(this);
  late final $AdiamentosDoseTable adiamentosDose = $AdiamentosDoseTable(this);
  late final Index idxMedicamentosNome = Index(
    'idx_medicamentos_nome',
    'CREATE INDEX idx_medicamentos_nome ON medicamentos (nome)',
  );
  late final Index idxTratamentosMedicamento = Index(
    'idx_tratamentos_medicamento',
    'CREATE INDEX idx_tratamentos_medicamento ON tratamentos (medicamento_id)',
  );
  late final Index idxTratamentosAtivos = Index(
    'idx_tratamentos_ativos',
    'CREATE INDEX idx_tratamentos_ativos ON tratamentos (ativo, data_inicio)',
  );
  late final Index idxHorariosTratamentoOrdem = Index(
    'idx_horarios_tratamento_ordem',
    'CREATE INDEX idx_horarios_tratamento_ordem ON horarios_tratamento (tratamento_id, ordem)',
  );
  late final Index idxRegistrosDoseProgramada = Index(
    'idx_registros_dose_programada',
    'CREATE INDEX idx_registros_dose_programada ON registros_dose (data_hora_programada)',
  );
  late final Index idxRegistrosDoseMedicamento = Index(
    'idx_registros_dose_medicamento',
    'CREATE INDEX idx_registros_dose_medicamento ON registros_dose (medicamento_id, data_hora_programada)',
  );
  late final Index idxMovimentacoesMedicamentoData = Index(
    'idx_movimentacoes_medicamento_data',
    'CREATE INDEX idx_movimentacoes_medicamento_data ON movimentacoes_estoque (medicamento_id, data_hora)',
  );
  late final Index idxMovimentacoesRegistroDose = Index(
    'idx_movimentacoes_registro_dose',
    'CREATE INDEX idx_movimentacoes_registro_dose ON movimentacoes_estoque (registro_dose_id)',
  );
  late final Index idxAnexosMedicamento = Index(
    'idx_anexos_medicamento',
    'CREATE INDEX idx_anexos_medicamento ON anexos (medicamento_id)',
  );
  late final Index idxAdiamentosLembrete = Index(
    'idx_adiamentos_lembrete',
    'CREATE INDEX idx_adiamentos_lembrete ON adiamentos_dose (lembrar_em)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    medicamentos,
    tratamentos,
    horariosTratamento,
    registrosDose,
    movimentacoesEstoque,
    anexos,
    configuracoes,
    adiamentosDose,
    idxMedicamentosNome,
    idxTratamentosMedicamento,
    idxTratamentosAtivos,
    idxHorariosTratamentoOrdem,
    idxRegistrosDoseProgramada,
    idxRegistrosDoseMedicamento,
    idxMovimentacoesMedicamentoData,
    idxMovimentacoesRegistroDose,
    idxAnexosMedicamento,
    idxAdiamentosLembrete,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medicamentos',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('tratamentos', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tratamentos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('horarios_tratamento', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tratamentos',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('horarios_tratamento', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tratamentos',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('registros_dose', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medicamentos',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('registros_dose', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medicamentos',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('movimentacoes_estoque', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'registros_dose',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('movimentacoes_estoque', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medicamentos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('anexos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medicamentos',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('anexos', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tratamentos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('adiamentos_dose', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tratamentos',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('adiamentos_dose', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medicamentos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('adiamentos_dose', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medicamentos',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('adiamentos_dose', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$MedicamentosTableCreateCompanionBuilder =
    MedicamentosCompanion Function({
      required String id,
      required String nome,
      Value<String?> concentracao,
      Value<String?> formaFarmaceutica,
      Value<String?> unidadeDosePadrao,
      Value<String?> unidadeEstoque,
      Value<String?> observacoes,
      Value<bool> controleEstoque,
      Value<bool> ativo,
      required DateTime criadoEm,
      required DateTime atualizadoEm,
      Value<int> rowid,
    });
typedef $$MedicamentosTableUpdateCompanionBuilder =
    MedicamentosCompanion Function({
      Value<String> id,
      Value<String> nome,
      Value<String?> concentracao,
      Value<String?> formaFarmaceutica,
      Value<String?> unidadeDosePadrao,
      Value<String?> unidadeEstoque,
      Value<String?> observacoes,
      Value<bool> controleEstoque,
      Value<bool> ativo,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<int> rowid,
    });

final class $$MedicamentosTableReferences
    extends BaseReferences<_$AppDatabase, $MedicamentosTable, MedicamentoDb> {
  $$MedicamentosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TratamentosTable, List<TratamentoDb>>
  _tratamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tratamentos,
    aliasName: 'medicamentos__id__tratamentos__medicamento_id',
  );

  $$TratamentosTableProcessedTableManager get tratamentosRefs {
    final manager = $$TratamentosTableTableManager(
      $_db,
      $_db.tratamentos,
    ).filter((f) => f.medicamentoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tratamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RegistrosDoseTable, List<RegistroDoseDb>>
  _registrosDoseRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.registrosDose,
    aliasName: 'medicamentos__id__registros_dose__medicamento_id',
  );

  $$RegistrosDoseTableProcessedTableManager get registrosDoseRefs {
    final manager = $$RegistrosDoseTableTableManager(
      $_db,
      $_db.registrosDose,
    ).filter((f) => f.medicamentoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_registrosDoseRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MovimentacoesEstoqueTable,
    List<MovimentacaoEstoqueDb>
  >
  _movimentacoesEstoqueRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.movimentacoesEstoque,
        aliasName: 'medicamentos__id__movimentacoes_estoque__medicamento_id',
      );

  $$MovimentacoesEstoqueTableProcessedTableManager
  get movimentacoesEstoqueRefs {
    final manager = $$MovimentacoesEstoqueTableTableManager(
      $_db,
      $_db.movimentacoesEstoque,
    ).filter((f) => f.medicamentoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _movimentacoesEstoqueRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AnexosTable, List<AnexoDb>> _anexosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.anexos,
    aliasName: 'medicamentos__id__anexos__medicamento_id',
  );

  $$AnexosTableProcessedTableManager get anexosRefs {
    final manager = $$AnexosTableTableManager(
      $_db,
      $_db.anexos,
    ).filter((f) => f.medicamentoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_anexosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AdiamentosDoseTable, List<AdiamentoDoseDb>>
  _adiamentosDoseRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.adiamentosDose,
    aliasName: 'medicamentos__id__adiamentos_dose__medicamento_id',
  );

  $$AdiamentosDoseTableProcessedTableManager get adiamentosDoseRefs {
    final manager = $$AdiamentosDoseTableTableManager(
      $_db,
      $_db.adiamentosDose,
    ).filter((f) => f.medicamentoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_adiamentosDoseRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicamentosTableFilterComposer
    extends Composer<_$AppDatabase, $MedicamentosTable> {
  $$MedicamentosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concentracao => $composableBuilder(
    column: $table.concentracao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formaFarmaceutica => $composableBuilder(
    column: $table.formaFarmaceutica,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidadeDosePadrao => $composableBuilder(
    column: $table.unidadeDosePadrao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidadeEstoque => $composableBuilder(
    column: $table.unidadeEstoque,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacoes => $composableBuilder(
    column: $table.observacoes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get controleEstoque => $composableBuilder(
    column: $table.controleEstoque,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tratamentosRefs(
    Expression<bool> Function($$TratamentosTableFilterComposer f) f,
  ) {
    final $$TratamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tratamentos,
      getReferencedColumn: (t) => t.medicamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TratamentosTableFilterComposer(
            $db: $db,
            $table: $db.tratamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> registrosDoseRefs(
    Expression<bool> Function($$RegistrosDoseTableFilterComposer f) f,
  ) {
    final $$RegistrosDoseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registrosDose,
      getReferencedColumn: (t) => t.medicamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistrosDoseTableFilterComposer(
            $db: $db,
            $table: $db.registrosDose,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> movimentacoesEstoqueRefs(
    Expression<bool> Function($$MovimentacoesEstoqueTableFilterComposer f) f,
  ) {
    final $$MovimentacoesEstoqueTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movimentacoesEstoque,
      getReferencedColumn: (t) => t.medicamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovimentacoesEstoqueTableFilterComposer(
            $db: $db,
            $table: $db.movimentacoesEstoque,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> anexosRefs(
    Expression<bool> Function($$AnexosTableFilterComposer f) f,
  ) {
    final $$AnexosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.anexos,
      getReferencedColumn: (t) => t.medicamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnexosTableFilterComposer(
            $db: $db,
            $table: $db.anexos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> adiamentosDoseRefs(
    Expression<bool> Function($$AdiamentosDoseTableFilterComposer f) f,
  ) {
    final $$AdiamentosDoseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adiamentosDose,
      getReferencedColumn: (t) => t.medicamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdiamentosDoseTableFilterComposer(
            $db: $db,
            $table: $db.adiamentosDose,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicamentosTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicamentosTable> {
  $$MedicamentosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concentracao => $composableBuilder(
    column: $table.concentracao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formaFarmaceutica => $composableBuilder(
    column: $table.formaFarmaceutica,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidadeDosePadrao => $composableBuilder(
    column: $table.unidadeDosePadrao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidadeEstoque => $composableBuilder(
    column: $table.unidadeEstoque,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacoes => $composableBuilder(
    column: $table.observacoes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get controleEstoque => $composableBuilder(
    column: $table.controleEstoque,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicamentosTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicamentosTable> {
  $$MedicamentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get concentracao => $composableBuilder(
    column: $table.concentracao,
    builder: (column) => column,
  );

  GeneratedColumn<String> get formaFarmaceutica => $composableBuilder(
    column: $table.formaFarmaceutica,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unidadeDosePadrao => $composableBuilder(
    column: $table.unidadeDosePadrao,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unidadeEstoque => $composableBuilder(
    column: $table.unidadeEstoque,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observacoes => $composableBuilder(
    column: $table.observacoes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get controleEstoque => $composableBuilder(
    column: $table.controleEstoque,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ativo =>
      $composableBuilder(column: $table.ativo, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  Expression<T> tratamentosRefs<T extends Object>(
    Expression<T> Function($$TratamentosTableAnnotationComposer a) f,
  ) {
    final $$TratamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tratamentos,
      getReferencedColumn: (t) => t.medicamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TratamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.tratamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> registrosDoseRefs<T extends Object>(
    Expression<T> Function($$RegistrosDoseTableAnnotationComposer a) f,
  ) {
    final $$RegistrosDoseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registrosDose,
      getReferencedColumn: (t) => t.medicamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistrosDoseTableAnnotationComposer(
            $db: $db,
            $table: $db.registrosDose,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> movimentacoesEstoqueRefs<T extends Object>(
    Expression<T> Function($$MovimentacoesEstoqueTableAnnotationComposer a) f,
  ) {
    final $$MovimentacoesEstoqueTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.movimentacoesEstoque,
          getReferencedColumn: (t) => t.medicamentoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MovimentacoesEstoqueTableAnnotationComposer(
                $db: $db,
                $table: $db.movimentacoesEstoque,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> anexosRefs<T extends Object>(
    Expression<T> Function($$AnexosTableAnnotationComposer a) f,
  ) {
    final $$AnexosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.anexos,
      getReferencedColumn: (t) => t.medicamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnexosTableAnnotationComposer(
            $db: $db,
            $table: $db.anexos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> adiamentosDoseRefs<T extends Object>(
    Expression<T> Function($$AdiamentosDoseTableAnnotationComposer a) f,
  ) {
    final $$AdiamentosDoseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adiamentosDose,
      getReferencedColumn: (t) => t.medicamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdiamentosDoseTableAnnotationComposer(
            $db: $db,
            $table: $db.adiamentosDose,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicamentosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicamentosTable,
          MedicamentoDb,
          $$MedicamentosTableFilterComposer,
          $$MedicamentosTableOrderingComposer,
          $$MedicamentosTableAnnotationComposer,
          $$MedicamentosTableCreateCompanionBuilder,
          $$MedicamentosTableUpdateCompanionBuilder,
          (MedicamentoDb, $$MedicamentosTableReferences),
          MedicamentoDb,
          PrefetchHooks Function({
            bool tratamentosRefs,
            bool registrosDoseRefs,
            bool movimentacoesEstoqueRefs,
            bool anexosRefs,
            bool adiamentosDoseRefs,
          })
        > {
  $$MedicamentosTableTableManager(_$AppDatabase db, $MedicamentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicamentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicamentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicamentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String?> concentracao = const Value.absent(),
                Value<String?> formaFarmaceutica = const Value.absent(),
                Value<String?> unidadeDosePadrao = const Value.absent(),
                Value<String?> unidadeEstoque = const Value.absent(),
                Value<String?> observacoes = const Value.absent(),
                Value<bool> controleEstoque = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicamentosCompanion(
                id: id,
                nome: nome,
                concentracao: concentracao,
                formaFarmaceutica: formaFarmaceutica,
                unidadeDosePadrao: unidadeDosePadrao,
                unidadeEstoque: unidadeEstoque,
                observacoes: observacoes,
                controleEstoque: controleEstoque,
                ativo: ativo,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nome,
                Value<String?> concentracao = const Value.absent(),
                Value<String?> formaFarmaceutica = const Value.absent(),
                Value<String?> unidadeDosePadrao = const Value.absent(),
                Value<String?> unidadeEstoque = const Value.absent(),
                Value<String?> observacoes = const Value.absent(),
                Value<bool> controleEstoque = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<int> rowid = const Value.absent(),
              }) => MedicamentosCompanion.insert(
                id: id,
                nome: nome,
                concentracao: concentracao,
                formaFarmaceutica: formaFarmaceutica,
                unidadeDosePadrao: unidadeDosePadrao,
                unidadeEstoque: unidadeEstoque,
                observacoes: observacoes,
                controleEstoque: controleEstoque,
                ativo: ativo,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicamentosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tratamentosRefs = false,
                registrosDoseRefs = false,
                movimentacoesEstoqueRefs = false,
                anexosRefs = false,
                adiamentosDoseRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tratamentosRefs) db.tratamentos,
                    if (registrosDoseRefs) db.registrosDose,
                    if (movimentacoesEstoqueRefs) db.movimentacoesEstoque,
                    if (anexosRefs) db.anexos,
                    if (adiamentosDoseRefs) db.adiamentosDose,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tratamentosRefs)
                        await $_getPrefetchedData<
                          MedicamentoDb,
                          $MedicamentosTable,
                          TratamentoDb
                        >(
                          currentTable: table,
                          referencedTable: $$MedicamentosTableReferences
                              ._tratamentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicamentosTableReferences(
                                db,
                                table,
                                p0,
                              ).tratamentosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (registrosDoseRefs)
                        await $_getPrefetchedData<
                          MedicamentoDb,
                          $MedicamentosTable,
                          RegistroDoseDb
                        >(
                          currentTable: table,
                          referencedTable: $$MedicamentosTableReferences
                              ._registrosDoseRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicamentosTableReferences(
                                db,
                                table,
                                p0,
                              ).registrosDoseRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (movimentacoesEstoqueRefs)
                        await $_getPrefetchedData<
                          MedicamentoDb,
                          $MedicamentosTable,
                          MovimentacaoEstoqueDb
                        >(
                          currentTable: table,
                          referencedTable: $$MedicamentosTableReferences
                              ._movimentacoesEstoqueRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicamentosTableReferences(
                                db,
                                table,
                                p0,
                              ).movimentacoesEstoqueRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (anexosRefs)
                        await $_getPrefetchedData<
                          MedicamentoDb,
                          $MedicamentosTable,
                          AnexoDb
                        >(
                          currentTable: table,
                          referencedTable: $$MedicamentosTableReferences
                              ._anexosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicamentosTableReferences(
                                db,
                                table,
                                p0,
                              ).anexosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (adiamentosDoseRefs)
                        await $_getPrefetchedData<
                          MedicamentoDb,
                          $MedicamentosTable,
                          AdiamentoDoseDb
                        >(
                          currentTable: table,
                          referencedTable: $$MedicamentosTableReferences
                              ._adiamentosDoseRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicamentosTableReferences(
                                db,
                                table,
                                p0,
                              ).adiamentosDoseRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MedicamentosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicamentosTable,
      MedicamentoDb,
      $$MedicamentosTableFilterComposer,
      $$MedicamentosTableOrderingComposer,
      $$MedicamentosTableAnnotationComposer,
      $$MedicamentosTableCreateCompanionBuilder,
      $$MedicamentosTableUpdateCompanionBuilder,
      (MedicamentoDb, $$MedicamentosTableReferences),
      MedicamentoDb,
      PrefetchHooks Function({
        bool tratamentosRefs,
        bool registrosDoseRefs,
        bool movimentacoesEstoqueRefs,
        bool anexosRefs,
        bool adiamentosDoseRefs,
      })
    >;
typedef $$TratamentosTableCreateCompanionBuilder =
    TratamentosCompanion Function({
      required String id,
      required String medicamentoId,
      required double quantidadeDose,
      required String unidadeDose,
      Value<double?> consumoEstoquePorDose,
      required DateTime dataInicio,
      Value<DateTime?> dataFim,
      required bool usoContinuo,
      required String tipoAgendamento,
      Value<DateTime?> dataHoraAncora,
      Value<int?> intervaloMinutos,
      Value<String> recorrencia,
      Value<int?> recorrenciaIntervalo,
      Value<String?> recorrenciaDiasSemana,
      Value<int?> recorrenciaDiaDoMes,
      Value<String?> instrucoes,
      Value<bool> ativo,
      Value<DateTime?> encerradoEm,
      required DateTime criadoEm,
      required DateTime atualizadoEm,
      Value<int> rowid,
    });
typedef $$TratamentosTableUpdateCompanionBuilder =
    TratamentosCompanion Function({
      Value<String> id,
      Value<String> medicamentoId,
      Value<double> quantidadeDose,
      Value<String> unidadeDose,
      Value<double?> consumoEstoquePorDose,
      Value<DateTime> dataInicio,
      Value<DateTime?> dataFim,
      Value<bool> usoContinuo,
      Value<String> tipoAgendamento,
      Value<DateTime?> dataHoraAncora,
      Value<int?> intervaloMinutos,
      Value<String> recorrencia,
      Value<int?> recorrenciaIntervalo,
      Value<String?> recorrenciaDiasSemana,
      Value<int?> recorrenciaDiaDoMes,
      Value<String?> instrucoes,
      Value<bool> ativo,
      Value<DateTime?> encerradoEm,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<int> rowid,
    });

final class $$TratamentosTableReferences
    extends BaseReferences<_$AppDatabase, $TratamentosTable, TratamentoDb> {
  $$TratamentosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicamentosTable _medicamentoIdTable(_$AppDatabase db) => db
      .medicamentos
      .createAlias('tratamentos__medicamento_id__medicamentos__id');

  $$MedicamentosTableProcessedTableManager get medicamentoId {
    final $_column = $_itemColumn<String>('medicamento_id')!;

    final manager = $$MedicamentosTableTableManager(
      $_db,
      $_db.medicamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $HorariosTratamentoTable,
    List<HorarioTratamentoDb>
  >
  _horariosTratamentoRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.horariosTratamento,
        aliasName: 'tratamentos__id__horarios_tratamento__tratamento_id',
      );

  $$HorariosTratamentoTableProcessedTableManager get horariosTratamentoRefs {
    final manager = $$HorariosTratamentoTableTableManager(
      $_db,
      $_db.horariosTratamento,
    ).filter((f) => f.tratamentoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _horariosTratamentoRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RegistrosDoseTable, List<RegistroDoseDb>>
  _registrosDoseRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.registrosDose,
    aliasName: 'tratamentos__id__registros_dose__tratamento_id',
  );

  $$RegistrosDoseTableProcessedTableManager get registrosDoseRefs {
    final manager = $$RegistrosDoseTableTableManager(
      $_db,
      $_db.registrosDose,
    ).filter((f) => f.tratamentoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_registrosDoseRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AdiamentosDoseTable, List<AdiamentoDoseDb>>
  _adiamentosDoseRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.adiamentosDose,
    aliasName: 'tratamentos__id__adiamentos_dose__tratamento_id',
  );

  $$AdiamentosDoseTableProcessedTableManager get adiamentosDoseRefs {
    final manager = $$AdiamentosDoseTableTableManager(
      $_db,
      $_db.adiamentosDose,
    ).filter((f) => f.tratamentoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_adiamentosDoseRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TratamentosTableFilterComposer
    extends Composer<_$AppDatabase, $TratamentosTable> {
  $$TratamentosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantidadeDose => $composableBuilder(
    column: $table.quantidadeDose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidadeDose => $composableBuilder(
    column: $table.unidadeDose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get consumoEstoquePorDose => $composableBuilder(
    column: $table.consumoEstoquePorDose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get dataInicio =>
      $composableBuilder(
        column: $table.dataInicio,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get dataFim =>
      $composableBuilder(
        column: $table.dataFim,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get usoContinuo => $composableBuilder(
    column: $table.usoContinuo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoAgendamento => $composableBuilder(
    column: $table.tipoAgendamento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataHoraAncora => $composableBuilder(
    column: $table.dataHoraAncora,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervaloMinutos => $composableBuilder(
    column: $table.intervaloMinutos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recorrencia => $composableBuilder(
    column: $table.recorrencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recorrenciaIntervalo => $composableBuilder(
    column: $table.recorrenciaIntervalo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recorrenciaDiasSemana => $composableBuilder(
    column: $table.recorrenciaDiasSemana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recorrenciaDiaDoMes => $composableBuilder(
    column: $table.recorrenciaDiaDoMes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instrucoes => $composableBuilder(
    column: $table.instrucoes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get encerradoEm => $composableBuilder(
    column: $table.encerradoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicamentosTableFilterComposer get medicamentoId {
    final $$MedicamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableFilterComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> horariosTratamentoRefs(
    Expression<bool> Function($$HorariosTratamentoTableFilterComposer f) f,
  ) {
    final $$HorariosTratamentoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.horariosTratamento,
      getReferencedColumn: (t) => t.tratamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HorariosTratamentoTableFilterComposer(
            $db: $db,
            $table: $db.horariosTratamento,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> registrosDoseRefs(
    Expression<bool> Function($$RegistrosDoseTableFilterComposer f) f,
  ) {
    final $$RegistrosDoseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registrosDose,
      getReferencedColumn: (t) => t.tratamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistrosDoseTableFilterComposer(
            $db: $db,
            $table: $db.registrosDose,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> adiamentosDoseRefs(
    Expression<bool> Function($$AdiamentosDoseTableFilterComposer f) f,
  ) {
    final $$AdiamentosDoseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adiamentosDose,
      getReferencedColumn: (t) => t.tratamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdiamentosDoseTableFilterComposer(
            $db: $db,
            $table: $db.adiamentosDose,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TratamentosTableOrderingComposer
    extends Composer<_$AppDatabase, $TratamentosTable> {
  $$TratamentosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantidadeDose => $composableBuilder(
    column: $table.quantidadeDose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidadeDose => $composableBuilder(
    column: $table.unidadeDose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get consumoEstoquePorDose => $composableBuilder(
    column: $table.consumoEstoquePorDose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dataInicio => $composableBuilder(
    column: $table.dataInicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dataFim => $composableBuilder(
    column: $table.dataFim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get usoContinuo => $composableBuilder(
    column: $table.usoContinuo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoAgendamento => $composableBuilder(
    column: $table.tipoAgendamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataHoraAncora => $composableBuilder(
    column: $table.dataHoraAncora,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervaloMinutos => $composableBuilder(
    column: $table.intervaloMinutos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recorrencia => $composableBuilder(
    column: $table.recorrencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recorrenciaIntervalo => $composableBuilder(
    column: $table.recorrenciaIntervalo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recorrenciaDiasSemana => $composableBuilder(
    column: $table.recorrenciaDiasSemana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recorrenciaDiaDoMes => $composableBuilder(
    column: $table.recorrenciaDiaDoMes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrucoes => $composableBuilder(
    column: $table.instrucoes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get encerradoEm => $composableBuilder(
    column: $table.encerradoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicamentosTableOrderingComposer get medicamentoId {
    final $$MedicamentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableOrderingComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TratamentosTableAnnotationComposer
    extends Composer<_$AppDatabase, $TratamentosTable> {
  $$TratamentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get quantidadeDose => $composableBuilder(
    column: $table.quantidadeDose,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unidadeDose => $composableBuilder(
    column: $table.unidadeDose,
    builder: (column) => column,
  );

  GeneratedColumn<double> get consumoEstoquePorDose => $composableBuilder(
    column: $table.consumoEstoquePorDose,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get dataInicio =>
      $composableBuilder(
        column: $table.dataInicio,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get dataFim =>
      $composableBuilder(column: $table.dataFim, builder: (column) => column);

  GeneratedColumn<bool> get usoContinuo => $composableBuilder(
    column: $table.usoContinuo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoAgendamento => $composableBuilder(
    column: $table.tipoAgendamento,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataHoraAncora => $composableBuilder(
    column: $table.dataHoraAncora,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervaloMinutos => $composableBuilder(
    column: $table.intervaloMinutos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recorrencia => $composableBuilder(
    column: $table.recorrencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recorrenciaIntervalo => $composableBuilder(
    column: $table.recorrenciaIntervalo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recorrenciaDiasSemana => $composableBuilder(
    column: $table.recorrenciaDiasSemana,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recorrenciaDiaDoMes => $composableBuilder(
    column: $table.recorrenciaDiaDoMes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instrucoes => $composableBuilder(
    column: $table.instrucoes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ativo =>
      $composableBuilder(column: $table.ativo, builder: (column) => column);

  GeneratedColumn<DateTime> get encerradoEm => $composableBuilder(
    column: $table.encerradoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  $$MedicamentosTableAnnotationComposer get medicamentoId {
    final $$MedicamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> horariosTratamentoRefs<T extends Object>(
    Expression<T> Function($$HorariosTratamentoTableAnnotationComposer a) f,
  ) {
    final $$HorariosTratamentoTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.horariosTratamento,
          getReferencedColumn: (t) => t.tratamentoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HorariosTratamentoTableAnnotationComposer(
                $db: $db,
                $table: $db.horariosTratamento,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> registrosDoseRefs<T extends Object>(
    Expression<T> Function($$RegistrosDoseTableAnnotationComposer a) f,
  ) {
    final $$RegistrosDoseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registrosDose,
      getReferencedColumn: (t) => t.tratamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistrosDoseTableAnnotationComposer(
            $db: $db,
            $table: $db.registrosDose,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> adiamentosDoseRefs<T extends Object>(
    Expression<T> Function($$AdiamentosDoseTableAnnotationComposer a) f,
  ) {
    final $$AdiamentosDoseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.adiamentosDose,
      getReferencedColumn: (t) => t.tratamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AdiamentosDoseTableAnnotationComposer(
            $db: $db,
            $table: $db.adiamentosDose,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TratamentosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TratamentosTable,
          TratamentoDb,
          $$TratamentosTableFilterComposer,
          $$TratamentosTableOrderingComposer,
          $$TratamentosTableAnnotationComposer,
          $$TratamentosTableCreateCompanionBuilder,
          $$TratamentosTableUpdateCompanionBuilder,
          (TratamentoDb, $$TratamentosTableReferences),
          TratamentoDb,
          PrefetchHooks Function({
            bool medicamentoId,
            bool horariosTratamentoRefs,
            bool registrosDoseRefs,
            bool adiamentosDoseRefs,
          })
        > {
  $$TratamentosTableTableManager(_$AppDatabase db, $TratamentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TratamentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TratamentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TratamentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> medicamentoId = const Value.absent(),
                Value<double> quantidadeDose = const Value.absent(),
                Value<String> unidadeDose = const Value.absent(),
                Value<double?> consumoEstoquePorDose = const Value.absent(),
                Value<DateTime> dataInicio = const Value.absent(),
                Value<DateTime?> dataFim = const Value.absent(),
                Value<bool> usoContinuo = const Value.absent(),
                Value<String> tipoAgendamento = const Value.absent(),
                Value<DateTime?> dataHoraAncora = const Value.absent(),
                Value<int?> intervaloMinutos = const Value.absent(),
                Value<String> recorrencia = const Value.absent(),
                Value<int?> recorrenciaIntervalo = const Value.absent(),
                Value<String?> recorrenciaDiasSemana = const Value.absent(),
                Value<int?> recorrenciaDiaDoMes = const Value.absent(),
                Value<String?> instrucoes = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
                Value<DateTime?> encerradoEm = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TratamentosCompanion(
                id: id,
                medicamentoId: medicamentoId,
                quantidadeDose: quantidadeDose,
                unidadeDose: unidadeDose,
                consumoEstoquePorDose: consumoEstoquePorDose,
                dataInicio: dataInicio,
                dataFim: dataFim,
                usoContinuo: usoContinuo,
                tipoAgendamento: tipoAgendamento,
                dataHoraAncora: dataHoraAncora,
                intervaloMinutos: intervaloMinutos,
                recorrencia: recorrencia,
                recorrenciaIntervalo: recorrenciaIntervalo,
                recorrenciaDiasSemana: recorrenciaDiasSemana,
                recorrenciaDiaDoMes: recorrenciaDiaDoMes,
                instrucoes: instrucoes,
                ativo: ativo,
                encerradoEm: encerradoEm,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String medicamentoId,
                required double quantidadeDose,
                required String unidadeDose,
                Value<double?> consumoEstoquePorDose = const Value.absent(),
                required DateTime dataInicio,
                Value<DateTime?> dataFim = const Value.absent(),
                required bool usoContinuo,
                required String tipoAgendamento,
                Value<DateTime?> dataHoraAncora = const Value.absent(),
                Value<int?> intervaloMinutos = const Value.absent(),
                Value<String> recorrencia = const Value.absent(),
                Value<int?> recorrenciaIntervalo = const Value.absent(),
                Value<String?> recorrenciaDiasSemana = const Value.absent(),
                Value<int?> recorrenciaDiaDoMes = const Value.absent(),
                Value<String?> instrucoes = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
                Value<DateTime?> encerradoEm = const Value.absent(),
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<int> rowid = const Value.absent(),
              }) => TratamentosCompanion.insert(
                id: id,
                medicamentoId: medicamentoId,
                quantidadeDose: quantidadeDose,
                unidadeDose: unidadeDose,
                consumoEstoquePorDose: consumoEstoquePorDose,
                dataInicio: dataInicio,
                dataFim: dataFim,
                usoContinuo: usoContinuo,
                tipoAgendamento: tipoAgendamento,
                dataHoraAncora: dataHoraAncora,
                intervaloMinutos: intervaloMinutos,
                recorrencia: recorrencia,
                recorrenciaIntervalo: recorrenciaIntervalo,
                recorrenciaDiasSemana: recorrenciaDiasSemana,
                recorrenciaDiaDoMes: recorrenciaDiaDoMes,
                instrucoes: instrucoes,
                ativo: ativo,
                encerradoEm: encerradoEm,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TratamentosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                medicamentoId = false,
                horariosTratamentoRefs = false,
                registrosDoseRefs = false,
                adiamentosDoseRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (horariosTratamentoRefs) db.horariosTratamento,
                    if (registrosDoseRefs) db.registrosDose,
                    if (adiamentosDoseRefs) db.adiamentosDose,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (medicamentoId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.medicamentoId,
                                    referencedTable:
                                        $$TratamentosTableReferences
                                            ._medicamentoIdTable(db),
                                    referencedColumn:
                                        $$TratamentosTableReferences
                                            ._medicamentoIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (horariosTratamentoRefs)
                        await $_getPrefetchedData<
                          TratamentoDb,
                          $TratamentosTable,
                          HorarioTratamentoDb
                        >(
                          currentTable: table,
                          referencedTable: $$TratamentosTableReferences
                              ._horariosTratamentoRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TratamentosTableReferences(
                                db,
                                table,
                                p0,
                              ).horariosTratamentoRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tratamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (registrosDoseRefs)
                        await $_getPrefetchedData<
                          TratamentoDb,
                          $TratamentosTable,
                          RegistroDoseDb
                        >(
                          currentTable: table,
                          referencedTable: $$TratamentosTableReferences
                              ._registrosDoseRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TratamentosTableReferences(
                                db,
                                table,
                                p0,
                              ).registrosDoseRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tratamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (adiamentosDoseRefs)
                        await $_getPrefetchedData<
                          TratamentoDb,
                          $TratamentosTable,
                          AdiamentoDoseDb
                        >(
                          currentTable: table,
                          referencedTable: $$TratamentosTableReferences
                              ._adiamentosDoseRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TratamentosTableReferences(
                                db,
                                table,
                                p0,
                              ).adiamentosDoseRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tratamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TratamentosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TratamentosTable,
      TratamentoDb,
      $$TratamentosTableFilterComposer,
      $$TratamentosTableOrderingComposer,
      $$TratamentosTableAnnotationComposer,
      $$TratamentosTableCreateCompanionBuilder,
      $$TratamentosTableUpdateCompanionBuilder,
      (TratamentoDb, $$TratamentosTableReferences),
      TratamentoDb,
      PrefetchHooks Function({
        bool medicamentoId,
        bool horariosTratamentoRefs,
        bool registrosDoseRefs,
        bool adiamentosDoseRefs,
      })
    >;
typedef $$HorariosTratamentoTableCreateCompanionBuilder =
    HorariosTratamentoCompanion Function({
      required String id,
      required String tratamentoId,
      required int hora,
      required int minuto,
      required int ordem,
      Value<int> rowid,
    });
typedef $$HorariosTratamentoTableUpdateCompanionBuilder =
    HorariosTratamentoCompanion Function({
      Value<String> id,
      Value<String> tratamentoId,
      Value<int> hora,
      Value<int> minuto,
      Value<int> ordem,
      Value<int> rowid,
    });

final class $$HorariosTratamentoTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $HorariosTratamentoTable,
          HorarioTratamentoDb
        > {
  $$HorariosTratamentoTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TratamentosTable _tratamentoIdTable(_$AppDatabase db) => db
      .tratamentos
      .createAlias('horarios_tratamento__tratamento_id__tratamentos__id');

  $$TratamentosTableProcessedTableManager get tratamentoId {
    final $_column = $_itemColumn<String>('tratamento_id')!;

    final manager = $$TratamentosTableTableManager(
      $_db,
      $_db.tratamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tratamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HorariosTratamentoTableFilterComposer
    extends Composer<_$AppDatabase, $HorariosTratamentoTable> {
  $$HorariosTratamentoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minuto => $composableBuilder(
    column: $table.minuto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );

  $$TratamentosTableFilterComposer get tratamentoId {
    final $$TratamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tratamentoId,
      referencedTable: $db.tratamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TratamentosTableFilterComposer(
            $db: $db,
            $table: $db.tratamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HorariosTratamentoTableOrderingComposer
    extends Composer<_$AppDatabase, $HorariosTratamentoTable> {
  $$HorariosTratamentoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minuto => $composableBuilder(
    column: $table.minuto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );

  $$TratamentosTableOrderingComposer get tratamentoId {
    final $$TratamentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tratamentoId,
      referencedTable: $db.tratamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TratamentosTableOrderingComposer(
            $db: $db,
            $table: $db.tratamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HorariosTratamentoTableAnnotationComposer
    extends Composer<_$AppDatabase, $HorariosTratamentoTable> {
  $$HorariosTratamentoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get hora =>
      $composableBuilder(column: $table.hora, builder: (column) => column);

  GeneratedColumn<int> get minuto =>
      $composableBuilder(column: $table.minuto, builder: (column) => column);

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);

  $$TratamentosTableAnnotationComposer get tratamentoId {
    final $$TratamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tratamentoId,
      referencedTable: $db.tratamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TratamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.tratamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HorariosTratamentoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HorariosTratamentoTable,
          HorarioTratamentoDb,
          $$HorariosTratamentoTableFilterComposer,
          $$HorariosTratamentoTableOrderingComposer,
          $$HorariosTratamentoTableAnnotationComposer,
          $$HorariosTratamentoTableCreateCompanionBuilder,
          $$HorariosTratamentoTableUpdateCompanionBuilder,
          (HorarioTratamentoDb, $$HorariosTratamentoTableReferences),
          HorarioTratamentoDb,
          PrefetchHooks Function({bool tratamentoId})
        > {
  $$HorariosTratamentoTableTableManager(
    _$AppDatabase db,
    $HorariosTratamentoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HorariosTratamentoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HorariosTratamentoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HorariosTratamentoTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tratamentoId = const Value.absent(),
                Value<int> hora = const Value.absent(),
                Value<int> minuto = const Value.absent(),
                Value<int> ordem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HorariosTratamentoCompanion(
                id: id,
                tratamentoId: tratamentoId,
                hora: hora,
                minuto: minuto,
                ordem: ordem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tratamentoId,
                required int hora,
                required int minuto,
                required int ordem,
                Value<int> rowid = const Value.absent(),
              }) => HorariosTratamentoCompanion.insert(
                id: id,
                tratamentoId: tratamentoId,
                hora: hora,
                minuto: minuto,
                ordem: ordem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HorariosTratamentoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tratamentoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tratamentoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tratamentoId,
                                referencedTable:
                                    $$HorariosTratamentoTableReferences
                                        ._tratamentoIdTable(db),
                                referencedColumn:
                                    $$HorariosTratamentoTableReferences
                                        ._tratamentoIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HorariosTratamentoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HorariosTratamentoTable,
      HorarioTratamentoDb,
      $$HorariosTratamentoTableFilterComposer,
      $$HorariosTratamentoTableOrderingComposer,
      $$HorariosTratamentoTableAnnotationComposer,
      $$HorariosTratamentoTableCreateCompanionBuilder,
      $$HorariosTratamentoTableUpdateCompanionBuilder,
      (HorarioTratamentoDb, $$HorariosTratamentoTableReferences),
      HorarioTratamentoDb,
      PrefetchHooks Function({bool tratamentoId})
    >;
typedef $$RegistrosDoseTableCreateCompanionBuilder =
    RegistrosDoseCompanion Function({
      required String id,
      required String doseKey,
      required String tratamentoId,
      required String medicamentoId,
      required DateTime dataHoraProgramada,
      required DateTime dataHoraAcao,
      required double quantidadeDose,
      required String unidadeDose,
      required String status,
      Value<String?> observacao,
      required DateTime criadoEm,
      required DateTime atualizadoEm,
      Value<int> rowid,
    });
typedef $$RegistrosDoseTableUpdateCompanionBuilder =
    RegistrosDoseCompanion Function({
      Value<String> id,
      Value<String> doseKey,
      Value<String> tratamentoId,
      Value<String> medicamentoId,
      Value<DateTime> dataHoraProgramada,
      Value<DateTime> dataHoraAcao,
      Value<double> quantidadeDose,
      Value<String> unidadeDose,
      Value<String> status,
      Value<String?> observacao,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<int> rowid,
    });

final class $$RegistrosDoseTableReferences
    extends BaseReferences<_$AppDatabase, $RegistrosDoseTable, RegistroDoseDb> {
  $$RegistrosDoseTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TratamentosTable _tratamentoIdTable(_$AppDatabase db) => db
      .tratamentos
      .createAlias('registros_dose__tratamento_id__tratamentos__id');

  $$TratamentosTableProcessedTableManager get tratamentoId {
    final $_column = $_itemColumn<String>('tratamento_id')!;

    final manager = $$TratamentosTableTableManager(
      $_db,
      $_db.tratamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tratamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MedicamentosTable _medicamentoIdTable(_$AppDatabase db) => db
      .medicamentos
      .createAlias('registros_dose__medicamento_id__medicamentos__id');

  $$MedicamentosTableProcessedTableManager get medicamentoId {
    final $_column = $_itemColumn<String>('medicamento_id')!;

    final manager = $$MedicamentosTableTableManager(
      $_db,
      $_db.medicamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $MovimentacoesEstoqueTable,
    List<MovimentacaoEstoqueDb>
  >
  _movimentacoesEstoqueRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.movimentacoesEstoque,
        aliasName:
            'registros_dose__id__movimentacoes_estoque__registro_dose_id',
      );

  $$MovimentacoesEstoqueTableProcessedTableManager
  get movimentacoesEstoqueRefs {
    final manager = $$MovimentacoesEstoqueTableTableManager(
      $_db,
      $_db.movimentacoesEstoque,
    ).filter((f) => f.registroDoseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _movimentacoesEstoqueRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RegistrosDoseTableFilterComposer
    extends Composer<_$AppDatabase, $RegistrosDoseTable> {
  $$RegistrosDoseTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseKey => $composableBuilder(
    column: $table.doseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataHoraProgramada => $composableBuilder(
    column: $table.dataHoraProgramada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataHoraAcao => $composableBuilder(
    column: $table.dataHoraAcao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantidadeDose => $composableBuilder(
    column: $table.quantidadeDose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidadeDose => $composableBuilder(
    column: $table.unidadeDose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$TratamentosTableFilterComposer get tratamentoId {
    final $$TratamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tratamentoId,
      referencedTable: $db.tratamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TratamentosTableFilterComposer(
            $db: $db,
            $table: $db.tratamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicamentosTableFilterComposer get medicamentoId {
    final $$MedicamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableFilterComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> movimentacoesEstoqueRefs(
    Expression<bool> Function($$MovimentacoesEstoqueTableFilterComposer f) f,
  ) {
    final $$MovimentacoesEstoqueTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.movimentacoesEstoque,
      getReferencedColumn: (t) => t.registroDoseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MovimentacoesEstoqueTableFilterComposer(
            $db: $db,
            $table: $db.movimentacoesEstoque,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RegistrosDoseTableOrderingComposer
    extends Composer<_$AppDatabase, $RegistrosDoseTable> {
  $$RegistrosDoseTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseKey => $composableBuilder(
    column: $table.doseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataHoraProgramada => $composableBuilder(
    column: $table.dataHoraProgramada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataHoraAcao => $composableBuilder(
    column: $table.dataHoraAcao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantidadeDose => $composableBuilder(
    column: $table.quantidadeDose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidadeDose => $composableBuilder(
    column: $table.unidadeDose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$TratamentosTableOrderingComposer get tratamentoId {
    final $$TratamentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tratamentoId,
      referencedTable: $db.tratamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TratamentosTableOrderingComposer(
            $db: $db,
            $table: $db.tratamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicamentosTableOrderingComposer get medicamentoId {
    final $$MedicamentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableOrderingComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegistrosDoseTableAnnotationComposer
    extends Composer<_$AppDatabase, $RegistrosDoseTable> {
  $$RegistrosDoseTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get doseKey =>
      $composableBuilder(column: $table.doseKey, builder: (column) => column);

  GeneratedColumn<DateTime> get dataHoraProgramada => $composableBuilder(
    column: $table.dataHoraProgramada,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataHoraAcao => $composableBuilder(
    column: $table.dataHoraAcao,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantidadeDose => $composableBuilder(
    column: $table.quantidadeDose,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unidadeDose => $composableBuilder(
    column: $table.unidadeDose,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  $$TratamentosTableAnnotationComposer get tratamentoId {
    final $$TratamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tratamentoId,
      referencedTable: $db.tratamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TratamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.tratamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicamentosTableAnnotationComposer get medicamentoId {
    final $$MedicamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> movimentacoesEstoqueRefs<T extends Object>(
    Expression<T> Function($$MovimentacoesEstoqueTableAnnotationComposer a) f,
  ) {
    final $$MovimentacoesEstoqueTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.movimentacoesEstoque,
          getReferencedColumn: (t) => t.registroDoseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MovimentacoesEstoqueTableAnnotationComposer(
                $db: $db,
                $table: $db.movimentacoesEstoque,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RegistrosDoseTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RegistrosDoseTable,
          RegistroDoseDb,
          $$RegistrosDoseTableFilterComposer,
          $$RegistrosDoseTableOrderingComposer,
          $$RegistrosDoseTableAnnotationComposer,
          $$RegistrosDoseTableCreateCompanionBuilder,
          $$RegistrosDoseTableUpdateCompanionBuilder,
          (RegistroDoseDb, $$RegistrosDoseTableReferences),
          RegistroDoseDb,
          PrefetchHooks Function({
            bool tratamentoId,
            bool medicamentoId,
            bool movimentacoesEstoqueRefs,
          })
        > {
  $$RegistrosDoseTableTableManager(_$AppDatabase db, $RegistrosDoseTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegistrosDoseTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegistrosDoseTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegistrosDoseTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> doseKey = const Value.absent(),
                Value<String> tratamentoId = const Value.absent(),
                Value<String> medicamentoId = const Value.absent(),
                Value<DateTime> dataHoraProgramada = const Value.absent(),
                Value<DateTime> dataHoraAcao = const Value.absent(),
                Value<double> quantidadeDose = const Value.absent(),
                Value<String> unidadeDose = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> observacao = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RegistrosDoseCompanion(
                id: id,
                doseKey: doseKey,
                tratamentoId: tratamentoId,
                medicamentoId: medicamentoId,
                dataHoraProgramada: dataHoraProgramada,
                dataHoraAcao: dataHoraAcao,
                quantidadeDose: quantidadeDose,
                unidadeDose: unidadeDose,
                status: status,
                observacao: observacao,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String doseKey,
                required String tratamentoId,
                required String medicamentoId,
                required DateTime dataHoraProgramada,
                required DateTime dataHoraAcao,
                required double quantidadeDose,
                required String unidadeDose,
                required String status,
                Value<String?> observacao = const Value.absent(),
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<int> rowid = const Value.absent(),
              }) => RegistrosDoseCompanion.insert(
                id: id,
                doseKey: doseKey,
                tratamentoId: tratamentoId,
                medicamentoId: medicamentoId,
                dataHoraProgramada: dataHoraProgramada,
                dataHoraAcao: dataHoraAcao,
                quantidadeDose: quantidadeDose,
                unidadeDose: unidadeDose,
                status: status,
                observacao: observacao,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RegistrosDoseTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tratamentoId = false,
                medicamentoId = false,
                movimentacoesEstoqueRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (movimentacoesEstoqueRefs) db.movimentacoesEstoque,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tratamentoId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tratamentoId,
                                    referencedTable:
                                        $$RegistrosDoseTableReferences
                                            ._tratamentoIdTable(db),
                                    referencedColumn:
                                        $$RegistrosDoseTableReferences
                                            ._tratamentoIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (medicamentoId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.medicamentoId,
                                    referencedTable:
                                        $$RegistrosDoseTableReferences
                                            ._medicamentoIdTable(db),
                                    referencedColumn:
                                        $$RegistrosDoseTableReferences
                                            ._medicamentoIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (movimentacoesEstoqueRefs)
                        await $_getPrefetchedData<
                          RegistroDoseDb,
                          $RegistrosDoseTable,
                          MovimentacaoEstoqueDb
                        >(
                          currentTable: table,
                          referencedTable: $$RegistrosDoseTableReferences
                              ._movimentacoesEstoqueRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RegistrosDoseTableReferences(
                                db,
                                table,
                                p0,
                              ).movimentacoesEstoqueRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.registroDoseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RegistrosDoseTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RegistrosDoseTable,
      RegistroDoseDb,
      $$RegistrosDoseTableFilterComposer,
      $$RegistrosDoseTableOrderingComposer,
      $$RegistrosDoseTableAnnotationComposer,
      $$RegistrosDoseTableCreateCompanionBuilder,
      $$RegistrosDoseTableUpdateCompanionBuilder,
      (RegistroDoseDb, $$RegistrosDoseTableReferences),
      RegistroDoseDb,
      PrefetchHooks Function({
        bool tratamentoId,
        bool medicamentoId,
        bool movimentacoesEstoqueRefs,
      })
    >;
typedef $$MovimentacoesEstoqueTableCreateCompanionBuilder =
    MovimentacoesEstoqueCompanion Function({
      required String id,
      required String medicamentoId,
      Value<String?> registroDoseId,
      Value<String?> movimentacaoOrigemId,
      required String tipo,
      required double quantidade,
      required String unidade,
      required DateTime dataHora,
      Value<String?> observacao,
      Value<int> rowid,
    });
typedef $$MovimentacoesEstoqueTableUpdateCompanionBuilder =
    MovimentacoesEstoqueCompanion Function({
      Value<String> id,
      Value<String> medicamentoId,
      Value<String?> registroDoseId,
      Value<String?> movimentacaoOrigemId,
      Value<String> tipo,
      Value<double> quantidade,
      Value<String> unidade,
      Value<DateTime> dataHora,
      Value<String?> observacao,
      Value<int> rowid,
    });

final class $$MovimentacoesEstoqueTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MovimentacoesEstoqueTable,
          MovimentacaoEstoqueDb
        > {
  $$MovimentacoesEstoqueTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicamentosTable _medicamentoIdTable(_$AppDatabase db) => db
      .medicamentos
      .createAlias('movimentacoes_estoque__medicamento_id__medicamentos__id');

  $$MedicamentosTableProcessedTableManager get medicamentoId {
    final $_column = $_itemColumn<String>('medicamento_id')!;

    final manager = $$MedicamentosTableTableManager(
      $_db,
      $_db.medicamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RegistrosDoseTable _registroDoseIdTable(_$AppDatabase db) =>
      db.registrosDose.createAlias(
        'movimentacoes_estoque__registro_dose_id__registros_dose__id',
      );

  $$RegistrosDoseTableProcessedTableManager? get registroDoseId {
    final $_column = $_itemColumn<String>('registro_dose_id');
    if ($_column == null) return null;
    final manager = $$RegistrosDoseTableTableManager(
      $_db,
      $_db.registrosDose,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_registroDoseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MovimentacoesEstoqueTableFilterComposer
    extends Composer<_$AppDatabase, $MovimentacoesEstoqueTable> {
  $$MovimentacoesEstoqueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movimentacaoOrigemId => $composableBuilder(
    column: $table.movimentacaoOrigemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidade => $composableBuilder(
    column: $table.unidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataHora => $composableBuilder(
    column: $table.dataHora,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicamentosTableFilterComposer get medicamentoId {
    final $$MedicamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableFilterComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RegistrosDoseTableFilterComposer get registroDoseId {
    final $$RegistrosDoseTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.registroDoseId,
      referencedTable: $db.registrosDose,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistrosDoseTableFilterComposer(
            $db: $db,
            $table: $db.registrosDose,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovimentacoesEstoqueTableOrderingComposer
    extends Composer<_$AppDatabase, $MovimentacoesEstoqueTable> {
  $$MovimentacoesEstoqueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movimentacaoOrigemId => $composableBuilder(
    column: $table.movimentacaoOrigemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidade => $composableBuilder(
    column: $table.unidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataHora => $composableBuilder(
    column: $table.dataHora,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicamentosTableOrderingComposer get medicamentoId {
    final $$MedicamentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableOrderingComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RegistrosDoseTableOrderingComposer get registroDoseId {
    final $$RegistrosDoseTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.registroDoseId,
      referencedTable: $db.registrosDose,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistrosDoseTableOrderingComposer(
            $db: $db,
            $table: $db.registrosDose,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovimentacoesEstoqueTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovimentacoesEstoqueTable> {
  $$MovimentacoesEstoqueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get movimentacaoOrigemId => $composableBuilder(
    column: $table.movimentacaoOrigemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unidade =>
      $composableBuilder(column: $table.unidade, builder: (column) => column);

  GeneratedColumn<DateTime> get dataHora =>
      $composableBuilder(column: $table.dataHora, builder: (column) => column);

  GeneratedColumn<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => column,
  );

  $$MedicamentosTableAnnotationComposer get medicamentoId {
    final $$MedicamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RegistrosDoseTableAnnotationComposer get registroDoseId {
    final $$RegistrosDoseTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.registroDoseId,
      referencedTable: $db.registrosDose,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistrosDoseTableAnnotationComposer(
            $db: $db,
            $table: $db.registrosDose,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovimentacoesEstoqueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovimentacoesEstoqueTable,
          MovimentacaoEstoqueDb,
          $$MovimentacoesEstoqueTableFilterComposer,
          $$MovimentacoesEstoqueTableOrderingComposer,
          $$MovimentacoesEstoqueTableAnnotationComposer,
          $$MovimentacoesEstoqueTableCreateCompanionBuilder,
          $$MovimentacoesEstoqueTableUpdateCompanionBuilder,
          (MovimentacaoEstoqueDb, $$MovimentacoesEstoqueTableReferences),
          MovimentacaoEstoqueDb,
          PrefetchHooks Function({bool medicamentoId, bool registroDoseId})
        > {
  $$MovimentacoesEstoqueTableTableManager(
    _$AppDatabase db,
    $MovimentacoesEstoqueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimentacoesEstoqueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MovimentacoesEstoqueTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MovimentacoesEstoqueTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> medicamentoId = const Value.absent(),
                Value<String?> registroDoseId = const Value.absent(),
                Value<String?> movimentacaoOrigemId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<double> quantidade = const Value.absent(),
                Value<String> unidade = const Value.absent(),
                Value<DateTime> dataHora = const Value.absent(),
                Value<String?> observacao = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovimentacoesEstoqueCompanion(
                id: id,
                medicamentoId: medicamentoId,
                registroDoseId: registroDoseId,
                movimentacaoOrigemId: movimentacaoOrigemId,
                tipo: tipo,
                quantidade: quantidade,
                unidade: unidade,
                dataHora: dataHora,
                observacao: observacao,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String medicamentoId,
                Value<String?> registroDoseId = const Value.absent(),
                Value<String?> movimentacaoOrigemId = const Value.absent(),
                required String tipo,
                required double quantidade,
                required String unidade,
                required DateTime dataHora,
                Value<String?> observacao = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovimentacoesEstoqueCompanion.insert(
                id: id,
                medicamentoId: medicamentoId,
                registroDoseId: registroDoseId,
                movimentacaoOrigemId: movimentacaoOrigemId,
                tipo: tipo,
                quantidade: quantidade,
                unidade: unidade,
                dataHora: dataHora,
                observacao: observacao,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MovimentacoesEstoqueTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({medicamentoId = false, registroDoseId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (medicamentoId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.medicamentoId,
                                    referencedTable:
                                        $$MovimentacoesEstoqueTableReferences
                                            ._medicamentoIdTable(db),
                                    referencedColumn:
                                        $$MovimentacoesEstoqueTableReferences
                                            ._medicamentoIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (registroDoseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.registroDoseId,
                                    referencedTable:
                                        $$MovimentacoesEstoqueTableReferences
                                            ._registroDoseIdTable(db),
                                    referencedColumn:
                                        $$MovimentacoesEstoqueTableReferences
                                            ._registroDoseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$MovimentacoesEstoqueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovimentacoesEstoqueTable,
      MovimentacaoEstoqueDb,
      $$MovimentacoesEstoqueTableFilterComposer,
      $$MovimentacoesEstoqueTableOrderingComposer,
      $$MovimentacoesEstoqueTableAnnotationComposer,
      $$MovimentacoesEstoqueTableCreateCompanionBuilder,
      $$MovimentacoesEstoqueTableUpdateCompanionBuilder,
      (MovimentacaoEstoqueDb, $$MovimentacoesEstoqueTableReferences),
      MovimentacaoEstoqueDb,
      PrefetchHooks Function({bool medicamentoId, bool registroDoseId})
    >;
typedef $$AnexosTableCreateCompanionBuilder =
    AnexosCompanion Function({
      required String id,
      required String medicamentoId,
      required String tipo,
      required String caminhoRelativo,
      Value<String?> nomeOriginal,
      required DateTime criadoEm,
      Value<int> rowid,
    });
typedef $$AnexosTableUpdateCompanionBuilder =
    AnexosCompanion Function({
      Value<String> id,
      Value<String> medicamentoId,
      Value<String> tipo,
      Value<String> caminhoRelativo,
      Value<String?> nomeOriginal,
      Value<DateTime> criadoEm,
      Value<int> rowid,
    });

final class $$AnexosTableReferences
    extends BaseReferences<_$AppDatabase, $AnexosTable, AnexoDb> {
  $$AnexosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicamentosTable _medicamentoIdTable(_$AppDatabase db) =>
      db.medicamentos.createAlias('anexos__medicamento_id__medicamentos__id');

  $$MedicamentosTableProcessedTableManager get medicamentoId {
    final $_column = $_itemColumn<String>('medicamento_id')!;

    final manager = $$MedicamentosTableTableManager(
      $_db,
      $_db.medicamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnexosTableFilterComposer
    extends Composer<_$AppDatabase, $AnexosTable> {
  $$AnexosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caminhoRelativo => $composableBuilder(
    column: $table.caminhoRelativo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomeOriginal => $composableBuilder(
    column: $table.nomeOriginal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicamentosTableFilterComposer get medicamentoId {
    final $$MedicamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableFilterComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnexosTableOrderingComposer
    extends Composer<_$AppDatabase, $AnexosTable> {
  $$AnexosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caminhoRelativo => $composableBuilder(
    column: $table.caminhoRelativo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomeOriginal => $composableBuilder(
    column: $table.nomeOriginal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicamentosTableOrderingComposer get medicamentoId {
    final $$MedicamentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableOrderingComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnexosTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnexosTable> {
  $$AnexosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get caminhoRelativo => $composableBuilder(
    column: $table.caminhoRelativo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nomeOriginal => $composableBuilder(
    column: $table.nomeOriginal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  $$MedicamentosTableAnnotationComposer get medicamentoId {
    final $$MedicamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnexosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnexosTable,
          AnexoDb,
          $$AnexosTableFilterComposer,
          $$AnexosTableOrderingComposer,
          $$AnexosTableAnnotationComposer,
          $$AnexosTableCreateCompanionBuilder,
          $$AnexosTableUpdateCompanionBuilder,
          (AnexoDb, $$AnexosTableReferences),
          AnexoDb,
          PrefetchHooks Function({bool medicamentoId})
        > {
  $$AnexosTableTableManager(_$AppDatabase db, $AnexosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnexosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnexosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnexosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> medicamentoId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> caminhoRelativo = const Value.absent(),
                Value<String?> nomeOriginal = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AnexosCompanion(
                id: id,
                medicamentoId: medicamentoId,
                tipo: tipo,
                caminhoRelativo: caminhoRelativo,
                nomeOriginal: nomeOriginal,
                criadoEm: criadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String medicamentoId,
                required String tipo,
                required String caminhoRelativo,
                Value<String?> nomeOriginal = const Value.absent(),
                required DateTime criadoEm,
                Value<int> rowid = const Value.absent(),
              }) => AnexosCompanion.insert(
                id: id,
                medicamentoId: medicamentoId,
                tipo: tipo,
                caminhoRelativo: caminhoRelativo,
                nomeOriginal: nomeOriginal,
                criadoEm: criadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AnexosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({medicamentoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (medicamentoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicamentoId,
                                referencedTable: $$AnexosTableReferences
                                    ._medicamentoIdTable(db),
                                referencedColumn: $$AnexosTableReferences
                                    ._medicamentoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AnexosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnexosTable,
      AnexoDb,
      $$AnexosTableFilterComposer,
      $$AnexosTableOrderingComposer,
      $$AnexosTableAnnotationComposer,
      $$AnexosTableCreateCompanionBuilder,
      $$AnexosTableUpdateCompanionBuilder,
      (AnexoDb, $$AnexosTableReferences),
      AnexoDb,
      PrefetchHooks Function({bool medicamentoId})
    >;
typedef $$ConfiguracoesTableCreateCompanionBuilder =
    ConfiguracoesCompanion Function({
      required String chave,
      required String valor,
      required DateTime atualizadoEm,
      Value<int> rowid,
    });
typedef $$ConfiguracoesTableUpdateCompanionBuilder =
    ConfiguracoesCompanion Function({
      Value<String> chave,
      Value<String> valor,
      Value<DateTime> atualizadoEm,
      Value<int> rowid,
    });

class $$ConfiguracoesTableFilterComposer
    extends Composer<_$AppDatabase, $ConfiguracoesTable> {
  $$ConfiguracoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfiguracoesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfiguracoesTable> {
  $$ConfiguracoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfiguracoesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfiguracoesTable> {
  $$ConfiguracoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );
}

class $$ConfiguracoesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfiguracoesTable,
          ConfiguracaoDb,
          $$ConfiguracoesTableFilterComposer,
          $$ConfiguracoesTableOrderingComposer,
          $$ConfiguracoesTableAnnotationComposer,
          $$ConfiguracoesTableCreateCompanionBuilder,
          $$ConfiguracoesTableUpdateCompanionBuilder,
          (
            ConfiguracaoDb,
            BaseReferences<_$AppDatabase, $ConfiguracoesTable, ConfiguracaoDb>,
          ),
          ConfiguracaoDb,
          PrefetchHooks Function()
        > {
  $$ConfiguracoesTableTableManager(_$AppDatabase db, $ConfiguracoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfiguracoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfiguracoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfiguracoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chave = const Value.absent(),
                Value<String> valor = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracoesCompanion(
                chave: chave,
                valor: valor,
                atualizadoEm: atualizadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chave,
                required String valor,
                required DateTime atualizadoEm,
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracoesCompanion.insert(
                chave: chave,
                valor: valor,
                atualizadoEm: atualizadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfiguracoesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfiguracoesTable,
      ConfiguracaoDb,
      $$ConfiguracoesTableFilterComposer,
      $$ConfiguracoesTableOrderingComposer,
      $$ConfiguracoesTableAnnotationComposer,
      $$ConfiguracoesTableCreateCompanionBuilder,
      $$ConfiguracoesTableUpdateCompanionBuilder,
      (
        ConfiguracaoDb,
        BaseReferences<_$AppDatabase, $ConfiguracoesTable, ConfiguracaoDb>,
      ),
      ConfiguracaoDb,
      PrefetchHooks Function()
    >;
typedef $$AdiamentosDoseTableCreateCompanionBuilder =
    AdiamentosDoseCompanion Function({
      required String id,
      required String doseKey,
      required String tratamentoId,
      required String medicamentoId,
      required DateTime dataHoraProgramada,
      required DateTime lembrarEm,
      required int notificacaoId,
      required DateTime criadoEm,
      Value<int> rowid,
    });
typedef $$AdiamentosDoseTableUpdateCompanionBuilder =
    AdiamentosDoseCompanion Function({
      Value<String> id,
      Value<String> doseKey,
      Value<String> tratamentoId,
      Value<String> medicamentoId,
      Value<DateTime> dataHoraProgramada,
      Value<DateTime> lembrarEm,
      Value<int> notificacaoId,
      Value<DateTime> criadoEm,
      Value<int> rowid,
    });

final class $$AdiamentosDoseTableReferences
    extends
        BaseReferences<_$AppDatabase, $AdiamentosDoseTable, AdiamentoDoseDb> {
  $$AdiamentosDoseTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TratamentosTable _tratamentoIdTable(_$AppDatabase db) => db
      .tratamentos
      .createAlias('adiamentos_dose__tratamento_id__tratamentos__id');

  $$TratamentosTableProcessedTableManager get tratamentoId {
    final $_column = $_itemColumn<String>('tratamento_id')!;

    final manager = $$TratamentosTableTableManager(
      $_db,
      $_db.tratamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tratamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MedicamentosTable _medicamentoIdTable(_$AppDatabase db) => db
      .medicamentos
      .createAlias('adiamentos_dose__medicamento_id__medicamentos__id');

  $$MedicamentosTableProcessedTableManager get medicamentoId {
    final $_column = $_itemColumn<String>('medicamento_id')!;

    final manager = $$MedicamentosTableTableManager(
      $_db,
      $_db.medicamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AdiamentosDoseTableFilterComposer
    extends Composer<_$AppDatabase, $AdiamentosDoseTable> {
  $$AdiamentosDoseTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseKey => $composableBuilder(
    column: $table.doseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataHoraProgramada => $composableBuilder(
    column: $table.dataHoraProgramada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lembrarEm => $composableBuilder(
    column: $table.lembrarEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificacaoId => $composableBuilder(
    column: $table.notificacaoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$TratamentosTableFilterComposer get tratamentoId {
    final $$TratamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tratamentoId,
      referencedTable: $db.tratamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TratamentosTableFilterComposer(
            $db: $db,
            $table: $db.tratamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicamentosTableFilterComposer get medicamentoId {
    final $$MedicamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableFilterComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdiamentosDoseTableOrderingComposer
    extends Composer<_$AppDatabase, $AdiamentosDoseTable> {
  $$AdiamentosDoseTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseKey => $composableBuilder(
    column: $table.doseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataHoraProgramada => $composableBuilder(
    column: $table.dataHoraProgramada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lembrarEm => $composableBuilder(
    column: $table.lembrarEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificacaoId => $composableBuilder(
    column: $table.notificacaoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$TratamentosTableOrderingComposer get tratamentoId {
    final $$TratamentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tratamentoId,
      referencedTable: $db.tratamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TratamentosTableOrderingComposer(
            $db: $db,
            $table: $db.tratamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicamentosTableOrderingComposer get medicamentoId {
    final $$MedicamentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableOrderingComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdiamentosDoseTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdiamentosDoseTable> {
  $$AdiamentosDoseTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get doseKey =>
      $composableBuilder(column: $table.doseKey, builder: (column) => column);

  GeneratedColumn<DateTime> get dataHoraProgramada => $composableBuilder(
    column: $table.dataHoraProgramada,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lembrarEm =>
      $composableBuilder(column: $table.lembrarEm, builder: (column) => column);

  GeneratedColumn<int> get notificacaoId => $composableBuilder(
    column: $table.notificacaoId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  $$TratamentosTableAnnotationComposer get tratamentoId {
    final $$TratamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tratamentoId,
      referencedTable: $db.tratamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TratamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.tratamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicamentosTableAnnotationComposer get medicamentoId {
    final $$MedicamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicamentoId,
      referencedTable: $db.medicamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.medicamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdiamentosDoseTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdiamentosDoseTable,
          AdiamentoDoseDb,
          $$AdiamentosDoseTableFilterComposer,
          $$AdiamentosDoseTableOrderingComposer,
          $$AdiamentosDoseTableAnnotationComposer,
          $$AdiamentosDoseTableCreateCompanionBuilder,
          $$AdiamentosDoseTableUpdateCompanionBuilder,
          (AdiamentoDoseDb, $$AdiamentosDoseTableReferences),
          AdiamentoDoseDb,
          PrefetchHooks Function({bool tratamentoId, bool medicamentoId})
        > {
  $$AdiamentosDoseTableTableManager(
    _$AppDatabase db,
    $AdiamentosDoseTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdiamentosDoseTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdiamentosDoseTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdiamentosDoseTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> doseKey = const Value.absent(),
                Value<String> tratamentoId = const Value.absent(),
                Value<String> medicamentoId = const Value.absent(),
                Value<DateTime> dataHoraProgramada = const Value.absent(),
                Value<DateTime> lembrarEm = const Value.absent(),
                Value<int> notificacaoId = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdiamentosDoseCompanion(
                id: id,
                doseKey: doseKey,
                tratamentoId: tratamentoId,
                medicamentoId: medicamentoId,
                dataHoraProgramada: dataHoraProgramada,
                lembrarEm: lembrarEm,
                notificacaoId: notificacaoId,
                criadoEm: criadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String doseKey,
                required String tratamentoId,
                required String medicamentoId,
                required DateTime dataHoraProgramada,
                required DateTime lembrarEm,
                required int notificacaoId,
                required DateTime criadoEm,
                Value<int> rowid = const Value.absent(),
              }) => AdiamentosDoseCompanion.insert(
                id: id,
                doseKey: doseKey,
                tratamentoId: tratamentoId,
                medicamentoId: medicamentoId,
                dataHoraProgramada: dataHoraProgramada,
                lembrarEm: lembrarEm,
                notificacaoId: notificacaoId,
                criadoEm: criadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AdiamentosDoseTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tratamentoId = false, medicamentoId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tratamentoId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tratamentoId,
                                    referencedTable:
                                        $$AdiamentosDoseTableReferences
                                            ._tratamentoIdTable(db),
                                    referencedColumn:
                                        $$AdiamentosDoseTableReferences
                                            ._tratamentoIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (medicamentoId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.medicamentoId,
                                    referencedTable:
                                        $$AdiamentosDoseTableReferences
                                            ._medicamentoIdTable(db),
                                    referencedColumn:
                                        $$AdiamentosDoseTableReferences
                                            ._medicamentoIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$AdiamentosDoseTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdiamentosDoseTable,
      AdiamentoDoseDb,
      $$AdiamentosDoseTableFilterComposer,
      $$AdiamentosDoseTableOrderingComposer,
      $$AdiamentosDoseTableAnnotationComposer,
      $$AdiamentosDoseTableCreateCompanionBuilder,
      $$AdiamentosDoseTableUpdateCompanionBuilder,
      (AdiamentoDoseDb, $$AdiamentosDoseTableReferences),
      AdiamentoDoseDb,
      PrefetchHooks Function({bool tratamentoId, bool medicamentoId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MedicamentosTableTableManager get medicamentos =>
      $$MedicamentosTableTableManager(_db, _db.medicamentos);
  $$TratamentosTableTableManager get tratamentos =>
      $$TratamentosTableTableManager(_db, _db.tratamentos);
  $$HorariosTratamentoTableTableManager get horariosTratamento =>
      $$HorariosTratamentoTableTableManager(_db, _db.horariosTratamento);
  $$RegistrosDoseTableTableManager get registrosDose =>
      $$RegistrosDoseTableTableManager(_db, _db.registrosDose);
  $$MovimentacoesEstoqueTableTableManager get movimentacoesEstoque =>
      $$MovimentacoesEstoqueTableTableManager(_db, _db.movimentacoesEstoque);
  $$AnexosTableTableManager get anexos =>
      $$AnexosTableTableManager(_db, _db.anexos);
  $$ConfiguracoesTableTableManager get configuracoes =>
      $$ConfiguracoesTableTableManager(_db, _db.configuracoes);
  $$AdiamentosDoseTableTableManager get adiamentosDose =>
      $$AdiamentosDoseTableTableManager(_db, _db.adiamentosDose);
}
