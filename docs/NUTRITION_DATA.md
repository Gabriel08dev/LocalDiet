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
- **Texto digitado como número.** Uma célula numérica vem como texto (`,0,02`) e é lida como 0,02.

### Como o app usa os valores

- O banco guarda, por alimento, seis valores numéricos usados em somas (energia, proteína, carboidrato, lipídeos, fibra e sódio) e o registro completo da TACO, com os símbolos originais, em `foods.nutrients_json`.
- Nas somas, `Tr` conta como zero. `NA`, `*` e valor ausente não têm número: ficam nulos no banco e também contam como zero em somas.
- Na ficha do alimento, cada caso aparece como é (`Tr`, `NA`, `*`, `—`), nunca como "0".
- Seis alimentos não têm energia numérica na TACO (quatro em reavaliação e dois não aplicáveis). Na busca, eles aparecem com "Energia não informada na TACO".

### Uso e redistribuição

**Pendente.** O NEPA disponibiliza a tabela publicamente para download, mas os termos de uso e redistribuição não foram verificados para este projeto. Quem mantém o repositório deve confirmá-los antes de distribuir o app além do uso pessoal.

## Medidas caseiras

**Nesta versão não há medidas caseiras do sistema.** `assets/data/measures.jsonl` está vazio.

A regra do projeto é que uma conversão de medida caseira para gramas só entra com fonte e página documentadas. As 63 conversões da primeira versão do app se perderam com os arquivos originais, e a fonte candidata para refazê-las (IBGE, Pesquisa de Orçamentos Familiares 2008-2009, *Tabela de medidas referidas para os alimentos consumidos no Brasil*) não respondeu ao acesso feito em 07/10/2026. Nenhuma conversão foi criada por estimativa.

Enquanto isso, o usuário salva as próprias porções em qualquer alimento.

### Formato do asset

Uma linha JSON por medida:

```json
{"food": 488, "label": "unidade", "grams": 50, "ref": "IBGE, POF 2008-2009, Tabela de medidas referidas, p. 00"}
```

- `food`: número do alimento na TACO.
- `label`: nome da medida, como aparece para o usuário.
- `grams`: gramas de uma unidade da medida.
- `ref`: fonte e página. É obrigatório: o importador recusa o asset inteiro se alguma linha vier sem ele.

O exemplo acima ilustra o formato e não é um dado verificado.

## Óleo de preparo

Ao interpretar um texto livre com um preparo, o app sugere óleo de soja (TACO nº 272) por item preparado: 5 g para refogado, 15 g para frito e 2 g para grelhado.

Esses valores são **estimativas do app, sem fonte oficial**. Por isso a sugestão aparece identificada como estimativa, pode ser editada ou removida antes de salvar, e não é feita quando o alimento escolhido na TACO já traz o preparo no nome. Os valores ficam em `lib/domain/preparation.dart`.

## Fórmulas

As fórmulas da meta de calorias e dos indicadores corporais estão em [SPEC.md](SPEC.md).
