"""Converte a planilha oficial da TACO (4a edicao, NEPA/UNICAMP) em assets/data/taco.jsonl.

Uso:
    python tool/build_taco.py [caminho-do-xlsx]

A planilha nao e versionada. Baixe-a de
https://nepa.unicamp.br/publicacoes/tabela-taco-excel/ e salve em
tool/source/Taco-4a-Edicao.xlsx (SHA-256 registrado em docs/NUTRITION_DATA.md).

Regras de conversao:
- Uma linha JSON por alimento, na ordem do numero do alimento na TACO.
- Valores numericos sao arredondados (meio para cima) com a mesma precisao da
  tabela publicada em PDF, porque a planilha traz as medias sem arredondar.
- "Tr" (traco), "NA" (nao aplicavel) e "*" (analise em reavaliacao) sao
  preservados como texto. Celula vazia (analise nao solicitada) vira null.
- Nenhum valor e estimado ou preenchido.
"""

import hashlib
import json
import sys
from decimal import ROUND_HALF_UP, Decimal
from pathlib import Path

import openpyxl

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_SOURCE = ROOT / "tool" / "source" / "Taco-4a-Edicao.xlsx"
OUTPUT = ROOT / "assets" / "data" / "taco.jsonl"
SHEET = "CMVCol taco3"
EXPECTED_FOODS = 597

# (indice da coluna, chave no JSON, casas decimais na tabela publicada)
COLUMNS = [
    (2, "moisture_pct", 1),
    (3, "energy_kcal", 0),
    (4, "energy_kj", 0),
    (5, "protein_g", 1),
    (6, "lipid_g", 1),
    (7, "cholesterol_mg", 0),
    (8, "carb_g", 1),
    (9, "fiber_g", 1),
    (10, "ash_g", 1),
    (11, "calcium_mg", 0),
    (12, "magnesium_mg", 0),
    (14, "manganese_mg", 2),
    (15, "phosphorus_mg", 0),
    (16, "iron_mg", 1),
    (17, "sodium_mg", 0),
    (18, "potassium_mg", 0),
    (19, "copper_mg", 2),
    (20, "zinc_mg", 1),
    (21, "retinol_mcg", 0),
    (22, "re_mcg", 0),
    (23, "rae_mcg", 0),
    (24, "thiamine_mg", 2),
    (25, "riboflavin_mg", 2),
    (26, "pyridoxine_mg", 2),
    (27, "niacin_mg", 2),
    (28, "vitamin_c_mg", 1),
]

SYMBOLS = {"Tr", "NA", "*"}

# Na planilha, estes dois nomes terminam com o numero da nota de rodape sobre
# teor alcoolico. O numero nao faz parte do nome do alimento.
FOOTNOTE_NAMES = {
    "Cana, aguardente 1": "Cana, aguardente",
    "Cerveja, pilsen 2": "Cerveja, pilsen",
}

# Na planilha, o alimento 540 traz apenas "L" como descricao. Pela posicao na
# ordem alfabetica do grupo "Alimentos preparados" (entre "Feijao tropeiro
# mineiro" e "Frango, com acafrao") e pela composicao, e a feijoada.
NAME_FIXES = {540: ("L", "Feijoada")}


def round_half_up(value, places):
    quantum = Decimal(1).scaleb(-places)
    rounded = Decimal(repr(float(value))).quantize(quantum, rounding=ROUND_HALF_UP)
    return int(rounded) if places == 0 else float(rounded)


def convert_cell(value, places, context):
    if value is None:
        return None
    if isinstance(value, bool):
        raise ValueError(f"valor booleano inesperado em {context}")
    if isinstance(value, (int, float)):
        return round_half_up(value, places)
    text = str(value).strip()
    if text == "":
        return None
    if text in SYMBOLS:
        return text
    # A planilha tem celulas numericas digitadas como texto (ex.: ",0,02").
    cleaned = text.strip(",").replace(",", ".")
    try:
        return round_half_up(float(cleaned), places)
    except ValueError as error:
        raise ValueError(f"valor nao reconhecido {text!r} em {context}") from error


def main():
    source = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_SOURCE
    workbook = openpyxl.load_workbook(source, data_only=True)
    sheet = workbook[SHEET]

    foods = []
    category = None
    for row in sheet.iter_rows(values_only=True):
        row = row[:29]
        first, second = row[0], row[1]
        is_food = isinstance(first, (int, float)) and isinstance(second, str)
        if is_food:
            number = int(first)
            if row[13] != first:
                raise ValueError(f"numero divergente na linha do alimento {number}")
            if category is None:
                raise ValueError(f"alimento {number} sem categoria")
            name = " ".join(second.split())
            name = FOOTNOTE_NAMES.get(name, name)
            if number in NAME_FIXES:
                found, fixed = NAME_FIXES[number]
                if name != found:
                    raise ValueError(f"alimento {number}: esperado {found!r}, veio {name!r}")
                name = fixed
            food = {"n": number, "name": name, "category": category}
            for index, key, places in COLUMNS:
                food[key] = convert_cell(row[index], places, f"alimento {number}, {key}")
            foods.append(food)
        elif isinstance(first, str) and all(cell is None for cell in row[1:]):
            title = first.strip()
            if title == "Legenda":
                break
            category = title

    numbers = [food["n"] for food in foods]
    if len(foods) != EXPECTED_FOODS or numbers != list(range(1, EXPECTED_FOODS + 1)):
        raise SystemExit(f"esperados {EXPECTED_FOODS} alimentos em sequencia, obtidos {len(foods)}")

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT.open("w", encoding="utf-8", newline="\n") as handle:
        for food in foods:
            handle.write(json.dumps(food, ensure_ascii=False, separators=(",", ":")) + "\n")

    digest = hashlib.sha256(source.read_bytes()).hexdigest()
    categories = sorted({food["category"] for food in foods})
    print(f"{len(foods)} alimentos, {len(categories)} categorias -> {OUTPUT.relative_to(ROOT)}")
    print(f"sha256 da planilha: {digest}")


if __name__ == "__main__":
    main()
