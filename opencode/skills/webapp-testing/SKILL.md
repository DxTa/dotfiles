# Webapp Testing

Toolkit for testing web applications using Playwright - frontend verification, screenshots, browser logs.

## When to Use

Use this skill when:
- Testing web applications end-to-end
- Verifying frontend functionality
- Taking screenshots of web pages
- Monitoring browser logs and errors
- Testing user flows and interactions
- Validating responsive design
- Testing authentication and authorization
- Performance testing web applications

## Key Concepts

### Playwright Features
- **Cross-browser**: Chrome, Firefox, Safari (WebKit)
- **Multi-language**: JavaScript, TypeScript, Python, Java, .NET
- **Headless mode**: Fast, no UI
- **Network interception**: Mock and inspect network traffic
- **Screenshots/Video**: Visual regression testing
- **Trace viewer**: Debug test execution

### Test Types
- **E2E Testing**: Complete user flows
- **Integration Testing**: Multiple components together
- **Visual Regression**: UI appearance validation
- **API Testing**: Network request/response validation
- **Accessibility Testing**: WCAG compliance

## Common Patterns

### Page Object Model
```javascript
// pages/LoginPage.js
class LoginPage {
  constructor(page) {
    this.page = page;
    this.usernameInput = page.locator('#username');
    this.passwordInput = page.locator('#password');
    this.loginButton = page.locator('button[type="submit"]');
  }

  async login(username, password) {
    await this.usernameInput.fill(username);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }
}

module.exports = { LoginPage };
```

### Basic Test
```javascript
// tests/login.spec.js
const { test, expect } = require('@playwright/test');
const { LoginPage } = require('../pages/LoginPage');

test('user can login', async ({ page }) => {
  await page.goto('https://example.com/login');

  const loginPage = new LoginPage(page);
  await loginPage.login('user@example.com', 'password');

  await expect(page).toHaveURL('https://example.com/dashboard');
});
```

### Screenshots
```javascript
test('take screenshot', async ({ page }) => {
  await page.goto('https://example.com');

  // Full page screenshot
  await page.screenshot({ path: 'full-page.png', fullPage: true });

  // Element screenshot
  await page.locator('.hero').screenshot({ path: 'hero.png' });

  // Screenshot on failure
  test.slow();
  await page.screenshot({ path: 'failure.png' });
});
```

### Browser Logs
```javascript
test('monitor browser logs', async ({ page }) => {
  const errors = [];

  page.on('console', msg => {
    if (msg.type() === 'error') {
      errors.push(msg.text());
    }
  });

  page.on('pageerror', error => {
    errors.push(error.toString());
  });

  await page.goto('https://example.com');

  expect(errors.length).toBe(0);
});
```

## Network Interception

### Mocking API Responses
```javascript
test('mock API response', async ({ page }) => {
  await page.route('**/api/users', route => {
    route.fulfill({
      status: 200,
      body: JSON.stringify([
        { id: 1, name: 'User 1' },
        { id: 2, name: 'User 2' }
      ])
    });
  });

  await page.goto('https://example.com');
  // Verify UI uses mocked data
});
```

### Monitoring Network Traffic
```javascript
test('monitor network requests', async ({ page, context }) => {
  const requests = [];

  page.on('request', request => {
    requests.push(request.url());
  });

  page.on('response', response => {
    if (response.status() >= 400) {
      console.log(`Failed request: ${response.url()}`);
    }
  });

  await page.goto('https://example.com');
});
```

## Testing User Flows

### Shopping Cart Flow
```javascript
test('complete purchase flow', async ({ page }) => {
  // Navigate to product
  await page.goto('https://example.com/products/1');
  await page.click('button:has-text("Add to Cart")');

  // Verify cart
  await page.click('.cart-icon');
  await expect(page.locator('.cart-item')).toHaveCount(1);

  // Checkout
  await page.click('button:has-text("Checkout")');
  await page.fill('#email', 'test@example.com');
  await page.fill('#address', '123 Test St');
  await page.click('button:has-text("Place Order")');

  // Confirm
  await expect(page).toHaveURL(/.*order-confirmation/);
});
```

## Responsive Design Testing

```javascript
const devices = ['Desktop Chrome', 'iPhone 12', 'iPad Pro'];

for (const device of devices) {
  test(`test on ${device}`, async ({ page }) => {
    await page.goto('https://example.com');

    const viewport = page.viewportSize();
    console.log(`Testing at ${viewport.width}x${viewport.height}`);

    await expect(page.locator('.hero')).toBeVisible();
    await expect(page.locator('.mobile-menu')).toBeVisible(
      viewport.width < 768 ? true : false
    );
  });
}
```

## Accessibility Testing

```javascript
test('check accessibility', async ({ page }) => {
  await page.goto('https://example.com');

  const violations = await page.accessibility.snapshot();

  violations.forEach(violation => {
    console.log(`Accessibility violation: ${violation.id}`);
    console.log(`  Description: ${violation.description}`);
  });

  expect(violations.length).toBe(0);
});
```

## Visual Regression Testing

```javascript
test('visual regression', async ({ page }) => {
  await page.goto('https://example.com');

  // Take screenshot and compare
  await expect(page).toHaveScreenshot('homepage.png', {
    maxDiffPixels: 100,
    threshold: 0.2
  });
});
```

## Performance Testing

```javascript
test('measure performance', async ({ page }) => {
  const startTime = Date.now();

  await page.goto('https://example.com');

  const loadTime = Date.now() - startTime;
  console.log(`Page load time: ${loadTime}ms`);

  const metrics = await page.evaluate(() => {
    const navigation = performance.getEntriesByType('navigation')[0];
    return {
      domContentLoaded: navigation.domContentLoadedEventEnd - navigation.domContentLoadedEventStart,
      loadComplete: navigation.loadEventEnd - navigation.loadEventStart
    };
  });

  console.log('Metrics:', metrics);
});
```

## Configuration

### playwright.config.js
```javascript
module.exports = {
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'https://example.com',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    headless: true
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } }
  ]
};
```

## Best Practices

### Test Design
- Use descriptive test names
- Test one behavior per test
- Use page object model for maintainability
- Avoid hard-coded waits (use waitForSelector instead)
- Isolate tests (no dependencies between tests)

### Maintenance
- Keep tests simple and focused
- Use data-driven tests for similar scenarios
- Regularly update selectors
- Run tests in CI/CD pipeline
- Review flaky tests and fix underlying issues

## File Patterns

Look for:
- `**/tests/**/*.{js,ts,py}`
- `**/e2e/**/*.{js,ts,py}`
- `**/playwright/**/*.{js,ts,py}`
- `**/screenshots/**/*.{png,jpg}`

## Keywords

Playwright, webapp testing, E2E testing, frontend testing, screenshot, browser logs, visual regression, network interception, accessibility testing, cross-browser testing, headless testing, page object model
