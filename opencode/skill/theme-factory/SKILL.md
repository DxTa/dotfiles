# Theme Factory

Toolkit for styling artifacts with themes - 10 pre-set themes with colors and fonts.

## When to Use

Use this skill when:
- Applying consistent theming to artifacts
- Creating themed UI components
- Switching between color schemes and fonts
- Building themeable applications
- Creating dark/light mode variations
- Generating themed design systems

## Pre-set Themes

### 1. Default (Modern Blue)
- Primary: #3B82F6 (Blue-500)
- Background: #F9FAFB (Gray-50)
- Text: #111827 (Gray-900)
- Font: Inter, sans-serif
- Accents: Emerald, Amber, Rose

### 2. Midnight (Dark)
- Primary: #60A5FA (Blue-400)
- Background: #0F172A (Slate-900)
- Text: #F1F5F9 (Slate-100)
- Font: Inter, sans-serif
- Accents: Violet, Sky, Cyan

### 3. Forest (Nature)
- Primary: #22C55E (Green-500)
- Background: #F0FDF4 (Green-50)
- Text: #14532D (Green-950)
- Font: Inter, sans-serif
- Accents: Emerald, Lime, Teal

### 4. Sunset (Warm)
- Primary: #F97316 (Orange-500)
- Background: #FFF7ED (Orange-50)
- Text: #431407 (Orange-950)
- Font: Inter, sans-serif
- Accents: Amber, Red, Pink

### 5. Royal (Purple)
- Primary: #8B5CF6 (Violet-500)
- Background: #F5F3FF (Violet-50)
- Text: #2E1065 (Violet-950)
- Font: Inter, sans-serif
- Accents: Purple, Indigo, Fuchsia

### 6. Ocean (Calm)
- Primary: #06B6D4 (Cyan-500)
- Background: #ECFEFF (Cyan-50)
- Text: #164E63 (Cyan-950)
- Font: Inter, sans-serif
- Accents: Sky, Teal, Blue

### 7. Crimson (Bold)
- Primary: #EF4444 (Red-500)
- Background: #FEF2F2 (Red-50)
- Text: #450A0A (Red-950)
- Font: Inter, sans-serif
- Accents: Rose, Orange, Pink

### 8. Slate (Professional)
- Primary: #64748B (Slate-500)
- Background: #F8FAFC (Slate-50)
- Text: #0F172A (Slate-900)
- Font: Inter, sans-serif
- Accents: Zinc, Gray, Neutral

### 9. Golden (Luxury)
- Primary: #D97706 (Amber-600)
- Background: #FFFBEB (Amber-50)
- Text: #451A03 (Amber-950)
- Font: Playfair Display, serif
- Accents: Orange, Yellow, Stone

### 10. Cyber (Tech)
- Primary: #00E5FF (Cyan-A400)
- Background: #0B0C10 (Dark)
- Text: #C5C6C7 (Gray)
- Font: JetBrains Mono, monospace
- Accents: Neon Green, Electric Purple, Hot Pink

## Theme Implementation

### JavaScript (React + Tailwind)
```javascript
const themes = {
  default: {
    primary: '#3B82F6',
    background: '#F9FAFB',
    text: '#111827',
    font: 'Inter, sans-serif'
  },
  midnight: {
    primary: '#60A5FA',
    background: '#0F172A',
    text: '#F1F5F9',
    font: 'Inter, sans-serif'
  }
  // ... other themes
};

function ThemedComponent({ theme = 'default' }) {
  const currentTheme = themes[theme];

  return (
    <div style={{
      backgroundColor: currentTheme.background,
      color: currentTheme.text,
      fontFamily: currentTheme.font,
      padding: '1rem',
      borderRadius: '0.5rem'
    }}>
      <button style={{
        backgroundColor: currentTheme.primary,
        color: 'white',
        padding: '0.5rem 1rem',
        borderRadius: '0.25rem'
      }}>
        Click me
      </button>
    </div>
  );
}
```

### Python (Tkinter)
```python
import tkinter as tk

THEMES = {
    'default': {
        'primary': '#3B82F6',
        'background': '#F9FAFB',
        'text': '#111827',
        'font': ('Inter', 12)
    },
    'midnight': {
        'primary': '#60A5FA',
        'background': '#0F172A',
        'text': '#F1F5F9',
        'font': ('Inter', 12)
    }
}

def apply_theme(root, theme_name):
    theme = THEMES[theme_name]
    root.configure(bg=theme['background'])

    # Apply to all widgets
    for widget in root.winfo_children():
        widget.configure(bg=theme['background'], fg=theme['text'])

# Usage
root = tk.Tk()
apply_theme(root, 'midnight')
```

### CSS Variables
```css
:root {
  --primary: #3B82F6;
  --background: #F9FAFB;
  --text: #111827;
  --font: 'Inter', sans-serif;
}

[data-theme="midnight"] {
  --primary: #60A5FA;
  --background: #0F172A;
  --text: #F1F5F9;
}

body {
  background-color: var(--background);
  color: var(--text);
  font-family: var(--font);
}

button {
  background-color: var(--primary);
  color: white;
}
```

## Patterns and Practices

### Theme Switching
```javascript
import { useState, createContext, useContext } from 'react';

const ThemeContext = createContext();

function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('default');

  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

function useTheme() {
  return useContext(ThemeContext);
}

function ThemeSwitcher() {
  const { theme, setTheme } = useTheme();

  return (
    <select value={theme} onChange={(e) => setTheme(e.target.value)}>
      <option value="default">Default</option>
      <option value="midnight">Midnight</option>
      <option value="forest">Forest</option>
      {/* ... other options */}
    </select>
  );
}
```

### Dark Mode Detection
```javascript
import { useEffect, useState } from 'react';

function useDarkMode() {
  const [isDark, setIsDark] = useState(false);

  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    setIsDark(mediaQuery.matches);

    const handler = (e) => setIsDark(e.matches);
    mediaQuery.addEventListener('change', handler);

    return () => mediaQuery.removeEventListener('change', handler);
  }, []);

  return isDark;
}

function AutoTheme() {
  const isDark = useDarkMode();
  const theme = isDark ? 'midnight' : 'default';

  return <ThemedApp theme={theme} />;
}
```

## Color Palettes

### Accessible Contrast Ratios
- AAA: 7:1 or higher
- AA: 4.5:1 or higher
- Large text AA: 3:1 or higher

### Tailwind Color Integration
```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: 'var(--primary)',
        background: 'var(--background)',
        text: 'var(--text)',
      }
    }
  }
}
```

## Best Practices

### Theme Design
- Maintain sufficient contrast for accessibility
- Use consistent color hierarchy
- Consider light/dark mode compatibility
- Test across devices and screen readers
- Keep color palettes limited (3-5 colors max)

### Implementation
- Use CSS variables for easy theming
- Implement theme switching without page reload
- Persist theme preference in localStorage
- Support system theme preferences
- Provide manual override option

### Performance
- Minimize theme-specific CSS
- Use efficient theme switching (CSS variables)
- Avoid JavaScript-based styling where possible
- Preload theme assets

## File Patterns

Look for:
- `**/themes/**/*.{css,js,py}`
- `**/styles/**/*.{css,scss}`
- `**/assets/themes/**/*`
- `**/design-system/**/*`

## Keywords

Theme, theming, color scheme, dark mode, light mode, CSS variables, design system, styled components, Tailwind theme, theme switching, color palette, font pairing
