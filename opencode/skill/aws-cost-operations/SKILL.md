# AWS Cost Operations

AWS cost optimization, monitoring, billing analysis, Cost Explorer, CloudWatch, CloudTrail, and Well-Architected Framework.

## When to Use

Use this skill when:
- Analyzing AWS costs and spending patterns
- Optimizing cloud infrastructure costs
- Setting up cost monitoring and alerts
- Reviewing Cost Explorer reports
- Implementing Well-Architected best practices
- Managing Cost and Usage Reports (CUR)
- Analyzing CloudTrail for cost impact
- Setting up budgets and forecasts

## Key Concepts

### AWS Cost Components
- **EC2**: Compute instances, reserved instances
- **EBS**: Storage volumes, snapshots
- **S3**: Object storage, data transfer
- **RDS**: Database instances, storage
- **Lambda**: Serverless compute
- **Data Transfer**: Egress, inter-region, inter-VPC

### Cost Optimization Pillars
1. **Cost Awareness**: Understand where you spend
2. **Cost Governance**: Policies and controls
3. **Cloud Economics**: Cost-efficient architectures
4. **Usage Efficiency**: Right-sized resources
5. **Rate Optimization**: Lower unit costs

## Cost Explorer

### Cost Analysis
```bash
# Get monthly costs by service
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --output json

# Get costs by tag
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --group-by Type=TAG,Key=Environment
```

### Cost Forecast
```bash
# Forecast costs for next 3 months
aws ce get-cost-forecast \
  --time-period Start=2024-02-01,End=2024-04-30 \
  --metric BlendedCost \
  --granularity MONTHLY \
  --prediction-interval-upper-bound 95
```

## AWS Budgets

### Create Budget
```bash
# Create cost budget
aws budgets create-budget \
  --account-id 123456789012 \
  --budget '{
    "BudgetName": "MonthlyCostBudget",
    "BudgetLimit": {
      "Amount": "1000",
      "Unit": "USD"
    },
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  }'

# Create budget with notifications
aws budgets create-budget \
  --account-id 123456789012 \
  --budget file://budget.json
```

### Budget Notifications
```json
{
  "BudgetName": "MonthlyCostBudget",
  "BudgetLimit": {
    "Amount": "1000",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST",
  "NotificationWithSubscribers": [
    {
      "Notification": {
        "NotificationType": "ACTUAL",
        "ComparisonOperator": "GREATER_THAN",
        "Threshold": 80
      },
      "Subscribers": [
        {
          "SubscriptionType": "EMAIL",
          "Address": "billing@example.com"
        }
      ]
    }
  ]
}
```

## Cost Monitoring

### CloudWatch Metrics
```bash
# Create cost anomaly alarm
aws cloudwatch put-metric-alarm \
  --alarm-name "CostAnomalyAlarm" \
  --alarm-description "Alert on unusual cost increases" \
  --metric-name AnomalousSpend \
  --namespace AWS/Billing \
  --statistic Sum \
  --period 86400 \
  --evaluation-periods 1 \
  --threshold 100 \
  --comparison-operator GreaterThanThreshold \
  --treat-missing-data notBreaching
```

### Anomaly Detection
```bash
# Enable cost anomaly detection
aws ce enable-anomaly-subscription \
  --account-id 123456789012 \
  --monitor "AnomalySubscription" \
  --subscription '{
    "Subscriber": {
      "Type": "SNS",
      "Address": "arn:aws:sns:us-east-1:123456789012:cost-alerts"
    },
    "Frequency": "DAILY",
    "Threshold": 100
  }'
```

## Cost Optimization Strategies

### EC2 Optimization
```bash
# Get compute optimizer recommendations
aws compute-optimizer-get-ec2-instance-recommendations \
  --account-ids 123456789012

# Right-size instances based on recommendations
# Purchase reserved instances for steady-state workloads
# Use spot instances for fault-tolerant workloads
```

### Storage Optimization
```bash
# Identify EBS volumes to right-size
aws ec2 describe-volumes \
  --query 'Volumes[?State==`available`].{ID:VolumeId,Size:Size,Type:VolumeType}'

# Move data to lower storage tiers
# Use S3 lifecycle policies
# Clean up old snapshots
```

### Lambda Optimization
```bash
# Configure memory and timeout efficiently
# Check Lambda cost analysis
aws lambda get-account-settings \
  --query 'AccountUsage'

# Use Lambda provisioned concurrency for consistent performance
```

## Cost and Usage Reports (CUR)

### Enable CUR
```bash
# Enable detailed billing report
aws cur put-report-definition \
  --report-definition '{
    "ReportName": "DailyCostReport",
    "TimeUnit": "DAILY",
    "Format": "textORcsv",
    "Compression": "GZIP",
    "S3Bucket": "my-billing-bucket",
    "S3Prefix": "cost-reports/",
    "S3Region": "us-east-1",
    "AdditionalSchemaElements": ["RESOURCES"]
  }'
```

### Query CUR
```python
import pandas as pd
import awswrangler as wr

# Read CUR data
df = wr.s3.read_csv(
    path="s3://my-billing-bucket/cost-reports/DailyCostReport-00001.csv.gz",
    dtype={
        "line_item_usage_start_date": "str",
        "line_item_usage_end_date": "str"
    }
)

# Analyze costs
costs_by_service = df.groupby("product_product_name")["line_item_unblended_cost"].sum()
print(costs_by_service)
```

## CloudTrail Analysis

### Cost Impact Analysis
```bash
# Query CloudTrail for expensive operations
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=RunInstances \
  --start-time 2024-01-01T00:00:00Z

# Analyze API calls that increase costs
# Identify over-provisioning patterns
# Track resource creation/deletion
```

## Well-Architected Framework

### Cost Optimization Pillar
1. **Expenditure awareness**: Understand where money is spent
2. **Cost-effective resources**: Choose right services
3. **Supply and demand**: Match capacity to demand
4. **Optimization over time**: Continuously improve
5. **Managed services**: Use when cost-effective

### Best Practices
- **Use appropriate instance types**: Match workload requirements
- **Implement auto scaling**: Scale resources with demand
- **Use reserved instances**: Commit for 1-3 years
- **Use spot instances**: Up to 90% savings
- **Use serverless**: Pay only for actual usage
- **Optimize storage tiers**: Use appropriate storage class
- **Minimize data transfer**: Reduce egress costs
- **Use CloudWatch**: Monitor and optimize

## Budget Automation

### Lambda Function for Alerts
```python
import boto3
import json

def lambda_handler(event, context):
    ce = boto3.client('ce')

    # Get current month costs
    response = ce.get_cost_and_usage(
        TimePeriod={
            'Start': '2024-01-01',
            'End': '2024-01-31'
        },
        Granularity='MONTHLY',
        Metrics=['BlendedCost']
    )

    cost = float(response['ResultsByTime'][0]['Total']['BlendedCost']['Amount'])

    # Send alert if over budget
    if cost > 1000:
        sns = boto3.client('sns')
        sns.publish(
            TopicArn='arn:aws:sns:us-east-1:123456789012:cost-alerts',
            Message=f'Cost alert: ${cost:.2f} spent this month'
        )

    return {'statusCode': 200}
```

## Cost Allocation

### Tagging Strategy
```bash
# Tag resources for cost allocation
aws ec2 create-tags \
  --resources i-1234567890abcdef0 \
  --tags Key=Environment,Value=prod \
           Key=Project,Value=myapp \
           Key=CostCenter,Value=engineering

# Create cost allocation tags in billing console
# Enable cost allocation for tags
# Review costs by tag in Cost Explorer
```

## File Patterns

Look for:
- `**/cost-optimizer/**/*.{py,js,ts}`
- `**/billing/**/*`
- `**/cost-reports/**/*`
- `**/terraform/**/*.tf` (cost-optimized resources)
- `**/scripts/cost*.sh`

## Keywords

AWS cost, cost optimization, billing, Cost Explorer, AWS Budgets, CloudWatch cost, CloudTrail, CUR, reserved instances, spot instances, Well-Architected, cost allocation, tagging
