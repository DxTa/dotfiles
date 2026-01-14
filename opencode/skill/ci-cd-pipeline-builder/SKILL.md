# CI/CD Pipeline Builder

CI/CD pipeline builder for GitHub Actions, GitLab CI, and Jenkins.

## When to Use

Use this skill when:
- Setting up CI/CD pipelines for new projects
- Configuring automated testing and deployment
- Creating GitHub Actions workflows
- Setting up GitLab CI/CD pipelines
- Configuring Jenkins jobs and pipelines
- Implementing continuous integration
- Setting up automated deployments
- Creating build, test, and deploy workflows

## Key Concepts

### CI/CD Components
- **Source Control**: Git workflows, branching strategies
- **Build**: Compilation, bundling, asset optimization
- **Test**: Unit tests, integration tests, e2e tests
- **Deploy**: Staging, production, rollback strategies
- **Monitoring**: Build status, deployment logs, alerts

### Pipeline Stages
- **Lint**: Code quality checks
- **Test**: Automated testing
- **Build**: Compile and bundle
- **Package**: Create artifacts
- **Deploy**: Deploy to environments
- **Notify**: Send status updates

## GitHub Actions

### Basic Workflow
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Run linting
        run: npm run lint

  build:
    needs: test
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Build
        run: npm run build

      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v3

      - name: Download artifacts
        uses: actions/download-artifact@v3
        with:
          name: dist

      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
```

### Docker Build & Push
```yaml
name: Docker Build

on:
  push:
    branches: [main]

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: username/myapp:latest,username/myapp:${{ github.sha }}
```

## GitLab CI/CD

### Basic Pipeline
```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - deploy

variables:
  NODE_ENV: test

test:
  stage: test
  image: node:18
  script:
    - npm ci
    - npm run test
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'

build:
  stage: build
  image: node:18
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

deploy_staging:
  stage: deploy
  image: alpine:latest
  only:
    - develop
  script:
    - apk add --no-cache openssh-client
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
    - scp -r dist/ user@staging.example.com:/var/www/app

deploy_production:
  stage: deploy
  image: alpine:latest
  only:
    - main
  script:
    - apk add --no-cache openssh-client
    - scp -r dist/ user@production.example.com:/var/www/app
  when: manual
```

## Jenkins

### Declarative Pipeline
```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Lint') {
            steps {
                sh 'npm run lint'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Deploy Staging') {
            when {
                branch 'develop'
            }
            steps {
                sh './scripts/deploy.sh staging'
            }
        }

        stage('Deploy Production') {
            when {
                branch 'main'
            }
            steps {
                input 'Deploy to production?'
                sh './scripts/deploy.sh production'
            }
        }
    }

    post {
        success {
            slackSend(
                color: 'good',
                message: "Build succeeded: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
            )
        }
        failure {
            slackSend(
                color: 'danger',
                message: "Build failed: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
            )
        }
    }
}
```

## Patterns and Practices

### Build Matrix
```yaml
strategy:
  matrix:
    node-version: [14.x, 16.x, 18.x]
    os: [ubuntu-latest, windows-latest, macos-latest]

steps:
  - uses: actions/setup-node@v3
    with:
      node-version: ${{ matrix.node-version }}
```

### Caching
```yaml
- name: Cache node modules
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### Environment-Specific Deployments
```yaml
deploy_staging:
  if: github.ref == 'refs/heads/develop'
  runs-on: ubuntu-latest
  steps:
    - name: Deploy to Staging
      run: npm run deploy:staging

deploy_production:
  if: github.ref == 'refs/heads/main'
  runs-on: ubuntu-latest
  steps:
    - name: Deploy to Production
      run: npm run deploy:production
```

### Notifications
```yaml
- name: Notify Slack on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Build failed'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Best Practices

### Pipeline Design
- Keep stages focused and atomic
- Use caching for dependencies
- Parallelize independent jobs
- Fail fast on linting/test failures
- Implement proper secret management

### Deployment Strategy
- Use feature flags for gradual rollouts
- Implement blue-green deployments
- Support instant rollbacks
- Monitor deployments with health checks
- Maintain multiple environments (dev, staging, prod)

### Security
- Never commit secrets or tokens
- Use encrypted secrets in CI/CD
- Implement security scanning (SAST/DAST)
- Sign and verify artifacts
- Use least-privilege IAM roles

## File Patterns

Look for:
- `.github/workflows/**/*.{yml,yaml}`
- `.gitlab-ci.yml`
- `Jenkinsfile`
- `**/.ci/**/*`
- `**/scripts/deploy.sh`

## Keywords

CI/CD, GitHub Actions, GitLab CI, Jenkins, continuous integration, continuous deployment, pipeline, automation, build, test, deploy, workflow, caching, matrix builds
