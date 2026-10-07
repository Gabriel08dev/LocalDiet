"""Gera o icone do app e a marca usada nas telas, a partir do logo.

Uso:
    python tool/build_icon.py

Requer os pacotes Pillow e numpy. A fonte e docs/brand/nutriviva.jpg, o logo
do NutriViva: o simbolo (N com folha dentro do anel) e, embaixo, o nome.

O script separa o simbolo do fundo claro do logo e escreve:

- assets/brand/mark.png: o simbolo com fundo transparente, usado no app;
- mipmap-*/ic_launcher_foreground.png e ic_launcher_monochrome.png: as
  camadas do icone adaptativo (Android 8 em diante), com o simbolo dentro da
  area segura;
- mipmap-*/ic_launcher.png: o icone pronto, para o Android 7.

A cor de fundo do icone adaptativo fica em values/colors.xml e e a mesma do
fundo do logo.
"""

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "docs" / "brand" / "nutriviva.jpg"
RES = ROOT / "android" / "app" / "src" / "main" / "res"
MARK = ROOT / "assets" / "brand" / "mark.png"

# Fundo do logo. O mesmo valor esta em values/colors.xml e em brandPaper.
PAPER = (0xFD, 0xFA, 0xF3)
# O simbolo ocupa a parte de cima da imagem; o nome fica abaixo desta linha.
SYMBOL_BOTTOM = 945

DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
ADAPTIVE_DP = 108
# Raio da area segura do icone adaptativo: o que estiver dentro dele aparece
# em qualquer formato de mascara.
SAFE_RADIUS_DP = 33
LEGACY_DP = 48
MARK_SIZE = 512


def extract_symbol():
    """Devolve o simbolo em RGBA, com a transparencia calculada.

    Cada pixel da borda e uma mistura do fundo com um dos dois verdes do
    logo. A proporcao dessa mistura vira a opacidade, e a cor volta a ser o
    verde puro. Assim o simbolo pode ser desenhado sobre qualquer fundo sem
    contorno claro.
    """
    image = Image.open(SOURCE).convert("RGB").crop((0, 0, 1264, SYMBOL_BOTTOM))
    pixels = np.asarray(image, dtype=np.float32)
    paper = np.array(PAPER, dtype=np.float32)
    offset = pixels - paper
    distance = np.linalg.norm(offset, axis=2)

    # Os dois verdes do logo, medidos na propria imagem.
    solid = distance > 150
    dark = np.median(pixels[solid & (pixels[..., 0] < 80)], axis=0)
    light = np.median(pixels[solid & (pixels[..., 0] >= 80)], axis=0)

    best_residual = np.full(distance.shape, np.inf, dtype=np.float32)
    alpha = np.zeros(distance.shape, dtype=np.float32)
    color = np.zeros(pixels.shape, dtype=np.float32)
    for ink in (dark, light):
        direction = ink - paper
        amount = offset @ direction / (direction @ direction)
        residual = np.linalg.norm(offset - amount[..., None] * direction, axis=2)
        closer = residual < best_residual
        best_residual[closer] = residual[closer]
        alpha[closer] = amount[closer]
        color[closer] = ink
    alpha = np.clip(alpha, 0, 1)
    alpha[alpha < 0.05] = 0
    # No miolo das formas fica a cor original, com as variacoes do desenho.
    inside = alpha > 0.97
    alpha[inside] = 1
    color[inside] = pixels[inside]

    rgba = np.dstack([color, alpha * 255]).round().astype(np.uint8)
    symbol = Image.fromarray(rgba, "RGBA")
    return symbol.crop(symbol.getchannel("A").getbbox())


def enclosing_circle(symbol):
    """Centro e raio do menor circulo que contem o simbolo."""
    opaque = np.argwhere(np.asarray(symbol.getchannel("A")) > 40)[::7]
    points = opaque[:, ::-1].astype(np.float64)  # (x, y)
    center = points.mean(axis=0)
    for step in range(1, 2000):
        farthest = points[np.argmax(np.linalg.norm(points - center, axis=1))]
        center += (farthest - center) / (step + 1)
    radius = np.linalg.norm(points - center, axis=1).max()
    return center, radius


def resize(image, scale):
    size = (max(1, round(image.width * scale)), max(1, round(image.height * scale)))
    # Reduz com a cor ja multiplicada pela opacidade, para nao criar halo.
    return image.convert("RGBa").resize(size, Image.LANCZOS).convert("RGBA")


def place(symbol, center, radius, canvas, target_radius):
    """O simbolo em uma tela quadrada, com o circulo que o contem centrado."""
    scale = target_radius / radius
    scaled = resize(symbol, scale)
    layer = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    left = round(canvas / 2 - center[0] * scale)
    top = round(canvas / 2 - center[1] * scale)
    layer.alpha_composite(scaled, (left, top))
    return layer


def monochrome(layer):
    """A mesma forma em uma cor so, que o Android pinta no icone tematico."""
    white = Image.new("RGBA", layer.size, (255, 255, 255, 0))
    white.putalpha(layer.getchannel("A"))
    return white


def legacy(symbol, center, radius, size):
    """O icone pronto: o simbolo sobre o fundo do logo, com cantos redondos."""
    big = size * 4
    tile = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    ImageDraw.Draw(tile).rounded_rectangle(
        (0, 0, big - 1, big - 1), radius=round(big * 0.22), fill=PAPER + (255,)
    )
    tile.alpha_composite(place(symbol, center, radius, big, big * 0.44))
    return tile.resize((size, size), Image.LANCZOS)


def main():
    symbol = extract_symbol()
    center, radius = enclosing_circle(symbol)

    MARK.parent.mkdir(parents=True, exist_ok=True)
    place(symbol, center, radius, MARK_SIZE, MARK_SIZE / 2).save(MARK, optimize=True)
    print(MARK.relative_to(ROOT))

    for density, factor in DENSITIES.items():
        folder = RES / f"mipmap-{density}"
        canvas = round(ADAPTIVE_DP * factor)
        foreground = place(symbol, center, radius, canvas, SAFE_RADIUS_DP * factor)
        foreground.save(folder / "ic_launcher_foreground.png", optimize=True)
        monochrome(foreground).save(folder / "ic_launcher_monochrome.png", optimize=True)
        legacy(symbol, center, radius, round(LEGACY_DP * factor)).save(
            folder / "ic_launcher.png", optimize=True
        )
        print(folder.relative_to(ROOT))


if __name__ == "__main__":
    main()
