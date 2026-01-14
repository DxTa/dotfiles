# AWS Serverless EDA

AWS serverless and event-driven architecture - Lambda, API Gateway, DynamoDB, Step Functions, EventBridge, SQS, SNS.

## When to Use

Use this skill when:
- Building serverless applications on AWS
- Designing event-driven architectures
- Using AWS Lambda functions
- Setting up API Gateway endpoints
- Implementing DynamoDB tables
- Creating Step Functions workflows
- Configuring EventBridge rules
- Setting up SQS queues and SNS topics

## Key Concepts

### Serverless Benefits
- **No servers to manage**: AWS handles infrastructure
- **Automatic scaling**: Scales based on demand
- **Pay for use**: Only pay for actual usage
- **Built-in availability**: High availability out of the box

### Event-Driven Architecture
- **Decoupled services**: Services communicate via events
- **Loose coupling**: Independent service evolution
- **Asynchronous processing**: Non-blocking workflows
- **Event sourcing**: State changes stored as events

## Lambda Functions

### Basic Function (Node.js)
```javascript
// index.js
exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));

  const response = {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Hello from Lambda!',
      input: event
    })
  };

  return response;
};
```

### Lambda with DynamoDB
```javascript
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const params = {
    TableName: 'Users',
    Item: {
      id: event.id,
      name: event.name,
      email: event.email
    }
  };

  await dynamodb.put(params).promise();

  return {
    statusCode: 201,
    body: JSON.stringify({ message: 'User created' })
  };
};
```

### Python Lambda
```python
import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Users')

def lambda_handler(event, context):
    # Process event
    user_id = event['id']
    name = event['name']

    # Save to DynamoDB
    table.put_item(
        Item={
            'id': user_id,
            'name': name
        }
    )

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'User created'})
    }
```

## API Gateway

### REST API
```yaml
# serverless.yml
service: my-api

provider:
  name: aws
  runtime: nodejs18.x

functions:
  hello:
    handler: handler.hello
    events:
      - http:
          path: hello
          method: get

  createUser:
    handler: handler.createUser
    events:
      - http:
          path: users
          method: post

plugins:
  - serverless-offline
```

### HTTP API (Simpler)
```bash
# Create HTTP API
aws apigatewayv2 create-api \
  --name MyAPI \
  --protocol-type HTTP

# Create integration with Lambda
aws apigatewayv2 create-integration \
  --api-id $API_ID \
  --integration-type AWS_PROXY \
  --integration-uri arn:aws:lambda:us-east-1:123456789012:function:my-function

# Create route
aws apigatewayv2 create-route \
  --api-id $API_ID \
  --route-key 'GET /hello' \
  --target $INTEGRATION_ID
```

## DynamoDB

### Table Creation
```python
import boto3

dynamodb = boto3.client('dynamodb')

# Create table
response = dynamodb.create_table(
    TableName='Users',
    KeySchema=[
        {
            'AttributeName': 'id',
            'KeyType': 'HASH'
        }
    ],
    AttributeDefinitions=[
        {
            'AttributeName': 'id',
            'AttributeType': 'S'
        }
    ],
    ProvisionedThroughput={
        'ReadCapacityUnits': 5,
        'WriteCapacityUnits': 5
    }
)

# Wait for table to be created
dynamodb.get_waiter('table_exists').wait(TableName='Users')
```

### Operations
```python
from boto3 import resource

dynamodb = resource('dynamodb')
table = dynamodb.Table('Users')

# Put item
table.put_item(
    Item={
        'id': 'user1',
        'name': 'John Doe',
        'email': 'john@example.com'
    }
)

# Get item
response = table.get_item(
    Key={'id': 'user1'}
)
item = response['Item']

# Query items
response = table.query(
    KeyConditionExpression='id = :id',
    ExpressionAttributeValues={
        ':id': 'user1'
    }
)
```

## Step Functions

### Workflow Definition
```json
{
  "Comment": "Hello world workflow",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:HelloWorld",
      "End": true
    }
  }
}
```

### Complex Workflow
```json
{
  "Comment": "Process order workflow",
  "StartAt": "ValidateOrder",
  "States": {
    "ValidateOrder": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:ValidateOrder",
      "Next": "ProcessPayment"
    },
    "ProcessPayment": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:ProcessPayment",
      "Next": "IsPaymentSuccessful"
    },
    "IsPaymentSuccessful": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.paymentSuccess",
          "BooleanEquals": true,
          "Next": "ShipOrder"
        }
      ],
      "Default": "PaymentFailed"
    },
    "ShipOrder": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:ShipOrder",
      "End": true
    },
    "PaymentFailed": {
      "Type": "Fail",
      "Cause": "Payment processing failed",
      "Error": "PaymentError"
    }
  }
}
```

## EventBridge

### Rule Creation
```python
import boto3

events = boto3.client('events')

# Create rule to trigger Lambda on schedule
response = events.put_rule(
    Name='DailyCleanup',
    ScheduleExpression='rate(1 day)',
    State='ENABLED'
)

# Add Lambda target
events.put_targets(
    Rule='DailyCleanup',
    Targets=[
        {
            'Arn': 'arn:aws:lambda:us-east-1:123456789012:function:CleanupFunction',
            'Id': '1'
        }
    ]
)
```

### Event Pattern
```python
# Trigger on S3 object creation
response = events.put_rule(
    Name='S3ObjectCreated',
    EventPattern=json.dumps({
        "source": ["aws.s3"],
        "detail-type": ["Object Created"],
        "detail": {
            "bucket": {
                "name": ["my-bucket"]
            }
        }
    })
)
```

## SQS (Simple Queue Service)

### Queue Creation
```python
import boto3

sqs = boto3.client('sqs')

# Create queue
response = sqs.create_queue(
    QueueName='my-queue',
    Attributes={
        'DelaySeconds': '0',
        'VisibilityTimeout': '60',
        'MessageRetentionPeriod': '86400'
    }
)

queue_url = response['QueueUrl']

# Send message
sqs.send_message(
    QueueUrl=queue_url,
    MessageBody='Hello from SQS'
)

# Receive message
messages = sqs.receive_message(
    QueueUrl=queue_url,
    MaxNumberOfMessages=10,
    WaitTimeSeconds=20
)
```

### Lambda + SQS
```python
import json

def lambda_handler(event, context):
    for record in event['Records']:
        message = json.loads(record['body'])

        # Process message
        print(f"Processing: {message}")

    return {
        'statusCode': 200,
        'body': json.dumps('Processed')
    }
```

## SNS (Simple Notification Service)

### Topic Creation
```python
import boto3

sns = boto3.client('sns')

# Create topic
response = sns.create_topic(
    Name='my-topic'
)
topic_arn = response['TopicArn']

# Subscribe to topic (email)
sns.subscribe(
    TopicArn=topic_arn,
    Protocol='email',
    Endpoint='user@example.com'
)

# Publish message
sns.publish(
    TopicArn=topic_arn,
    Message='Hello from SNS!',
    Subject='Notification'
)
```

## Patterns and Practices

### Fan-Out Pattern
```json
{
  "StartAt": "Broadcast",
  "States": {
    "Broadcast": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "ProcessA"
        },
        {
          "StartAt": "ProcessB"
        },
        {
          "StartAt": "ProcessC"
        }
      ]
    }
  }
}
```

### Error Handling
```python
import json

def lambda_handler(event, context):
    try:
        # Process event
        result = process_event(event)

        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }
    except Exception as e:
        # Log error
        print(f"Error: {str(e)}")

        # Send to dead-letter queue
        send_to_dlq(event)

        # Return error
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
```

### Best Practices
- **Keep functions small**: Single responsibility
- **Use environment variables**: Configuration
- **Implement dead-letter queues**: Failed messages
- **Monitor with CloudWatch**: Metrics and logs
- **Use AWS X-Ray**: Distributed tracing
- **Implement retries**: Transient failures
- **Enable logging**: Debug and audit

## File Patterns

Look for:
- `**/lambda/**/*.{js,py,go}`
- `**/serverless/**/*.yml`
- `**/step-functions/**/*.json`
- `**/sam/**/*.yaml`
- `**/cdk/**/*.ts`

## Keywords

AWS serverless, Lambda, API Gateway, DynamoDB, Step Functions, EventBridge, SQS, SNS, event-driven architecture, SAM, Serverless Framework, CDK, microservices
