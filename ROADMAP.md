# Roadmap

## Pendências desta versão

- **Validação em aparelho.** O app foi verificado por testes automatizados e pelo build no CI. Ainda não foi usado em um Android físico nesta reconstrução.
- **Medidas caseiras do sistema.** O asset está vazio. Refazer a base a partir de uma fonte com página documentada. Ver [docs/NUTRITION_DATA.md](docs/NUTRITION_DATA.md).
- **Termos de uso da TACO.** Confirmar o que o NEPA permite quanto à redistribuição dos dados.
- **Desempenho no Android.** Medir partida a frio, primeira abertura, busca e quadros lentos. Ver [docs/PERFORMANCE.md](docs/PERFORMANCE.md).
- **Ícone do app.** Ainda é o ícone padrão do Flutter.

## Próximos passos

- Redesign visual, se houver um arquivo de design. Cores, tipografia e componentes estão isolados em `lib/ui/theme/` e `lib/ui/widgets/`.
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
