"""Leitura da Tabela de Medidas Referidas do IBGE (POF 2008-2009).

A publicacao traz, para cada alimento citado na pesquisa, as medidas caseiras
referidas e a quantidade em gramas (ou mililitros) de cada uma. As paginas da
tabela estao giradas no PDF, mas a ordem de leitura do texto extraido segue as
linhas da tabela, com seis campos por linha:

    codigo e nome do alimento
    codigo e nome da preparacao
    codigo e nome da medida referida
    codigo e nome da medida padrao
    quantidade
    numero da fonte e descricao da medida na fonte

Este modulo so le o PDF. Quem decide o que entra no app e build_measures.py.
"""

import re
from dataclasses import dataclass
from pathlib import Path

import pymupdf

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "tool" / "source" / "ibge-medidas-referidas.pdf"

FOOD_LINE = re.compile(r"^(\d{7}) (.+)$")
CODED_LINE = re.compile(r"^(\d{1,3}) (.+)$")
NUMBER_LINE = re.compile(r"^\d+(?: \d{3})*(?:,\d+)?$")


@dataclass(frozen=True)
class Row:
    page: int  # pagina do PDF, contada a partir de 1
    food_code: str
    food: str
    preparation_code: int
    preparation: str
    measure_code: int
    measure: str
    quantity: float
    note: str


def _number(text):
    return float(text.replace(" ", "").replace(",", "."))


def _parse_chunk(page, lines):
    """Monta uma linha da tabela a partir das linhas de texto de um alimento."""
    match = FOOD_LINE.match(lines[0])
    food_code, food = match.group(1), match.group(2)
    fields = []  # preparacao, medida, medida padrao
    quantity = None
    note = []
    target = "food"
    for line in lines[1:]:
        if quantity is None and len(fields) == 3 and NUMBER_LINE.match(line):
            quantity = _number(line)
            target = "note"
            continue
        coded = CODED_LINE.match(line)
        if quantity is None and coded and len(fields) < 3:
            fields.append([int(coded.group(1)), coded.group(2)])
            target = "field"
            continue
        if target == "food":
            food += " " + line
        elif target == "field":
            fields[-1][1] += " " + line
        else:
            note.append(line)
    if len(fields) != 3 or quantity is None:
        return None
    return Row(
        page=page,
        food_code=food_code,
        food=" ".join(food.split()),
        preparation_code=fields[0][0],
        preparation=" ".join(fields[0][1].split()),
        measure_code=fields[1][0],
        measure=" ".join(fields[1][1].split()),
        quantity=quantity,
        note=" ".join(" ".join(note).split()),
    )


def read_rows(source=SOURCE):
    """Devolve as linhas da tabela e quantos trechos nao puderam ser lidos."""
    document = pymupdf.open(source)
    rows = []
    unreadable = 0
    for index in range(document.page_count):
        lines = [
            line.strip()
            for line in document[index].get_text().splitlines()
            if line.strip()
        ]
        starts = [i for i, line in enumerate(lines) if FOOD_LINE.match(line)]
        for position, start in enumerate(starts):
            end = starts[position + 1] if position + 1 < len(starts) else len(lines)
            row = _parse_chunk(index + 1, lines[start:end])
            if row is None:
                unreadable += 1
            else:
                rows.append(row)
    return rows, unreadable


if __name__ == "__main__":
    import collections
    import sys

    rows, unreadable = read_rows()
    foods = collections.OrderedDict()
    for row in rows:
        foods.setdefault((row.food_code, row.food), []).append(row)
    print(f"{len(rows)} linhas, {len(foods)} alimentos, {unreadable} trechos ilegiveis")
    terms = [term.lower() for term in sys.argv[1:]]
    for (code, name), food_rows in foods.items():
        if terms and not all(term in name.lower() for term in terms):
            continue
        if not terms:
            continue
        print(f"\n{code} {name}")
        for row in food_rows:
            print(
                f"  p.{row.page} [{row.preparation}] {row.measure}: "
                f"{row.quantity:g} ({row.note})"
            )
