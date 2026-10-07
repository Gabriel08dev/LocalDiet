# Especificação

## Regras de produto

1. **Offline por completo.** Nenhuma chamada de rede, sem backend, conta ou estatísticas de uso. O manifesto de release não declara a permissão `INTERNET` (o CI confere isso no APK) e `android:allowBackup` é `false`.
2. **O banco é a fonte de verdade.** A interface reage a streams do banco. Nenhuma tela guarda cópia do que está persistido.
3. **Uma única conta de porção:** `valor por 100 g × gramas / 100`, em `Nutrients.portion`. Telas não fazem conta.
4. **Símbolos da TACO preservados.** `Tr`, `NA`, `*` e valor ausente são distintos no banco e na ficha do alimento. Ver [NUTRITION_DATA.md](NUTRITION_DATA.md).
5. **Snapshot no Diário.** Cada item registrado guarda nome, medida, quantidade, gramas e os valores por 100 g do momento. Editar o alimento ou atualizar a TACO não muda o histórico.
6. **Refeição atômica.** Confirmar uma refeição com vários itens salva todos ou nenhum.
7. **Meta de calorias e Plano Base são independentes.** A meta vem do perfil; o plano é a soma da dieta planejada. O app não ajusta um pelo outro.
8. **Real × Meta.** Calorias consumidas são comparadas à meta do perfil. Proteína, carboidrato e gordura são comparados ao Plano Base. Sem plano, não há meta de macronutrientes. Acima da meta, a diferença aparece como excedente, nunca como restante negativo.
9. **Medidas caseiras do sistema só com fonte e página.** As do app vêm da tabela de medidas referidas do IBGE. Onde não há medida, a alternativa é gramas ou uma porção salva pelo usuário.
10. **O parser propõe, o usuário confirma.** Nada vindo do texto livre é salvo sem revisão. Quantidade que o texto não permite determinar fica em branco para o usuário preencher.
11. **Nada falso na interface.** Recurso inexistente não aparece como botão. Uma medição sozinha não vira gráfico.
12. **Datas são datas.** Nascimento, dia do Diário e dia da medição são gravados como `AAAA-MM-DD`, na data local, e não dependem de fuso.

## Estrutura

- **Refeições:** Café da manhã, Almoço, Lanche, Jantar, Outro.
- **Navegação:** Início, Diário, Plano, Evolução, Perfil.
- **Perfil:** nome, nascimento, sexo para o cálculo, altura, objetivo, nível de atividade e, opcionalmente, meta manual. O peso vem da medição mais recente.

## Fluxo de registro

1. **Busca.** Antes de digitar, aparecem favoritos, recentes e mais usados. A busca responde enquanto o usuário digita.
2. **Porção.** Uma folha sobre a busca, com as medidas como opções (colher, concha, unidade, fatia), quantidade ajustável e calorias e macronutrientes ao vivo. Abre na última porção usada do alimento ou, na primeira vez, em uma unidade da primeira medida caseira. Os botões de mais e menos andam de 1 em 1 em medidas (com meia medida abaixo de 1) e de 10 em 10 em gramas. Depois de adicionar, a busca volta vazia para o próximo alimento.
3. **Revisão.** Lista dos itens com o total da refeição. Cada item pode ser editado ou removido.
4. **Gravação.** Só ao confirmar na revisão. Sair antes disso pede confirmação para descartar.

O mesmo fluxo adiciona itens ao Plano Base.

### Ordem dos resultados da busca

1. Nomes que começam pelo primeiro termo digitado.
2. Alimentos do usuário.
3. Versão pronta antes da crua: um alimento cujo nome termina em "cru" ou "crua" fica depois quando existe o mesmo alimento cozido, grelhado ou assado. Quem digita "cru" recebe o cru primeiro.
4. Relevância do FTS5, depois nomes mais curtos.

### Texto livre

O texto é dividido em itens por vírgula, ponto e vírgula, quebra de linha, "+", " e " e " com ". Em cada item o parser lê quantidade (número, fração, "meia", números por extenso até seis), unidade de massa ou volume, medida caseira e modo de preparo.

- Massa (g, kg) vira gramas.
- Medida caseira ou contagem ("2 ovos", "1 concha de feijão", "2 scoops de whey") vira porção se o alimento tiver uma medida com esse nome, do sistema ou do usuário. A porção é salva na medida dita: "2 fatias" fica como 2 × fatia.
- Palavra genérica usa a medida mais comum: "colher" é colher de sopa, "copo" é copo médio, "xícara" é xícara de chá e "prato" é prato raso.
- Volume (ml, l) não é convertido: o usuário informa os gramas ou escolhe uma medida.

A regra de óleo de preparo está em [NUTRITION_DATA.md](NUTRITION_DATA.md).

## Seguir o plano

Quando o Plano Base tem itens para uma refeição e nada foi registrado nem marcado nela, o Início mostra o que estava planejado e duas respostas:

- **Segui o plano.** Registra no Diário os itens planejados, na mesma transação em que marca a refeição como seguida. Os itens entram com snapshot e podem ser ajustados depois. O aviso oferece desfazer, que remove os itens criados e a marcação.
- **Comi outra coisa.** Marca a refeição como trocada e abre o registro do que foi comido.

A marcação é uma por refeição e por dia. No Diário, o menu de cada refeição permite seguir o plano em qualquer dia e desmarcar. Desmarcar não apaga o que já foi registrado.

O Plano mostra a adesão dos últimos sete dias: em quantas das refeições marcadas o plano foi seguido. Refeições sem marcação não entram na conta.

## Fórmulas

### Meta de calorias

- **Taxa metabólica basal:** equação de Mifflin-St Jeor (1990).
  - Homens: `10 × peso (kg) + 6,25 × altura (cm) − 5 × idade + 5`
  - Mulheres: `10 × peso (kg) + 6,25 × altura (cm) − 5 × idade − 161`
- **Gasto diário:** taxa basal × fator de atividade.

  | Nível | Fator |
  |---|---|
  | Sedentário | 1,2 |
  | Levemente ativo | 1,375 |
  | Moderadamente ativo | 1,55 |
  | Muito ativo | 1,725 |
  | Extremamente ativo | 1,9 |

- **Meta calculada:** gasto diário × (1 + ajuste do objetivo). O ajuste é −20% para perder peso, 0 para manter e +10% para ganhar.

Os ajustes por objetivo são **uma convenção do app, não um valor de referência clínico**. As fórmulas da primeira versão do app não estavam disponíveis na reconstrução, então estes valores podem diferir dos anteriores. Quem tem meta definida por profissional usa a meta manual, que substitui a calculada.

### Aviso de meta baixa

Quando a meta em vigor (calculada ou manual) fica abaixo da taxa basal estimada, o app mostra um aviso recomendando orientação profissional. O app não altera a meta. Não há um piso numérico fixo: nenhum valor de referência foi adotado sem fonte.

### Indicadores corporais

- **IMC:** peso (kg) / altura (m)². Faixas da OMS para adultos: abaixo de 18,5; de 18,5 a 24,9; de 25 a 29,9; 30 ou mais.
- **Gordura corporal:** método da Marinha dos EUA (Hodgdon e Beckett, 1984), com medidas em centímetros.
  - Homens: `495 / (1,0324 − 0,19077 × log10(cintura − pescoço) + 0,15456 × log10(altura)) − 450`
  - Mulheres: `495 / (1,29579 − 0,35004 × log10(cintura + quadril − pescoço) + 0,22100 × log10(altura)) − 450`

  Sem as medidas necessárias, não há estimativa.

As estimativas valem para adultos. Para menores de 18 anos, o app mostra um aviso no perfil.

## Backup

O arquivo exportado traz perfil, medições, Diário com snapshots, Plano Base, alimentos e medidas do usuário, favoritos e preferências. A TACO não entra. Importar substitui todos os dados do aparelho, depois de mostrar um resumo do arquivo e pedir confirmação. Um arquivo inválido ou de versão mais nova é recusado sem alterar nada.
