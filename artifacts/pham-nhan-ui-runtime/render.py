"""Deterministic 1536x1024 UI review renderer.

The renderer mirrors the in-game fit-to-safe-area contract. Individual screen
layouts are registered incrementally as the Lua panels are rebuilt.
"""
from __future__ import annotations

import argparse
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

DESIGN = (1536, 1024)
BG = (10, 12, 20, 255)
PANEL = (19, 23, 36, 250)
SILVER = (195, 205, 224, 255)
PURPLE = (126, 78, 207, 255)
CYAN = (98, 192, 250, 255)


def font(size: int) -> ImageFont.FreeTypeFont:
    source = Path(__file__).parents[2] / "mods/PhamNhanTuTien/fonts/source/NotoSerif-Medium.ttf"
    return ImageFont.truetype(str(source), size)


def theme_preview() -> Image.Image:
    image = Image.new("RGBA", DESIGN, BG)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((64, 54, 1472, 970), 22, fill=PANEL, outline=SILVER, width=3)
    draw.polygon(((768, 28), (794, 54), (768, 80), (742, 54)), fill=PURPLE, outline=SILVER)
    draw.text((768, 118), "PHÀM NHÂN TU TIÊN", font=font(52), fill=SILVER, anchor="mm")
    draw.text((768, 190), "ARTIFACT UI • 1536 × 1024", font=font(28), fill=CYAN, anchor="mm")
    draw.line((136, 246, 1400, 246), fill=CYAN, width=2)
    for index, (name, colour) in enumerate((
        ("NềN", BG), ("PANEL", PANEL), ("BẠC", SILVER), ("TÍM", PURPLE), ("CYAN", CYAN)
    )):
        x = 244 + index * 260
        draw.rounded_rectangle((x - 82, 340, x + 82, 504), 16, fill=colour, outline=SILVER, width=2)
        draw.text((x, 548), name, font=font(24), fill=SILVER, anchor="mm")
    draw.text((768, 726), "Tiếng Việt: Cường hóa • Thần Binh Phổ • Kế Thừa", font=font(34), fill=SILVER, anchor="mm")
    draw.text((768, 812), "Fit-to-safe-area • không crop • không scale lồng nhau", font=font(25), fill=CYAN, anchor="mm")
    return image


def shell_preview() -> Image.Image:
    reference = Path(__file__).parents[1] / "pham-nhan-unified-ui/trang-bi-phac-thao.png"
    return Image.open(reference).convert("RGBA")


def artifact_preview(relative: str):
    def render() -> Image.Image:
        return Image.open(Path(__file__).parents[1] / relative).convert("RGBA")
    return render


def unified_canvas(active: int, title: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    image = shell_preview().copy()
    draw = ImageDraw.Draw(image)
    draw.rectangle((132, 286, 1404, 900), fill=(12, 14, 23, 255))
    tabs = ("Nhan vat", "Trang bi", "Nhiem vu", "Quan doan", "Cua hang", "Kho")
    for index, label in enumerate(tabs):
        x1 = 142 + index * 203
        fill = (164, 116, 216, 255) if index == active else (25, 22, 32, 255)
        draw.rectangle((x1, 178, x1 + 194, 226), fill=fill, outline=SILVER, width=2)
        draw.text((x1 + 97, 202), label, font=font(24), fill=(18, 16, 24, 255) if index == active else SILVER, anchor="mm")
    draw.text((768, 320), title, font=font(38), fill=SILVER, anchor="mm")
    draw.line((190, 354, 1346, 354), fill=CYAN, width=2)
    return image, draw


def character_preview() -> Image.Image:
    image, draw = unified_canvas(0, "NHAN VAT")
    draw.text((350, 408), "THUOC TINH", font=font(26), fill=CYAN, anchor="mm")
    rows = (("Suc manh", "18", "+1.5 sat thuong"), ("Nhanh nhen", "14", "+1.2% toc do"),
            ("The chat", "22", "+20 mau"), ("Cam quan", "12", "+1% chi mang"),
            ("Tri tue", "16", "+20 mana"))
    for i, (name, value, desc) in enumerate(rows):
        y = 470 + i * 76
        draw.rounded_rectangle((190, y - 28, 620, y + 28), 8, fill=(27, 27, 42, 255), outline=(92, 82, 115, 255), width=2)
        draw.text((214, y), name, font=font(23), fill=SILVER, anchor="lm")
        draw.text((475, y), value, font=font(24), fill=CYAN, anchor="mm")
        draw.text((602, y), desc, font=font(16), fill=(170, 170, 187, 255), anchor="rm")
    draw.line((700, 390, 700, 830), fill=(92, 82, 115, 255), width=2)
    draw.rounded_rectangle((770, 418, 1260, 650), 16, fill=(22, 21, 34, 255), outline=SILVER, width=2)
    draw.text((1015, 462), "CAP 35  •  RANK A", font=font(27), fill=CYAN, anchor="mm")
    draw.text((1015, 522), "EXP 7,850 / 10,000", font=font(23), fill=SILVER, anchor="mm")
    draw.rectangle((835, 554, 1195, 570), fill=(49, 45, 62, 255))
    draw.rectangle((835, 554, 1118, 570), fill=PURPLE)
    draw.text((1015, 610), "Diem tiem nang: 4", font=font(24), fill=(255, 215, 76, 255), anchor="mm")
    draw.rounded_rectangle((812, 700, 1218, 765), 8, fill=(75, 54, 112, 255), outline=SILVER, width=2)
    draw.text((1015, 732), "Thanh tuu • Mua • Dac quyen", font=font(22), fill=SILVER, anchor="mm")
    return image


def quest_preview(mode: int) -> Image.Image:
    image, draw = unified_canvas(2, "NHIEM VU")
    subtabs = ("Hang ngay", "Hiep hoi", "Thang rank")
    for i, label in enumerate(subtabs):
        x1 = 350 + i * 280
        draw.rounded_rectangle((x1, 374, x1 + 250, 424), 7,
                               fill=(164, 116, 216, 255) if i == mode else (26, 23, 35, 255),
                               outline=SILVER, width=2)
        draw.text((x1 + 125, 399), label, font=font(22), fill=SILVER, anchor="mm")
    titles = ("NHIEM VU NGAY", "NHIEM VU HIEP HOI", "THU THACH THANG RANK")
    accents = (CYAN, (255, 154, 55, 255), (208, 118, 242, 255))
    draw.text((768, 475), titles[mode], font=font(31), fill=accents[mode], anchor="mm")
    cards = ((210, 520, 650, 795), (688, 520, 1128, 795)) if mode != 2 else ((330, 520, 1206, 795),)
    for index, box in enumerate(cards):
        draw.rounded_rectangle(box, 14, fill=(25, 25, 39, 255), outline=(105, 92, 126, 255), width=2)
        cx = (box[0] + box[2]) // 2
        draw.text((cx, box[1] + 55), "Muc tieu" if index == 0 else "Phan thuong", font=font(25), fill=SILVER, anchor="mm")
        draw.text((cx, box[1] + 125), "Tieu diet quai va hoan thanh tien do", font=font(19), fill=(180, 181, 198, 255), anchor="mm")
        draw.text((cx, box[1] + 205), "Con lai 02:35", font=font(19), fill=CYAN, anchor="mm")
    return image


def army_preview() -> Image.Image:
    image, draw = unified_canvas(3, "QUAN DOAN")
    names = ("Igris Lv.10", "Beru [Khoa]", "Fruitfly [Khoa]", "Mac Anh [Khoa]", "Hac Anh [Khoa]")
    for i, name in enumerate(names):
        x1 = 190 + i * 230
        draw.rounded_rectangle((x1, 375, x1 + 210, 425), 7,
                               fill=(89, 60, 127, 255) if i == 0 else (26, 23, 35, 255),
                               outline=SILVER, width=2)
        draw.text((x1 + 105, 400), name, font=font(18), fill=SILVER, anchor="mm")
    draw.rounded_rectangle((190, 455, 640, 815), 14, fill=(22, 21, 34, 255), outline=(105, 92, 126, 255), width=2)
    draw.text((415, 505), "IGRIS", font=font(31), fill=(203, 129, 244, 255), anchor="mm")
    draw.polygon(((415, 545), (485, 655), (415, 735), (345, 655)), fill=(78, 38, 133, 255), outline=SILVER)
    draw.text((415, 775), "Cap 10 / 30  •  EXP 250 / 820", font=font(19), fill=SILVER, anchor="mm")
    draw.rounded_rectangle((680, 455, 1345, 815), 14, fill=(22, 21, 34, 255), outline=(105, 92, 126, 255), width=2)
    talents = ((5, "Thep Den", "Giam 10% sat thuong nhan vao"), (10, "Khieu Khich", "Tang mau va uu tien muc tieu"),
               (15, "Kiem Thuat", "Tang sat thuong gay ra"), (20, "Ho Chu", "Phan ung khi chu nhan bi danh"),
               (25, "Bat Khuat", "Tang toc do khi thap mau"), (30, "Loi The Ky Si", "Hoi sinh mot lan moi luot"))
    for i, (level, name, desc) in enumerate(talents):
        y = 495 + i * 49
        draw.text((712, y), f"Lv.{level}", font=font(17), fill=(255, 216, 91, 255), anchor="lm")
        draw.text((805, y), name, font=font(19), fill=SILVER if level <= 10 else (110, 110, 125, 255), anchor="lm")
        draw.text((1020, y), desc, font=font(15), fill=(174, 175, 194, 255), anchor="lm")
    return image


def shop_preview() -> Image.Image:
    image, draw = unified_canvas(4, "CUA HANG HAM NGUC")
    categories = ("Thuoc Tho San", "Thuoc De Tu", "Vat Pham", "Vu Khi")
    for i, label in enumerate(categories):
        x1 = 260 + i * 260
        draw.text((x1 + 100, 392), label, font=font(19), fill=(255, 211, 55, 255) if i == 0 else SILVER, anchor="mm")
    draw.text((230, 438), "Stock luan phien • Chu ky 0", font=font(19), fill=SILVER, anchor="lm")
    products = ("Thuoc Chinh Phat", "Thuoc Ho The", "Thuoc Tinh Tam", "Thuoc Hon Huyet", "Thuoc Hoc Gia",
                "Thuoc Ma Luc", "Thuoc Bao Kich", "Thuoc Toan Nang", "Thuoc Phong Toc", "Thuoc Sinh Menh")
    prices = (220, 150, 90, 240, 180, 120, 210, 300, 100, 170)
    for i, name in enumerate(products):
        col, row = i % 5, i // 5
        x = 250 + col * 220
        y = 510 + row * 165
        draw.polygon(((x, y - 36), (x + 34, y), (x, y + 36), (x - 34, y)), fill=(71, 34, 119, 255), outline=SILVER)
        draw.text((x, y + 58), name, font=font(17), fill=SILVER, anchor="mm")
        draw.text((x, y + 88), f"{prices[i]} Xu   Stock 2", font=font(16), fill=(255, 214, 56, 255), anchor="mm")
        draw.text((x, y + 114), "Thieu xu", font=font(15), fill=(245, 112, 77, 255), anchor="mm")
    draw.text((1240, 836), "So Xu: 0", font=font(24), fill=(255, 214, 56, 255), anchor="rm")
    return image


def storage_preview(locked: bool) -> Image.Image:
    image, draw = unified_canvas(5, "KHO QUAN VUONG")
    draw.text((768, 390), "120 o luu tru  •  Alt + chuot phai de khoa", font=font(19), fill=(174, 175, 194, 255), anchor="mm")
    first_x, first_y = 405, 455
    for index in range(40):
        col, row = index % 8, index // 8
        x = first_x + col * 92
        y = first_y + row * 75
        fill = (30, 30, 45, 255) if not locked or index % 7 else (70, 35, 50, 255)
        draw.rounded_rectangle((x - 31, y - 31, x + 31, y + 31), 7, fill=fill, outline=SILVER, width=2)
        if locked and index % 7 == 0:
            draw.text((x + 19, y + 17), "★", font=font(20), fill=(255, 80, 95, 255), anchor="mm")
    draw.text((768, 825), "‹        1 / 3        ›", font=font(24), fill=SILVER, anchor="mm")
    draw.text((768, 866), "Hien thi o 1-40 / 120" if not locked else "Vat pham khoa van giu nguyen trang thai", font=font(18), fill=CYAN, anchor="mm")
    return image


SCREENS = {
    "theme": theme_preview,
    "shell": shell_preview,
    "summary-combine": artifact_preview("bang-tong-hop/v3/hop-thanh.png"),
    "summary-socket": artifact_preview("bang-tong-hop/v3/kham.png"),
    "forge-cleanse": artifact_preview("than-binh-pho/v4/thanh-tay.png"),
    "forge-stone-change": artifact_preview("than-binh-pho/v4/duc-linh.png"),
    "forge-inherit": artifact_preview("than-binh-pho/v4/ke-thua.png"),
    "strengthen-empty": artifact_preview("lam-phuong-ui/trong.png"),
    "strengthen-ready": artifact_preview("lam-phuong-ui/cuong-hoa.png"),
    "strengthen-protected": artifact_preview("lam-phuong-ui/bao-ve.png"),
    "strengthen-maxed": artifact_preview("lam-phuong-ui/toi-da.png"),
    "character": character_preview,
    "quests-daily": lambda: quest_preview(0),
    "quests-guild": lambda: quest_preview(1),
    "quests-promotion": lambda: quest_preview(2),
    "army": army_preview,
    "shop": shop_preview,
    "storage-page-1": lambda: storage_preview(False),
    "storage-locked": lambda: storage_preview(True),
}


def fit(image: Image.Image, width: int, height: int) -> Image.Image:
    scale = min((width - 32) / image.width, (height - 32) / image.height, 1)
    resized = image.resize((round(image.width * scale), round(image.height * scale)), Image.Resampling.LANCZOS)
    output = Image.new("RGBA", (width, height), BG)
    output.alpha_composite(resized, ((width - resized.width) // 2, (height - resized.height) // 2))
    return output


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--screen", choices=sorted(SCREENS), required=True)
    parser.add_argument("--width", type=int, default=1536)
    parser.add_argument("--height", type=int, default=1024)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    fit(SCREENS[args.screen](), args.width, args.height).convert("RGB").save(args.output)
    print(args.output.resolve())


if __name__ == "__main__":
    main()
