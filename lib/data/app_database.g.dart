// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class FoodSearch extends Table
    with
        TableInfo<FoodSearch, FoodSearchData>,
        VirtualTableInfo<FoodSearch, FoodSearchData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  FoodSearch(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [foodId, body];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_search';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodSearchData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  FoodSearchData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodSearchData(
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  FoodSearch createAlias(String alias) {
    return FoodSearch(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(food_id UNINDEXED, body, tokenize = \'unicode61 remove_diacritics 2\')';
}

class FoodSearchData extends DataClass implements Insertable<FoodSearchData> {
  final String foodId;
  final String body;
  const FoodSearchData({required this.foodId, required this.body});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['food_id'] = Variable<String>(foodId);
    map['body'] = Variable<String>(body);
    return map;
  }

  FoodSearchCompanion toCompanion(bool nullToAbsent) {
    return FoodSearchCompanion(foodId: Value(foodId), body: Value(body));
  }

  factory FoodSearchData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodSearchData(
      foodId: serializer.fromJson<String>(json['food_id']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'food_id': serializer.toJson<String>(foodId),
      'body': serializer.toJson<String>(body),
    };
  }

  FoodSearchData copyWith({String? foodId, String? body}) =>
      FoodSearchData(foodId: foodId ?? this.foodId, body: body ?? this.body);
  FoodSearchData copyWithCompanion(FoodSearchCompanion data) {
    return FoodSearchData(
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodSearchData(')
          ..write('foodId: $foodId, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(foodId, body);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodSearchData &&
          other.foodId == this.foodId &&
          other.body == this.body);
}

class FoodSearchCompanion extends UpdateCompanion<FoodSearchData> {
  final Value<String> foodId;
  final Value<String> body;
  final Value<int> rowid;
  const FoodSearchCompanion({
    this.foodId = const Value.absent(),
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodSearchCompanion.insert({
    required String foodId,
    required String body,
    this.rowid = const Value.absent(),
  }) : foodId = Value(foodId),
       body = Value(body);
  static Insertable<FoodSearchData> custom({
    Expression<String>? foodId,
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (foodId != null) 'food_id': foodId,
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodSearchCompanion copyWith({
    Value<String>? foodId,
    Value<String>? body,
    Value<int>? rowid,
  }) {
    return FoodSearchCompanion(
      foodId: foodId ?? this.foodId,
      body: body ?? this.body,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodSearchCompanion(')
          ..write('foodId: $foodId, ')
          ..write('body: $body, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodsTable extends Foods with TableInfo<$FoodsTable, FoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FoodSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FoodSource>($FoodsTable.$convertersource);
  static const VerificationMeta _tacoNumberMeta = const VerificationMeta(
    'tacoNumber',
  );
  @override
  late final GeneratedColumn<int> tacoNumber = GeneratedColumn<int>(
    'taco_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbMeta = const VerificationMeta('carb');
  @override
  late final GeneratedColumn<double> carb = GeneratedColumn<double>(
    'carb',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
    'fiber',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sodiumMeta = const VerificationMeta('sodium');
  @override
  late final GeneratedColumn<double> sodium = GeneratedColumn<double>(
    'sodium',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nutrientsJsonMeta = const VerificationMeta(
    'nutrientsJson',
  );
  @override
  late final GeneratedColumn<String> nutrientsJson = GeneratedColumn<String>(
    'nutrients_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    source,
    tacoNumber,
    name,
    searchText,
    category,
    kcal,
    protein,
    carb,
    fat,
    fiber,
    sodium,
    nutrientsJson,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('taco_number')) {
      context.handle(
        _tacoNumberMeta,
        tacoNumber.isAcceptableOrUnknown(data['taco_number']!, _tacoNumberMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    } else if (isInserting) {
      context.missing(_searchTextMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('carb')) {
      context.handle(
        _carbMeta,
        carb.isAcceptableOrUnknown(data['carb']!, _carbMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    }
    if (data.containsKey('sodium')) {
      context.handle(
        _sodiumMeta,
        sodium.isAcceptableOrUnknown(data['sodium']!, _sodiumMeta),
      );
    }
    if (data.containsKey('nutrients_json')) {
      context.handle(
        _nutrientsJsonMeta,
        nutrientsJson.isAcceptableOrUnknown(
          data['nutrients_json']!,
          _nutrientsJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      source: $FoodsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      tacoNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}taco_number'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      ),
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      ),
      carb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carb'],
      ),
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      ),
      fiber: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber'],
      ),
      sodium: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium'],
      ),
      nutrientsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nutrients_json'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FoodSource, String, String> $convertersource =
      const EnumNameConverter<FoodSource>(FoodSource.values);
}

class FoodRow extends DataClass implements Insertable<FoodRow> {
  final String id;
  final FoodSource source;
  final int? tacoNumber;
  final String name;

  /// Nome normalizado, indexado pela busca.
  final String searchText;
  final String? category;
  final double? kcal;
  final double? protein;
  final double? carb;
  final double? fat;
  final double? fiber;
  final double? sodium;

  /// Todos os nutrientes da fonte, com os símbolos originais (Tr, NA, *).
  final String? nutrientsJson;
  final bool isActive;
  const FoodRow({
    required this.id,
    required this.source,
    this.tacoNumber,
    required this.name,
    required this.searchText,
    this.category,
    this.kcal,
    this.protein,
    this.carb,
    this.fat,
    this.fiber,
    this.sodium,
    this.nutrientsJson,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['source'] = Variable<String>(
        $FoodsTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || tacoNumber != null) {
      map['taco_number'] = Variable<int>(tacoNumber);
    }
    map['name'] = Variable<String>(name);
    map['search_text'] = Variable<String>(searchText);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || kcal != null) {
      map['kcal'] = Variable<double>(kcal);
    }
    if (!nullToAbsent || protein != null) {
      map['protein'] = Variable<double>(protein);
    }
    if (!nullToAbsent || carb != null) {
      map['carb'] = Variable<double>(carb);
    }
    if (!nullToAbsent || fat != null) {
      map['fat'] = Variable<double>(fat);
    }
    if (!nullToAbsent || fiber != null) {
      map['fiber'] = Variable<double>(fiber);
    }
    if (!nullToAbsent || sodium != null) {
      map['sodium'] = Variable<double>(sodium);
    }
    if (!nullToAbsent || nutrientsJson != null) {
      map['nutrients_json'] = Variable<String>(nutrientsJson);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      source: Value(source),
      tacoNumber: tacoNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(tacoNumber),
      name: Value(name),
      searchText: Value(searchText),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      kcal: kcal == null && nullToAbsent ? const Value.absent() : Value(kcal),
      protein: protein == null && nullToAbsent
          ? const Value.absent()
          : Value(protein),
      carb: carb == null && nullToAbsent ? const Value.absent() : Value(carb),
      fat: fat == null && nullToAbsent ? const Value.absent() : Value(fat),
      fiber: fiber == null && nullToAbsent
          ? const Value.absent()
          : Value(fiber),
      sodium: sodium == null && nullToAbsent
          ? const Value.absent()
          : Value(sodium),
      nutrientsJson: nutrientsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(nutrientsJson),
      isActive: Value(isActive),
    );
  }

  factory FoodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodRow(
      id: serializer.fromJson<String>(json['id']),
      source: $FoodsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      tacoNumber: serializer.fromJson<int?>(json['tacoNumber']),
      name: serializer.fromJson<String>(json['name']),
      searchText: serializer.fromJson<String>(json['searchText']),
      category: serializer.fromJson<String?>(json['category']),
      kcal: serializer.fromJson<double?>(json['kcal']),
      protein: serializer.fromJson<double?>(json['protein']),
      carb: serializer.fromJson<double?>(json['carb']),
      fat: serializer.fromJson<double?>(json['fat']),
      fiber: serializer.fromJson<double?>(json['fiber']),
      sodium: serializer.fromJson<double?>(json['sodium']),
      nutrientsJson: serializer.fromJson<String?>(json['nutrientsJson']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<String>(
        $FoodsTable.$convertersource.toJson(source),
      ),
      'tacoNumber': serializer.toJson<int?>(tacoNumber),
      'name': serializer.toJson<String>(name),
      'searchText': serializer.toJson<String>(searchText),
      'category': serializer.toJson<String?>(category),
      'kcal': serializer.toJson<double?>(kcal),
      'protein': serializer.toJson<double?>(protein),
      'carb': serializer.toJson<double?>(carb),
      'fat': serializer.toJson<double?>(fat),
      'fiber': serializer.toJson<double?>(fiber),
      'sodium': serializer.toJson<double?>(sodium),
      'nutrientsJson': serializer.toJson<String?>(nutrientsJson),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  FoodRow copyWith({
    String? id,
    FoodSource? source,
    Value<int?> tacoNumber = const Value.absent(),
    String? name,
    String? searchText,
    Value<String?> category = const Value.absent(),
    Value<double?> kcal = const Value.absent(),
    Value<double?> protein = const Value.absent(),
    Value<double?> carb = const Value.absent(),
    Value<double?> fat = const Value.absent(),
    Value<double?> fiber = const Value.absent(),
    Value<double?> sodium = const Value.absent(),
    Value<String?> nutrientsJson = const Value.absent(),
    bool? isActive,
  }) => FoodRow(
    id: id ?? this.id,
    source: source ?? this.source,
    tacoNumber: tacoNumber.present ? tacoNumber.value : this.tacoNumber,
    name: name ?? this.name,
    searchText: searchText ?? this.searchText,
    category: category.present ? category.value : this.category,
    kcal: kcal.present ? kcal.value : this.kcal,
    protein: protein.present ? protein.value : this.protein,
    carb: carb.present ? carb.value : this.carb,
    fat: fat.present ? fat.value : this.fat,
    fiber: fiber.present ? fiber.value : this.fiber,
    sodium: sodium.present ? sodium.value : this.sodium,
    nutrientsJson: nutrientsJson.present
        ? nutrientsJson.value
        : this.nutrientsJson,
    isActive: isActive ?? this.isActive,
  );
  FoodRow copyWithCompanion(FoodsCompanion data) {
    return FoodRow(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      tacoNumber: data.tacoNumber.present
          ? data.tacoNumber.value
          : this.tacoNumber,
      name: data.name.present ? data.name.value : this.name,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
      category: data.category.present ? data.category.value : this.category,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      protein: data.protein.present ? data.protein.value : this.protein,
      carb: data.carb.present ? data.carb.value : this.carb,
      fat: data.fat.present ? data.fat.value : this.fat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      sodium: data.sodium.present ? data.sodium.value : this.sodium,
      nutrientsJson: data.nutrientsJson.present
          ? data.nutrientsJson.value
          : this.nutrientsJson,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodRow(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('tacoNumber: $tacoNumber, ')
          ..write('name: $name, ')
          ..write('searchText: $searchText, ')
          ..write('category: $category, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('carb: $carb, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('nutrientsJson: $nutrientsJson, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    source,
    tacoNumber,
    name,
    searchText,
    category,
    kcal,
    protein,
    carb,
    fat,
    fiber,
    sodium,
    nutrientsJson,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodRow &&
          other.id == this.id &&
          other.source == this.source &&
          other.tacoNumber == this.tacoNumber &&
          other.name == this.name &&
          other.searchText == this.searchText &&
          other.category == this.category &&
          other.kcal == this.kcal &&
          other.protein == this.protein &&
          other.carb == this.carb &&
          other.fat == this.fat &&
          other.fiber == this.fiber &&
          other.sodium == this.sodium &&
          other.nutrientsJson == this.nutrientsJson &&
          other.isActive == this.isActive);
}

class FoodsCompanion extends UpdateCompanion<FoodRow> {
  final Value<String> id;
  final Value<FoodSource> source;
  final Value<int?> tacoNumber;
  final Value<String> name;
  final Value<String> searchText;
  final Value<String?> category;
  final Value<double?> kcal;
  final Value<double?> protein;
  final Value<double?> carb;
  final Value<double?> fat;
  final Value<double?> fiber;
  final Value<double?> sodium;
  final Value<String?> nutrientsJson;
  final Value<bool> isActive;
  final Value<int> rowid;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.tacoNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.searchText = const Value.absent(),
    this.category = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.carb = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.nutrientsJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodsCompanion.insert({
    required String id,
    required FoodSource source,
    this.tacoNumber = const Value.absent(),
    required String name,
    required String searchText,
    this.category = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.carb = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.nutrientsJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       source = Value(source),
       name = Value(name),
       searchText = Value(searchText);
  static Insertable<FoodRow> custom({
    Expression<String>? id,
    Expression<String>? source,
    Expression<int>? tacoNumber,
    Expression<String>? name,
    Expression<String>? searchText,
    Expression<String>? category,
    Expression<double>? kcal,
    Expression<double>? protein,
    Expression<double>? carb,
    Expression<double>? fat,
    Expression<double>? fiber,
    Expression<double>? sodium,
    Expression<String>? nutrientsJson,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (tacoNumber != null) 'taco_number': tacoNumber,
      if (name != null) 'name': name,
      if (searchText != null) 'search_text': searchText,
      if (category != null) 'category': category,
      if (kcal != null) 'kcal': kcal,
      if (protein != null) 'protein': protein,
      if (carb != null) 'carb': carb,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (sodium != null) 'sodium': sodium,
      if (nutrientsJson != null) 'nutrients_json': nutrientsJson,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodsCompanion copyWith({
    Value<String>? id,
    Value<FoodSource>? source,
    Value<int?>? tacoNumber,
    Value<String>? name,
    Value<String>? searchText,
    Value<String?>? category,
    Value<double?>? kcal,
    Value<double?>? protein,
    Value<double?>? carb,
    Value<double?>? fat,
    Value<double?>? fiber,
    Value<double?>? sodium,
    Value<String?>? nutrientsJson,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return FoodsCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      tacoNumber: tacoNumber ?? this.tacoNumber,
      name: name ?? this.name,
      searchText: searchText ?? this.searchText,
      category: category ?? this.category,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      carb: carb ?? this.carb,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      nutrientsJson: nutrientsJson ?? this.nutrientsJson,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $FoodsTable.$convertersource.toSql(source.value),
      );
    }
    if (tacoNumber.present) {
      map['taco_number'] = Variable<int>(tacoNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carb.present) {
      map['carb'] = Variable<double>(carb.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (sodium.present) {
      map['sodium'] = Variable<double>(sodium.value);
    }
    if (nutrientsJson.present) {
      map['nutrients_json'] = Variable<String>(nutrientsJson.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('tacoNumber: $tacoNumber, ')
          ..write('name: $name, ')
          ..write('searchText: $searchText, ')
          ..write('category: $category, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('carb: $carb, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('nutrientsJson: $nutrientsJson, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasuresTable extends Measures
    with TableInfo<$MeasuresTable, MeasureRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasuresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MeasureSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MeasureSource>($MeasuresTable.$convertersource);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    foodId,
    source,
    label,
    grams,
    reference,
    sortOrder,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measures';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasureRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasureRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasureRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      source: $MeasuresTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $MeasuresTable createAlias(String alias) {
    return $MeasuresTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MeasureSource, String, String> $convertersource =
      const EnumNameConverter<MeasureSource>(MeasureSource.values);
}

class MeasureRow extends DataClass implements Insertable<MeasureRow> {
  final String id;
  final String foodId;
  final MeasureSource source;
  final String label;

  /// Gramas de uma unidade da medida.
  final double grams;

  /// Fonte e página da conversão, obrigatória para medidas do sistema.
  final String? reference;
  final int sortOrder;
  final bool isActive;
  const MeasureRow({
    required this.id,
    required this.foodId,
    required this.source,
    required this.label,
    required this.grams,
    this.reference,
    required this.sortOrder,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['food_id'] = Variable<String>(foodId);
    {
      map['source'] = Variable<String>(
        $MeasuresTable.$convertersource.toSql(source),
      );
    }
    map['label'] = Variable<String>(label);
    map['grams'] = Variable<double>(grams);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  MeasuresCompanion toCompanion(bool nullToAbsent) {
    return MeasuresCompanion(
      id: Value(id),
      foodId: Value(foodId),
      source: Value(source),
      label: Value(label),
      grams: Value(grams),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory MeasureRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasureRow(
      id: serializer.fromJson<String>(json['id']),
      foodId: serializer.fromJson<String>(json['foodId']),
      source: $MeasuresTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      label: serializer.fromJson<String>(json['label']),
      grams: serializer.fromJson<double>(json['grams']),
      reference: serializer.fromJson<String?>(json['reference']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'foodId': serializer.toJson<String>(foodId),
      'source': serializer.toJson<String>(
        $MeasuresTable.$convertersource.toJson(source),
      ),
      'label': serializer.toJson<String>(label),
      'grams': serializer.toJson<double>(grams),
      'reference': serializer.toJson<String?>(reference),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  MeasureRow copyWith({
    String? id,
    String? foodId,
    MeasureSource? source,
    String? label,
    double? grams,
    Value<String?> reference = const Value.absent(),
    int? sortOrder,
    bool? isActive,
  }) => MeasureRow(
    id: id ?? this.id,
    foodId: foodId ?? this.foodId,
    source: source ?? this.source,
    label: label ?? this.label,
    grams: grams ?? this.grams,
    reference: reference.present ? reference.value : this.reference,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
  );
  MeasureRow copyWithCompanion(MeasuresCompanion data) {
    return MeasureRow(
      id: data.id.present ? data.id.value : this.id,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      source: data.source.present ? data.source.value : this.source,
      label: data.label.present ? data.label.value : this.label,
      grams: data.grams.present ? data.grams.value : this.grams,
      reference: data.reference.present ? data.reference.value : this.reference,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasureRow(')
          ..write('id: $id, ')
          ..write('foodId: $foodId, ')
          ..write('source: $source, ')
          ..write('label: $label, ')
          ..write('grams: $grams, ')
          ..write('reference: $reference, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    foodId,
    source,
    label,
    grams,
    reference,
    sortOrder,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasureRow &&
          other.id == this.id &&
          other.foodId == this.foodId &&
          other.source == this.source &&
          other.label == this.label &&
          other.grams == this.grams &&
          other.reference == this.reference &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class MeasuresCompanion extends UpdateCompanion<MeasureRow> {
  final Value<String> id;
  final Value<String> foodId;
  final Value<MeasureSource> source;
  final Value<String> label;
  final Value<double> grams;
  final Value<String?> reference;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<int> rowid;
  const MeasuresCompanion({
    this.id = const Value.absent(),
    this.foodId = const Value.absent(),
    this.source = const Value.absent(),
    this.label = const Value.absent(),
    this.grams = const Value.absent(),
    this.reference = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasuresCompanion.insert({
    required String id,
    required String foodId,
    required MeasureSource source,
    required String label,
    required double grams,
    this.reference = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       foodId = Value(foodId),
       source = Value(source),
       label = Value(label),
       grams = Value(grams);
  static Insertable<MeasureRow> custom({
    Expression<String>? id,
    Expression<String>? foodId,
    Expression<String>? source,
    Expression<String>? label,
    Expression<double>? grams,
    Expression<String>? reference,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (foodId != null) 'food_id': foodId,
      if (source != null) 'source': source,
      if (label != null) 'label': label,
      if (grams != null) 'grams': grams,
      if (reference != null) 'reference': reference,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasuresCompanion copyWith({
    Value<String>? id,
    Value<String>? foodId,
    Value<MeasureSource>? source,
    Value<String>? label,
    Value<double>? grams,
    Value<String?>? reference,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return MeasuresCompanion(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      source: source ?? this.source,
      label: label ?? this.label,
      grams: grams ?? this.grams,
      reference: reference ?? this.reference,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $MeasuresTable.$convertersource.toSql(source.value),
      );
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasuresCompanion(')
          ..write('id: $id, ')
          ..write('foodId: $foodId, ')
          ..write('source: $source, ')
          ..write('label: $label, ')
          ..write('grams: $grams, ')
          ..write('reference: $reference, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetVersionsTable extends AssetVersions
    with TableInfo<$AssetVersionsTable, AssetVersionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetMeta = const VerificationMeta('asset');
  @override
  late final GeneratedColumn<String> asset = GeneratedColumn<String>(
    'asset',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemCountMeta = const VerificationMeta(
    'itemCount',
  );
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
    'item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [asset, version, itemCount, importedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetVersionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset')) {
      context.handle(
        _assetMeta,
        asset.isAcceptableOrUnknown(data['asset']!, _assetMeta),
      );
    } else if (isInserting) {
      context.missing(_assetMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('item_count')) {
      context.handle(
        _itemCountMeta,
        itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta),
      );
    } else if (isInserting) {
      context.missing(_itemCountMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {asset};
  @override
  AssetVersionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetVersionRow(
      asset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      itemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_count'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $AssetVersionsTable createAlias(String alias) {
    return $AssetVersionsTable(attachedDatabase, alias);
  }
}

class AssetVersionRow extends DataClass implements Insertable<AssetVersionRow> {
  final String asset;
  final String version;
  final int itemCount;
  final DateTime importedAt;
  const AssetVersionRow({
    required this.asset,
    required this.version,
    required this.itemCount,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset'] = Variable<String>(asset);
    map['version'] = Variable<String>(version);
    map['item_count'] = Variable<int>(itemCount);
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  AssetVersionsCompanion toCompanion(bool nullToAbsent) {
    return AssetVersionsCompanion(
      asset: Value(asset),
      version: Value(version),
      itemCount: Value(itemCount),
      importedAt: Value(importedAt),
    );
  }

  factory AssetVersionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetVersionRow(
      asset: serializer.fromJson<String>(json['asset']),
      version: serializer.fromJson<String>(json['version']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'asset': serializer.toJson<String>(asset),
      'version': serializer.toJson<String>(version),
      'itemCount': serializer.toJson<int>(itemCount),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  AssetVersionRow copyWith({
    String? asset,
    String? version,
    int? itemCount,
    DateTime? importedAt,
  }) => AssetVersionRow(
    asset: asset ?? this.asset,
    version: version ?? this.version,
    itemCount: itemCount ?? this.itemCount,
    importedAt: importedAt ?? this.importedAt,
  );
  AssetVersionRow copyWithCompanion(AssetVersionsCompanion data) {
    return AssetVersionRow(
      asset: data.asset.present ? data.asset.value : this.asset,
      version: data.version.present ? data.version.value : this.version,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetVersionRow(')
          ..write('asset: $asset, ')
          ..write('version: $version, ')
          ..write('itemCount: $itemCount, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(asset, version, itemCount, importedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetVersionRow &&
          other.asset == this.asset &&
          other.version == this.version &&
          other.itemCount == this.itemCount &&
          other.importedAt == this.importedAt);
}

class AssetVersionsCompanion extends UpdateCompanion<AssetVersionRow> {
  final Value<String> asset;
  final Value<String> version;
  final Value<int> itemCount;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const AssetVersionsCompanion({
    this.asset = const Value.absent(),
    this.version = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetVersionsCompanion.insert({
    required String asset,
    required String version,
    required int itemCount,
    required DateTime importedAt,
    this.rowid = const Value.absent(),
  }) : asset = Value(asset),
       version = Value(version),
       itemCount = Value(itemCount),
       importedAt = Value(importedAt);
  static Insertable<AssetVersionRow> custom({
    Expression<String>? asset,
    Expression<String>? version,
    Expression<int>? itemCount,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (asset != null) 'asset': asset,
      if (version != null) 'version': version,
      if (itemCount != null) 'item_count': itemCount,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetVersionsCompanion copyWith({
    Value<String>? asset,
    Value<String>? version,
    Value<int>? itemCount,
    Value<DateTime>? importedAt,
    Value<int>? rowid,
  }) {
    return AssetVersionsCompanion(
      asset: asset ?? this.asset,
      version: version ?? this.version,
      itemCount: itemCount ?? this.itemCount,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (asset.present) {
      map['asset'] = Variable<String>(asset.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetVersionsCompanion(')
          ..write('asset: $asset, ')
          ..write('version: $version, ')
          ..write('itemCount: $itemCount, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiaryItemsTable extends DiaryItems
    with TableInfo<$DiaryItemsTable, DiaryItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($DiaryItemsTable.$converterdate);
  @override
  late final GeneratedColumnWithTypeConverter<MealType, String> meal =
      GeneratedColumn<String>(
        'meal',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MealType>($DiaryItemsTable.$convertermeal);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measureLabelMeta = const VerificationMeta(
    'measureLabel',
  );
  @override
  late final GeneratedColumn<String> measureLabel = GeneratedColumn<String>(
    'measure_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measureGramsMeta = const VerificationMeta(
    'measureGrams',
  );
  @override
  late final GeneratedColumn<double> measureGrams = GeneratedColumn<double>(
    'measure_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcal100Meta = const VerificationMeta(
    'kcal100',
  );
  @override
  late final GeneratedColumn<double> kcal100 = GeneratedColumn<double>(
    'kcal100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protein100Meta = const VerificationMeta(
    'protein100',
  );
  @override
  late final GeneratedColumn<double> protein100 = GeneratedColumn<double>(
    'protein100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carb100Meta = const VerificationMeta(
    'carb100',
  );
  @override
  late final GeneratedColumn<double> carb100 = GeneratedColumn<double>(
    'carb100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fat100Meta = const VerificationMeta('fat100');
  @override
  late final GeneratedColumn<double> fat100 = GeneratedColumn<double>(
    'fat100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiber100Meta = const VerificationMeta(
    'fiber100',
  );
  @override
  late final GeneratedColumn<double> fiber100 = GeneratedColumn<double>(
    'fiber100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sodium100Meta = const VerificationMeta(
    'sodium100',
  );
  @override
  late final GeneratedColumn<double> sodium100 = GeneratedColumn<double>(
    'sodium100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    meal,
    position,
    foodId,
    foodName,
    measureLabel,
    measureGrams,
    quantity,
    grams,
    kcal100,
    protein100,
    carb100,
    fat100,
    fiber100,
    sodium100,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiaryItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('measure_label')) {
      context.handle(
        _measureLabelMeta,
        measureLabel.isAcceptableOrUnknown(
          data['measure_label']!,
          _measureLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_measureLabelMeta);
    }
    if (data.containsKey('measure_grams')) {
      context.handle(
        _measureGramsMeta,
        measureGrams.isAcceptableOrUnknown(
          data['measure_grams']!,
          _measureGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_measureGramsMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('kcal100')) {
      context.handle(
        _kcal100Meta,
        kcal100.isAcceptableOrUnknown(data['kcal100']!, _kcal100Meta),
      );
    } else if (isInserting) {
      context.missing(_kcal100Meta);
    }
    if (data.containsKey('protein100')) {
      context.handle(
        _protein100Meta,
        protein100.isAcceptableOrUnknown(data['protein100']!, _protein100Meta),
      );
    } else if (isInserting) {
      context.missing(_protein100Meta);
    }
    if (data.containsKey('carb100')) {
      context.handle(
        _carb100Meta,
        carb100.isAcceptableOrUnknown(data['carb100']!, _carb100Meta),
      );
    } else if (isInserting) {
      context.missing(_carb100Meta);
    }
    if (data.containsKey('fat100')) {
      context.handle(
        _fat100Meta,
        fat100.isAcceptableOrUnknown(data['fat100']!, _fat100Meta),
      );
    } else if (isInserting) {
      context.missing(_fat100Meta);
    }
    if (data.containsKey('fiber100')) {
      context.handle(
        _fiber100Meta,
        fiber100.isAcceptableOrUnknown(data['fiber100']!, _fiber100Meta),
      );
    } else if (isInserting) {
      context.missing(_fiber100Meta);
    }
    if (data.containsKey('sodium100')) {
      context.handle(
        _sodium100Meta,
        sodium100.isAcceptableOrUnknown(data['sodium100']!, _sodium100Meta),
      );
    } else if (isInserting) {
      context.missing(_sodium100Meta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiaryItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: $DiaryItemsTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      meal: $DiaryItemsTable.$convertermeal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}meal'],
        )!,
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      ),
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      measureLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measure_label'],
      )!,
      measureGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}measure_grams'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
      kcal100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal100'],
      )!,
      protein100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein100'],
      )!,
      carb100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carb100'],
      )!,
      fat100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat100'],
      )!,
      fiber100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber100'],
      )!,
      sodium100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sodium100'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DiaryItemsTable createAlias(String alias) {
    return $DiaryItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalDate, String, String> $converterdate =
      const LocalDateConverter();
  static JsonTypeConverter2<MealType, String, String> $convertermeal =
      const EnumNameConverter<MealType>(MealType.values);
}

class DiaryItemRow extends DataClass implements Insertable<DiaryItemRow> {
  final String id;
  final LocalDate date;
  final MealType meal;
  final int position;
  final String? foodId;
  final String foodName;
  final String measureLabel;

  /// Gramas de uma unidade da medida usada (1 quando a medida é grama).
  final double measureGrams;
  final double quantity;
  final double grams;
  final double kcal100;
  final double protein100;
  final double carb100;
  final double fat100;
  final double fiber100;
  final double sodium100;
  final DateTime createdAt;
  const DiaryItemRow({
    required this.id,
    required this.date,
    required this.meal,
    required this.position,
    this.foodId,
    required this.foodName,
    required this.measureLabel,
    required this.measureGrams,
    required this.quantity,
    required this.grams,
    required this.kcal100,
    required this.protein100,
    required this.carb100,
    required this.fat100,
    required this.fiber100,
    required this.sodium100,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['date'] = Variable<String>(
        $DiaryItemsTable.$converterdate.toSql(date),
      );
    }
    {
      map['meal'] = Variable<String>(
        $DiaryItemsTable.$convertermeal.toSql(meal),
      );
    }
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || foodId != null) {
      map['food_id'] = Variable<String>(foodId);
    }
    map['food_name'] = Variable<String>(foodName);
    map['measure_label'] = Variable<String>(measureLabel);
    map['measure_grams'] = Variable<double>(measureGrams);
    map['quantity'] = Variable<double>(quantity);
    map['grams'] = Variable<double>(grams);
    map['kcal100'] = Variable<double>(kcal100);
    map['protein100'] = Variable<double>(protein100);
    map['carb100'] = Variable<double>(carb100);
    map['fat100'] = Variable<double>(fat100);
    map['fiber100'] = Variable<double>(fiber100);
    map['sodium100'] = Variable<double>(sodium100);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DiaryItemsCompanion toCompanion(bool nullToAbsent) {
    return DiaryItemsCompanion(
      id: Value(id),
      date: Value(date),
      meal: Value(meal),
      position: Value(position),
      foodId: foodId == null && nullToAbsent
          ? const Value.absent()
          : Value(foodId),
      foodName: Value(foodName),
      measureLabel: Value(measureLabel),
      measureGrams: Value(measureGrams),
      quantity: Value(quantity),
      grams: Value(grams),
      kcal100: Value(kcal100),
      protein100: Value(protein100),
      carb100: Value(carb100),
      fat100: Value(fat100),
      fiber100: Value(fiber100),
      sodium100: Value(sodium100),
      createdAt: Value(createdAt),
    );
  }

  factory DiaryItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryItemRow(
      id: serializer.fromJson<String>(json['id']),
      date: $DiaryItemsTable.$converterdate.fromJson(
        serializer.fromJson<String>(json['date']),
      ),
      meal: $DiaryItemsTable.$convertermeal.fromJson(
        serializer.fromJson<String>(json['meal']),
      ),
      position: serializer.fromJson<int>(json['position']),
      foodId: serializer.fromJson<String?>(json['foodId']),
      foodName: serializer.fromJson<String>(json['foodName']),
      measureLabel: serializer.fromJson<String>(json['measureLabel']),
      measureGrams: serializer.fromJson<double>(json['measureGrams']),
      quantity: serializer.fromJson<double>(json['quantity']),
      grams: serializer.fromJson<double>(json['grams']),
      kcal100: serializer.fromJson<double>(json['kcal100']),
      protein100: serializer.fromJson<double>(json['protein100']),
      carb100: serializer.fromJson<double>(json['carb100']),
      fat100: serializer.fromJson<double>(json['fat100']),
      fiber100: serializer.fromJson<double>(json['fiber100']),
      sodium100: serializer.fromJson<double>(json['sodium100']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(
        $DiaryItemsTable.$converterdate.toJson(date),
      ),
      'meal': serializer.toJson<String>(
        $DiaryItemsTable.$convertermeal.toJson(meal),
      ),
      'position': serializer.toJson<int>(position),
      'foodId': serializer.toJson<String?>(foodId),
      'foodName': serializer.toJson<String>(foodName),
      'measureLabel': serializer.toJson<String>(measureLabel),
      'measureGrams': serializer.toJson<double>(measureGrams),
      'quantity': serializer.toJson<double>(quantity),
      'grams': serializer.toJson<double>(grams),
      'kcal100': serializer.toJson<double>(kcal100),
      'protein100': serializer.toJson<double>(protein100),
      'carb100': serializer.toJson<double>(carb100),
      'fat100': serializer.toJson<double>(fat100),
      'fiber100': serializer.toJson<double>(fiber100),
      'sodium100': serializer.toJson<double>(sodium100),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DiaryItemRow copyWith({
    String? id,
    LocalDate? date,
    MealType? meal,
    int? position,
    Value<String?> foodId = const Value.absent(),
    String? foodName,
    String? measureLabel,
    double? measureGrams,
    double? quantity,
    double? grams,
    double? kcal100,
    double? protein100,
    double? carb100,
    double? fat100,
    double? fiber100,
    double? sodium100,
    DateTime? createdAt,
  }) => DiaryItemRow(
    id: id ?? this.id,
    date: date ?? this.date,
    meal: meal ?? this.meal,
    position: position ?? this.position,
    foodId: foodId.present ? foodId.value : this.foodId,
    foodName: foodName ?? this.foodName,
    measureLabel: measureLabel ?? this.measureLabel,
    measureGrams: measureGrams ?? this.measureGrams,
    quantity: quantity ?? this.quantity,
    grams: grams ?? this.grams,
    kcal100: kcal100 ?? this.kcal100,
    protein100: protein100 ?? this.protein100,
    carb100: carb100 ?? this.carb100,
    fat100: fat100 ?? this.fat100,
    fiber100: fiber100 ?? this.fiber100,
    sodium100: sodium100 ?? this.sodium100,
    createdAt: createdAt ?? this.createdAt,
  );
  DiaryItemRow copyWithCompanion(DiaryItemsCompanion data) {
    return DiaryItemRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      meal: data.meal.present ? data.meal.value : this.meal,
      position: data.position.present ? data.position.value : this.position,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      measureLabel: data.measureLabel.present
          ? data.measureLabel.value
          : this.measureLabel,
      measureGrams: data.measureGrams.present
          ? data.measureGrams.value
          : this.measureGrams,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      grams: data.grams.present ? data.grams.value : this.grams,
      kcal100: data.kcal100.present ? data.kcal100.value : this.kcal100,
      protein100: data.protein100.present
          ? data.protein100.value
          : this.protein100,
      carb100: data.carb100.present ? data.carb100.value : this.carb100,
      fat100: data.fat100.present ? data.fat100.value : this.fat100,
      fiber100: data.fiber100.present ? data.fiber100.value : this.fiber100,
      sodium100: data.sodium100.present ? data.sodium100.value : this.sodium100,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryItemRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('meal: $meal, ')
          ..write('position: $position, ')
          ..write('foodId: $foodId, ')
          ..write('foodName: $foodName, ')
          ..write('measureLabel: $measureLabel, ')
          ..write('measureGrams: $measureGrams, ')
          ..write('quantity: $quantity, ')
          ..write('grams: $grams, ')
          ..write('kcal100: $kcal100, ')
          ..write('protein100: $protein100, ')
          ..write('carb100: $carb100, ')
          ..write('fat100: $fat100, ')
          ..write('fiber100: $fiber100, ')
          ..write('sodium100: $sodium100, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    meal,
    position,
    foodId,
    foodName,
    measureLabel,
    measureGrams,
    quantity,
    grams,
    kcal100,
    protein100,
    carb100,
    fat100,
    fiber100,
    sodium100,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryItemRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.meal == this.meal &&
          other.position == this.position &&
          other.foodId == this.foodId &&
          other.foodName == this.foodName &&
          other.measureLabel == this.measureLabel &&
          other.measureGrams == this.measureGrams &&
          other.quantity == this.quantity &&
          other.grams == this.grams &&
          other.kcal100 == this.kcal100 &&
          other.protein100 == this.protein100 &&
          other.carb100 == this.carb100 &&
          other.fat100 == this.fat100 &&
          other.fiber100 == this.fiber100 &&
          other.sodium100 == this.sodium100 &&
          other.createdAt == this.createdAt);
}

class DiaryItemsCompanion extends UpdateCompanion<DiaryItemRow> {
  final Value<String> id;
  final Value<LocalDate> date;
  final Value<MealType> meal;
  final Value<int> position;
  final Value<String?> foodId;
  final Value<String> foodName;
  final Value<String> measureLabel;
  final Value<double> measureGrams;
  final Value<double> quantity;
  final Value<double> grams;
  final Value<double> kcal100;
  final Value<double> protein100;
  final Value<double> carb100;
  final Value<double> fat100;
  final Value<double> fiber100;
  final Value<double> sodium100;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DiaryItemsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.meal = const Value.absent(),
    this.position = const Value.absent(),
    this.foodId = const Value.absent(),
    this.foodName = const Value.absent(),
    this.measureLabel = const Value.absent(),
    this.measureGrams = const Value.absent(),
    this.quantity = const Value.absent(),
    this.grams = const Value.absent(),
    this.kcal100 = const Value.absent(),
    this.protein100 = const Value.absent(),
    this.carb100 = const Value.absent(),
    this.fat100 = const Value.absent(),
    this.fiber100 = const Value.absent(),
    this.sodium100 = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiaryItemsCompanion.insert({
    required String id,
    required LocalDate date,
    required MealType meal,
    required int position,
    this.foodId = const Value.absent(),
    required String foodName,
    required String measureLabel,
    required double measureGrams,
    required double quantity,
    required double grams,
    required double kcal100,
    required double protein100,
    required double carb100,
    required double fat100,
    required double fiber100,
    required double sodium100,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       meal = Value(meal),
       position = Value(position),
       foodName = Value(foodName),
       measureLabel = Value(measureLabel),
       measureGrams = Value(measureGrams),
       quantity = Value(quantity),
       grams = Value(grams),
       kcal100 = Value(kcal100),
       protein100 = Value(protein100),
       carb100 = Value(carb100),
       fat100 = Value(fat100),
       fiber100 = Value(fiber100),
       sodium100 = Value(sodium100),
       createdAt = Value(createdAt);
  static Insertable<DiaryItemRow> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<String>? meal,
    Expression<int>? position,
    Expression<String>? foodId,
    Expression<String>? foodName,
    Expression<String>? measureLabel,
    Expression<double>? measureGrams,
    Expression<double>? quantity,
    Expression<double>? grams,
    Expression<double>? kcal100,
    Expression<double>? protein100,
    Expression<double>? carb100,
    Expression<double>? fat100,
    Expression<double>? fiber100,
    Expression<double>? sodium100,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (meal != null) 'meal': meal,
      if (position != null) 'position': position,
      if (foodId != null) 'food_id': foodId,
      if (foodName != null) 'food_name': foodName,
      if (measureLabel != null) 'measure_label': measureLabel,
      if (measureGrams != null) 'measure_grams': measureGrams,
      if (quantity != null) 'quantity': quantity,
      if (grams != null) 'grams': grams,
      if (kcal100 != null) 'kcal100': kcal100,
      if (protein100 != null) 'protein100': protein100,
      if (carb100 != null) 'carb100': carb100,
      if (fat100 != null) 'fat100': fat100,
      if (fiber100 != null) 'fiber100': fiber100,
      if (sodium100 != null) 'sodium100': sodium100,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiaryItemsCompanion copyWith({
    Value<String>? id,
    Value<LocalDate>? date,
    Value<MealType>? meal,
    Value<int>? position,
    Value<String?>? foodId,
    Value<String>? foodName,
    Value<String>? measureLabel,
    Value<double>? measureGrams,
    Value<double>? quantity,
    Value<double>? grams,
    Value<double>? kcal100,
    Value<double>? protein100,
    Value<double>? carb100,
    Value<double>? fat100,
    Value<double>? fiber100,
    Value<double>? sodium100,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DiaryItemsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      meal: meal ?? this.meal,
      position: position ?? this.position,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      measureLabel: measureLabel ?? this.measureLabel,
      measureGrams: measureGrams ?? this.measureGrams,
      quantity: quantity ?? this.quantity,
      grams: grams ?? this.grams,
      kcal100: kcal100 ?? this.kcal100,
      protein100: protein100 ?? this.protein100,
      carb100: carb100 ?? this.carb100,
      fat100: fat100 ?? this.fat100,
      fiber100: fiber100 ?? this.fiber100,
      sodium100: sodium100 ?? this.sodium100,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $DiaryItemsTable.$converterdate.toSql(date.value),
      );
    }
    if (meal.present) {
      map['meal'] = Variable<String>(
        $DiaryItemsTable.$convertermeal.toSql(meal.value),
      );
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (measureLabel.present) {
      map['measure_label'] = Variable<String>(measureLabel.value);
    }
    if (measureGrams.present) {
      map['measure_grams'] = Variable<double>(measureGrams.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (kcal100.present) {
      map['kcal100'] = Variable<double>(kcal100.value);
    }
    if (protein100.present) {
      map['protein100'] = Variable<double>(protein100.value);
    }
    if (carb100.present) {
      map['carb100'] = Variable<double>(carb100.value);
    }
    if (fat100.present) {
      map['fat100'] = Variable<double>(fat100.value);
    }
    if (fiber100.present) {
      map['fiber100'] = Variable<double>(fiber100.value);
    }
    if (sodium100.present) {
      map['sodium100'] = Variable<double>(sodium100.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryItemsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('meal: $meal, ')
          ..write('position: $position, ')
          ..write('foodId: $foodId, ')
          ..write('foodName: $foodName, ')
          ..write('measureLabel: $measureLabel, ')
          ..write('measureGrams: $measureGrams, ')
          ..write('quantity: $quantity, ')
          ..write('grams: $grams, ')
          ..write('kcal100: $kcal100, ')
          ..write('protein100: $protein100, ')
          ..write('carb100: $carb100, ')
          ..write('fat100: $fat100, ')
          ..write('fiber100: $fiber100, ')
          ..write('sodium100: $sodium100, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanItemsTable extends PlanItems
    with TableInfo<$PlanItemsTable, PlanItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MealType, String> meal =
      GeneratedColumn<String>(
        'meal',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MealType>($PlanItemsTable.$convertermeal);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id)',
    ),
  );
  static const VerificationMeta _measureLabelMeta = const VerificationMeta(
    'measureLabel',
  );
  @override
  late final GeneratedColumn<String> measureLabel = GeneratedColumn<String>(
    'measure_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measureGramsMeta = const VerificationMeta(
    'measureGrams',
  );
  @override
  late final GeneratedColumn<double> measureGrams = GeneratedColumn<double>(
    'measure_grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    meal,
    position,
    foodId,
    measureLabel,
    measureGrams,
    quantity,
    grams,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('measure_label')) {
      context.handle(
        _measureLabelMeta,
        measureLabel.isAcceptableOrUnknown(
          data['measure_label']!,
          _measureLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_measureLabelMeta);
    }
    if (data.containsKey('measure_grams')) {
      context.handle(
        _measureGramsMeta,
        measureGrams.isAcceptableOrUnknown(
          data['measure_grams']!,
          _measureGramsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_measureGramsMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      meal: $PlanItemsTable.$convertermeal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}meal'],
        )!,
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      measureLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measure_label'],
      )!,
      measureGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}measure_grams'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      )!,
    );
  }

  @override
  $PlanItemsTable createAlias(String alias) {
    return $PlanItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MealType, String, String> $convertermeal =
      const EnumNameConverter<MealType>(MealType.values);
}

class PlanItemRow extends DataClass implements Insertable<PlanItemRow> {
  final String id;
  final MealType meal;
  final int position;
  final String foodId;
  final String measureLabel;
  final double measureGrams;
  final double quantity;
  final double grams;
  const PlanItemRow({
    required this.id,
    required this.meal,
    required this.position,
    required this.foodId,
    required this.measureLabel,
    required this.measureGrams,
    required this.quantity,
    required this.grams,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['meal'] = Variable<String>(
        $PlanItemsTable.$convertermeal.toSql(meal),
      );
    }
    map['position'] = Variable<int>(position);
    map['food_id'] = Variable<String>(foodId);
    map['measure_label'] = Variable<String>(measureLabel);
    map['measure_grams'] = Variable<double>(measureGrams);
    map['quantity'] = Variable<double>(quantity);
    map['grams'] = Variable<double>(grams);
    return map;
  }

  PlanItemsCompanion toCompanion(bool nullToAbsent) {
    return PlanItemsCompanion(
      id: Value(id),
      meal: Value(meal),
      position: Value(position),
      foodId: Value(foodId),
      measureLabel: Value(measureLabel),
      measureGrams: Value(measureGrams),
      quantity: Value(quantity),
      grams: Value(grams),
    );
  }

  factory PlanItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanItemRow(
      id: serializer.fromJson<String>(json['id']),
      meal: $PlanItemsTable.$convertermeal.fromJson(
        serializer.fromJson<String>(json['meal']),
      ),
      position: serializer.fromJson<int>(json['position']),
      foodId: serializer.fromJson<String>(json['foodId']),
      measureLabel: serializer.fromJson<String>(json['measureLabel']),
      measureGrams: serializer.fromJson<double>(json['measureGrams']),
      quantity: serializer.fromJson<double>(json['quantity']),
      grams: serializer.fromJson<double>(json['grams']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'meal': serializer.toJson<String>(
        $PlanItemsTable.$convertermeal.toJson(meal),
      ),
      'position': serializer.toJson<int>(position),
      'foodId': serializer.toJson<String>(foodId),
      'measureLabel': serializer.toJson<String>(measureLabel),
      'measureGrams': serializer.toJson<double>(measureGrams),
      'quantity': serializer.toJson<double>(quantity),
      'grams': serializer.toJson<double>(grams),
    };
  }

  PlanItemRow copyWith({
    String? id,
    MealType? meal,
    int? position,
    String? foodId,
    String? measureLabel,
    double? measureGrams,
    double? quantity,
    double? grams,
  }) => PlanItemRow(
    id: id ?? this.id,
    meal: meal ?? this.meal,
    position: position ?? this.position,
    foodId: foodId ?? this.foodId,
    measureLabel: measureLabel ?? this.measureLabel,
    measureGrams: measureGrams ?? this.measureGrams,
    quantity: quantity ?? this.quantity,
    grams: grams ?? this.grams,
  );
  PlanItemRow copyWithCompanion(PlanItemsCompanion data) {
    return PlanItemRow(
      id: data.id.present ? data.id.value : this.id,
      meal: data.meal.present ? data.meal.value : this.meal,
      position: data.position.present ? data.position.value : this.position,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      measureLabel: data.measureLabel.present
          ? data.measureLabel.value
          : this.measureLabel,
      measureGrams: data.measureGrams.present
          ? data.measureGrams.value
          : this.measureGrams,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      grams: data.grams.present ? data.grams.value : this.grams,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanItemRow(')
          ..write('id: $id, ')
          ..write('meal: $meal, ')
          ..write('position: $position, ')
          ..write('foodId: $foodId, ')
          ..write('measureLabel: $measureLabel, ')
          ..write('measureGrams: $measureGrams, ')
          ..write('quantity: $quantity, ')
          ..write('grams: $grams')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    meal,
    position,
    foodId,
    measureLabel,
    measureGrams,
    quantity,
    grams,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanItemRow &&
          other.id == this.id &&
          other.meal == this.meal &&
          other.position == this.position &&
          other.foodId == this.foodId &&
          other.measureLabel == this.measureLabel &&
          other.measureGrams == this.measureGrams &&
          other.quantity == this.quantity &&
          other.grams == this.grams);
}

class PlanItemsCompanion extends UpdateCompanion<PlanItemRow> {
  final Value<String> id;
  final Value<MealType> meal;
  final Value<int> position;
  final Value<String> foodId;
  final Value<String> measureLabel;
  final Value<double> measureGrams;
  final Value<double> quantity;
  final Value<double> grams;
  final Value<int> rowid;
  const PlanItemsCompanion({
    this.id = const Value.absent(),
    this.meal = const Value.absent(),
    this.position = const Value.absent(),
    this.foodId = const Value.absent(),
    this.measureLabel = const Value.absent(),
    this.measureGrams = const Value.absent(),
    this.quantity = const Value.absent(),
    this.grams = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanItemsCompanion.insert({
    required String id,
    required MealType meal,
    required int position,
    required String foodId,
    required String measureLabel,
    required double measureGrams,
    required double quantity,
    required double grams,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       meal = Value(meal),
       position = Value(position),
       foodId = Value(foodId),
       measureLabel = Value(measureLabel),
       measureGrams = Value(measureGrams),
       quantity = Value(quantity),
       grams = Value(grams);
  static Insertable<PlanItemRow> custom({
    Expression<String>? id,
    Expression<String>? meal,
    Expression<int>? position,
    Expression<String>? foodId,
    Expression<String>? measureLabel,
    Expression<double>? measureGrams,
    Expression<double>? quantity,
    Expression<double>? grams,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (meal != null) 'meal': meal,
      if (position != null) 'position': position,
      if (foodId != null) 'food_id': foodId,
      if (measureLabel != null) 'measure_label': measureLabel,
      if (measureGrams != null) 'measure_grams': measureGrams,
      if (quantity != null) 'quantity': quantity,
      if (grams != null) 'grams': grams,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanItemsCompanion copyWith({
    Value<String>? id,
    Value<MealType>? meal,
    Value<int>? position,
    Value<String>? foodId,
    Value<String>? measureLabel,
    Value<double>? measureGrams,
    Value<double>? quantity,
    Value<double>? grams,
    Value<int>? rowid,
  }) {
    return PlanItemsCompanion(
      id: id ?? this.id,
      meal: meal ?? this.meal,
      position: position ?? this.position,
      foodId: foodId ?? this.foodId,
      measureLabel: measureLabel ?? this.measureLabel,
      measureGrams: measureGrams ?? this.measureGrams,
      quantity: quantity ?? this.quantity,
      grams: grams ?? this.grams,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (meal.present) {
      map['meal'] = Variable<String>(
        $PlanItemsTable.$convertermeal.toSql(meal.value),
      );
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (measureLabel.present) {
      map['measure_label'] = Variable<String>(measureLabel.value);
    }
    if (measureGrams.present) {
      map['measure_grams'] = Variable<double>(measureGrams.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanItemsCompanion(')
          ..write('id: $id, ')
          ..write('meal: $meal, ')
          ..write('position: $position, ')
          ..write('foodId: $foodId, ')
          ..write('measureLabel: $measureLabel, ')
          ..write('measureGrams: $measureGrams, ')
          ..write('quantity: $quantity, ')
          ..write('grams: $grams, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanChecksTable extends PlanChecks
    with TableInfo<$PlanChecksTable, PlanCheckRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanChecksTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($PlanChecksTable.$converterdate);
  @override
  late final GeneratedColumnWithTypeConverter<MealType, String> meal =
      GeneratedColumn<String>(
        'meal',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MealType>($PlanChecksTable.$convertermeal);
  @override
  late final GeneratedColumnWithTypeConverter<PlanCheckStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PlanCheckStatus>($PlanChecksTable.$converterstatus);
  static const VerificationMeta _checkedAtMeta = const VerificationMeta(
    'checkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
    'checked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [date, meal, status, checkedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_checks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanCheckRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('checked_at')) {
      context.handle(
        _checkedAtMeta,
        checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_checkedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date, meal};
  @override
  PlanCheckRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanCheckRow(
      date: $PlanChecksTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      meal: $PlanChecksTable.$convertermeal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}meal'],
        )!,
      ),
      status: $PlanChecksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      checkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_at'],
      )!,
    );
  }

  @override
  $PlanChecksTable createAlias(String alias) {
    return $PlanChecksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalDate, String, String> $converterdate =
      const LocalDateConverter();
  static JsonTypeConverter2<MealType, String, String> $convertermeal =
      const EnumNameConverter<MealType>(MealType.values);
  static JsonTypeConverter2<PlanCheckStatus, String, String> $converterstatus =
      const EnumNameConverter<PlanCheckStatus>(PlanCheckStatus.values);
}

class PlanCheckRow extends DataClass implements Insertable<PlanCheckRow> {
  final LocalDate date;
  final MealType meal;
  final PlanCheckStatus status;
  final DateTime checkedAt;
  const PlanCheckRow({
    required this.date,
    required this.meal,
    required this.status,
    required this.checkedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['date'] = Variable<String>(
        $PlanChecksTable.$converterdate.toSql(date),
      );
    }
    {
      map['meal'] = Variable<String>(
        $PlanChecksTable.$convertermeal.toSql(meal),
      );
    }
    {
      map['status'] = Variable<String>(
        $PlanChecksTable.$converterstatus.toSql(status),
      );
    }
    map['checked_at'] = Variable<DateTime>(checkedAt);
    return map;
  }

  PlanChecksCompanion toCompanion(bool nullToAbsent) {
    return PlanChecksCompanion(
      date: Value(date),
      meal: Value(meal),
      status: Value(status),
      checkedAt: Value(checkedAt),
    );
  }

  factory PlanCheckRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanCheckRow(
      date: $PlanChecksTable.$converterdate.fromJson(
        serializer.fromJson<String>(json['date']),
      ),
      meal: $PlanChecksTable.$convertermeal.fromJson(
        serializer.fromJson<String>(json['meal']),
      ),
      status: $PlanChecksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      checkedAt: serializer.fromJson<DateTime>(json['checkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(
        $PlanChecksTable.$converterdate.toJson(date),
      ),
      'meal': serializer.toJson<String>(
        $PlanChecksTable.$convertermeal.toJson(meal),
      ),
      'status': serializer.toJson<String>(
        $PlanChecksTable.$converterstatus.toJson(status),
      ),
      'checkedAt': serializer.toJson<DateTime>(checkedAt),
    };
  }

  PlanCheckRow copyWith({
    LocalDate? date,
    MealType? meal,
    PlanCheckStatus? status,
    DateTime? checkedAt,
  }) => PlanCheckRow(
    date: date ?? this.date,
    meal: meal ?? this.meal,
    status: status ?? this.status,
    checkedAt: checkedAt ?? this.checkedAt,
  );
  PlanCheckRow copyWithCompanion(PlanChecksCompanion data) {
    return PlanCheckRow(
      date: data.date.present ? data.date.value : this.date,
      meal: data.meal.present ? data.meal.value : this.meal,
      status: data.status.present ? data.status.value : this.status,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanCheckRow(')
          ..write('date: $date, ')
          ..write('meal: $meal, ')
          ..write('status: $status, ')
          ..write('checkedAt: $checkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, meal, status, checkedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanCheckRow &&
          other.date == this.date &&
          other.meal == this.meal &&
          other.status == this.status &&
          other.checkedAt == this.checkedAt);
}

class PlanChecksCompanion extends UpdateCompanion<PlanCheckRow> {
  final Value<LocalDate> date;
  final Value<MealType> meal;
  final Value<PlanCheckStatus> status;
  final Value<DateTime> checkedAt;
  final Value<int> rowid;
  const PlanChecksCompanion({
    this.date = const Value.absent(),
    this.meal = const Value.absent(),
    this.status = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanChecksCompanion.insert({
    required LocalDate date,
    required MealType meal,
    required PlanCheckStatus status,
    required DateTime checkedAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       meal = Value(meal),
       status = Value(status),
       checkedAt = Value(checkedAt);
  static Insertable<PlanCheckRow> custom({
    Expression<String>? date,
    Expression<String>? meal,
    Expression<String>? status,
    Expression<DateTime>? checkedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (meal != null) 'meal': meal,
      if (status != null) 'status': status,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanChecksCompanion copyWith({
    Value<LocalDate>? date,
    Value<MealType>? meal,
    Value<PlanCheckStatus>? status,
    Value<DateTime>? checkedAt,
    Value<int>? rowid,
  }) {
    return PlanChecksCompanion(
      date: date ?? this.date,
      meal: meal ?? this.meal,
      status: status ?? this.status,
      checkedAt: checkedAt ?? this.checkedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(
        $PlanChecksTable.$converterdate.toSql(date.value),
      );
    }
    if (meal.present) {
      map['meal'] = Variable<String>(
        $PlanChecksTable.$convertermeal.toSql(meal.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PlanChecksTable.$converterstatus.toSql(status.value),
      );
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanChecksCompanion(')
          ..write('date: $date, ')
          ..write('meal: $meal, ')
          ..write('status: $status, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTable extends BodyMeasurements
    with TableInfo<$BodyMeasurementsTable, BodyMeasurementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($BodyMeasurementsTable.$converterdate);
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waistCmMeta = const VerificationMeta(
    'waistCm',
  );
  @override
  late final GeneratedColumn<double> waistCm = GeneratedColumn<double>(
    'waist_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _neckCmMeta = const VerificationMeta('neckCm');
  @override
  late final GeneratedColumn<double> neckCm = GeneratedColumn<double>(
    'neck_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hipCmMeta = const VerificationMeta('hipCm');
  @override
  late final GeneratedColumn<double> hipCm = GeneratedColumn<double>(
    'hip_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    weightKg,
    waistCm,
    neckCm,
    hipCm,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyMeasurementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('waist_cm')) {
      context.handle(
        _waistCmMeta,
        waistCm.isAcceptableOrUnknown(data['waist_cm']!, _waistCmMeta),
      );
    }
    if (data.containsKey('neck_cm')) {
      context.handle(
        _neckCmMeta,
        neckCm.isAcceptableOrUnknown(data['neck_cm']!, _neckCmMeta),
      );
    }
    if (data.containsKey('hip_cm')) {
      context.handle(
        _hipCmMeta,
        hipCm.isAcceptableOrUnknown(data['hip_cm']!, _hipCmMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyMeasurementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: $BodyMeasurementsTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      waistCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}waist_cm'],
      ),
      neckCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}neck_cm'],
      ),
      hipCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hip_cm'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalDate, String, String> $converterdate =
      const LocalDateConverter();
}

class BodyMeasurementRow extends DataClass
    implements Insertable<BodyMeasurementRow> {
  final String id;
  final LocalDate date;
  final double? weightKg;
  final double? waistCm;
  final double? neckCm;
  final double? hipCm;
  final DateTime createdAt;
  const BodyMeasurementRow({
    required this.id,
    required this.date,
    this.weightKg,
    this.waistCm,
    this.neckCm,
    this.hipCm,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['date'] = Variable<String>(
        $BodyMeasurementsTable.$converterdate.toSql(date),
      );
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || waistCm != null) {
      map['waist_cm'] = Variable<double>(waistCm);
    }
    if (!nullToAbsent || neckCm != null) {
      map['neck_cm'] = Variable<double>(neckCm);
    }
    if (!nullToAbsent || hipCm != null) {
      map['hip_cm'] = Variable<double>(hipCm);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BodyMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      id: Value(id),
      date: Value(date),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      waistCm: waistCm == null && nullToAbsent
          ? const Value.absent()
          : Value(waistCm),
      neckCm: neckCm == null && nullToAbsent
          ? const Value.absent()
          : Value(neckCm),
      hipCm: hipCm == null && nullToAbsent
          ? const Value.absent()
          : Value(hipCm),
      createdAt: Value(createdAt),
    );
  }

  factory BodyMeasurementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurementRow(
      id: serializer.fromJson<String>(json['id']),
      date: $BodyMeasurementsTable.$converterdate.fromJson(
        serializer.fromJson<String>(json['date']),
      ),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      waistCm: serializer.fromJson<double?>(json['waistCm']),
      neckCm: serializer.fromJson<double?>(json['neckCm']),
      hipCm: serializer.fromJson<double?>(json['hipCm']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(
        $BodyMeasurementsTable.$converterdate.toJson(date),
      ),
      'weightKg': serializer.toJson<double?>(weightKg),
      'waistCm': serializer.toJson<double?>(waistCm),
      'neckCm': serializer.toJson<double?>(neckCm),
      'hipCm': serializer.toJson<double?>(hipCm),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BodyMeasurementRow copyWith({
    String? id,
    LocalDate? date,
    Value<double?> weightKg = const Value.absent(),
    Value<double?> waistCm = const Value.absent(),
    Value<double?> neckCm = const Value.absent(),
    Value<double?> hipCm = const Value.absent(),
    DateTime? createdAt,
  }) => BodyMeasurementRow(
    id: id ?? this.id,
    date: date ?? this.date,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    waistCm: waistCm.present ? waistCm.value : this.waistCm,
    neckCm: neckCm.present ? neckCm.value : this.neckCm,
    hipCm: hipCm.present ? hipCm.value : this.hipCm,
    createdAt: createdAt ?? this.createdAt,
  );
  BodyMeasurementRow copyWithCompanion(BodyMeasurementsCompanion data) {
    return BodyMeasurementRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      waistCm: data.waistCm.present ? data.waistCm.value : this.waistCm,
      neckCm: data.neckCm.present ? data.neckCm.value : this.neckCm,
      hipCm: data.hipCm.present ? data.hipCm.value : this.hipCm,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('waistCm: $waistCm, ')
          ..write('neckCm: $neckCm, ')
          ..write('hipCm: $hipCm, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, weightKg, waistCm, neckCm, hipCm, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurementRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.weightKg == this.weightKg &&
          other.waistCm == this.waistCm &&
          other.neckCm == this.neckCm &&
          other.hipCm == this.hipCm &&
          other.createdAt == this.createdAt);
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurementRow> {
  final Value<String> id;
  final Value<LocalDate> date;
  final Value<double?> weightKg;
  final Value<double?> waistCm;
  final Value<double?> neckCm;
  final Value<double?> hipCm;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BodyMeasurementsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.neckCm = const Value.absent(),
    this.hipCm = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    required String id,
    required LocalDate date,
    this.weightKg = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.neckCm = const Value.absent(),
    this.hipCm = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<BodyMeasurementRow> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<double>? weightKg,
    Expression<double>? waistCm,
    Expression<double>? neckCm,
    Expression<double>? hipCm,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
      if (waistCm != null) 'waist_cm': waistCm,
      if (neckCm != null) 'neck_cm': neckCm,
      if (hipCm != null) 'hip_cm': hipCm,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyMeasurementsCompanion copyWith({
    Value<String>? id,
    Value<LocalDate>? date,
    Value<double?>? weightKg,
    Value<double?>? waistCm,
    Value<double?>? neckCm,
    Value<double?>? hipCm,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BodyMeasurementsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      waistCm: waistCm ?? this.waistCm,
      neckCm: neckCm ?? this.neckCm,
      hipCm: hipCm ?? this.hipCm,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $BodyMeasurementsTable.$converterdate.toSql(date.value),
      );
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (waistCm.present) {
      map['waist_cm'] = Variable<double>(waistCm.value);
    }
    if (neckCm.present) {
      map['neck_cm'] = Variable<double>(neckCm.value);
    }
    if (hipCm.present) {
      map['hip_cm'] = Variable<double>(hipCm.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('waistCm: $waistCm, ')
          ..write('neckCm: $neckCm, ')
          ..write('hipCm: $hipCm, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> birthDate =
      GeneratedColumn<String>(
        'birth_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($ProfilesTable.$converterbirthDate);
  @override
  late final GeneratedColumnWithTypeConverter<Sex, String> sex =
      GeneratedColumn<String>(
        'sex',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Sex>($ProfilesTable.$convertersex);
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Goal, String> goal =
      GeneratedColumn<String>(
        'goal',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Goal>($ProfilesTable.$convertergoal);
  @override
  late final GeneratedColumnWithTypeConverter<ActivityLevel, String> activity =
      GeneratedColumn<String>(
        'activity',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ActivityLevel>($ProfilesTable.$converteractivity);
  static const VerificationMeta _manualKcalTargetMeta = const VerificationMeta(
    'manualKcalTarget',
  );
  @override
  late final GeneratedColumn<double> manualKcalTarget = GeneratedColumn<double>(
    'manual_kcal_target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    birthDate,
    sex,
    heightCm,
    goal,
    activity,
    manualKcalTarget,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('manual_kcal_target')) {
      context.handle(
        _manualKcalTargetMeta,
        manualKcalTarget.isAcceptableOrUnknown(
          data['manual_kcal_target']!,
          _manualKcalTargetMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      birthDate: $ProfilesTable.$converterbirthDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}birth_date'],
        )!,
      ),
      sex: $ProfilesTable.$convertersex.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sex'],
        )!,
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      goal: $ProfilesTable.$convertergoal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}goal'],
        )!,
      ),
      activity: $ProfilesTable.$converteractivity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}activity'],
        )!,
      ),
      manualKcalTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}manual_kcal_target'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalDate, String, String> $converterbirthDate =
      const LocalDateConverter();
  static JsonTypeConverter2<Sex, String, String> $convertersex =
      const EnumNameConverter<Sex>(Sex.values);
  static JsonTypeConverter2<Goal, String, String> $convertergoal =
      const EnumNameConverter<Goal>(Goal.values);
  static JsonTypeConverter2<ActivityLevel, String, String> $converteractivity =
      const EnumNameConverter<ActivityLevel>(ActivityLevel.values);
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final int id;
  final String name;
  final LocalDate birthDate;
  final Sex sex;
  final double heightCm;
  final Goal goal;
  final ActivityLevel activity;

  /// Meta calórica definida pelo usuário, que substitui a calculada.
  final double? manualKcalTarget;
  const ProfileRow({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.sex,
    required this.heightCm,
    required this.goal,
    required this.activity,
    this.manualKcalTarget,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['birth_date'] = Variable<String>(
        $ProfilesTable.$converterbirthDate.toSql(birthDate),
      );
    }
    {
      map['sex'] = Variable<String>($ProfilesTable.$convertersex.toSql(sex));
    }
    map['height_cm'] = Variable<double>(heightCm);
    {
      map['goal'] = Variable<String>($ProfilesTable.$convertergoal.toSql(goal));
    }
    {
      map['activity'] = Variable<String>(
        $ProfilesTable.$converteractivity.toSql(activity),
      );
    }
    if (!nullToAbsent || manualKcalTarget != null) {
      map['manual_kcal_target'] = Variable<double>(manualKcalTarget);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      name: Value(name),
      birthDate: Value(birthDate),
      sex: Value(sex),
      heightCm: Value(heightCm),
      goal: Value(goal),
      activity: Value(activity),
      manualKcalTarget: manualKcalTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(manualKcalTarget),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthDate: $ProfilesTable.$converterbirthDate.fromJson(
        serializer.fromJson<String>(json['birthDate']),
      ),
      sex: $ProfilesTable.$convertersex.fromJson(
        serializer.fromJson<String>(json['sex']),
      ),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      goal: $ProfilesTable.$convertergoal.fromJson(
        serializer.fromJson<String>(json['goal']),
      ),
      activity: $ProfilesTable.$converteractivity.fromJson(
        serializer.fromJson<String>(json['activity']),
      ),
      manualKcalTarget: serializer.fromJson<double?>(json['manualKcalTarget']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'birthDate': serializer.toJson<String>(
        $ProfilesTable.$converterbirthDate.toJson(birthDate),
      ),
      'sex': serializer.toJson<String>(
        $ProfilesTable.$convertersex.toJson(sex),
      ),
      'heightCm': serializer.toJson<double>(heightCm),
      'goal': serializer.toJson<String>(
        $ProfilesTable.$convertergoal.toJson(goal),
      ),
      'activity': serializer.toJson<String>(
        $ProfilesTable.$converteractivity.toJson(activity),
      ),
      'manualKcalTarget': serializer.toJson<double?>(manualKcalTarget),
    };
  }

  ProfileRow copyWith({
    int? id,
    String? name,
    LocalDate? birthDate,
    Sex? sex,
    double? heightCm,
    Goal? goal,
    ActivityLevel? activity,
    Value<double?> manualKcalTarget = const Value.absent(),
  }) => ProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    birthDate: birthDate ?? this.birthDate,
    sex: sex ?? this.sex,
    heightCm: heightCm ?? this.heightCm,
    goal: goal ?? this.goal,
    activity: activity ?? this.activity,
    manualKcalTarget: manualKcalTarget.present
        ? manualKcalTarget.value
        : this.manualKcalTarget,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      sex: data.sex.present ? data.sex.value : this.sex,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      goal: data.goal.present ? data.goal.value : this.goal,
      activity: data.activity.present ? data.activity.value : this.activity,
      manualKcalTarget: data.manualKcalTarget.present
          ? data.manualKcalTarget.value
          : this.manualKcalTarget,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('sex: $sex, ')
          ..write('heightCm: $heightCm, ')
          ..write('goal: $goal, ')
          ..write('activity: $activity, ')
          ..write('manualKcalTarget: $manualKcalTarget')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    birthDate,
    sex,
    heightCm,
    goal,
    activity,
    manualKcalTarget,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthDate == this.birthDate &&
          other.sex == this.sex &&
          other.heightCm == this.heightCm &&
          other.goal == this.goal &&
          other.activity == this.activity &&
          other.manualKcalTarget == this.manualKcalTarget);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<LocalDate> birthDate;
  final Value<Sex> sex;
  final Value<double> heightCm;
  final Value<Goal> goal;
  final Value<ActivityLevel> activity;
  final Value<double?> manualKcalTarget;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.sex = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.goal = const Value.absent(),
    this.activity = const Value.absent(),
    this.manualKcalTarget = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required LocalDate birthDate,
    required Sex sex,
    required double heightCm,
    required Goal goal,
    required ActivityLevel activity,
    this.manualKcalTarget = const Value.absent(),
  }) : name = Value(name),
       birthDate = Value(birthDate),
       sex = Value(sex),
       heightCm = Value(heightCm),
       goal = Value(goal),
       activity = Value(activity);
  static Insertable<ProfileRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? birthDate,
    Expression<String>? sex,
    Expression<double>? heightCm,
    Expression<String>? goal,
    Expression<String>? activity,
    Expression<double>? manualKcalTarget,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthDate != null) 'birth_date': birthDate,
      if (sex != null) 'sex': sex,
      if (heightCm != null) 'height_cm': heightCm,
      if (goal != null) 'goal': goal,
      if (activity != null) 'activity': activity,
      if (manualKcalTarget != null) 'manual_kcal_target': manualKcalTarget,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<LocalDate>? birthDate,
    Value<Sex>? sex,
    Value<double>? heightCm,
    Value<Goal>? goal,
    Value<ActivityLevel>? activity,
    Value<double?>? manualKcalTarget,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      goal: goal ?? this.goal,
      activity: activity ?? this.activity,
      manualKcalTarget: manualKcalTarget ?? this.manualKcalTarget,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(
        $ProfilesTable.$converterbirthDate.toSql(birthDate.value),
      );
    }
    if (sex.present) {
      map['sex'] = Variable<String>(
        $ProfilesTable.$convertersex.toSql(sex.value),
      );
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(
        $ProfilesTable.$convertergoal.toSql(goal.value),
      );
    }
    if (activity.present) {
      map['activity'] = Variable<String>(
        $ProfilesTable.$converteractivity.toSql(activity.value),
      );
    }
    if (manualKcalTarget.present) {
      map['manual_kcal_target'] = Variable<double>(manualKcalTarget.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('sex: $sex, ')
          ..write('heightCm: $heightCm, ')
          ..write('goal: $goal, ')
          ..write('activity: $activity, ')
          ..write('manualKcalTarget: $manualKcalTarget')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [foodId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {foodId};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  final String foodId;
  final DateTime createdAt;
  const FavoriteRow({required this.foodId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['food_id'] = Variable<String>(foodId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      foodId: Value(foodId),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      foodId: serializer.fromJson<String>(json['foodId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'foodId': serializer.toJson<String>(foodId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FavoriteRow copyWith({String? foodId, DateTime? createdAt}) => FavoriteRow(
    foodId: foodId ?? this.foodId,
    createdAt: createdAt ?? this.createdAt,
  );
  FavoriteRow copyWithCompanion(FavoritesCompanion data) {
    return FavoriteRow(
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('foodId: $foodId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(foodId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.foodId == this.foodId &&
          other.createdAt == this.createdAt);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<String> foodId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.foodId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String foodId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : foodId = Value(foodId),
       createdAt = Value(createdAt);
  static Insertable<FavoriteRow> custom({
    Expression<String>? foodId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (foodId != null) 'food_id': foodId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? foodId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      foodId: foodId ?? this.foodId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('foodId: $foodId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final FoodSearch foodSearch = FoodSearch(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final Trigger foodsSearchInsert = Trigger(
    'CREATE TRIGGER foods_search_insert AFTER INSERT ON foods BEGIN INSERT INTO food_search (food_id, body) VALUES (new.id, new.search_text);END',
    'foods_search_insert',
  );
  late final Trigger foodsSearchUpdate = Trigger(
    'CREATE TRIGGER foods_search_update AFTER UPDATE OF search_text ON foods BEGIN DELETE FROM food_search WHERE food_id = old.id;INSERT INTO food_search (food_id, body) VALUES (new.id, new.search_text);END',
    'foods_search_update',
  );
  late final Trigger foodsSearchDelete = Trigger(
    'CREATE TRIGGER foods_search_delete AFTER DELETE ON foods BEGIN DELETE FROM food_search WHERE food_id = old.id;END',
    'foods_search_delete',
  );
  late final $MeasuresTable measures = $MeasuresTable(this);
  late final $AssetVersionsTable assetVersions = $AssetVersionsTable(this);
  late final $DiaryItemsTable diaryItems = $DiaryItemsTable(this);
  late final $PlanItemsTable planItems = $PlanItemsTable(this);
  late final $PlanChecksTable planChecks = $PlanChecksTable(this);
  late final $BodyMeasurementsTable bodyMeasurements = $BodyMeasurementsTable(
    this,
  );
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index foodsBySource = Index(
    'foods_by_source',
    'CREATE INDEX foods_by_source ON foods (source, is_active)',
  );
  late final Index measuresByFood = Index(
    'measures_by_food',
    'CREATE INDEX measures_by_food ON measures (food_id)',
  );
  late final Index diaryItemsByDay = Index(
    'diary_items_by_day',
    'CREATE INDEX diary_items_by_day ON diary_items (date, meal, position)',
  );
  late final Index diaryItemsByFood = Index(
    'diary_items_by_food',
    'CREATE INDEX diary_items_by_food ON diary_items (food_id)',
  );
  late final Index planItemsByMeal = Index(
    'plan_items_by_meal',
    'CREATE INDEX plan_items_by_meal ON plan_items (meal, position)',
  );
  late final Index bodyMeasurementsByDate = Index(
    'body_measurements_by_date',
    'CREATE INDEX body_measurements_by_date ON body_measurements (date)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    foodSearch,
    foods,
    foodsSearchInsert,
    foodsSearchUpdate,
    foodsSearchDelete,
    measures,
    assetVersions,
    diaryItems,
    planItems,
    planChecks,
    bodyMeasurements,
    profiles,
    favorites,
    settings,
    foodsBySource,
    measuresByFood,
    diaryItemsByDay,
    diaryItemsByFood,
    planItemsByMeal,
    bodyMeasurementsByDate,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'foods',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('food_search', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'foods',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [
        TableUpdate('food_search', kind: UpdateKind.delete),
        TableUpdate('food_search', kind: UpdateKind.insert),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'foods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('food_search', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $FoodSearchCreateCompanionBuilder = FoodSearchCompanion Function({
  required String foodId,
  required String body,
  Value<int> rowid,
});
typedef $FoodSearchUpdateCompanionBuilder = FoodSearchCompanion Function({
  Value<String> foodId,
  Value<String> body,
  Value<int> rowid,
});

class $FoodSearchFilterComposer extends Composer<_$AppDatabase, FoodSearch> {
  $FoodSearchFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );
}

class $FoodSearchOrderingComposer extends Composer<_$AppDatabase, FoodSearch> {
  $FoodSearchOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );
}

class $FoodSearchAnnotationComposer
    extends Composer<_$AppDatabase, FoodSearch> {
  $FoodSearchAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
}

class $FoodSearchTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          FoodSearch,
          FoodSearchData,
          $FoodSearchFilterComposer,
          $FoodSearchOrderingComposer,
          $FoodSearchAnnotationComposer,
          $FoodSearchCreateCompanionBuilder,
          $FoodSearchUpdateCompanionBuilder,
          (
            FoodSearchData,
            BaseReferences<_$AppDatabase, FoodSearch, FoodSearchData>,
          ),
          FoodSearchData,
          PrefetchHooks Function()
        > {
  $FoodSearchTableManager(_$AppDatabase db, FoodSearch table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FoodSearchFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FoodSearchOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FoodSearchAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> foodId = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => FoodSearchCompanion(foodId: foodId, body: body, rowid: rowid),
          createCompanionCallback:
              ({
                required String foodId,
                required String body,
                Value<int> rowid = const Value.absent(),
              }) => FoodSearchCompanion.insert(
                foodId: foodId,
                body: body,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<FoodSearch, FoodSearchData>(table),
                  BaseReferences<_$AppDatabase, FoodSearch, FoodSearchData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $FoodSearchProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      FoodSearch,
      FoodSearchData,
      $FoodSearchFilterComposer,
      $FoodSearchOrderingComposer,
      $FoodSearchAnnotationComposer,
      $FoodSearchCreateCompanionBuilder,
      $FoodSearchUpdateCompanionBuilder,
      (
        FoodSearchData,
        BaseReferences<_$AppDatabase, FoodSearch, FoodSearchData>,
      ),
      FoodSearchData,
      PrefetchHooks Function()
    >;
typedef $$FoodsTableCreateCompanionBuilder = FoodsCompanion Function({
  required String id,
  required FoodSource source,
  Value<int?> tacoNumber,
  required String name,
  required String searchText,
  Value<String?> category,
  Value<double?> kcal,
  Value<double?> protein,
  Value<double?> carb,
  Value<double?> fat,
  Value<double?> fiber,
  Value<double?> sodium,
  Value<String?> nutrientsJson,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$FoodsTableUpdateCompanionBuilder = FoodsCompanion Function({
  Value<String> id,
  Value<FoodSource> source,
  Value<int?> tacoNumber,
  Value<String> name,
  Value<String> searchText,
  Value<String?> category,
  Value<double?> kcal,
  Value<double?> protein,
  Value<double?> carb,
  Value<double?> fat,
  Value<double?> fiber,
  Value<double?> sodium,
  Value<String?> nutrientsJson,
  Value<bool> isActive,
  Value<int> rowid,
});

final class $$FoodsTableReferences
    extends BaseReferences<_$AppDatabase, $FoodsTable, FoodRow> {
  $$FoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MeasuresTable, List<MeasureRow>>
  _measuresRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.measures,
    aliasName: 'foods__id__measures__food_id',
  );

  $$MeasuresTableProcessedTableManager get measuresRefs {
    final manager = $$MeasuresTableTableManager(
      $_db,
      $_db.measures,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_measuresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlanItemsTable, List<PlanItemRow>>
  _planItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planItems,
    aliasName: 'foods__id__plan_items__food_id',
  );

  $$PlanItemsTableProcessedTableManager get planItemsRefs {
    final manager = $$PlanItemsTableTableManager(
      $_db,
      $_db.planItems,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_planItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FavoritesTable, List<FavoriteRow>>
  _favoritesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.favorites,
    aliasName: 'foods__id__favorites__food_id',
  );

  $$FavoritesTableProcessedTableManager get favoritesRefs {
    final manager = $$FavoritesTableTableManager(
      $_db,
      $_db.favorites,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_favoritesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoodsTableFilterComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<FoodSource, FoodSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get tacoNumber => $composableBuilder(
    column: $table.tacoNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carb => $composableBuilder(
    column: $table.carb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nutrientsJson => $composableBuilder(
    column: $table.nutrientsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> measuresRefs(
    Expression<bool> Function($$MeasuresTableFilterComposer f) f,
  ) {
    final $$MeasuresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measures,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasuresTableFilterComposer(
            $db: $db,
            $table: $db.measures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> planItemsRefs(
    Expression<bool> Function($$PlanItemsTableFilterComposer f) f,
  ) {
    final $$PlanItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableFilterComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> favoritesRefs(
    Expression<bool> Function($$FavoritesTableFilterComposer f) f,
  ) {
    final $$FavoritesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.favorites,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FavoritesTableFilterComposer(
            $db: $db,
            $table: $db.favorites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableOrderingComposer({
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

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tacoNumber => $composableBuilder(
    column: $table.tacoNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carb => $composableBuilder(
    column: $table.carb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nutrientsJson => $composableBuilder(
    column: $table.nutrientsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FoodSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get tacoNumber => $composableBuilder(
    column: $table.tacoNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carb =>
      $composableBuilder(column: $table.carb, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<double> get sodium =>
      $composableBuilder(column: $table.sodium, builder: (column) => column);

  GeneratedColumn<String> get nutrientsJson => $composableBuilder(
    column: $table.nutrientsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> measuresRefs<T extends Object>(
    Expression<T> Function($$MeasuresTableAnnotationComposer a) f,
  ) {
    final $$MeasuresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measures,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasuresTableAnnotationComposer(
            $db: $db,
            $table: $db.measures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> planItemsRefs<T extends Object>(
    Expression<T> Function($$PlanItemsTableAnnotationComposer a) f,
  ) {
    final $$PlanItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> favoritesRefs<T extends Object>(
    Expression<T> Function($$FavoritesTableAnnotationComposer a) f,
  ) {
    final $$FavoritesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.favorites,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FavoritesTableAnnotationComposer(
            $db: $db,
            $table: $db.favorites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodsTable,
          FoodRow,
          $$FoodsTableFilterComposer,
          $$FoodsTableOrderingComposer,
          $$FoodsTableAnnotationComposer,
          $$FoodsTableCreateCompanionBuilder,
          $$FoodsTableUpdateCompanionBuilder,
          (FoodRow, $$FoodsTableReferences),
          FoodRow,
          PrefetchHooks Function({
            bool measuresRefs,
            bool planItemsRefs,
            bool favoritesRefs,
          })
        > {
  $$FoodsTableTableManager(_$AppDatabase db, $FoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<FoodSource> source = const Value.absent(),
                Value<int?> tacoNumber = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carb = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> fiber = const Value.absent(),
                Value<double?> sodium = const Value.absent(),
                Value<String?> nutrientsJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodsCompanion(
                id: id,
                source: source,
                tacoNumber: tacoNumber,
                name: name,
                searchText: searchText,
                category: category,
                kcal: kcal,
                protein: protein,
                carb: carb,
                fat: fat,
                fiber: fiber,
                sodium: sodium,
                nutrientsJson: nutrientsJson,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required FoodSource source,
                Value<int?> tacoNumber = const Value.absent(),
                required String name,
                required String searchText,
                Value<String?> category = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carb = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> fiber = const Value.absent(),
                Value<double?> sodium = const Value.absent(),
                Value<String?> nutrientsJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodsCompanion.insert(
                id: id,
                source: source,
                tacoNumber: tacoNumber,
                name: name,
                searchText: searchText,
                category: category,
                kcal: kcal,
                protein: protein,
                carb: carb,
                fat: fat,
                fiber: fiber,
                sodium: sodium,
                nutrientsJson: nutrientsJson,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodsTable, FoodRow>(table),
                  $$FoodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                measuresRefs = false,
                planItemsRefs = false,
                favoritesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (measuresRefs) db.measures,
                    if (planItemsRefs) db.planItems,
                    if (favoritesRefs) db.favorites,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (measuresRefs)
                        await $_getPrefetchedData<
                          FoodRow,
                          $FoodsTable,
                          MeasureRow
                        >(
                          currentTable: table,
                          referencedTable: $$FoodsTableReferences
                              ._measuresRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).measuresRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.foodId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (planItemsRefs)
                        await $_getPrefetchedData<
                          FoodRow,
                          $FoodsTable,
                          PlanItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$FoodsTableReferences
                              ._planItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).planItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.foodId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (favoritesRefs)
                        await $_getPrefetchedData<
                          FoodRow,
                          $FoodsTable,
                          FavoriteRow
                        >(
                          currentTable: table,
                          referencedTable: $$FoodsTableReferences
                              ._favoritesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).favoritesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.foodId == item.id,
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

typedef $$FoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodsTable,
      FoodRow,
      $$FoodsTableFilterComposer,
      $$FoodsTableOrderingComposer,
      $$FoodsTableAnnotationComposer,
      $$FoodsTableCreateCompanionBuilder,
      $$FoodsTableUpdateCompanionBuilder,
      (FoodRow, $$FoodsTableReferences),
      FoodRow,
      PrefetchHooks Function({
        bool measuresRefs,
        bool planItemsRefs,
        bool favoritesRefs,
      })
    >;
typedef $$MeasuresTableCreateCompanionBuilder = MeasuresCompanion Function({
  required String id,
  required String foodId,
  required MeasureSource source,
  required String label,
  required double grams,
  Value<String?> reference,
  Value<int> sortOrder,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$MeasuresTableUpdateCompanionBuilder = MeasuresCompanion Function({
  Value<String> id,
  Value<String> foodId,
  Value<MeasureSource> source,
  Value<String> label,
  Value<double> grams,
  Value<String?> reference,
  Value<int> sortOrder,
  Value<bool> isActive,
  Value<int> rowid,
});

final class $$MeasuresTableReferences
    extends BaseReferences<_$AppDatabase, $MeasuresTable, MeasureRow> {
  $$MeasuresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoodsTable _foodIdTable(_$AppDatabase db) =>
      db.foods.createAlias('measures__food_id__foods__id');

  $$FoodsTableProcessedTableManager get foodId {
    final $_column = $_itemColumn<String>('food_id')!;

    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MeasuresTableFilterComposer
    extends Composer<_$AppDatabase, $MeasuresTable> {
  $$MeasuresTableFilterComposer({
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

  ColumnWithTypeConverterFilters<MeasureSource, MeasureSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasuresTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasuresTable> {
  $$MeasuresTableOrderingComposer({
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

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasuresTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasuresTable> {
  $$MeasuresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MeasureSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$FoodsTableAnnotationComposer get foodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasuresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasuresTable,
          MeasureRow,
          $$MeasuresTableFilterComposer,
          $$MeasuresTableOrderingComposer,
          $$MeasuresTableAnnotationComposer,
          $$MeasuresTableCreateCompanionBuilder,
          $$MeasuresTableUpdateCompanionBuilder,
          (MeasureRow, $$MeasuresTableReferences),
          MeasureRow,
          PrefetchHooks Function({bool foodId})
        > {
  $$MeasuresTableTableManager(_$AppDatabase db, $MeasuresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasuresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasuresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasuresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> foodId = const Value.absent(),
                Value<MeasureSource> source = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasuresCompanion(
                id: id,
                foodId: foodId,
                source: source,
                label: label,
                grams: grams,
                reference: reference,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String foodId,
                required MeasureSource source,
                required String label,
                required double grams,
                Value<String?> reference = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasuresCompanion.insert(
                id: id,
                foodId: foodId,
                source: source,
                label: label,
                grams: grams,
                reference: reference,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasuresTable, MeasureRow>(table),
                  $$MeasuresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({foodId = false}) {
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
                    if (foodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.foodId,
                        referencedTable: $$MeasuresTableReferences._foodIdTable(
                          db,
                        ),
                        referencedColumn: $$MeasuresTableReferences
                            ._foodIdTable(db)
                            .id,
                      ) as T;
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

typedef $$MeasuresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasuresTable,
      MeasureRow,
      $$MeasuresTableFilterComposer,
      $$MeasuresTableOrderingComposer,
      $$MeasuresTableAnnotationComposer,
      $$MeasuresTableCreateCompanionBuilder,
      $$MeasuresTableUpdateCompanionBuilder,
      (MeasureRow, $$MeasuresTableReferences),
      MeasureRow,
      PrefetchHooks Function({bool foodId})
    >;
typedef $$AssetVersionsTableCreateCompanionBuilder =
    AssetVersionsCompanion Function({
      required String asset,
      required String version,
      required int itemCount,
      required DateTime importedAt,
      Value<int> rowid,
    });
typedef $$AssetVersionsTableUpdateCompanionBuilder =
    AssetVersionsCompanion Function({
      Value<String> asset,
      Value<String> version,
      Value<int> itemCount,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });

class $$AssetVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetVersionsTable> {
  $$AssetVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get asset => $composableBuilder(
    column: $table.asset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssetVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetVersionsTable> {
  $$AssetVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get asset => $composableBuilder(
    column: $table.asset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetVersionsTable> {
  $$AssetVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get asset =>
      $composableBuilder(column: $table.asset, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );
}

class $$AssetVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetVersionsTable,
          AssetVersionRow,
          $$AssetVersionsTableFilterComposer,
          $$AssetVersionsTableOrderingComposer,
          $$AssetVersionsTableAnnotationComposer,
          $$AssetVersionsTableCreateCompanionBuilder,
          $$AssetVersionsTableUpdateCompanionBuilder,
          (
            AssetVersionRow,
            BaseReferences<_$AppDatabase, $AssetVersionsTable, AssetVersionRow>,
          ),
          AssetVersionRow,
          PrefetchHooks Function()
        > {
  $$AssetVersionsTableTableManager(_$AppDatabase db, $AssetVersionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> asset = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetVersionsCompanion(
                asset: asset,
                version: version,
                itemCount: itemCount,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String asset,
                required String version,
                required int itemCount,
                required DateTime importedAt,
                Value<int> rowid = const Value.absent(),
              }) => AssetVersionsCompanion.insert(
                asset: asset,
                version: version,
                itemCount: itemCount,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetVersionsTable, AssetVersionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AssetVersionsTable,
                    AssetVersionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssetVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetVersionsTable,
      AssetVersionRow,
      $$AssetVersionsTableFilterComposer,
      $$AssetVersionsTableOrderingComposer,
      $$AssetVersionsTableAnnotationComposer,
      $$AssetVersionsTableCreateCompanionBuilder,
      $$AssetVersionsTableUpdateCompanionBuilder,
      (
        AssetVersionRow,
        BaseReferences<_$AppDatabase, $AssetVersionsTable, AssetVersionRow>,
      ),
      AssetVersionRow,
      PrefetchHooks Function()
    >;
typedef $$DiaryItemsTableCreateCompanionBuilder = DiaryItemsCompanion Function({
  required String id,
  required LocalDate date,
  required MealType meal,
  required int position,
  Value<String?> foodId,
  required String foodName,
  required String measureLabel,
  required double measureGrams,
  required double quantity,
  required double grams,
  required double kcal100,
  required double protein100,
  required double carb100,
  required double fat100,
  required double fiber100,
  required double sodium100,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$DiaryItemsTableUpdateCompanionBuilder = DiaryItemsCompanion Function({
  Value<String> id,
  Value<LocalDate> date,
  Value<MealType> meal,
  Value<int> position,
  Value<String?> foodId,
  Value<String> foodName,
  Value<String> measureLabel,
  Value<double> measureGrams,
  Value<double> quantity,
  Value<double> grams,
  Value<double> kcal100,
  Value<double> protein100,
  Value<double> carb100,
  Value<double> fat100,
  Value<double> fiber100,
  Value<double> sodium100,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$DiaryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $DiaryItemsTable> {
  $$DiaryItemsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<MealType, MealType, String> get meal =>
      $composableBuilder(
        column: $table.meal,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measureLabel => $composableBuilder(
    column: $table.measureLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get measureGrams => $composableBuilder(
    column: $table.measureGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal100 => $composableBuilder(
    column: $table.kcal100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein100 => $composableBuilder(
    column: $table.protein100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carb100 => $composableBuilder(
    column: $table.carb100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat100 => $composableBuilder(
    column: $table.fat100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiber100 => $composableBuilder(
    column: $table.fiber100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sodium100 => $composableBuilder(
    column: $table.sodium100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiaryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $DiaryItemsTable> {
  $$DiaryItemsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measureLabel => $composableBuilder(
    column: $table.measureLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get measureGrams => $composableBuilder(
    column: $table.measureGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal100 => $composableBuilder(
    column: $table.kcal100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein100 => $composableBuilder(
    column: $table.protein100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carb100 => $composableBuilder(
    column: $table.carb100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat100 => $composableBuilder(
    column: $table.fat100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiber100 => $composableBuilder(
    column: $table.fiber100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sodium100 => $composableBuilder(
    column: $table.sodium100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiaryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiaryItemsTable> {
  $$DiaryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MealType, String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<String> get measureLabel => $composableBuilder(
    column: $table.measureLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get measureGrams => $composableBuilder(
    column: $table.measureGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get kcal100 =>
      $composableBuilder(column: $table.kcal100, builder: (column) => column);

  GeneratedColumn<double> get protein100 => $composableBuilder(
    column: $table.protein100,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carb100 =>
      $composableBuilder(column: $table.carb100, builder: (column) => column);

  GeneratedColumn<double> get fat100 =>
      $composableBuilder(column: $table.fat100, builder: (column) => column);

  GeneratedColumn<double> get fiber100 =>
      $composableBuilder(column: $table.fiber100, builder: (column) => column);

  GeneratedColumn<double> get sodium100 =>
      $composableBuilder(column: $table.sodium100, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DiaryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiaryItemsTable,
          DiaryItemRow,
          $$DiaryItemsTableFilterComposer,
          $$DiaryItemsTableOrderingComposer,
          $$DiaryItemsTableAnnotationComposer,
          $$DiaryItemsTableCreateCompanionBuilder,
          $$DiaryItemsTableUpdateCompanionBuilder,
          (
            DiaryItemRow,
            BaseReferences<_$AppDatabase, $DiaryItemsTable, DiaryItemRow>,
          ),
          DiaryItemRow,
          PrefetchHooks Function()
        > {
  $$DiaryItemsTableTableManager(_$AppDatabase db, $DiaryItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<LocalDate> date = const Value.absent(),
                Value<MealType> meal = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> foodId = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<String> measureLabel = const Value.absent(),
                Value<double> measureGrams = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<double> kcal100 = const Value.absent(),
                Value<double> protein100 = const Value.absent(),
                Value<double> carb100 = const Value.absent(),
                Value<double> fat100 = const Value.absent(),
                Value<double> fiber100 = const Value.absent(),
                Value<double> sodium100 = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiaryItemsCompanion(
                id: id,
                date: date,
                meal: meal,
                position: position,
                foodId: foodId,
                foodName: foodName,
                measureLabel: measureLabel,
                measureGrams: measureGrams,
                quantity: quantity,
                grams: grams,
                kcal100: kcal100,
                protein100: protein100,
                carb100: carb100,
                fat100: fat100,
                fiber100: fiber100,
                sodium100: sodium100,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required LocalDate date,
                required MealType meal,
                required int position,
                Value<String?> foodId = const Value.absent(),
                required String foodName,
                required String measureLabel,
                required double measureGrams,
                required double quantity,
                required double grams,
                required double kcal100,
                required double protein100,
                required double carb100,
                required double fat100,
                required double fiber100,
                required double sodium100,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DiaryItemsCompanion.insert(
                id: id,
                date: date,
                meal: meal,
                position: position,
                foodId: foodId,
                foodName: foodName,
                measureLabel: measureLabel,
                measureGrams: measureGrams,
                quantity: quantity,
                grams: grams,
                kcal100: kcal100,
                protein100: protein100,
                carb100: carb100,
                fat100: fat100,
                fiber100: fiber100,
                sodium100: sodium100,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DiaryItemsTable, DiaryItemRow>(table),
                  BaseReferences<_$AppDatabase, $DiaryItemsTable, DiaryItemRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiaryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiaryItemsTable,
      DiaryItemRow,
      $$DiaryItemsTableFilterComposer,
      $$DiaryItemsTableOrderingComposer,
      $$DiaryItemsTableAnnotationComposer,
      $$DiaryItemsTableCreateCompanionBuilder,
      $$DiaryItemsTableUpdateCompanionBuilder,
      (
        DiaryItemRow,
        BaseReferences<_$AppDatabase, $DiaryItemsTable, DiaryItemRow>,
      ),
      DiaryItemRow,
      PrefetchHooks Function()
    >;
typedef $$PlanItemsTableCreateCompanionBuilder = PlanItemsCompanion Function({
  required String id,
  required MealType meal,
  required int position,
  required String foodId,
  required String measureLabel,
  required double measureGrams,
  required double quantity,
  required double grams,
  Value<int> rowid,
});
typedef $$PlanItemsTableUpdateCompanionBuilder = PlanItemsCompanion Function({
  Value<String> id,
  Value<MealType> meal,
  Value<int> position,
  Value<String> foodId,
  Value<String> measureLabel,
  Value<double> measureGrams,
  Value<double> quantity,
  Value<double> grams,
  Value<int> rowid,
});

final class $$PlanItemsTableReferences
    extends BaseReferences<_$AppDatabase, $PlanItemsTable, PlanItemRow> {
  $$PlanItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoodsTable _foodIdTable(_$AppDatabase db) =>
      db.foods.createAlias('plan_items__food_id__foods__id');

  $$FoodsTableProcessedTableManager get foodId {
    final $_column = $_itemColumn<String>('food_id')!;

    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlanItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<MealType, MealType, String> get meal =>
      $composableBuilder(
        column: $table.meal,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measureLabel => $composableBuilder(
    column: $table.measureLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get measureGrams => $composableBuilder(
    column: $table.measureGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableOrderingComposer({
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

  ColumnOrderings<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measureLabel => $composableBuilder(
    column: $table.measureLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get measureGrams => $composableBuilder(
    column: $table.measureGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MealType, String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get measureLabel => $composableBuilder(
    column: $table.measureLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get measureGrams => $composableBuilder(
    column: $table.measureGrams,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  $$FoodsTableAnnotationComposer get foodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanItemsTable,
          PlanItemRow,
          $$PlanItemsTableFilterComposer,
          $$PlanItemsTableOrderingComposer,
          $$PlanItemsTableAnnotationComposer,
          $$PlanItemsTableCreateCompanionBuilder,
          $$PlanItemsTableUpdateCompanionBuilder,
          (PlanItemRow, $$PlanItemsTableReferences),
          PlanItemRow,
          PrefetchHooks Function({bool foodId})
        > {
  $$PlanItemsTableTableManager(_$AppDatabase db, $PlanItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<MealType> meal = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> foodId = const Value.absent(),
                Value<String> measureLabel = const Value.absent(),
                Value<double> measureGrams = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> grams = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanItemsCompanion(
                id: id,
                meal: meal,
                position: position,
                foodId: foodId,
                measureLabel: measureLabel,
                measureGrams: measureGrams,
                quantity: quantity,
                grams: grams,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required MealType meal,
                required int position,
                required String foodId,
                required String measureLabel,
                required double measureGrams,
                required double quantity,
                required double grams,
                Value<int> rowid = const Value.absent(),
              }) => PlanItemsCompanion.insert(
                id: id,
                meal: meal,
                position: position,
                foodId: foodId,
                measureLabel: measureLabel,
                measureGrams: measureGrams,
                quantity: quantity,
                grams: grams,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanItemsTable, PlanItemRow>(table),
                  $$PlanItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({foodId = false}) {
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
                    if (foodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.foodId,
                        referencedTable: $$PlanItemsTableReferences
                            ._foodIdTable(db),
                        referencedColumn: $$PlanItemsTableReferences
                            ._foodIdTable(db)
                            .id,
                      ) as T;
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

typedef $$PlanItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanItemsTable,
      PlanItemRow,
      $$PlanItemsTableFilterComposer,
      $$PlanItemsTableOrderingComposer,
      $$PlanItemsTableAnnotationComposer,
      $$PlanItemsTableCreateCompanionBuilder,
      $$PlanItemsTableUpdateCompanionBuilder,
      (PlanItemRow, $$PlanItemsTableReferences),
      PlanItemRow,
      PrefetchHooks Function({bool foodId})
    >;
typedef $$PlanChecksTableCreateCompanionBuilder = PlanChecksCompanion Function({
  required LocalDate date,
  required MealType meal,
  required PlanCheckStatus status,
  required DateTime checkedAt,
  Value<int> rowid,
});
typedef $$PlanChecksTableUpdateCompanionBuilder = PlanChecksCompanion Function({
  Value<LocalDate> date,
  Value<MealType> meal,
  Value<PlanCheckStatus> status,
  Value<DateTime> checkedAt,
  Value<int> rowid,
});

class $$PlanChecksTableFilterComposer
    extends Composer<_$AppDatabase, $PlanChecksTable> {
  $$PlanChecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<MealType, MealType, String> get meal =>
      $composableBuilder(
        column: $table.meal,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PlanCheckStatus, PlanCheckStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanChecksTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanChecksTable> {
  $$PlanChecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanChecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanChecksTable> {
  $$PlanChecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<LocalDate, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MealType, String> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PlanCheckStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);
}

class $$PlanChecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanChecksTable,
          PlanCheckRow,
          $$PlanChecksTableFilterComposer,
          $$PlanChecksTableOrderingComposer,
          $$PlanChecksTableAnnotationComposer,
          $$PlanChecksTableCreateCompanionBuilder,
          $$PlanChecksTableUpdateCompanionBuilder,
          (
            PlanCheckRow,
            BaseReferences<_$AppDatabase, $PlanChecksTable, PlanCheckRow>,
          ),
          PlanCheckRow,
          PrefetchHooks Function()
        > {
  $$PlanChecksTableTableManager(_$AppDatabase db, $PlanChecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanChecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanChecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanChecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<LocalDate> date = const Value.absent(),
                Value<MealType> meal = const Value.absent(),
                Value<PlanCheckStatus> status = const Value.absent(),
                Value<DateTime> checkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanChecksCompanion(
                date: date,
                meal: meal,
                status: status,
                checkedAt: checkedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required LocalDate date,
                required MealType meal,
                required PlanCheckStatus status,
                required DateTime checkedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlanChecksCompanion.insert(
                date: date,
                meal: meal,
                status: status,
                checkedAt: checkedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanChecksTable, PlanCheckRow>(table),
                  BaseReferences<_$AppDatabase, $PlanChecksTable, PlanCheckRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanChecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanChecksTable,
      PlanCheckRow,
      $$PlanChecksTableFilterComposer,
      $$PlanChecksTableOrderingComposer,
      $$PlanChecksTableAnnotationComposer,
      $$PlanChecksTableCreateCompanionBuilder,
      $$PlanChecksTableUpdateCompanionBuilder,
      (
        PlanCheckRow,
        BaseReferences<_$AppDatabase, $PlanChecksTable, PlanCheckRow>,
      ),
      PlanCheckRow,
      PrefetchHooks Function()
    >;
typedef $$BodyMeasurementsTableCreateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      required String id,
      required LocalDate date,
      Value<double?> weightKg,
      Value<double?> waistCm,
      Value<double?> neckCm,
      Value<double?> hipCm,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BodyMeasurementsTableUpdateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      Value<String> id,
      Value<LocalDate> date,
      Value<double?> weightKg,
      Value<double?> waistCm,
      Value<double?> neckCm,
      Value<double?> hipCm,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BodyMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get neckCm => $composableBuilder(
    column: $table.neckCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hipCm => $composableBuilder(
    column: $table.hipCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get neckCm => $composableBuilder(
    column: $table.neckCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hipCm => $composableBuilder(
    column: $table.hipCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get waistCm =>
      $composableBuilder(column: $table.waistCm, builder: (column) => column);

  GeneratedColumn<double> get neckCm =>
      $composableBuilder(column: $table.neckCm, builder: (column) => column);

  GeneratedColumn<double> get hipCm =>
      $composableBuilder(column: $table.hipCm, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BodyMeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyMeasurementsTable,
          BodyMeasurementRow,
          $$BodyMeasurementsTableFilterComposer,
          $$BodyMeasurementsTableOrderingComposer,
          $$BodyMeasurementsTableAnnotationComposer,
          $$BodyMeasurementsTableCreateCompanionBuilder,
          $$BodyMeasurementsTableUpdateCompanionBuilder,
          (
            BodyMeasurementRow,
            BaseReferences<
              _$AppDatabase,
              $BodyMeasurementsTable,
              BodyMeasurementRow
            >,
          ),
          BodyMeasurementRow,
          PrefetchHooks Function()
        > {
  $$BodyMeasurementsTableTableManager(
    _$AppDatabase db,
    $BodyMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<LocalDate> date = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> neckCm = const Value.absent(),
                Value<double?> hipCm = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion(
                id: id,
                date: date,
                weightKg: weightKg,
                waistCm: waistCm,
                neckCm: neckCm,
                hipCm: hipCm,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required LocalDate date,
                Value<double?> weightKg = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> neckCm = const Value.absent(),
                Value<double?> hipCm = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion.insert(
                id: id,
                date: date,
                weightKg: weightKg,
                waistCm: waistCm,
                neckCm: neckCm,
                hipCm: hipCm,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BodyMeasurementsTable, BodyMeasurementRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $BodyMeasurementsTable,
                    BodyMeasurementRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyMeasurementsTable,
      BodyMeasurementRow,
      $$BodyMeasurementsTableFilterComposer,
      $$BodyMeasurementsTableOrderingComposer,
      $$BodyMeasurementsTableAnnotationComposer,
      $$BodyMeasurementsTableCreateCompanionBuilder,
      $$BodyMeasurementsTableUpdateCompanionBuilder,
      (
        BodyMeasurementRow,
        BaseReferences<
          _$AppDatabase,
          $BodyMeasurementsTable,
          BodyMeasurementRow
        >,
      ),
      BodyMeasurementRow,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required String name,
  required LocalDate birthDate,
  required Sex sex,
  required double heightCm,
  required Goal goal,
  required ActivityLevel activity,
  Value<double?> manualKcalTarget,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<LocalDate> birthDate,
  Value<Sex> sex,
  Value<double> heightCm,
  Value<Goal> goal,
  Value<ActivityLevel> activity,
  Value<double?> manualKcalTarget,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get birthDate =>
      $composableBuilder(
        column: $table.birthDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Sex, Sex, String> get sex =>
      $composableBuilder(
        column: $table.sex,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Goal, Goal, String> get goal =>
      $composableBuilder(
        column: $table.goal,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ActivityLevel, ActivityLevel, String>
  get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get manualKcalTarget => $composableBuilder(
    column: $table.manualKcalTarget,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get manualKcalTarget => $composableBuilder(
    column: $table.manualKcalTarget,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Sex, String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Goal, String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityLevel, String> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumn<double> get manualKcalTarget => $composableBuilder(
    column: $table.manualKcalTarget,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<LocalDate> birthDate = const Value.absent(),
                Value<Sex> sex = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<Goal> goal = const Value.absent(),
                Value<ActivityLevel> activity = const Value.absent(),
                Value<double?> manualKcalTarget = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                name: name,
                birthDate: birthDate,
                sex: sex,
                heightCm: heightCm,
                goal: goal,
                activity: activity,
                manualKcalTarget: manualKcalTarget,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required LocalDate birthDate,
                required Sex sex,
                required double heightCm,
                required Goal goal,
                required ActivityLevel activity,
                Value<double?> manualKcalTarget = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                name: name,
                birthDate: birthDate,
                sex: sex,
                heightCm: heightCm,
                goal: goal,
                activity: activity,
                manualKcalTarget: manualKcalTarget,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, ProfileRow>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String foodId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> foodId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$FavoritesTableReferences
    extends BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow> {
  $$FavoritesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoodsTable _foodIdTable(_$AppDatabase db) =>
      db.foods.createAlias('favorites__food_id__foods__id');

  $$FoodsTableProcessedTableManager get foodId {
    final $_column = $_itemColumn<String>('food_id')!;

    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FoodsTableAnnotationComposer get foodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          FavoriteRow,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (FavoriteRow, $$FavoritesTableReferences),
          FavoriteRow,
          PrefetchHooks Function({bool foodId})
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> foodId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion(
                foodId: foodId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String foodId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion.insert(
                foodId: foodId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTable, FavoriteRow>(table),
                  $$FavoritesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({foodId = false}) {
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
                    if (foodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.foodId,
                        referencedTable: $$FavoritesTableReferences
                            ._foodIdTable(db),
                        referencedColumn: $$FavoritesTableReferences
                            ._foodIdTable(db)
                            .id,
                      ) as T;
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

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      FavoriteRow,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (FavoriteRow, $$FavoritesTableReferences),
      FavoriteRow,
      PrefetchHooks Function({bool foodId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $FoodSearchTableManager get foodSearch =>
      $FoodSearchTableManager(_db, _db.foodSearch);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db, _db.foods);
  $$MeasuresTableTableManager get measures =>
      $$MeasuresTableTableManager(_db, _db.measures);
  $$AssetVersionsTableTableManager get assetVersions =>
      $$AssetVersionsTableTableManager(_db, _db.assetVersions);
  $$DiaryItemsTableTableManager get diaryItems =>
      $$DiaryItemsTableTableManager(_db, _db.diaryItems);
  $$PlanItemsTableTableManager get planItems =>
      $$PlanItemsTableTableManager(_db, _db.planItems);
  $$PlanChecksTableTableManager get planChecks =>
      $$PlanChecksTableTableManager(_db, _db.planChecks);
  $$BodyMeasurementsTableTableManager get bodyMeasurements =>
      $$BodyMeasurementsTableTableManager(_db, _db.bodyMeasurements);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
