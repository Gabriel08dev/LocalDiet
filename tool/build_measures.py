"""Gera assets/data/measures.jsonl a partir da Tabela de Medidas Referidas do IBGE.

Uso:
    python tool/build_measures.py [--resumo]

O PDF nao e versionado. Baixe-o de
https://biblioteca.ibge.gov.br/visualizacao/livros/liv50000.pdf e salve em
tool/source/ibge-medidas-referidas.pdf (SHA-256 em docs/NUTRITION_DATA.md).

Regras:
- Cada medida do asset vem de uma linha da tabela do IBGE e cita a pagina do
  PDF e o alimento do IBGE de onde saiu. Nenhum valor e estimado aqui.
- A correspondencia entre o alimento da TACO e o do IBGE e feita a mao, em
  MAPPING, e so para alimentos na forma em que sao consumidos: as quantidades
  do IBGE para arroz, por exemplo, sao de arroz cozido.
- Ficam de fora as linhas em que o IBGE substituiu a medida citada por outra
  (uma "caneca" de arroz registrada como "prato fundo raso"), reconhecidas
  porque a descricao da fonte nao menciona a propria medida.
- Para bebidas, o IBGE informa mililitros e adota a densidade da agua, entao
  1 ml entra como 1 g.
"""

import json
import sys
import unicodedata
from pathlib import Path

from ibge_measures import read_rows

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "assets" / "data" / "measures.jsonl"
SOURCE_NAME = "IBGE, POF 2008-2009, Tabela de Medidas Referidas"
MAX_PER_FOOD = 7

# Ordem em que as medidas aparecem no app; o que nao esta aqui nao entra.
PRIORITY = [
    "Unidade",
    "Folha",
    "Fatia",
    "Pote",
    "Colher de sopa",
    "Colher de arroz/servir",
    "Concha",
    "Escumadeira",
    "Xícara de chá",
    "Copo americano",
    "Copo médio",
    "Copo de requeijão",
    "Copo grande",
    "Lata (350 ml)",
    "Garrafa (600 ml)",
    "Caneca",
    "Xícara de café",
    "Filé",
    "Bife",
    "Posta",
    "Coxa",
    "Sobrecoxa",
    "Peito",
    "Asa",
    "Pedaço",
    "Prato raso",
    "Prato fundo",
    "Colher de sobremesa",
    "Colher de chá",
    "Colher de café",
    "Tablete",
    "Barra",
    "Rodela",
    "Gomo",
    "Espiga",
    "Cacho",
    "Punhado",
    "Ponta de faca",
    "Dose",
    "Taça",
    "Sachê",
    "Pacote",
    "Porção",
]

# Medidas que nomeiam um recipiente. Para alimentos solidos o IBGE muitas vezes
# registra essas medidas com a quantidade de outra (uma "caneca" de arroz como
# "prato fundo raso"); elas so entram quando a fonte descreve a propria medida.
CONTAINERS = {
    "Xícara de chá",
    "Xícara de café",
    "Copo americano",
    "Copo médio",
    "Copo de requeijão",
    "Copo grande",
    "Caneca",
    "Prato raso",
    "Prato fundo",
    "Lata (350 ml)",
    "Garrafa (600 ml)",
    "Pote",
    "Dose",
    "Taça",
    "Punhado",
    "Pacote",
    "Barra",
    "Tablete",
}

# Nome da medida no app, quando difere do nome no IBGE em minusculas.
LABELS = {"Colher de arroz/servir": "colher de servir"}

# Conjuntos de medidas que fazem sentido para cada tipo de alimento. A tabela
# do IBGE tambem traz, por exemplo, "copo" para laranja (o suco) e "peito"
# para coxa de frango (o alimento e "frango em pedacos"); estes conjuntos
# deixam so as medidas que descrevem o alimento da TACO.
SPOONS = ["Colher de sopa", "Colher de sobremesa", "Colher de chá", "Colher de café"]
SPREAD = SPOONS + ["Ponta de faca"]
SERVED = [
    "Colher de sopa",
    "Colher de arroz/servir",
    "Concha",
    "Escumadeira",
    "Prato raso",
    "Prato fundo",
    "Porção",
]
FRUIT = ["Unidade", "Fatia", "Rodela", "Gomo", "Cacho", "Pedaço", "Porção"]
CUT = ["Bife", "Filé", "Fatia", "Pedaço", "Porção"]
FISH = ["Filé", "Posta", "Porção"]
UNIT = ["Unidade"]
SLICE = ["Fatia", "Porção"]
BISCUIT = ["Unidade", "Pacote", "Porção"]
DRINK = [
    "Xícara de chá",
    "Xícara de café",
    "Copo americano",
    "Copo médio",
    "Copo de requeijão",
    "Copo grande",
    "Caneca",
    "Lata (350 ml)",
    "Garrafa (600 ml)",
]
YOGURT = [
    "Pote",
    "Colher de sopa",
    "Copo americano",
    "Copo médio",
    "Copo de requeijão",
    "Copo grande",
]

# (numeros na TACO, codigo do alimento no IBGE, inicio do nome da preparacao,
# medidas aproveitadas). A preparacao None corresponde a "Nao se aplica".
# Sem o quarto elemento, entram as medidas de PRIORITY que o alimento tiver.
MAPPING = [
    # Cereais, paes e massas
    ([1], "6300201", None, SERVED),
    ([3, 5], "6300101", None, SERVED),
    ([7], "6500401", None, SPOONS + ["Colher de arroz/servir", "Porção"]),
    ([8], "8002301", None, BISCUIT),
    ([9, 10], "8004801", None, BISCUIT),
    ([11, 12], "8004807", None, BISCUIT),
    ([13], "8002201", None, BISCUIT),
    ([15], "8002701", None, ["Fatia", "Pedaço"]),
    ([16], "8003801", None, ["Fatia", "Pedaço"]),
    ([17], "8004101", None, ["Fatia", "Pedaço"]),
    ([18], "8002601", None, ["Fatia", "Pedaço"]),
    ([25, 26], "6500903", None, ["Colher de sopa", "Xícara de chá", "Copo americano", "Punhado"]),
    ([45], "7700401", None, SPOONS + ["Colher de arroz/servir", "Concha"]),
    ([48, 51], "8000501", None, ["Fatia"]),
    ([52], "8001401", None, ["Fatia"]),
    ([53], "8000105", None, UNIT),
    ([56, 58], "8500202", None, UNIT),
    ([61], "8501202", None, ["Xícara de chá", "Copo americano", "Copo médio", "Copo grande"]),
    ([62], "8500218", None, SERVED + ["Pedaço"]),
    ([63], "8001901", None, ["Unidade", "Pacote"]),
    ([121, 122], "6501401", None, SPOONS + ["Colher de arroz/servir", "Xícara de chá"]),
    ([140], "8000801", None, UNIT),
    ([533], "6902901", None, ["Fatia", "Pedaço", "Colher de sopa", "Colher de arroz/servir"]),
    ([542], "6503401", "Molho vermelho", SERVED),
    ([551], "6501516", None, UNIT),
    # Leguminosas, nozes e sementes
    ([561, 563, 565, 567, 569, 571, 573], "6303102", None, SERVED),
    ([577], "6302901", None, SERVED),
    ([560], "7700201", None, SPOONS + ["Colher de arroz/servir"]),
    ([558], "6301001", None, ["Colher de sopa", "Punhado", "Pacote"]),
    ([579], "6903203", None, UNIT),
    ([588], "6600801", None, ["Unidade", "Punhado"]),
    ([589], "6600701", None, ["Unidade", "Punhado"]),
    # Carnes
    ([326], "7104301", "Cozido", SERVED),
    ([328], "7100801", "Cozido", CUT + ["Colher de arroz/servir"]),
    ([340], "7100201", "Empanado", CUT),
    ([344, 346], "7100201", "Grelhado", CUT),
    ([347], "7101301", "Assado", CUT),
    ([356], "7102501", "Grelhado", CUT),
    ([358], "7100101", "Grelhado", CUT),
    ([370], "7100301", "Grelhado", CUT),
    ([371], "7101001", "Cozido", CUT + ["Colher de sopa", "Concha"]),
    ([377], "7100501", "Grelhado", CUT),
    ([381, 383], "7100304", "Grelhado", CUT),
    ([384], "8100101", "Cozido", ["Colher de sopa", "Colher de arroz/servir", "Pedaço", "Porção"]),
    ([396], "7800302", "Assado", ["Coxa"]),
    ([398], "7800302", "Cozido", ["Coxa"]),
    ([401], "7800402", "Empanado", ["Filé", "Porção"]),
    ([403], "7800103", "Assado", ["Coxa", "Sobrecoxa", "Peito", "Asa", "Pedaço", "Porção"]),
    ([404], "7800103", "Cozido", ["Coxa", "Sobrecoxa", "Peito", "Asa", "Pedaço", "Porção"]),
    ([406], "7800401", "Assado", ["Filé", "Peito", "Porção"]),
    ([408], "7800401", "Cozido", ["Filé", "Peito", "Colher de sopa", "Colher de arroz/servir", "Porção"]),
    ([410], "7800401", "Grelhado", ["Filé", "Peito", "Porção"]),
    ([411, 413], "7800302", "Assado", ["Sobrecoxa"]),
    ([416], "8100502", "Frito", UNIT),
    ([417], "8100502", "Grelhado", UNIT),
    ([419], "8102207", "Frito", ["Unidade", "Gomo", "Rodela"]),
    ([420], "8102207", "Grelhado", ["Unidade", "Gomo", "Rodela"]),
    ([422], "8102204", "Frito", ["Unidade", "Gomo", "Rodela", "Fatia"]),
    ([423], "8102204", "Grelhado", ["Unidade", "Gomo", "Rodela"]),
    ([424], "8102601", None, ["Fatia"]),
    ([428], "7103305", "Frito", ["Bife", "Pedaço"]),
    ([429], "7103305", "Grelhado", ["Bife", "Pedaço"]),
    ([430], "7103501", "Assado", ["Unidade", "Pedaço", "Porção"]),
    ([432], "7103701", "Assado", ["Fatia", "Pedaço"]),
    ([435], "7103401", "Assado", ["Fatia", "Pedaço"]),
    ([323], "8103601", None, ["Fatia"]),
    ([438, 439], "8102901", None, ["Fatia"]),
    ([443], "8102701", None, ["Fatia"]),
    ([386], "8500205", None, UNIT),
    ([388], "8500203", None, UNIT),
    ([389], "8500206", None, UNIT),
    ([440, 442], "8500211", None, UNIT),
    # Pescados
    ([277], "7703402", None, ["Colher de sopa", "Colher de sobremesa", "Porção"]),
    ([319], "7703002", None, ["Unidade", "Colher de sopa"]),
    ([301], "7200101", "Assado", FISH),
    ([303, 305, 308], "7200101", "Frito", FISH),
    ([315, 317], "7200101", "Grelhado", FISH),
    ([313], "7400101", "Grelhado", FISH),
    # Ovos
    ([484], "8506501", None, ["Unidade", "Fatia", "Pedaço"]),
    ([488], "7803301", "Cozido", UNIT),
    ([489], "7803301", "Cru", UNIT),
    ([490], "7803301", "Frito", UNIT),
    ([485], "7803501", "Cru", UNIT),
    # Leite e derivados
    ([447], "7901001", None, SPOONS + ["Colher de arroz/servir"]),
    ([448], "7901204", None, YOGURT),
    ([449], "7901203", None, YOGURT),
    ([450, 451, 452], "7901201", None, YOGURT),
    ([453], "7900901", None, SPOONS),
    ([455], "7903102", None, DRINK),
    ([456], "7900710", None, SPOONS),
    ([457], "7903601", None, DRINK),
    ([458], "7900101", None, DRINK),
    ([459], "7900601", None, SPOONS),
    ([460], "7901304", None, ["Unidade", "Copo médio"]),
    ([461], "7902001", None, SLICE),
    ([463], "7901801", None, SLICE),
    ([467], "7901701", None, SLICE),
    ([468], "7902901", None, SPREAD),
    ([469], "7902201", None, ["Fatia", "Colher de sopa", "Porção"]),
    ([261, 262], "7901501", None, SPREAD),
    ([263, 264, 265, 266], "7901602", None, SPREAD),
    # Frutas
    ([163], "6802701", None, FRUIT + ["Colher de sopa"]),
    ([164], "6802601", None, FRUIT),
    ([172], "6804301", None, FRUIT),
    ([175, 178, 179, 180, 182], "6801101", "Cru", FRUIT),
    ([189], "6802801", None, FRUIT),
    ([197, 200], "6804201", None, FRUIT),
    ([207], "6807801", None, FRUIT),
    ([208, 210, 212, 214, 216], "6801801", None, FRUIT),
    ([209, 211, 213, 215, 217], "8500407", None, DRINK),
    ([220], "6802001", None, FRUIT),
    ([221, 222], "6803001", None, FRUIT),
    ([225, 226], "6803101", None, FRUIT + ["Colher de sopa"]),
    ([228, 229, 231], "6803201", None, FRUIT),
    ([232], "6803301", None, UNIT),
    ([235], "6803401", None, FRUIT),
    ([236], "6803501", None, FRUIT),
    ([237, 238], "6802202", None, FRUIT),
    ([239], "6805201", None, FRUIT),
    ([242, 243], "6803601", None, FRUIT),
    ([244], "6803701", None, FRUIT),
    ([251], "6802201", None, FRUIT),
    ([256, 257], "6803901", None, FRUIT),
    # Verduras e legumes
    ([64], "6703901", "Cozido"),
    ([68], "6703901", "Refogado"),
    ([70], "6703701", "Cozido"),
    ([72], "6703701", "Refogado"),
    ([75], "6701301", "Cru"),
    ([77, 78, 79, 80], "6700101", None),
    ([88], "6400401", "Cozido"),
    ([91], "6400101", "Cozido"),
    ([93], "6400101", "Frito"),
    ([95], "6705401", "Cozido"),
    ([97], "6401101", "Cozido"),
    ([98], "6401101", "Cru"),
    ([100], "6701704", "Cozido"),
    ([107], "6705701", "Cru"),
    ([109], "6401201", "Cozido"),
    ([110], "6401201", "Cru"),
    ([112], "6704101", "Cozido"),
    ([115], "6700501", "Cru"),
    ([116], "6700501", "Refogado"),
    ([118], "6700601", "Cozido"),
    ([129], "6400601", "Cozido"),
    ([132], "6400601", "Frito"),
    ([142], "6704001", None),
    ([149], "6700901", "Cru"),
    ([151], "6700901", "Refogado"),
    ([152], "6702001", None),
    ([157, 161], "6705101", None),
    ([159], "7004801", None, SPOONS + ["Colher de arroz/servir", "Concha"]),
    # Gorduras, acucares, bebidas e preparacoes
    ([260], "8400101", None, SPOONS),
    ([272], "8400301", None, SPOONS),
    ([491], "6900821", None, SPOONS),
    ([492, 494], "6906602", None, SPOONS + ["Sachê"]),
    ([493], "6900304", None, SPOONS),
    ([495, 498], "6900702", None, ["Unidade", "Barra", "Tablete", "Pedaço"]),
    ([501], "6904201", None, SPOONS + ["Pedaço", "Unidade"]),
    ([524], "7004301", None, SPREAD + ["Sachê"]),
    ([471], "8501302", None, DRINK),
    ([474], "8300101", None, DRINK),
    ([478], "8202101", None, DRINK),
    ([480], "8200101", None, DRINK),
    ([481], "8200301", None, DRINK),
    ([131], "8502201", None, SERVED),
    ([526], "8579002", None, SERVED),
    ([527], "8503501", None, SERVED),
    ([537, 538], "7705401", None, SERVED),
    ([540], "7701901", None, SERVED),
    ([545], "8500802", None, SERVED),
    ([584], "7903402", None),
]


def normalize(text):
    decomposed = unicodedata.normalize("NFD", text.lower())
    return "".join(c for c in decomposed if unicodedata.category(c) != "Mn")


def is_own_measure(row):
    """Falso quando o IBGE registrou um recipiente com a quantidade de outro."""
    if row.measure not in CONTAINERS:
        return True
    keyword = normalize(row.measure).split()[0]
    return keyword in normalize(row.note)


def select(rows, only=None):
    """As medidas de um alimento que entram no app, na ordem de exibicao."""
    allowed = PRIORITY if only is None else only
    by_measure = {}
    for row in rows:
        if row.measure in allowed and row.quantity > 0 and is_own_measure(row):
            by_measure.setdefault(row.measure, row)
    ordered = sorted(by_measure.values(), key=lambda row: PRIORITY.index(row.measure))
    return ordered[:MAX_PER_FOOD]


def main():
    summary = "--resumo" in sys.argv
    rows, unreadable = read_rows()
    if unreadable:
        raise SystemExit(f"{unreadable} trechos da tabela nao puderam ser lidos")

    by_food = {}
    for row in rows:
        by_food.setdefault(row.food_code, []).append(row)

    taco = {
        food["n"]: food["name"]
        for food in map(json.loads, (ROOT / "assets/data/taco.jsonl").open(encoding="utf-8"))
    }

    lines = []
    seen = set()
    for numbers, code, preparation, *rest in MAPPING:
        only = rest[0] if rest else None
        if code not in by_food:
            raise SystemExit(f"codigo do IBGE desconhecido: {code}")
        wanted = "Não se aplica" if preparation is None else preparation
        matching = [r for r in by_food[code] if r.preparation.startswith(wanted)]
        if not matching:
            available = sorted({r.preparation for r in by_food[code]})
            raise SystemExit(f"{code}: sem preparacao '{wanted}'; ha {available}")
        chosen = select(matching, only)
        if not chosen:
            raise SystemExit(f"{code} ({wanted}): nenhuma medida aproveitavel")
        for number in numbers:
            if number not in taco:
                raise SystemExit(f"numero da TACO desconhecido: {number}")
            if number in seen:
                raise SystemExit(f"alimento da TACO repetido no mapeamento: {number}")
            seen.add(number)
            if summary:
                listed = ", ".join(
                    f"{LABELS.get(r.measure, r.measure.lower())}={r.quantity:g}" for r in chosen
                )
                print(f"{number} {taco[number]} <- {chosen[0].food} [{wanted}]: {listed}")
            for row in chosen:
                lines.append(
                    {
                        "food": number,
                        "label": LABELS.get(row.measure, row.measure.lower()),
                        "grams": row.quantity,
                        "ref": f"{SOURCE_NAME}, p. {row.page} do PDF: {row.food}",
                    }
                )

    lines.sort(key=lambda line: line["food"])
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT.open("w", encoding="utf-8", newline="\n") as handle:
        for line in lines:
            handle.write(json.dumps(line, ensure_ascii=False, separators=(",", ":")) + "\n")
    print(f"{len(lines)} medidas para {len(seen)} alimentos -> {OUTPUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
