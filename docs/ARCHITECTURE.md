# Arquitetura

Flutter com Material 3, Riverpod para estado, Drift sobre SQLite (com FTS5) para persistência e GoRouter para navegação.

## Camadas

```text
lib/
  domain/     Dart puro: sem Flutter e sem Drift
  data/       tabelas, importadores e repositórios
  ui/         tema, textos, telas e componentes
  providers.dart
  main.dart
```

- **`domain/`** tem as regras que não dependem de banco nem de tela: data sem fuso (`LocalDate`), conta de porção (`Nutrients`), meta de calorias, indicadores corporais, Real × Meta, normalização de busca, parser de texto e regra do óleo.
- **`data/`** define o schema (`tables.dart`, `search.drift`), sincroniza os assets com o banco (`asset_importer.dart`) e expõe repositórios. Só esta camada executa consultas.
- **`ui/`** consome os repositórios por meio de `providers.dart`. Telas não executam consultas nem fazem contas nutricionais.

`ui/strings.dart` concentra os textos da interface, `ui/format.dart` a formatação em pt-BR, e `ui/theme/app_theme.dart` as cores, espaçamentos e raios. Um redesign troca esses arquivos e os componentes de `ui/widgets/` sem tocar em regras de negócio.

### Visual e movimento

- **Cores.** A paleta parte do logo: fundo creme (o do logo), cartões brancos e o verde-escuro da marca para ações. O verde da folha aparece em pastel nos estados selecionados e no degradê do cartão de destaque. As demais cores são tons pastel (`Tone`: pêssego, menta, rosa, lavanda, céu e limão), usados nos ícones de refeições e de grupos de alimentos. O tema escuro usa fundo verde-noite, o verde da folha nas ações e os mesmos tons como luz.
- **Formas.** Cartões com cantos de 28, botões e etiquetas em pílula, barra de navegação flutuante.
- **Movimento.** `ui/widgets/motion.dart` reúne as animações: telas que entram surgindo e subindo (`risePage`), troca de aba animada (`BranchSwitcher`), blocos que aparecem em sequência (`Reveal`) e números, barras e anéis que contam até o novo valor (`AnimatedCount`, `AnimatedFraction`). Todas respeitam a opção do sistema de reduzir animações.
- **Marca.** O logo do NutriViva está em `docs/brand/nutriviva.jpg`. `tool/build_icon.py` separa o símbolo do fundo e gera o ícone do Android (adaptativo do Android 8 em diante, com camada monocromática para o ícone temático) e `assets/brand/mark.png`, que o widget `BrandMark` mostra sobre o fundo claro do logo nos dois temas.
- **Nome antigo.** O app se chamava LocalDiet. O nome continua nos identificadores que não podem mudar sem perder dados: `applicationId` (uma troca instalaria um segundo app, sem o histórico), arquivo do banco, formato do backup e alias da chave de assinatura. O pacote Dart também manteve o nome.

## Banco

Schema na versão 2. O arquivo se chama `localdiet2.sqlite`, nome diferente do usado pela primeira versão do app, e é aberto em isolate de segundo plano por `drift_flutter`.

| Tabela | Conteúdo |
|---|---|
| `foods` | Alimentos da TACO e do usuário, com seis valores por 100 g e o registro completo da fonte |
| `food_search` | Índice FTS5 do nome normalizado, mantido por gatilhos |
| `measures` | Medidas caseiras do sistema (com fonte) e do usuário |
| `asset_versions` | Versão importada de cada asset |
| `diary_items` | Itens consumidos, com snapshot |
| `plan_items` | Itens do Plano Base |
| `plan_checks` | Marcação diária de cada refeição do plano: seguida ou trocada (desde a versão 2) |
| `body_measurements` | Peso e medidas corporais |
| `profiles` | Perfil (uma linha) |
| `favorites` | Alimentos favoritos |
| `settings` | Preferências por chave |

### Identidade e remoção

- Alimentos da TACO têm id `taco:<número>`. Alimentos e medidas do usuário têm id `user:<128 bits aleatórios>`. Nenhuma referência depende de autoincremento, então reimportações e backups preservam os vínculos.
- Alimentos e medidas nunca são apagados em uso normal: são desativados (`is_active = 0`). Somem da busca, mas o Diário e o Plano continuam a resolvê-los.
- `diary_items.food_id` é uma referência fraca, sem chave estrangeira: o item se basta com o snapshot. `plan_items`, `measures` e `favorites` têm chave estrangeira para `foods`.
- Um item do Plano cujo alimento foi desativado continua visível e é sinalizado para revisão.

### Datas

Datas sem hora (`profiles.birth_date`, `diary_items.date`, `body_measurements.date`, `plan_checks.date`) são texto `AAAA-MM-DD`, convertidas por `LocalDateConverter`. Instantes de verdade (`created_at`, `imported_at`) usam o tipo de data e hora do Drift.

## Sincronização dos assets

`AssetImporter` roda na abertura do app. Para cada asset:

1. Calcula a versão a partir do conteúdo (FNV-1a de 64 bits). Se for igual à gravada em `asset_versions`, não faz nada.
2. Em uma transação, insere o que é novo, atualiza o que mudou, desativa o que saiu do asset e grava a nova versão.

Como a versão vem do conteúdo, alterar o asset basta para a sincronização rodar na próxima abertura.

## Busca

`foods.search_text` guarda o nome em minúsculas, sem acentos e sem pontuação. Gatilhos copiam esse texto para `food_search` a cada inserção, alteração ou exclusão.

`buildFtsQuery` transforma o que foi digitado em uma expressão FTS5: todos os termos obrigatórios, cada um como prefixo, com plural e gênero reduzidos ao mesmo radical e sinônimos regionais (aipim, macaxeira e mandioca, por exemplo). A ordem dos resultados está em [SPEC.md](SPEC.md).

## Backup

`BackupRepository` exporta um JSON com `format`, `formatVersion`, `schemaVersion`, `exportedAt` e uma lista por tabela de dados do usuário. As linhas usam a serialização JSON das classes geradas pelo Drift.

A importação analisa o arquivo inteiro antes de escrever e substitui os dados em uma transação. Arquivo de outro formato, com seção ausente, linha inválida, `formatVersion` ou `schemaVersion` maiores que os do app é recusado.

Backups do schema 1 não têm a seção `planChecks` e são aceitos sem ela. Ao criar uma nova versão do schema que mude dados existentes, a importação precisa de um passo que converta backups antigos.

## Testes

```text
test/
  domain/      regras puras
  data/        importadores, busca, repositórios, backup e parser com a base real
  migrations/  cada versão antiga migrada até cada versão seguinte
  ui/          fluxos de ponta a ponta, layout e capturas
```

- Os testes de `data/` e `ui/` usam um banco em memória com a TACO real.
- `test/ui/layout_test.dart` percorre todas as telas em 390 × 844 e 320 × 568, com a fonte em 1×, 1,5× e 2×. Conteúdo que estoura o espaço faz o teste falhar.
- `test/flutter_test_config.dart` carrega as fontes reais do Material, para que as capturas mostrem texto de verdade.
- `test/ui/day_test.dart` percorre um dia de uso como uma pessoa faria: segue o plano no café, troca o almoço e o registra pela busca em colheres e conchas, descreve o lanche em texto e ajusta o jantar no Diário.
- `test/ui/screenshots_test.dart` gera `docs/screenshots/` e só roda com `--update-goldens`. As imagens variam entre sistemas, então não são usadas como teste de regressão.

## Migrations

Os snapshots de cada versão do schema estão em `drift_schemas/app/`. As migrations ficam em `lib/data/app_database.dart`, uma função por passo (`from1To2`, e assim por diante). `test/migrations/app/migration_test.dart` migra um banco de cada versão antiga até cada versão seguinte e confere o resultado contra o snapshot; para a versão 1, também confere que os dados de um banco como o do primeiro APK continuam intactos.

Para mudar o schema:

1. Altere as tabelas e aumente `schemaVersion` em `lib/data/app_database.dart`.
2. Rode `dart run build_runner build`.
3. Rode `dart run drift_dev make-migrations`. Ele exporta o snapshot da nova versão e regenera `lib/data/app_database.steps.dart` e `test/migrations/app/generated/`. Ele também reescreve `migration_test.dart` com um modelo: restaure o arquivo mantido à mão com `git checkout` e acrescente o teste da nova versão.
4. Escreva o passo da migration e, se o backup for afetado, o tratamento de backups antigos.

## Build e publicação

`.github/workflows/build.yml` roda em cada push: formatação, análise, testes, APK de release assinado e a verificação de que o APK não declara a permissão `INTERNET`. Uma tag `v*` publica o APK em Releases com o nome `NutriViva.apk`.

O número de versão do Android (`versionCode`) é o número da execução do workflow, que sempre cresce. O nome da versão vem da tag.
