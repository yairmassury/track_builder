#!/usr/bin/env python3
"""Generate launcher icons for Track Builder app.

Creates a simple, colorful car-on-track icon suitable for a kids game.
Outputs icons in all required Android mipmap sizes.
"""

from PIL import Image, ImageDraw, ImageFont
import os

SIZES = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'android', 'app', 'src', 'main', 'res')


def create_icon(size: int) -> Image.Image:
    """Create a track builder icon at the given size."""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Background: rounded orange square
    margin = size * 0.02
    bg_rect = [margin, margin, size - margin, size - margin]
    radius = size * 0.2
    draw.rounded_rectangle(bg_rect, radius=radius, fill='#FF8C00')

    # Inner gradient effect (darker at bottom)
    for i in range(int(size * 0.3)):
        y = size - margin - i
        alpha = int(80 * (1 - i / (size * 0.3)))
        draw.line([(margin + radius/2, y), (size - margin - radius/2, y)],
                  fill=(0, 0, 0, alpha))

    # Track path (curved line)
    track_width = max(2, size * 0.06)
    track_color = '#FFD700'

    # Draw a stylized track curve
    cx, cy = size * 0.5, size * 0.45
    r = size * 0.28
    # Arc representing track
    bbox = [cx - r, cy - r, cx + r, cy + r]
    draw.arc(bbox, start=200, end=340, fill=track_color, width=int(track_width))

    # Straight section
    draw.line(
        [(size * 0.15, size * 0.55), (size * 0.85, size * 0.55)],
        fill=track_color, width=int(track_width)
    )

    # Car (simple rectangle with wheels)
    car_w = size * 0.22
    car_h = size * 0.12
    car_x = size * 0.55
    car_y = size * 0.48

    # Car body
    car_rect = [car_x, car_y, car_x + car_w, car_y + car_h]
    draw.rounded_rectangle(car_rect, radius=size * 0.03, fill='#FF4444')

    # Windshield
    ws_x = car_x + car_w * 0.55
    ws_rect = [ws_x, car_y + car_h * 0.15, ws_x + car_w * 0.2, car_y + car_h * 0.85]
    draw.rounded_rectangle(ws_rect, radius=size * 0.01, fill='#87CEEB')

    # Wheels
    wheel_r = size * 0.035
    wheel_color = '#333333'
    # Front wheel
    draw.ellipse(
        [car_x + car_w * 0.2 - wheel_r, car_y + car_h - wheel_r,
         car_x + car_w * 0.2 + wheel_r, car_y + car_h + wheel_r],
        fill=wheel_color
    )
    # Rear wheel
    draw.ellipse(
        [car_x + car_w * 0.8 - wheel_r, car_y + car_h - wheel_r,
         car_x + car_w * 0.8 + wheel_r, car_y + car_h + wheel_r],
        fill=wheel_color
    )

    # "TB" text at bottom
    text_y = size * 0.68
    try:
        font_size = int(size * 0.2)
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
    except (OSError, IOError):
        font = ImageFont.load_default()

    # Draw text centered
    text = "TB"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    tx = (size - tw) / 2
    draw.text((tx, text_y), text, fill='white', font=font)

    return img


def main():
    for folder, px in SIZES.items():
        out_path = os.path.join(OUTPUT_DIR, folder)
        os.makedirs(out_path, exist_ok=True)

        icon = create_icon(px)
        icon_path = os.path.join(out_path, 'ic_launcher.png')
        icon.save(icon_path, 'PNG')
        print(f"  {folder}: {px}x{px}px -> {icon_path}")

    print("\nDone! Icons generated for all mipmap sizes.")


if __name__ == '__main__':
    main()
