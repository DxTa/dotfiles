# Algorithmic Art

Creating algorithmic art using p5.js with seeded randomness and interactive parameter exploration.

## When to Use

Use this skill when:
- Creating generative and algorithmic art
- Using p5.js for creative coding
- Working with seeded randomness for reproducibility
- Building interactive art with parameter controls
- Exploring mathematical patterns and visualizations
- Creating procedural textures and patterns
- Building art installations and displays
- Teaching creative coding concepts

## Key Concepts

### Generative Art Principles
- **Seeded Randomness**: Reproducible results with random seeds
- **Parameter Space**: Art controlled by variables
- **Iteration**: Loops and recursive patterns
- **Emergence**: Complex behavior from simple rules
- **Interaction**: User input affecting output

### p5.js Fundamentals
- **setup()**: Initialization (canvas, settings)
- **draw()**: Animation loop (called continuously)
- **Coordinate System**: (0,0) at top-left
- **Color**: RGB, HSB, alpha blending
- **Shapes**: Points, lines, ellipses, rectangles, vertices
- **Transformations**: Translate, rotate, scale

### Patterns & Techniques
- **Perlin Noise**: Natural-looking random
- **L-Systems**: Fractal patterns
- **Recursive Functions**: Self-similar structures
- **Particle Systems**: Simulating physics
- **Flow Fields**: Vector-based movement
- **Trigonometry**: Sine waves, circles, spirals
- **Cellular Automata**: Game of Life, CA rules

## Common Libraries

### p5.js Core
```javascript
// Basic structure
function setup() {
  createCanvas(800, 600);
  background(220);
}

function draw() {
  ellipse(mouseX, mouseY, 20, 20);
}
```

### Additional Libraries
- **p5.sound**: Audio processing
- **p5.gui**: Parameter controls
- **p5.collide2d**: Collision detection
- **toxiclibs**: Advanced algorithms
- **ml5.js**: Machine learning integration

## Patterns and Practices

### Generative Art Workflow
1. **Define Concept**: What patterns to explore
2. **Choose Parameters**: Variables to control
3. **Implement Rules**: How patterns generate
4. **Add Randomness**: Controlled stochastic elements
5. **Create UI**: Parameter sliders/controls
6. **Explore Space**: Test different parameter values
7. **Capture Results**: Save high-res images/videos
8. **Iterate**: Refine based on output

### Best Practices
- Use color palettes for harmony
- Implement save functionality (PNG/SVG)
- Add UI for parameter exploration
- Seed random for reproducibility
- Use frameCount for animation
- Optimize for performance (avoid heavy calculations in draw)
- Export at high resolution for printing
- Comment code for documentation

### Code Organization
```javascript
let params = {
  count: 100,
  size: 10,
  colorMode: 'HSB',
  seed: 42
};

function setup() {
  createCanvas(800, 800);
  colorMode(params.colorMode);
  randomSeed(params.seed);
  generate();
}

function generate() {
  background(20);
  for (let i = 0; i < params.count; i++) {
    drawElement(i);
  }
}

function drawElement(index) {
  // Draw single element
}
```

## Examples

### Seeded Randomness
```javascript
let seed = 12345;

function setup() {
  createCanvas(800, 800);
  randomSeed(seed);  // Reproducible results
  generatePattern();
}

function generatePattern() {
  background(30);
  for (let i = 0; i < 100; i++) {
    let x = random(width);
    let y = random(height);
    let size = random(10, 50);
    fill(random(255), random(255), random(255));
    ellipse(x, y, size);
  }
}

function keyPressed() {
  if (key === 's') {
    saveCanvas('artwork.png');
  }
  if (key === 'n') {
    seed++;
    randomSeed(seed);
    generatePattern();
  }
}
```

### Flow Field
```javascript
let particles = [];
let noiseScale = 0.01;

function setup() {
  createCanvas(800, 800);
  background(0);

  for (let i = 0; i < 1000; i++) {
    particles.push(new Particle());
  }
}

function draw() {
  particles.forEach(p => {
    p.update();
    p.show();
  });
}

class Particle {
  constructor() {
    this.pos = createVector(random(width), random(height));
    this.vel = createVector(0, 0);
    this.acc = createVector(0, 0);
    this.maxSpeed = 2;
    this.prevPos = this.pos.copy();
  }

  update() {
    let angle = noise(this.pos.x * noiseScale, this.pos.y * noiseScale) * TWO_PI * 2;
    this.acc = p5.Vector.fromAngle(angle);

    this.vel.add(this.acc);
    this.vel.limit(this.maxSpeed);
    this.prevPos = this.pos.copy();
    this.pos.add(this.vel);

    if (this.pos.x > width || this.pos.x < 0) this.pos.x = random(width);
    if (this.pos.y > height || this.pos.y < 0) this.pos.y = random(height);
  }

  show() {
    stroke(255, 50);
    line(this.prevPos.x, this.prevPos.y, this.pos.x, this.pos.y);
  }
}
```

### L-System
```javascript
let axiom = "F";
let sentence = axiom;
let len = 100;
let angle = 25;

function setup() {
  createCanvas(800, 800);
  background(30);

  for (let i = 0; i < 5; i++) {
    generate();
  }
}

function generate() {
  let nextSentence = "";
  for (let i = 0; i < sentence.length; i++) {
    let current = sentence.charAt(i);
    if (current === "F") {
      nextSentence += "FF+[+F-F-F]-[-F+F+F]";
    } else {
      nextSentence += current;
    }
  }
  sentence = nextSentence;
}

function draw() {
  turtle(sentence);
}

function turtle(s) {
  translate(width / 2, height);
  for (let i = 0; i < s.length; i++) {
    let current = s.charAt(i);
    if (current === "F") {
      line(0, 0, 0, -len);
      translate(0, -len);
    } else if (current === "+") {
      rotate(radians(angle));
    } else if (current === "-") {
      rotate(-radians(angle));
    } else if (current === "[") {
      push();
    } else if (current === "]") {
      pop();
    }
  }
}
```

## Interactive Controls

### Using p5.gui
```javascript
let gui;

function setup() {
  createCanvas(800, 800);
  gui = createGui();
  gui.addGlobals('particleCount', 'sizeRange', 'colorMode');
}

function draw() {
  background(30);
  // Use params from GUI
}
```

## File Patterns

Look for:
- `**/sketch.js`
- `**/generative-art/**/*`
- `**/creative-coding/**/*`
- `**/p5js/**/*`
- `**/algorithmic-art/**/*`

## Keywords

p5.js, generative art, algorithmic art, creative coding, seeded randomness, procedural generation, flow fields, L-systems, particle systems, Perlin noise, interactive art, parametric design
