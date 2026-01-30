#!/usr/bin/env python3
"""
Create App Store screenshots with gradient background and Korean text overlay.
Uses Pillow for image processing with proper Korean font support.
"""

import os
from PIL import Image, ImageDraw, ImageFont

# Configuration
SCREENSHOTS_DIR = "screenshots/ko"
FONTS_DIR = "fonts"
BACKGROUNDS_DIR = "backgrounds"
OUTPUT_DIR = "screenshots/ko"

# Canvas size for iPhone 15 Pro Max (6.7")
CANVAS_WIDTH = 1290
CANVAS_HEIGHT = 2796

# Text configuration
KEYWORD_FONT_SIZE = 100
TITLE_FONT_SIZE = 48
TEXT_COLOR = (255, 255, 255)
PADDING = 80
TEXT_TOP_MARGIN = 180

# Screenshot data
SCREENSHOTS = [
    {
        "file": "01_counter_ko.png",
        "keyword": "손은 뜨개질에만",
        "title": '"다음" 한마디로 카운트'
    },
    {
        "file": "02_projects_ko.png",
        "keyword": "3개 동시에? OK",
        "title": "여러 프로젝트 동시에"
    },
    {
        "file": "03_memo_ko.png",
        "keyword": "메모해두면 알려드려요",
        "title": "특정 단에 메모 알림"
    },
    {
        "file": "04_progress_ko.png",
        "keyword": "27% 완성!",
        "title": "목표까지 얼마나 남았을까"
    },
    {
        "file": "05_settings_ko.png",
        "keyword": "내 스타일대로",
        "title": "다크모드, 햅틱 피드백"
    }
]

def load_font(font_path, size):
    """Load a font, falling back to default if not found."""
    try:
        return ImageFont.truetype(font_path, size)
    except Exception as e:
        print(f"Warning: Could not load font {font_path}: {e}")
        # Try system fonts
        try:
            return ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", size)
        except:
            return ImageFont.load_default()

def create_gradient_background(width, height):
    """Create a purple-blue gradient background."""
    # Load the gradient image
    gradient_path = os.path.join(BACKGROUNDS_DIR, "gradient.png")
    if os.path.exists(gradient_path):
        gradient = Image.open(gradient_path).convert("RGBA")
        return gradient.resize((width, height), Image.Resampling.LANCZOS)
    else:
        # Create gradient programmatically
        img = Image.new("RGBA", (width, height))
        for y in range(height):
            r = int(88 + (y / height) * (45 - 88))
            g = int(86 + (y / height) * (60 - 86))
            b = int(214 + (y / height) * (170 - 214))
            for x in range(width):
                img.putpixel((x, y), (r, g, b, 255))
        return img

def create_screenshot(screenshot_data, keyword_font, title_font):
    """Create a single screenshot with background and text."""
    # Create canvas with gradient
    canvas = create_gradient_background(CANVAS_WIDTH, CANVAS_HEIGHT)
    draw = ImageDraw.Draw(canvas)

    # Load the screenshot
    screenshot_path = os.path.join(SCREENSHOTS_DIR, screenshot_data["file"])
    if not os.path.exists(screenshot_path):
        print(f"Screenshot not found: {screenshot_path}")
        return None

    screenshot = Image.open(screenshot_path).convert("RGBA")

    # Calculate text positions
    keyword = screenshot_data["keyword"]
    title = screenshot_data["title"]

    # Draw keyword (larger, bold)
    keyword_bbox = draw.textbbox((0, 0), keyword, font=keyword_font)
    keyword_width = keyword_bbox[2] - keyword_bbox[0]
    keyword_x = (CANVAS_WIDTH - keyword_width) // 2
    keyword_y = TEXT_TOP_MARGIN
    draw.text((keyword_x, keyword_y), keyword, font=keyword_font, fill=TEXT_COLOR)

    # Draw title (smaller, regular)
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_x = (CANVAS_WIDTH - title_width) // 2
    title_y = keyword_y + keyword_bbox[3] - keyword_bbox[1] + 30
    draw.text((title_x, title_y), title, font=title_font, fill=TEXT_COLOR)

    # Calculate screenshot position (centered horizontally, below text)
    text_bottom = title_y + title_bbox[3] - title_bbox[1] + 60
    available_height = CANVAS_HEIGHT - text_bottom - PADDING

    # Scale screenshot to fit
    scale = min(
        (CANVAS_WIDTH - 2 * PADDING) / screenshot.width,
        available_height / screenshot.height
    )
    new_width = int(screenshot.width * scale)
    new_height = int(screenshot.height * scale)

    screenshot = screenshot.resize((new_width, new_height), Image.Resampling.LANCZOS)

    # Position screenshot
    screenshot_x = (CANVAS_WIDTH - new_width) // 2
    screenshot_y = text_bottom + (available_height - new_height) // 2

    # Paste screenshot onto canvas
    canvas.paste(screenshot, (screenshot_x, screenshot_y), screenshot)

    return canvas

def main():
    # Change to fastlane directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    # Load fonts
    keyword_font_path = os.path.join(FONTS_DIR, "Pretendard-Bold.ttf")
    title_font_path = os.path.join(FONTS_DIR, "Pretendard-Regular.ttf")

    keyword_font = load_font(keyword_font_path, KEYWORD_FONT_SIZE)
    title_font = load_font(title_font_path, TITLE_FONT_SIZE)

    print(f"Using keyword font: {keyword_font_path}")
    print(f"Using title font: {title_font_path}")

    # Process each screenshot
    for data in SCREENSHOTS:
        print(f"Processing {data['file']}...")
        result = create_screenshot(data, keyword_font, title_font)

        if result:
            output_filename = data["file"].replace(".png", "_framed.png")
            output_path = os.path.join(OUTPUT_DIR, output_filename)
            result.save(output_path, "PNG")
            print(f"  Saved: {output_path}")
        else:
            print(f"  Failed to process {data['file']}")

    print("\nDone!")

if __name__ == "__main__":
    main()
