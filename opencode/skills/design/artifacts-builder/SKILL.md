# Artifacts Builder

Suite of tools for creating elaborate, multi-component Claude.ai HTML artifacts using React, Tailwind CSS, and shadcn/ui.

## When to Use

Use this skill when:
- Creating complex, multi-page HTML artifacts for Claude.ai
- Building interactive artifacts with state management
- Using React components in single-file artifacts
- Implementing shadcn/ui components in artifacts
- Creating artifacts with routing and navigation
- Bundling multiple components into single-file
- Building stateful, interactive applications as artifacts

## Key Concepts

### Artifact Structure
- **Single File**: All code in one HTML file
- **Inline Styles**: Tailwind CSS via CDN
- **React Runtime**: Babel for JSX transformation
- **Component Composition**: Multiple React components
- **State Management**: useState, useEffect, context

### shadcn/ui in Artifacts
- **Components**: Button, Card, Dialog, Dropdown, etc.
- **Styling**: Tailwind CSS classes
- **Customization**: Tailwind config, custom styles
- **Icons**: Lucide React icons
- **Theme**: Dark mode support

### Advanced Features
- **Routing**: Hash-based or state-based navigation
- **Forms**: Validation, submission handling
- **Data Fetching**: Async operations, loading states
- **Local Storage**: Persisting user data
- **Animations**: Framer Motion or CSS transitions

## Patterns and Practices

### Artifact Template
```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://unpkg.com/react@18/umd/react.development.js"></script>
  <script src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
  <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
</head>
<body>
  <div id="root"></div>
  <script type="text/babel">
    const { useState, useEffect } = React;

    function App() {
      const [count, setCount] = useState(0);
      return (
        <div className="p-8">
          <h1 className="text-3xl font-bold">Hello World</h1>
        </div>
      );
    }

    ReactDOM.createRoot(document.getElementById('root')).render(<App />);
  </script>
</body>
</html>
```

### Component Organization
```javascript
// Main App
function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      <MainContent />
      <Footer />
    </div>
  );
}

// Header Component
function Header() {
  return (
    <header className="bg-white shadow">
      <nav className="max-w-7xl mx-auto px-4 py-4">
        <h1 className="text-2xl font-bold">My App</h1>
      </nav>
    </header>
  );
}
```

### Stateful Interactive Artifact
```javascript
function InteractiveApp() {
  const [items, setItems] = useState([]);
  const [filter, setFilter] = useState('');

  const filteredItems = items.filter(item =>
    item.name.toLowerCase().includes(filter.toLowerCase())
  );

  return (
    <div className="p-8">
      <input
        type="text"
        placeholder="Filter items..."
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        className="border p-2 rounded w-full mb-4"
      />
      <div className="grid grid-cols-3 gap-4">
        {filteredItems.map(item => (
          <Card key={item.id} item={item} />
        ))}
      </div>
    </div>
  );
}
```

### Routing in Artifacts
```javascript
function App() {
  const [view, setView] = useState('dashboard');

  return (
    <div className="min-h-screen bg-gray-100">
      <Navigation setView={setView} />
      {view === 'dashboard' && <Dashboard />}
      {view === 'settings' && <Settings />}
      {view === 'reports' && <Reports />}
    </div>
  );
}

function Navigation({ setView }) {
  return (
    <nav className="bg-white shadow p-4">
      <button onClick={() => setView('dashboard')}>Dashboard</button>
      <button onClick={() => setView('settings')}>Settings</button>
      <button onClick={() => setView('reports')}>Reports</button>
    </nav>
  );
}
```

## shadcn/ui Components

### Button
```javascript
function Button({ children, variant = 'default', size = 'md' }) {
  const baseStyles = "px-4 py-2 rounded-md font-medium transition";
  const variants = {
    default: "bg-blue-600 text-white hover:bg-blue-700",
    outline: "border border-gray-300 hover:bg-gray-50",
    ghost: "hover:bg-gray-100",
  };
  return (
    <button className={`${baseStyles} ${variants[variant]}`}>
      {children}
    </button>
  );
}
```

### Card
```javascript
function Card({ children, title }) {
  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      {title && <h3 className="text-lg font-semibold mb-4">{title}</h3>}
      {children}
    </div>
  );
}
```

### Dialog
```javascript
function Dialog({ isOpen, onClose, title, children }) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="absolute inset-0 bg-black/50" onClick={onClose}></div>
      <div className="relative bg-white rounded-lg p-6 max-w-md w-full shadow-xl">
        <h2 className="text-xl font-bold mb-4">{title}</h2>
        {children}
        <button onClick={onClose} className="mt-4 px-4 py-2 bg-gray-200 rounded">
          Close
        </button>
      </div>
    </div>
  );
}
```

### Form Components
```javascript
function Input({ label, ...props }) {
  return (
    <div className="mb-4">
      <label className="block text-sm font-medium mb-1">{label}</label>
      <input
        className="w-full border rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
        {...props}
      />
    </div>
  );
}

function Select({ label, options, ...props }) {
  return (
    <div className="mb-4">
      <label className="block text-sm font-medium mb-1">{label}</label>
      <select
        className="w-full border rounded-md px-3 py-2"
        {...props}
      >
        {options.map(opt => (
          <option key={opt.value} value={opt.value}>{opt.label}</option>
        ))}
      </select>
    </div>
  );
}
```

## Best Practices

### Performance
- Use React.memo for expensive components
- Lazy load data with useEffect
- Debounce search/filter inputs
- Minimize re-renders with proper state placement

### Accessibility
- Add ARIA labels to interactive elements
- Ensure keyboard navigation works
- Use semantic HTML elements
- Provide sufficient color contrast

### Styling
- Use Tailwind utility classes consistently
- Create reusable component variants
- Use semantic color tokens (primary, secondary)
- Support dark mode with dark: prefix

## File Patterns

Look for:
- `**/artifacts/**/*`
- `**/html-artifacts/**/*`
- `**/interactive-components/**/*`
- `**/*.html` (artifact files)

## Keywords

HTML artifact, React artifact, shadcn/ui, Tailwind CSS, interactive artifact, multi-component artifact, single-file app, stateful artifact, artifact with routing, bundled artifact, Claude.ai artifact
