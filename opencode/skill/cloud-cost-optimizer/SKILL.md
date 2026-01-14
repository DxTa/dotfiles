# Cloud Cost Optimizer

Cloud cost optimization and reporting for AWS, GCP, Azure.

## When to Use

Use this skill when:
- Identifying cloud cost waste and inefficiencies
- Optimizing cloud infrastructure spending
- Analyzing cost allocation and chargebacks
- Rightsizing cloud resources
- Planning reserved instances and savings plans
- Setting cost budgets and alerts
- Multi-cloud cost management
- Cloud cost reporting and forecasting

## Key Concepts

### Cost Analysis
- **Cost Allocation**: Tag-based cost distribution
- **Rightsizing**: Matching resources to actual usage
- **Idle Resources**: Identify unused/underutilized assets
- **Orphaned Resources**: Unattached volumes, snapshots, EIPs
- **Storage Optimization**: Tiering and lifecycle policies

### Cost Optimization Strategies
- **Reserved Instances (RIs)**: Pre-purchase for 1-3 year terms
- **Savings Plans**: Flexible commitment pricing
- **Spot Instances**: Use spare capacity (up to 90% savings)
- **Auto Scaling**: Scale based on demand
- **Instance Families**: Choose cost-effective instance types
- **Storage Classes**: Use S3 tiers, Glacier, Archive
- **Data Transfer**: Minimize egress costs

### Monitoring & Alerting
- **Budgets**: Set spending limits and alerts
- **Anomaly Detection**: Unusual spending patterns
- **Cost Trends**: Historical analysis and forecasting
- **Real-time Monitoring**: Track spending by service, tag, region

## Cloud Provider Tools

### AWS
- **Cost Explorer**: Detailed cost analysis
- **AWS Budgets**: Budgets and alerts
- **Trusted Advisor**: Cost optimization recommendations
- **Compute Optimizer**: Rightsizing recommendations
- **S3 Storage Lens**: Storage cost analysis
- **Cost and Usage Report (CUR)**: Detailed billing data

### GCP
- **Cloud Billing**: Cost breakdown and reports
- **Cost Management**: Budgets and forecasts
- **Recommendations**: Cost optimization suggestions
- **BigQuery Export**: Analyze billing data

### Azure
- **Cost Management**: Monitor and optimize costs
- **Budgets**: Set spending limits
- **Advisor**: Optimization recommendations
- **Cost Analysis**: Detailed cost reports

## Third-Party Tools
- **CloudHealth**: Multi-cloud cost management
- **Cloudability**: AWS cost optimization
- **Spot.io**: Automated cloud optimization
- **Infracost**: Terraform cost estimation
- **Kubecost**: Kubernetes cost monitoring

## Patterns and Practices

### Cost Optimization Workflow
1. **Audit Current Spending**: Comprehensive cost analysis
2. **Identify Waste**: Idle, orphaned, over-provisioned resources
3. **Rightsize Resources**: Match to actual usage
4. **Purchase Commitments**: RIs and Savings Plans
5. **Implement Tagging**: Enable cost allocation
6. **Set Budgets & Alerts**: Proactive monitoring
7. **Monitor Trends**: Track optimization impact
8. **Review Regularly**: Monthly cost reviews

### Tagging Strategy
- **Environment**: prod, dev, test, staging
- **Owner/Team**: responsible team or individual
- **Project/Service**: specific project or service name
- **Cost Center**: billing code or department
- **Purpose**: web, database, cache, storage

### Best Practices
- Implement comprehensive tagging strategy
- Use auto-scaling for variable workloads
- Schedule non-production resources to stop
- Use appropriate storage classes for data lifecycle
- Purchase RIs for predictable workloads
- Use spot instances for batch processing
- Monitor and clean up unused resources
- Regularly review and update security groups/route tables
- Optimize data transfer costs
- Use CloudWatch Logs Insights for cost-effective log analysis

## AWS CLI Examples

### Cost Explorer
```bash
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

### Identify Idle EC2 Instances
```bash
aws ec2 describe-instances \
  --query 'Reservations[].Instances[?State.Name==`running`].[InstanceId,LaunchTime]' \
  --output table
```

### Get Savings Plans Recommendations
```bash
aws ce get-savings-plans-purchase-recommendation
```

## Terraform Cost Estimation

```hcl
resource "aws_instance" "web" {
  instance_type = "t3.micro"  # Cost-optimized choice

  tags = {
    Environment = "prod"
    CostCenter  = "engineering"
  }
}
```

## File Patterns

Look for:
- `**/terraform/**/*`
- `**/cloudformation/**/*`
- `**/kubernetes/**/*`
- `**/iac/**/*`
- `**/cost-optimizer/**/*`
- `**/*.tf`, `**/*.yaml` (CloudFormation)

## Keywords

Cloud cost, cost optimization, AWS, GCP, Azure, cost analysis, reserved instances, savings plans, spot instances, rightsizing, cost allocation, cloud billing, cost monitoring, budgeting, cloud waste
