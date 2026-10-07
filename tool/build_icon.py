"""Gera o icone do app para Android.

Uso:
    python tool/build_icon.py

Requer o pacote Pillow. Escreve os PNGs usados ate o Android 7 em
android/app/src/main/res/mipmap-*/ic_launcher.png. Do Android 8 em diante o
icone e adaptativo e vem dos XMLs em drawable/ e mipmap-anydpi-v26/, que usam
as mesmas cores e o mesmo desenho: um anel de progresso com um ponto no
centro, sobre o degrade lilas, azul e menta do app.
"""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "android" / "app" / "src" / "main" / "res"
SIZES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
GRADIENT = [(0x8E, 0x7C, 0xFF), (0x6F, 0xB8, 0xFF), (0x62, 0xDD, 0xB4)]
SCALE = 4  # desenha maior e reduz, para bordas suaves


def gradient(size):
    """Degrade diagonal, do canto superior esquerdo ao inferior direito."""
    image = Image.new("RGB", (size, size))
    pixels = image.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * (size - 1))
            first, second = (GRADIENT[0], GRADIENT[1]) if t < 0.5 else (GRADIENT[1], GRADIENT[2])
            local = t * 2 if t < 0.5 else (t - 0.5) * 2
            pixels[x, y] = tuple(round(a + (b - a) * local) for a, b in zip(first, second))
    return image


def render(size):
    big = size * SCALE
    base = gradient(big).convert("RGBA")
    mask = Image.new("L", (big, big), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, big - 1, big - 1), radius=round(big * 0.24), fill=255)
    base.putalpha(mask)

    draw = ImageDraw.Draw(base)
    center = big / 2
    radius = big * 0.24
    stroke = round(big * 0.085)
    box = (center - radius, center - radius, center + radius, center + radius)
    # Tres quartos de volta, comecando no topo.
    draw.arc(box, start=-90, end=180, fill="white", width=stroke)
    for angle_point in ((center, center - radius + stroke / 2), (center - radius + stroke / 2, center)):
        x, y = angle_point
        draw.ellipse((x - stroke / 2, y - stroke / 2, x + stroke / 2, y + stroke / 2), fill="white")
    dot = big * 0.07
    draw.ellipse((center - dot, center - dot, center + dot, center + dot), fill="white")
    return base.resize((size, size), Image.LANCZOS)


def main():
    for density, size in SIZES.items():
        target = RES / f"mipmap-{density}" / "ic_launcher.png"
        render(size).save(target)
        print(target.relative_to(ROOT))


if __name__ == "__main__":
    main()
