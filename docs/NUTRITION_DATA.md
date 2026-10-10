# Dados nutricionais

## Composição dos alimentos: TACO

| | |
|---|---|
| Fonte | Tabela Brasileira de Composição de Alimentos (TACO), 4ª edição revisada e ampliada, NEPA/UNICAMP, 2011 |
| Arquivo de origem | `Taco-4a-Edicao.xlsx`, planilha `CMVCol taco3` |
| Endereço | https://nepa.unicamp.br/publicacoes/tabela-taco-excel/ |
| Baixado em | 07/10/2026 |
| SHA-256 | `a66b8ec528daeabc63bc2b015fc9bd8c6d76b941c2fc0ed93a4311d449302d14` |
| Resultado | `assets/data/taco.jsonl`: 597 alimentos em 15 categorias |

A planilha não é versionada. Para regenerar o asset, salve-a em `tool/source/Taco-4a-Edicao.xlsx` e rode:

```bash
python tool/build_taco.py
```

O script confere que saem exatamente 597 alimentos, numerados de 1 a 597, e imprime o SHA-256 da planilha usada.

### Regras de conversão

- **Arredondamento.** A planilha traz médias sem arredondar (arroz integral cozido: 123,53 kcal). O asset arredonda cada coluna, meio para cima, com a precisão da tabela publicada em PDF (124 kcal). Energia, colesterol, cálcio, magnésio, fósforo, sódio, potássio e retinol ficam inteiros; proteína, lipídeos, carboidrato, fibra, cinzas, umidade, ferro, zinco e vitamina C, com uma casa; manganês, cobre e vitaminas do complexo B, com duas.
- **Símbolos preservados.** `Tr` (traço), `NA` (não aplicável) e `*` (análise em reavaliação) continuam como texto no asset. Célula em branco (análise não solicitada) vira `null`. Nenhum valor é estimado ou preenchido.
- **Nomes.** Dois nomes terminam, na planilha, com o número de uma nota de rodapé: "Cana, aguardente 1" e "Cerveja, pilsen 2". O número foi retirado.
- **Alimento 540.** Na planilha, a descrição do alimento 540 é apenas "L". O asset usa "Feijoada". **Esta correção é inferida**, não lida de outra fonte: o alimento fica entre "Feijão tropeiro mineiro" e "Frango, com açafrão" na ordem alfabética do grupo de alimentos preparados, e a composição (117 kcal por 100 g) é compatível. Vale conferir com a edição em PDF.
- **Texto digitado como número.** Uma célula numérica vem como texto (`,0,02`) e é lida como 0,02.

### Como o app usa os valores

- O banco guarda, por alimento, seis valores numéricos usados em somas (energia, proteína, carboidrato, lipídeos, fibra e sódio) e o registro completo da TACO, com os símbolos originais, em `foods.nutrients_json`.
- Nas somas, `Tr` conta como zero. `NA`, `*` e valor ausente não têm número: ficam nulos no banco e também contam como zero em somas.
- Na ficha do alimento, cada caso aparece como é (`Tr`, `NA`, `*`, `—`), nunca como "0".
- Seis alimentos não têm energia numérica na TACO. Em dois, o sal grosso e o sal dietético, a energia é "não aplicável" e eles aparecem com 0 kcal. Nos outros quatro a análise está em reavaliação, e a tabela também não traz proteína, carboidrato nem gordura, então não há como calcular a energia: leite de vaca integral (458), leite de vaca desnatado UHT (457), iogurte sabor abacaxi (450) e coco verde cru (591). Esses quatro aparecem com "Energia não informada" na busca, na escolha de porção e na proposta do texto livre, com o aviso de que contam como 0 kcal no registro. O app não estima o valor: quem quiser contar as calorias cadastra o alimento com os dados do rótulo.

### Uso e redistribuição

**Pendente.** O NEPA disponibiliza a tabela publicamente para download, mas os termos de uso e redistribuição não foram verificados para este projeto. Quem mantém o repositório deve confirmá-los antes de distribuir o app além do uso pessoal.

## Medidas caseiras: IBGE

| | |
|---|---|
| Fonte | IBGE, Pesquisa de Orçamentos Familiares 2008-2009, *Tabela de Medidas Referidas para os Alimentos Consumidos no Brasil*, Rio de Janeiro, 2011 |
| Arquivo de origem | `liv50000.pdf`, 545 páginas |
| Endereço | https://biblioteca.ibge.gov.br/visualizacao/livros/liv50000.pdf |
| Baixado em | 07/10/2026 |
| SHA-256 | `317ace59e53e25f3fc4913c5f552adf181bf001e6272edb5ae7a46804aa360b0` |
| Resultado | `assets/data/measures.jsonl`: 1.463 medidas para 390 alimentos |

O PDF não é versionado. Para regenerar o asset, salve-o em `tool/source/ibge-medidas-referidas.pdf` e rode (requer o pacote Python `pymupdf`):

```bash
python tool/build_measures.py --resumo
```

`tool/ibge_measures.py` lê a tabela inteira do PDF: 11.801 linhas de 1.124 alimentos. `tool/build_measures.py` escolhe o que entra no app.

### Regras

- **Cada medida vem de uma linha da tabela do IBGE.** O campo `ref` de cada medida cita a página do PDF e o alimento do IBGE de onde ela saiu. Nenhuma quantidade é estimada ou ajustada.
- **A correspondência entre alimentos é feita à mão**, na lista `MAPPING` do script: número do alimento na TACO, código do alimento no IBGE e preparação (cozido, grelhado, frito etc.).
- **Só alimentos na forma em que são consumidos.** As quantidades do IBGE para arroz e feijão são do alimento cozido, então "Arroz, tipo 1, cru" e "Feijão, carioca, cru" ficam sem medida.
- **Substituições do IBGE ficam de fora.** Para medidas pouco usuais, o IBGE registra a quantidade de outra medida (uma "caneca" de arroz como "prato fundo raso"). Essas linhas são reconhecidas porque a descrição da fonte não menciona a própria medida, e não entram.
- **Medidas que descrevem o alimento.** A tabela traz "copo" para laranja (o suco) e "peito" para o alimento "frango em pedaços". O script limita cada tipo de alimento às medidas que fazem sentido para ele: fruta em unidade e fatia, carne em bife e filé, pão em unidade ou fatia. Folhas cruas (acelga, almeirão, chicória, espinafre) ficam com folha, prato e porção: para a colher de folha crua, a tabela repete a quantidade da folha refogada.
- **Entrada genérica quando não há específica.** A TACO detalha alimentos que o IBGE só traz de forma genérica. Nesses casos vale a entrada genérica: cortes bovinos sem entrada própria usam "Carne bovina" na mesma preparação; óleos de canola, girassol e milho usam "Óleo não especificado"; pão de soja e pão sovado usam "Pão não especificado"; refrigerantes de laranja e limão usam "Refrigerante não especificado"; peixes de origem ambígua usam "Peixe não especificado". O `ref` de cada medida diz de qual entrada ela veio.
- **Produto nomeado pela marca no IBGE.** Três correspondências usam entradas que a tabela nomeia pela marca do produto pesquisado: a mistura de cereais para vitamina ("Neston"), a bebida isotônica ("Gatorade") e o extrato de soja fluido ("Ades original").
- **Medidas descartadas à mão.** Ficaram de fora medidas publicadas que não descrevem o alimento da TACO: a "unidade" de 227 g da graviola e a de 30 g para o camarão sete-barbas, a "unidade" das frutas em calda, a "porção" de 224 g da acerola e a colher de sobremesa da linhaça, incoerente com a colher de sopa.
- **No máximo sete medidas por alimento**, na ordem em que aparecem no app.
- **Colheres, conchas e pratos são cheios, e os tamanhos são médios.** É a convenção da publicação.
- **Bebidas.** O IBGE informa mililitros e adota a densidade da água. O app segue a publicação: 1 ml entra como 1 g.

### O que não está coberto

- **207 alimentos sem medida.** São as formas cruas de alimentos que se comem cozidos (carnes, pescados, feijões, arroz, mandioca), polpas congeladas e sucos concentrados, pós e misturas que o IBGE só mediu já preparados (creme de arroz, fubá, macarrão instantâneo, gelatina, capuccino) e os que não têm correspondente claro ou medida aproveitável na tabela (farinha de trigo, farinha de rosca, amido de milho, salsa, gergelim, tabule, virado à paulista, clara e gema de ovo separadas). Para eles, o usuário usa gramas ou salva a própria porção.
- **Colheres de líquidos e pós são as da publicação.** A tabela registra 8 g por colher de sopa de óleo e 6 g por colher de sopa de shoyu, abaixo do que uma colher cheia costuma pesar. O app mantém o valor publicado; quem mede de outro jeito salva a própria porção.
- **Variações de tamanho.** A banana de 75 g é a média do IBGE para vários tipos de banana. Uma banana nanica grande pesa mais. A porção salva pelo usuário cobre esses casos.
- **Suplementos e industrializados.** Não estão na TACO. O usuário cadastra o alimento e a porção, como um scoop.

### Formato do asset

Uma linha JSON por medida:

```json
{"food":3,"label":"colher de sopa","grams":25.0,"ref":"IBGE, POF 2008-2009, Tabela de Medidas Referidas, p. 35 do PDF: Arroz (polido, parboilizado)"}
```

- `food`: número do alimento na TACO.
- `label`: nome da medida, como aparece para o usuário.
- `grams`: gramas de uma unidade da medida.
- `ref`: fonte, página e alimento na fonte. É obrigatório: o importador recusa o asset inteiro se alguma linha vier sem ele.

### Uso e redistribuição

**Pendente.** A publicação é distribuída gratuitamente pelo IBGE. Os termos de reutilização dos dados não foram verificados para este projeto.

## Óleo de preparo

Ao interpretar um texto livre com um preparo, o app sugere óleo de soja (TACO nº 272) por item preparado: 5 g para refogado, 15 g para frito e 2 g para grelhado.

Esses valores são **estimativas do app, sem fonte oficial**. Por isso a sugestão aparece identificada como estimativa, pode ser editada ou removida antes de salvar, e não é feita quando o alimento escolhido na TACO já traz o preparo no nome. Os valores ficam em `lib/domain/preparation.dart`.

## Fórmulas

As fórmulas da meta de calorias e dos indicadores corporais estão em [SPEC.md](SPEC.md).
