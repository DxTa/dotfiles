# Slack GIF Creator

Toolkit for creating animated GIFs optimized for Slack with size constraints and animation primitives.

## When to Use

Use this skill when:
- Creating animated GIFs for Slack
- Optimizing GIFs for file size limits
- Creating animated reactions and memes
- Building animated notifications and alerts
- Generating animated status indicators
- Creating product demo animations
- Building animated marketing content

## Key Concepts

### Slack GIF Constraints
- **File Size Limit**: 10MB for free workspace
- **Dimensions**: Recommended 400x400 or smaller
- **Frame Rate**: 15-30 FPS for smooth playback
- **Optimization**: Reduce colors, use dithering
- **Looping**: Infinite loop for seamless playback

### Animation Techniques
- **Frame-based**: Sequence of images
- **Tweening**: Interpolated transitions
- **Keyframe Animation**: Define key states
- **Programmatic**: Code-generated animations

## Common Tools

### FFmpeg (CLI)
```bash
# Create GIF from video
ffmpeg -i video.mp4 -vf "fps=10,scale=400:-1:flags=lanczos" -c:v gif output.gif

# Optimize GIF size
ffmpeg -i input.gif -vf "scale=400:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" output.gif

# Create from images
ffmpeg -i %03d.png -vf "fps=10,scale=400:-1" output.gif
```

### ImageMagick
```bash
# Create animated GIF from images
convert -delay 10 -loop 0 *.png output.gif

# Optimize GIF
convert output.gif -fuzz 10% -layers Optimize optimized.gif

# Resize and optimize
convert output.gif -resize 400x400 -fuzz 5% -layers Optimize final.gif
```

### Python Libraries
- **Pillow**: Image processing and GIF creation
- **imageio**: Reading/writing GIFs
- **gifsicle**: GIF optimization

### Node.js Libraries
- **sharp**: High-performance image processing
- **gifwrap**: GIF manipulation
- **omggif**: GIF encoding

## Patterns and Practices

### GIF Creation Workflow
1. **Design Animation**: Concept, frames, timing
2. **Generate Frames**: Code, export from tool, create manually
3. **Assemble GIF**: Combine frames with correct timing
4. **Optimize**: Reduce size while maintaining quality
5. **Test in Slack**: Verify playback
6. **Iterate**: Refine based on feedback

### Python Example
```python
from PIL import Image, ImageDraw, ImageFont
import os

def create_text_gif(text, output_file, frames=20):
    images = []
    width, height = 400, 200

    for i in range(frames):
        # Create frame
        img = Image.new('RGB', (width, height), color='white')
        draw = ImageDraw.Draw(img)

        # Animate position
        x = int((width / frames) * i)
        draw.text((x, 50), text, fill='black')

        images.append(img)

    # Save as GIF
    images[0].save(
        output_file,
        save_all=True,
        append_images=images[1:],
        duration=100,  # ms per frame
        loop=0  # infinite loop
    )

create_text_gif("Hello Slack!", "output.gif")
```

### Node.js Example
```javascript
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

async function createGif(images, output) {
  // Load images
  const frames = await Promise.all(
    images.map(img => sharp(img).resize(400, 400).gif().toBuffer())
  );

  // Create animated GIF
  await sharp({
    create: {
      width: 400,
      height: 400,
      channels: 3,
      background: { r: 255, g: 255, b: 255 }
    }
  })
  .gif({ delay: 100, loop: 0 })
  .toFile(output);
}
```

### FFmpeg Optimization
```bash
# Two-pass optimization
ffmpeg -i input.gif -vf "fps=15,scale=400:-1:flags=lanczos" -f gif - \
  | gifsicle --optimize=3 --delay=10 > output.gif
```

## Animation Primitives

### Text Animation
```python
from PIL import Image, ImageDraw

def typing_effect(text, output):
    frames = []
    for i in range(1, len(text) + 1):
        img = Image.new('RGB', (400, 100), color='white')
        draw = ImageDraw.Draw(img)
        draw.text((10, 30), text[:i], fill='black')
        frames.append(img)

    frames[0].save(output, save_all=True, append_images=frames[1:], duration=100, loop=0)
```

### Progress Bar
```python
def progress_gif(output, steps=10):
    frames = []
    for i in range(steps + 1):
        img = Image.new('RGB', (400, 50), color='white')
        draw = ImageDraw.Draw(img)

        # Background bar
        draw.rectangle([10, 20, 390, 40], outline='black', width=2)

        # Progress
        width = int((380 / steps) * i)
        draw.rectangle([10, 20, 10 + width, 40], fill='blue')

        frames.append(img)

    frames[0].save(output, save_all=True, append_images=frames[1:], duration=200, loop=0)
```

### Bouncing Ball
```python
import math

def bouncing_ball(output, frames=30):
    images = []
    width, height = 400, 400

    for i in range(frames):
        img = Image.new('RGB', (width, height), color='white')
        draw = ImageDraw.Draw(img)

        # Calculate position (sine wave)
        t = (i / frames) * 2 * math.pi
        y = int(350 - 300 * abs(math.sin(t)))
        x = 200

        # Draw ball
        draw.ellipse([x-20, y-20, x+20, y+20], fill='red')
        draw.rectangle([50, 370, 350, 380], fill='black')

        images.append(img)

    images[0].save(output, save_all=True, append_images=images[1:], duration=100, loop=0)
```

## Optimization Techniques

### Reduce Colors
```python
# Use adaptive palette
from PIL import Image

img = Image.open('input.gif')
img = img.convert('P', palette=Image.Palette.ADAPTIVE, colors=64)
img.save('output.gif', optimize=True)
```

### Frame Skipping
```python
# Skip every other frame
def skip_frames(frames, step=2):
    return frames[::step]
```

### Crop and Resize
```bash
# Crop to content and resize
ffmpeg -i input.gif -vf "crop=400:400:0:0,scale=200:200" output.gif
```

## Best Practices

### Slack-Specific
- Keep dimensions under 400x400
- Target file size < 5MB for quick loading
- Use looping for seamless playback
- Ensure text is readable at small sizes
- Test in Slack before sharing

### Performance
- Limit frames to 30-60 for file size
- Use 15-20 FPS for balance
- Reduce colors to 64-256
- Apply optimization after creation
- Use consistent timing between frames

### Design
- Clear, simple concepts
- High contrast for visibility
- Smooth transitions between frames
- No rapid flickering
- Consider accessibility (avoid excessive flashing)

## File Patterns

Look for:
- `**/animations/**/*.{gif,png}`
- `**/gifs/**/*`
- `**/slack-gifs/**/*`
- `**/creative/**/*`

## Keywords

GIF, Slack GIF, animated GIF, GIF optimization, animation primitives, meme generation, animated reactions, Slack integration, ImageMagick, FFmpeg, Pillow, sharp
