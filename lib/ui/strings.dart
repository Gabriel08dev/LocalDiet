import '../data/app_database.dart';
import '../data/repositories/backup_repository.dart';
import '../domain/body_metrics.dart';
import '../domain/calorie_target.dart';
import '../domain/local_date.dart';
import '../domain/nutrients.dart';
import '../domain/portion.dart';
import '../domain/preparation.dart';
import '../domain/profile_enums.dart';
import 'format.dart';

String mealLabel(MealType meal) => switch (meal) {
  MealType.breakfast => 'Café da manhã',
  MealType.lunch => 'Almoço',
  MealType.snack => 'Lanche',
  MealType.dinner => 'Jantar',
  MealType.other => 'Outro',
};

/// A refeição depois da preposição: "no almoço", "em Outro".
String _inMeal(MealType meal) => switch (meal) {
  MealType.breakfast => 'no café da manhã',
  MealType.lunch => 'no almoço',
  MealType.snack => 'no lanche',
  MealType.dinner => 'no jantar',
  MealType.other => 'em Outro',
};

String sexLabel(Sex sex) => switch (sex) {
  Sex.female => 'Feminino',
  Sex.male => 'Masculino',
};

String goalLabel(Goal goal) => switch (goal) {
  Goal.lose => 'Perder peso',
  Goal.maintain => 'Manter o peso',
  Goal.gain => 'Ganhar peso',
};

String activityLabel(ActivityLevel level) => switch (level) {
  ActivityLevel.sedentary => 'Sedentário',
  ActivityLevel.light => 'Levemente ativo',
  ActivityLevel.moderate => 'Moderadamente ativo',
  ActivityLevel.active => 'Muito ativo',
  ActivityLevel.veryActive => 'Extremamente ativo',
};

String activityHelp(ActivityLevel level) => switch (level) {
  ActivityLevel.sedentary => 'Pouco ou nenhum exercício, trabalho sentado.',
  ActivityLevel.light => 'Exercício leve de 1 a 3 dias por semana.',
  ActivityLevel.moderate => 'Exercício moderado de 3 a 5 dias por semana.',
  ActivityLevel.active => 'Exercício intenso de 6 a 7 dias por semana.',
  ActivityLevel.veryActive =>
    'Exercício intenso todos os dias ou trabalho físico pesado.',
};

String bmiRangeLabel(BmiRange range) => switch (range) {
  BmiRange.underweight => 'Abaixo do peso',
  BmiRange.normal => 'Peso adequado',
  BmiRange.overweight => 'Sobrepeso',
  BmiRange.obesity => 'Obesidade',
};

String preparationLabel(Preparation preparation) => switch (preparation) {
  Preparation.sauteed => 'refogado',
  Preparation.fried => 'frito',
  Preparation.grilled => 'grelhado',
};

String _goalAdjustmentLabel(Goal goal) {
  final percent = (goalAdjustment[goal]! * 100).round();
  if (percent == 0) return 'sem ajuste';
  return percent > 0 ? '+$percent%' : '−${percent.abs()}%';
}

/// Textos da interface, em um só lugar.
abstract final class S {
  static const appName = 'NutriViva';

  // Navegação
  static const home = 'Início';
  static const diary = 'Diário';
  static const plan = 'Plano';
  static const evolution = 'Evolução';
  static const profile = 'Perfil';

  // Ações comuns
  static const add = 'Adicionar';
  static const save = 'Salvar';
  static const cancel = 'Cancelar';
  static const remove = 'Remover';
  static const delete = 'Excluir';
  static const discard = 'Descartar';
  static const undo = 'Desfazer';
  static const ok = 'Entendi';
  static const clear = 'Limpar';
  static const tryAgain = 'Tentar de novo';
  static const moreOptions = 'Mais opções';
  static const less = 'Diminuir';
  static const more = 'Aumentar';

  // Validação
  static const requiredField = 'Preencha este campo';
  static const chooseOption = 'Escolha uma opção';
  static const invalidNumber = 'Digite um número';
  static const mustBePositive = 'Precisa ser maior que zero';
  static const invalidQuantity = 'Digite uma quantidade maior que zero';
  static String minValue(double value) => 'No mínimo ${formatNumber(value)}';
  static String maxValue(double value) => 'No máximo ${formatNumber(value)}';

  // Nutrientes e unidades
  static const kcalUnit = 'kcal';
  static const energy = 'Energia';
  static const protein = 'Proteína';
  static const carb = 'Carboidrato';
  static const fat = 'Gordura';
  static const fiber = 'Fibra';
  static const sodium = 'Sódio';
  static const grams = 'Gramas';
  static const quantity = 'Quantidade';
  static const gramsMeasure = 'gramas';
  static const estimate = 'estimativa';
  static const food = 'Alimento';
  static const myFood = 'Meu alimento';

  static String kcalPer100(double? kcal) => kcal == null
      ? 'Energia não informada na TACO'
      : '${formatInteger(kcal)} kcal por 100 g';
  static String macroLine(Nutrients nutrients) =>
      'P ${formatNumber(nutrients.protein)} g · '
      'C ${formatNumber(nutrients.carb)} g · '
      'G ${formatNumber(nutrients.fat)} g';
  static String gramsOfTarget(double consumed, double target) =>
      '${formatInteger(consumed)} de ${formatInteger(target)} g';
  static String equalsGrams(double grams) => '= ${formatGrams(grams)}';
  static String measureChip(String label, double grams) =>
      '$label · ${formatGrams(grams)}';
  static String portionText(Portion portion) => portion.isInGrams
      ? formatGrams(portion.grams)
      : '${formatNumber(portion.quantity)} × ${portion.measureLabel} · '
            '${formatGrams(portion.grams)}';
  static String itemsAndKcal(int count, double kcal) =>
      '${count == 1 ? '1 item' : '$count itens'} · ${formatKcal(kcal)}';

  // Abertura e onboarding
  static const preparingFoods = 'Preparando a base de alimentos…';
  static const bootFailed = 'Não foi possível abrir a base de alimentos';
  static const bootFailedHelp =
      'Seus registros não foram alterados. Tente de novo.';
  static const loadFailed = 'Não foi possível carregar os dados';
  static const onboardingTitle = 'Vamos começar';
  static const onboardingIntro =
      'Estes dados servem para estimar sua meta de calorias. '
      'Você pode mudá-los depois.';
  static const name = 'Nome';
  static const birthDate = 'Data de nascimento';
  static const sexForCalculation = 'Sexo para o cálculo';
  static const sexHelp =
      'Usado apenas nas fórmulas de gasto de energia e gordura corporal.';
  static const height = 'Altura';
  static const weight = 'Peso';
  static const goal = 'Objetivo';
  static const activity = 'Nível de atividade';
  static const optionalMeasures = 'Medidas opcionais';
  static const optionalMeasuresHelp =
      'Com cintura e pescoço (e quadril, para mulheres) o app estima a '
      'gordura corporal. Pode deixar em branco.';
  static const waist = 'Cintura';
  static const neck = 'Pescoço';
  static const hip = 'Quadril';
  static const start = 'Começar';
  static const privacyNote =
      'Seus dados ficam só neste aparelho. O app funciona sem internet.';
  static const minorNotice =
      'As estimativas deste app foram feitas para adultos. Para menores de '
      '18 anos, siga a orientação de um profissional de saúde.';

  // Início
  static String hello(String name) => 'Olá, $name';
  static String todayLong(LocalDate date) {
    final text = formatLongDay(date);
    return text[0].toUpperCase() + text.substring(1);
  }

  static const kcalRemainingLabel = 'Restam hoje';
  static const kcalOverLabel = 'Excedente hoje';
  static String kcalAmount(double kcal) => formatKcal(kcal);
  static const todayMeals = 'Refeições de hoje';
  static const logFood = 'Registrar refeição';
  static const nothingLogged = 'Nada registrado';
  static const nothingPlanned = 'Nada planejado';
  static const noKcalTarget = 'Sem meta de calorias';
  static const macrosNeedPlan =
      'Monte um Plano Base para ter metas de proteína, carboidrato e gordura.';
  static const belowBmrNotice =
      'Sua meta está abaixo da taxa metabólica basal estimada. Converse com '
      'um profissional de saúde antes de seguir uma meta tão baixa.';
  static String kcalRemaining(double kcal) => 'Restam ${formatKcal(kcal)}';
  static String kcalOver(double kcal) => 'Excedente de ${formatKcal(kcal)}';
  static String kcalTargetLine(double kcal) => 'Meta de ${formatKcal(kcal)}';
  static String addToMeal(String meal) => 'Adicionar a $meal';

  // Seguir o plano
  static const followPlan = 'Segui o plano';
  static const ateSomethingElse = 'Fiz outra refeição';
  static String followPlanFor(String meal) => 'Segui o plano: $meal';
  static String ateSomethingElseFor(String meal) => 'Fiz outra refeição: $meal';
  static const planFollowed = 'Plano seguido';
  static const otherMeal = 'Outra refeição';
  static const clearPlanCheck = 'Desmarcar';
  static String planFollowedMessage(String meal) =>
      '$meal registrado conforme o plano';
  static String plannedSummary(int count, double kcal) =>
      'Planejado: ${count == 1 ? '1 item' : '$count itens'} · '
      '${formatKcal(kcal)}';
  static const adherenceTitle = 'Adesão nos últimos 7 dias';
  static const adherenceEmpty =
      'No Início, marque em cada refeição se você seguiu o plano ou fez '
      'outra refeição. O resumo aparece aqui.';
  static String adherenceSummary(int followed, int marked) =>
      'Plano seguido em $followed de '
      '${marked == 1 ? '1 refeição marcada' : '$marked refeições marcadas'}';
  static String adherenceOther(int other) => switch (other) {
    0 => 'Nenhuma refeição trocada por outra.',
    1 => '1 refeição trocada por outra.',
    _ => '$other refeições trocadas por outras.',
  };

  // Diário
  static const previousWeek = 'Semana anterior';
  static const nextWeek = 'Próxima semana';
  static const goToToday = 'Ir para hoje';
  static const chooseDay = 'Escolher o dia';
  static const copyFromAnotherDay = 'Copiar de outro dia';
  static const nothingToCopy = 'Nenhuma refeição anterior';
  static const nothingToCopyHelp =
      'Quando houver registros em dias anteriores, eles aparecem aqui.';
  static String copyTo(String meal) => 'Copiar para $meal';
  static String itemRemoved(String name) => '"$name" foi removido';
  static String itemsCopied(int count) =>
      count == 1 ? '1 item copiado' : '$count itens copiados';

  // Montagem da refeição
  static const searchHint = 'Buscar alimento';
  static const searchIntro =
      'Busque entre os 597 alimentos da TACO e os que você cadastrar. '
      'Os mais comuns já têm medidas como colher, concha e unidade. '
      'Os que você usar nesta refeição aparecem aqui para o próximo registro.';
  static const favorites = 'Favoritos';
  static String recentsIn(MealType meal) => 'Recentes ${_inMeal(meal)}';
  static String frequentsIn(MealType meal) => 'Mais usados ${_inMeal(meal)}';
  static String noRecentsIn(MealType meal) =>
      'Você ainda não registrou nada ${_inMeal(meal)}. '
      'Cada refeição guarda o próprio histórico.';
  static const describeMeal = 'Descrever em texto';
  static const describeMealHint =
      'Ex.: 2 ovos fritos, 150 g de arroz e 1 concha de feijão';
  static const createFood = 'Criar alimento';
  static String createFoodNamed(String name) => 'Criar "$name"';
  static const noFoodFound = 'Nenhum alimento encontrado';
  static const noFoodFoundHelp =
      'Tente outro nome ou cadastre o alimento com os dados do rótulo.';
  static const review = 'Revisar';
  static const reviewMeal = 'Revisar refeição';
  static const mealTotal = 'Total da refeição';
  static const addMoreFoods = 'Adicionar mais alimentos';
  static String saveToDiary(String meal) => 'Salvar em $meal';
  static String saveToPlan(String meal) => 'Salvar no plano: $meal';
  static const mealSaved = 'Refeição registrada';
  static const planSaved = 'Plano atualizado';
  static const saveFailed = 'Não foi possível salvar. Nada foi gravado.';
  static const discardMealTitle = 'Descartar esta refeição?';
  static const discardMealMessage =
      'Os alimentos escolhidos ainda não foram salvos.';

  // Porção
  static const foodSheet = 'Ficha do alimento';
  static const energyUnknown = 'Energia não informada';
  static const energyUnknownNote =
      'A TACO não informa a energia nem os macronutrientes deste alimento '
      '(análise em reavaliação). No registro, ele conta como 0 kcal. Para '
      'contar as calorias, crie o seu alimento com os dados do rótulo.';
  static const energyUnknownShort =
      'Sem energia na TACO: conta como 0 kcal. Prefira um alimento seu.';
  static const addFavorite = 'Favoritar';
  static const removeFavorite = 'Tirar dos favoritos';
  static const myPortion = 'Minha porção';
  static const myPortionHelp =
      'Salve uma medida sua para este alimento, com o peso que você medir. '
      'Toque em um nome ou escreva o seu.';
  static const portionName = 'Nome da porção';
  static const portionNameHint = 'Ex.: fatia, concha, scoop';
  static const portionNameSuggestions = [
    'colher de sopa',
    'colher de servir',
    'concha',
    'scoop',
    'xícara',
    'copo',
    'fatia',
    'unidade',
    'pote',
  ];
  static const portionWeight = 'Peso da porção';
  static const portionWeightMissing = 'Informe o peso da porção em gramas';
  static String removeMeasureTitle(String label) =>
      'Remover a porção "$label"?';
  static const removeMeasureMessage =
      'Os registros que já usaram esta porção não mudam.';

  // Texto livre
  static const interpret = 'Interpretar';
  static const interpretAgain = 'Interpretar de novo';
  static const nothingRecognized =
      'Não reconheci nenhum alimento neste texto. Separe os itens por '
      'vírgula, como em "2 ovos, 100 g de arroz".';
  static const parserNotice =
      'Esta é uma proposta. Confira o alimento e os gramas de cada item '
      'antes de continuar.';
  static const parserIncomplete =
      'Informe os gramas ou remova os itens que estão incompletos.';
  static const parserFoodNotFound =
      'Não encontrei este alimento. Remova o item e adicione pela busca.';
  static const parserGramsMissing =
      'Não foi possível determinar a quantidade. Informe os gramas.';
  static const addToMealReview = 'Adicionar à refeição';
  static String measureNote(Portion portion) =>
      '${formatNumber(portion.quantity)} × ${portion.measureLabel} de '
      '${formatGrams(portion.measureGrams)}';
  static String oilEstimateFor(String preparation) =>
      'Óleo do preparo ($preparation): estimativa do app';
  static const oilEstimateHelp =
      'Valor estimado, sem fonte oficial. Ajuste ou remova se não usou óleo.';

  // Alimentos do usuário
  static const myFoods = 'Meus alimentos';
  static const editFood = 'Editar alimento';
  static const foodName = 'Nome do alimento';
  static const per100g = 'Valores por 100 g';
  static const per100gHelp =
      'Use a tabela nutricional do rótulo. Se ela estiver por porção, '
      'converta para 100 g.';
  static const usualPortion = 'Porção habitual (opcional)';
  static const usualPortionHelp =
      'Uma medida que você costuma usar, para não digitar gramas toda vez.';
  static const foodSaved = 'Alimento salvo';
  static const foodRemoved = 'Alimento removido';
  static const foodNotFound = 'Alimento não encontrado';
  static const deactivateFoodTitle = 'Remover este alimento?';
  static const deactivateFoodMessage =
      'Ele sai da busca. O que já foi registrado no Diário continua igual.';
  static const noUserFoods = 'Nenhum alimento cadastrado';
  static const noUserFoodsHelp =
      'Cadastre produtos que não estão na TACO, como industrializados e '
      'suplementos.';
  static String tacoFoodSource(int? number, String? category) =>
      ['TACO nº ${number ?? '?'}', ?category].join(' · ');
  static const tacoLegend =
      'Tr: traço. NA: não aplicável. *: análise em reavaliação. '
      '—: análise não solicitada. Fonte: TACO, 4ª edição, NEPA/UNICAMP.';

  // Plano Base
  static const planTitle = 'Plano Base';
  static const planTotal = 'Total planejado para o dia';
  static const planEmpty =
      'O Plano Base é a sua dieta planejada. Adicione alimentos a cada '
      'refeição para ter metas de proteína, carboidrato e gordura no dia a '
      'dia.';
  static const planNeedsReview = 'Alimento removido. Revise este item.';
  static String planVersusTarget(double kcal) =>
      'Sua meta de calorias é de ${formatKcal(kcal)}. O plano e a meta são '
      'independentes: um não ajusta o outro.';

  // Evolução
  static const history = 'Histórico';
  static const newMeasurement = 'Nova medição';
  static const editMeasurement = 'Editar medição';
  static const deleteMeasurement = 'Excluir medição';
  static const deleteMeasurementTitle = 'Excluir esta medição?';
  static String deleteMeasurementMessage(LocalDate date) =>
      'A medição de ${formatDate(date)} será apagada.';
  static const measurementEmpty = 'Preencha ao menos uma medida.';
  static const date = 'Data';
  static const noMeasurements = 'Nenhuma medição';
  static const noMeasurementsHelp =
      'Registre peso e medidas para acompanhar sua evolução.';
  static const noWeightYet = 'Registre o peso para ver os indicadores.';
  static const currentWeight = 'Peso atual';
  static const bmi = 'IMC';
  static const bodyFat = 'Gordura';
  static const chartNeedsTwo =
      'Registre mais uma medição para ver a evolução em gráfico.';
  static String weightChange(double delta, LocalDate since) {
    final sinceText = 'desde ${formatDate(since)}';
    if (delta.abs() < 0.05) return 'Sem variação $sinceText';
    final sign = delta > 0 ? '+' : '−';
    return '$sign${formatNumber(delta.abs())} kg $sinceText';
  }

  static String measurementSummary(BodyMeasurementRow row) => [
    if (row.weightKg != null) '${formatNumber(row.weightKg!)} kg',
    if (row.waistCm != null) 'cintura ${formatNumber(row.waistCm!)} cm',
    if (row.neckCm != null) 'pescoço ${formatNumber(row.neckCm!)} cm',
    if (row.hipCm != null) 'quadril ${formatNumber(row.hipCm!)} cm',
  ].join(' · ');

  // Perfil
  static const personalData = 'Dados pessoais';
  static const profileSaved = 'Perfil atualizado';
  static String profileSummary(ProfileRow profile, LocalDate today) =>
      '${profile.birthDate.ageOn(today)} anos · '
      '${formatNumber(profile.heightCm)} cm · ${goalLabel(profile.goal)}';
  static const targetNeedsWeight =
      'Registre seu peso na Evolução para calcular a meta de calorias.';
  static const calculatedTarget = 'Meta de calorias calculada';
  static const manualTarget = 'Meta de calorias manual';
  static const manualTargetHelp =
      'Use quando tiver uma meta definida por nutricionista ou médico. Ela '
      'substitui a meta calculada.';
  static const useManualTarget = 'Definir meta manual';
  static const changeManualTarget = 'Alterar meta manual';
  static const useCalculatedTarget = 'Voltar à meta calculada';
  static const kcalPerDayLabel = 'Calorias por dia';
  static String kcalPerDay(double kcal) =>
      '${formatInteger(kcal)} kcal por dia';
  static String targetBreakdown(CalorieTarget target, Goal goal) =>
      'Taxa basal estimada: ${formatKcal(target.bmr)}\n'
      'Gasto diário estimado: ${formatKcal(target.dailyExpenditure)}\n'
      'Meta calculada (${goalLabel(goal).toLowerCase()}, '
      '${_goalAdjustmentLabel(goal)}): ${formatKcal(target.calculated)}';
  static const theme = 'Tema';
  static const themeSystem = 'Sistema';
  static const themeLight = 'Claro';
  static const themeDark = 'Escuro';

  // Dados
  static const dataTitle = 'Exportar e importar dados';
  static const dataSubtitle = 'Cópia de segurança em arquivo';
  static const dataIntro =
      'Seus dados existem só neste aparelho. Exporte um arquivo de tempos em '
      'tempos para não perder o histórico ao trocar de celular ou reinstalar '
      'o app.';
  static const exportTitle = 'Exportar';
  static const exportHelp =
      'Gera um arquivo com perfil, medições, Diário, Plano Base, seus '
      'alimentos, suas porções e favoritos. Guarde em um lugar seguro.';
  static const exportAction = 'Exportar meus dados';
  static const exportDone = 'Arquivo de backup salvo';
  static const fileFailed =
      'Não foi possível abrir ou gravar o arquivo. Nada foi alterado.';
  static const importTitle = 'Importar';
  static const importHelp =
      'Lê um arquivo exportado pelo NutriViva. Os dados deste aparelho são '
      'substituídos pelos do arquivo, depois da sua confirmação.';
  static const importAction = 'Importar de um arquivo';
  static const importConfirmTitle = 'Substituir os dados deste aparelho?';
  static const importReplace = 'Substituir';
  static const importDone = 'Dados importados';
  static const importErrorTitle = 'Não foi possível importar';
  static const importNotText =
      'O arquivo escolhido não é um backup do NutriViva.';
  static const importFailed =
      'A importação falhou e foi desfeita. Seus dados continuam como estavam.';
  static String importSummary(BackupSummary summary) {
    final exported = summary.exportedAt == null
        ? ''
        : ' de ${formatDate(LocalDate.fromDateTime(summary.exportedAt!.toLocal()))}';
    String count(int value, String one, String many) =>
        value == 1 ? '1 $one' : '$value $many';
    final lines = [
      if (summary.hasProfile) 'perfil',
      count(summary.bodyMeasurements, 'medição', 'medições'),
      '${count(summary.diaryItems, 'registro', 'registros')} no Diário, em '
          '${count(summary.diaryDays, 'dia', 'dias')}',
      '${count(summary.planItems, 'item', 'itens')} no Plano Base',
      count(summary.userFoods, 'alimento seu', 'alimentos seus'),
      count(summary.userMeasures, 'porção sua', 'porções suas'),
      count(summary.favorites, 'favorito', 'favoritos'),
    ];
    return 'O backup$exported contém:\n'
        '${lines.map((line) => '• $line').join('\n')}\n\n'
        'Tudo o que está neste aparelho será substituído por esse conteúdo. '
        'Não é possível desfazer.';
  }

  // Sobre
  static const aboutTitle = 'Sobre e fontes';
  static String versionLine(String version) => 'Versão $version';
  static const healthNotice =
      'O NutriViva é uma ferramenta de registro. As metas e estimativas são '
      'cálculos gerais e não substituem o acompanhamento de nutricionista ou '
      'médico.';
  static const aboutFoodsTitle = 'Composição dos alimentos';
  static const aboutFoodsBody =
      'Os valores vêm da Tabela Brasileira de Composição de Alimentos (TACO), '
      '4ª edição revisada e ampliada, publicada em 2011 pelo NEPA/UNICAMP: '
      '597 alimentos, com valores por 100 g, arredondados como na tabela '
      'publicada. Na ficha de cada alimento, "Tr" indica traço, "NA" não '
      'aplicável e "*" análise em reavaliação. Nas somas, esses casos contam '
      'como zero. Os itens marcados como "Meu alimento" foram cadastrados '
      'por você.';
  static const aboutMeasuresTitle = 'Medidas caseiras';
  static const aboutMeasuresBody =
      'As medidas caseiras (colher, concha, xícara, copo, fatia, unidade) vêm '
      'da Tabela de Medidas Referidas para os Alimentos Consumidos no Brasil, '
      'da Pesquisa de Orçamentos Familiares 2008-2009 do IBGE. Colheres, '
      'conchas e pratos são cheios, e os tamanhos são médios. Elas existem '
      'para 390 dos 597 alimentos, nas formas em que são consumidos; nos '
      'demais, use gramas ou salve a sua própria porção, como um scoop. Em '
      'bebidas, 1 ml conta como 1 g, como na tabela do IBGE.';
  static const aboutFormulasTitle = 'Fórmulas';
  static const aboutFormulasBody =
      'Taxa metabólica basal: equação de Mifflin-St Jeor (1990).\n'
      'Gasto diário: taxa basal multiplicada pelo fator de atividade, de 1,2 '
      '(sedentário) a 1,9 (extremamente ativo).\n'
      'Meta de calorias: gasto diário menos 20% para perder peso, sem ajuste '
      'para manter e mais 10% para ganhar. Esses ajustes são uma convenção '
      'do app, não uma prescrição; se você tem orientação profissional, use '
      'a meta manual.\n'
      'IMC: peso dividido pela altura ao quadrado, com as faixas da OMS para '
      'adultos.\n'
      'Gordura corporal: estimativa pelo método da Marinha dos EUA (Hodgdon '
      'e Beckett, 1984), com cintura, pescoço, altura e, para mulheres, '
      'quadril.';
  static const aboutOilTitle = 'Óleo de preparo';
  static const aboutOilBody =
      'Ao descrever uma refeição em texto com um preparo, o app sugere o '
      'óleo usado: 5 g para refogado, 15 g para frito e 2 g para grelhado, '
      'por item. São estimativas do app, sem fonte oficial. Elas aparecem '
      'identificadas e você pode ajustar ou remover. Não há sugestão quando '
      'o alimento da TACO já traz o preparo no nome.';
  static const aboutPrivacyTitle = 'Privacidade';
  static const aboutPrivacyBody =
      'O NutriViva funciona sem internet e não pede essa permissão ao '
      'sistema. Seus dados ficam só neste aparelho: não há conta, nuvem nem '
      'estatísticas de uso. A cópia de segurança é o arquivo que você '
      'exporta em Perfil, Exportar e importar dados.';
}
