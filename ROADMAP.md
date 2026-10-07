# Roadmap

## Pendências desta versão

- **Medidas caseiras para os demais alimentos.** 225 dos 597 alimentos têm medidas do IBGE. Ampliar o cruzamento em `tool/build_measures.py`. Ver [docs/NUTRITION_DATA.md](docs/NUTRITION_DATA.md).
- **Nome do alimento 540 da TACO.** "Feijoada" foi inferido, porque a planilha traz só "L". Conferir com a edição em PDF.
- **Termos de uso da TACO e do IBGE.** Confirmar o que as duas fontes permitem quanto à redistribuição dos dados.
- **Desempenho no Android.** Medir partida a frio, primeira abertura, busca e quadros lentos. Ver [docs/PERFORMANCE.md](docs/PERFORMANCE.md).

## Próximos passos

- Seguir o plano: esta é uma primeira versão. Faltam o histórico de adesão por dia e por refeição, a opção de marcar uma refeição como pulada e planos diferentes para dias diferentes da semana.
- Visual: uma fonte própria embutida no app (hoje ele usa a fonte do sistema) e ilustrações nos estados vazios. Cores, formas e animações estão isolados em `lib/ui/theme/` e `lib/ui/widgets/`.
- Resumo semanal: média de calorias frente à meta e tendência de peso.
- Receitas: um alimento composto de outros alimentos.
- Conversão de volume para gramas em líquidos, quando houver densidade documentada.

## Fora de escopo

Estes recursos não serão implementados enquanto as premissas do app forem as atuais.

| Recurso | Motivo |
|---|---|
| Leitura de código de barras | Depende de uma base de produtos online |
| Bases nutricionais online | O app funciona sem rede |
| Sincronização em nuvem e contas | Os dados não saem do aparelho; a cópia de segurança é o arquivo exportado |
| Interpretação de texto por modelo de linguagem | Exigiria rede ou um modelo embarcado; o parser é heurístico e conferido pelo usuário |
| Notificações e lembretes | Ampliam o projeto antes de o núcleo estar validado em uso |
| iOS, web e desktop | O alvo de entrega é Android |
