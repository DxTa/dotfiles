# Security Test Scanner

Security vulnerability scanner covering OWASP Top 10, injection flaws, XSS, CSRF, and authentication issues.

## When to Use

Use this skill when:
- Scanning applications for security vulnerabilities
- Conducting security audits and assessments
- Testing for OWASP Top 10 vulnerabilities
- Checking injection flaws (SQL, NoSQL, OS command)
- Verifying XSS and CSRF protections
- Testing authentication and authorization
- Security testing in CI/CD pipelines
- Penetration testing preparation

## Key Concepts

### OWASP Top 10
1. Broken Access Control
2. Cryptographic Failures
3. Injection (SQL, NoSQL, OS, LDAP)
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable/Outdated Components
7. Identification & Authentication Failures
8. Software & Data Integrity Failures
9. Security Logging & Monitoring Failures
10. Server-Side Request Forgery (SSRF)

### Common Vulnerabilities
- **Injection**: SQL, NoSQL, OS command, LDAP
- **XSS**: Reflected, stored, DOM-based
- **CSRF**: Cross-site request forgery
- **SSRF**: Server-side request forgery
- **XXE**: XML external entity injection
- **IDOR**: Insecure direct object references
- **Path Traversal**: Directory traversal
- **Authentication Issues**: Weak passwords, session fixation

### Security Tools
- **OWASP ZAP**: Web application security scanner
- **Burp Suite**: Professional penetration testing
- **SQLMap**: SQL injection detection
- **Nikto**: Web server scanner
- **Nuclei**: Fast vulnerability scanner
- **Semgrep**: Static code analysis
- **Snyk**: Dependency vulnerability scanning
- **Trivy**: Container security scanner

## Patterns and Practices

### Security Testing Workflow
1. Reconnaissance (information gathering)
2. Vulnerability scanning (automated)
3. Manual testing (manual exploits)
4. Authentication/authorization testing
5. Session management testing
6. Input validation testing
7. Error handling analysis
8. Business logic testing
9. Report generation and remediation

### Static Analysis (SAST)
- Scan code before deployment
- Check for security anti-patterns
- Detect hardcoded secrets and credentials
- Validate secure coding practices
- Identify dependency vulnerabilities

### Dynamic Analysis (DAST)
- Test running applications
- Simulate real attacks
- Test authentication flows
- Verify security headers
- Check input validation

### Best Practices
- Security testing throughout SDLC (shift left)
- Combine automated and manual testing
- Regular dependency updates and scanning
- Implement security headers (CSP, X-Frame-Options)
- Use HTTPS everywhere
- Implement rate limiting
- Log security events
- Regular security training

## Tools by Language

### JavaScript/Node.js
```bash
npm audit
npx snyk test
npx semgrep --config auto
```

### Python
```bash
pip install bandit
bandit -r src/
pip install safety
safety check
```

### Dependency Scanning
```bash
npm audit
pip-audit
snyk test
trivy image myapp:latest
```

## CI/CD Integration

### GitHub Actions
```yaml
- name: Run security scan
  uses: snyk/actions/node@master
- name: Run SAST
  uses: github/super-linter@v4
  env:
    VALIDATE_ALL_CODEBASE: false
    VALIDATE_JAVASCRIPT_ES: true
```

## File Patterns

Look for:
- `**/security/**/*`
- `**/*security*.{js,ts,py,java}`
- `**/auth/**/*`
- `**/tests/security/**/*`
- `**/pentest/**/*`

## Keywords

Security scan, vulnerability scanner, OWASP Top 10, injection flaw, XSS, CSRF, SSRF, SQL injection, penetration testing, security audit, SAST, DAST, security testing, authentication, authorization
