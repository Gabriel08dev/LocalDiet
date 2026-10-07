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

## Banco

Schema na versão 1. O arquivo se chama `localdiet2.sqlite`, nome diferente do usado pela primeira versão do app, e é aberto em isolate de segundo plano por `drift_flutter`.

| Tabela | Conteúdo |
|---|---|
| `foods` | Alimentos da TACO e do usuário, com seis valores por 100 g e o registro completo da fonte |
| `food_search` | Índice FTS5 do nome normalizado, mantido por gatilhos |
| `measures` | Medidas caseiras do sistema (com fonte) e do usuário |
| `asset_versions` | Versão importada de cada asset |
| `diary_items` | Itens consumidos, com snapshot |
| `plan_items` | Itens do Plano Base |
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

Datas sem hora (`profiles.birth_date`, `diary_items.date`, `body_measurements.date`) são texto `AAAA-MM-DD`, convertidas por `LocalDateConverter`. Instantes de verdade (`created_at`, `imported_at`) usam o tipo de data e hora do Drift.

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

Ao criar a versão 2 do schema, a importação precisa ganhar um passo que converta backups da versão 1.

## Testes

```text
test/
  domain/      regras puras
  data/        importadores, busca, repositórios, backup e parser com a base real
  migrations/  schema atual contra o snapshot exportado
  ui/          fluxos de ponta a ponta, layout e capturas
```

- Os testes de `data/` e `ui/` usam um banco em memória com a TACO real.
- `test/ui/layout_test.dart` percorre todas as telas em 390 × 844 e 320 × 568, com a fonte em 1×, 1,5× e 2×. Conteúdo que estoura o espaço faz o teste falhar.
- `test/flutter_test_config.dart` carrega as fontes reais do Material, para que as capturas mostrem texto de verdade.
- `test/ui/screenshots_test.dart` gera `docs/screenshots/` e só roda com `--update-goldens`. As imagens variam entre sistemas, então não são usadas como teste de regressão.

## Migrations

O snapshot do schema atual está em `drift_schemas/app/drift_schema_v1.json`. Para mudar o schema:

1. Altere as tabelas e aumente `schemaVersion` em `lib/data/app_database.dart`.
2. Rode `dart run build_runner build`.
3. Rode `dart run drift_dev make-migrations`. Ele exporta o snapshot da nova versão e gera os passos de migration e os testes que partem de um banco real na versão anterior.
4. Escreva a migration e, se o backup for afetado, o passo de conversão de backups antigos.

## Build e publicação

`.github/workflows/build.yml` roda em cada push: formatação, análise, testes, APK de release assinado e a verificação de que o APK não declara a permissão `INTERNET`. Uma tag `v*` publica o APK em Releases com o nome `LocalDiet.apk`.

O número de versão do Android (`versionCode`) é o número da execução do workflow, que sempre cresce. O nome da versão vem da tag.
