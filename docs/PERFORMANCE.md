# Desempenho

**Nenhuma medição foi feita em Android nesta versão.** A máquina de desenvolvimento não tinha aparelho conectado. Os números abaixo ainda precisam ser coletados; nada aqui é estimativa.

## O que medir em um aparelho físico

| Medida | Como |
|---|---|
| Partida a frio | Tempo do toque no ícone até o Início, com o app já aberto uma vez |
| Primeira abertura | O mesmo, logo após instalar: inclui a importação dos 597 alimentos |
| Primeira busca | Do último caractere digitado ao resultado, na primeira busca após abrir |
| Buscas seguintes | O mesmo, com o banco já aquecido |
| Quadros lentos | Abertura do teclado na busca e rolagem do Diário, em modo profile |

Use um build em modo profile:

```bash
flutter run --profile
```

Registre o modelo do aparelho, a versão do Android e a versão do app junto dos números.

## Referência da primeira versão do app

Medidos no Windows, na primeira versão do app, e úteis apenas como ordem de grandeza:

| Operação | Tempo |
|---|---|
| Importação da TACO | 320 a 395 ms |
| Primeira busca | 6 a 8 ms |
| Buscas seguintes | 1,4 a 2,8 ms |

## O que já está no projeto

- O banco roda em isolate de segundo plano, então consultas e a importação não bloqueiam a interface.
- A importação só roda quando o conteúdo do asset muda.
- A busca espera 250 ms depois da última tecla e devolve no máximo 40 resultados.
