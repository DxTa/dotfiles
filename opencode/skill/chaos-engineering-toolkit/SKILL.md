# Chaos Engineering Toolkit

Chaos engineering toolkit for testing system resilience through controlled failure injection and stress testing.

## When to Use

Use this skill when working on:
- Chaos engineering experiments and tests
- System resilience and recovery validation
- Failure injection testing
- Circuit breaker and retry testing
- GameDays and disaster recovery testing
- Cascading failure prevention
- Latency simulation and resource exhaustion tests

## Key Concepts

### Chaos Engineering Principles
- Hypothesis-driven experimentation
- Blast radius minimization
- Steady-state measurement
- Real-world simulation
- Automated vs. manual experiments

### Common Tools
- **Chaos Mesh**: Kubernetes-native chaos engineering
- **Gremlin**: SaaS-based chaos platform
- **Toxiproxy**: Network fault simulation
- **Litmus**: Cloud-native chaos engineering
- **Chaos Toolkit**: Extensible framework

## Patterns and Practices

### Failure Injection Types
- Network failures: latency, packet loss, DNS errors
- Resource exhaustion: CPU, memory, disk I/O
- Service failures: process kills, container crashes
- Dependency failures: database, cache, external APIs

### Experiment Design
1. Define steady-state (metrics, success rates)
2. Formulate hypothesis (e.g., "service X tolerates 50ms latency")
3. Introduce failure (minimal blast radius)
4. Observe impact on steady-state
5. Rollback if hypothesis disproved
6. Document findings and improvements

### Best Practices
- Start in non-production environments
- Monitor throughout experiments
- Set up automated rollback mechanisms
- Document all experiments for post-mortem analysis
- Schedule regular GameDays for team training
- Use canary deployments for gradual failure introduction

## File Patterns

Look for:
- `**/chaos/**/*`
- `**/*chaos*.{js,ts,py,yaml,yml}`
- `**/resilience/**/*`
- `**/tests/chaos/**/*`

## Keywords

Chaos engineering, chaos test, chaos experiment, resilience test, failure injection, latency simulation, resource exhaustion, circuit breaker, retry testing, GameDays, cascading failure, recovery mechanism, system resilience
