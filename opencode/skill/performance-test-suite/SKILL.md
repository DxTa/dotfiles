# Performance Test Suite

Performance testing suite for load testing, stress testing, and bottleneck identification.

## When to Use

Use this skill when:
- Conducting load, stress, spike, or endurance tests
- Analyzing performance metrics and bottlenecks
- Investigating memory leaks or resource issues
- Measuring response times, throughput, and latency
- Benchmarking system performance
- Identifying breaking points
- Capacity planning

## Key Concepts

### Test Types
- **Load Testing**: Expected user traffic patterns
- **Stress Testing**: Beyond expected limits to find breaking point
- **Spike Testing**: Sudden traffic increases
- **Endurance Testing**: Sustained load over time (soak testing)
- **Volume Testing**: Large data volumes
- **Scalability Testing**: Vertical and horizontal scaling

### Common Tools
- **k6**: Modern load testing with JavaScript
- **JMeter**: Java-based, feature-rich
- **Locust**: Python-based, distributed
- **Gatling**: Scala-based, high-performance
- **Artillery**: Node.js-based
- **wrk**: Single-threaded HTTP benchmarking

### Key Metrics
- Response time (avg, p50, p95, p99)
- Throughput (requests per second)
- Error rate
- CPU/memory usage
- Database query performance
- Network latency
- Concurrent users

## Patterns and Practices

### Test Design
1. Define performance requirements (SLAs, SLOs)
2. Identify critical user journeys
3. Create realistic test scenarios
4. Set up test environment (production-like)
5. Configure baselines and thresholds
6. Run tests and collect metrics
7. Analyze results and identify bottlenecks
8. Report findings and recommendations

### Bottleneck Investigation
- Database: slow queries, missing indexes, connection pools
- Application: inefficient algorithms, memory leaks, thread contention
- Network: bandwidth, latency, DNS resolution
- Infrastructure: CPU, memory, disk I/O limits
- External dependencies: third-party API latency

### Best Practices
- Test in production-like environments
- Use realistic test data
- Monitor infrastructure during tests
- Automate test execution in CI/CD
- Establish performance baselines early
- Profile and optimize before scaling
- Document performance budgets

## File Patterns

Look for:
- `**/performance/**/*`
- `**/load-test*/**/*`
- `**/*perf*.{js,ts,py}`
- `**/benchmarks/**/*`
- `**/*benchmark*.{js,ts,py}`

## Keywords

Load test, stress test, performance test, benchmark, spike test, endurance test, performance metrics, bottleneck, memory leak, response time, throughput, latency, performance analysis, capacity test, breaking point
