# LocalDiet

Aplicativo Android de acompanhamento nutricional que funciona sem internet. A composição dos alimentos vem da Tabela Brasileira de Composição de Alimentos (TACO), 4ª edição, do NEPA/UNICAMP. Todos os dados ficam no aparelho.

## Baixar

O APK mais recente fica em:

**https://github.com/Gabriel08dev/LocalDiet/releases/latest/download/LocalDiet.apk**

Abra o link no celular, baixe o arquivo e toque nele para instalar. Na primeira vez, o Android pede permissão para o navegador instalar apps; conceda e repita. As versões seguintes instalam por cima da anterior e mantêm os dados.

## O que o app faz

- **Diário.** Registre o que comeu por refeição. Cada registro guarda os valores nutricionais do momento, então mudanças futuras na base não alteram o histórico.
- **Busca.** 597 alimentos da TACO e os que você cadastrar, com busca por prefixo, sem acentos, e atalhos para recentes, mais usados e favoritos.
- **Porções.** Em gramas ou em medidas que você mesmo salva ("minha fatia = 35 g"). A escolha de porção abre na última quantidade usada.
- **Texto livre.** Descreva a refeição ("2 ovos fritos, 150 g de arroz") e confira a proposta antes de salvar.
- **Plano Base.** A dieta planejada por refeição, que serve de meta para proteína, carboidrato e gordura.
- **Meta de calorias.** Calculada a partir do perfil, ou definida manualmente.
- **Evolução.** Peso, cintura, pescoço e quadril, com gráficos, IMC e estimativa de gordura corporal.
- **Backup.** Exporte e importe todos os seus dados em um arquivo.

O app não pede permissão de internet, não tem conta e não envia nada para fora do aparelho. Ele é uma ferramenta de registro e não substitui o acompanhamento de nutricionista ou médico.

Capturas de tela: [tema claro](docs/screenshots/claro) e [tema escuro](docs/screenshots/escuro).

## Desenvolvimento

Requer Flutter 3.47.6 (canal estável).

```bash
flutter pub get
```

```bash
flutter test
```

As mesmas verificações do CI (formatação, análise e testes) rodam com `tool/check.ps1`.

Depois de alterar tabelas em `lib/data/tables.dart` ou `lib/data/search.drift`, gere o código de novo:

```bash
dart run build_runner build
```

Para regenerar as capturas de tela:

```bash
flutter test --update-goldens test/ui/screenshots_test.dart
```

### Documentação

- [docs/SPEC.md](docs/SPEC.md): regras de produto e fórmulas.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): camadas, banco, busca, backup e como criar uma migration.
- [docs/NUTRITION_DATA.md](docs/NUTRITION_DATA.md): origem e conversão dos dados nutricionais.
- [docs/PERFORMANCE.md](docs/PERFORMANCE.md): medições de desempenho.
- [ROADMAP.md](ROADMAP.md): o que vem a seguir e o que está fora de escopo.

### Build e assinatura

Cada push em `main` roda o workflow `build`, que verifica o código e gera o APK de release. Uma tag `v*` também publica o APK em Releases.

O APK é assinado com a chave guardada nos segredos `KEYSTORE_BASE64` e `KEYSTORE_PASSWORD` do repositório. A chave precisa ser sempre a mesma: um APK assinado com outra chave não instala por cima do anterior.

Para assinar um build local, crie `android/key.properties` (o arquivo não é versionado):

```properties
storeFile=caminho/para/a/chave.p12
storePassword=...
keyPassword=...
keyAlias=localdiet
```

Sem esse arquivo, o build local usa a chave de debug.
