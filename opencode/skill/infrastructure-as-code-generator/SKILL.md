# Infrastructure as Code Generator

Infrastructure as Code generator for Terraform, CloudFormation, and Pulumi.

## When to Use

Use this skill when:
- Defining infrastructure as code
- Creating cloud resources (AWS, GCP, Azure)
- Automating infrastructure provisioning
- Managing Terraform configurations
- Writing CloudFormation templates
- Developing Pulumi infrastructure
- Implementing infrastructure best practices
- Setting up multi-environment infrastructure

## Key Concepts

### IaC Benefits
- **Reproducibility**: Consistent deployments
- **Version Control**: Git-based infrastructure changes
- **Automation**: Automated provisioning and updates
- **Scalability**: Easy to scale resources
- **Documentation**: Code serves as documentation

### Core Principles
- **Idempotency**: Same result on repeated runs
- **Declarative**: Define desired state, not how to achieve it
- **Immutability**: Replace instead of modify
- **Modularity**: Reusable components and modules

## Terraform

### Basic Configuration
```hcl
# main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
    Environment = "production"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}
```

### Variables and Outputs
```hcl
# variables.tf
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 2
}

# outputs.tf
output "instance_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP of the web server"
}
```

### Modules
```hcl
# modules/vpc/main.tf
variable "cidr_block" {
  type = string
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
}

output "vpc_id" {
  value = aws_vpc.this.id
}

# main.tf - using module
module "vpc" {
  source = "./modules/vpc"

  cidr_block = "10.0.0.0/16"
}
```

### Backend Configuration
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## CloudFormation

### Basic Template
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Simple EC2 instance

Parameters:
  InstanceType:
    Type: String
    Default: t3.micro
    Description: EC2 instance type

Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-0c55b159cbfafe1f0
      InstanceType: !Ref InstanceType
      Tags:
        - Key: Name
          Value: MyEC2Instance

Outputs:
  InstanceId:
    Description: Instance ID
    Value: !Ref MyInstance
  PublicIP:
    Description: Public IP
    Value: !GetAtt MyInstance.PublicIp
```

### Nested Stacks
```yaml
AWSTemplateFormatVersion: '2010-09-09'

Resources:
  VPCStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub https://s3.amazonaws.com/${Bucket}/vpc.yaml
      Parameters:
        VpcCIDR: 10.0.0.0/16
```

### Mappings and Conditions
```yaml
Parameters:
  Environment:
    Type: String
    AllowedValues:
      - dev
      - prod

Conditions:
  IsProd: !Equals [!Ref Environment, prod]

Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !If [IsProd, t3.large, t3.micro]
      Tags:
        - Key: Environment
          Value: !Ref Environment
```

## Pulumi

### AWS Configuration (TypeScript)
```typescript
import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

// Create VPC
const vpc = new aws.ec2.Vpc("main-vpc", {
  cidrBlock: "10.0.0.0/16",
  tags: {
    Name: "main-vpc"
  }
});

// Create subnet
const subnet = new aws.ec2.Subnet("public-subnet", {
  vpcId: vpc.id,
  cidrBlock: "10.0.1.0/24",
  tags: {
    Name: "public-subnet"
  }
});

// Export values
export const vpcId = vpc.id;
export const subnetId = subnet.id;
```

### Stack Configuration
```typescript
// Pulumi.dev.ts
import * as pulumi from "@pulumi/pulumi";
import * as config from "./config";

const config = new pulumi.Config();
const environment = config.require("environment");

// Environment-specific resources
const instanceType = environment === "prod" ? "t3.large" : "t3.micro";
```

## Patterns and Practices

### Multi-Environment Setup
```hcl
# environments/dev/backend.tf
resource "aws_instance" "web" {
  instance_type = "t3.micro"
  # ...
}

# environments/prod/backend.tf
resource "aws_instance" "web" {
  instance_type = "t3.large"
  # ...
}

# main.tf
module "backend" {
  source = "./environments/${terraform.workspace}/backend"
}
```

### State Management
```bash
# Initialize with remote backend
terraform init -backend-config="bucket=my-state" -backend-config="key=prod/terraform.tfstate"

# Import existing resources
terraform import aws_instance.web i-1234567890

# State manipulation
terraform state show aws_instance.web
terraform state mv aws_instance.web aws_instance.web_new
```

### Best Practices
- Use modules for reusability
- Implement state locking
- Use consistent naming conventions
- Tag all resources
- Implement least-privilege IAM
- Separate state by environment
- Use variables for configuration
- Encrypt sensitive data

## Security Best Practices

### IAM Roles
```hcl
resource "aws_iam_role" "ec2_role" {
  name = "ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
```

### Security Groups
```hcl
resource "aws_security_group" "web" {
  name_prefix = "web-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Testing

### Terraform Tests
```go
// main_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformBasicExample(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/basic",
    }

    defer terraform.Destroy(t, terraformOptions)

    terraform.InitAndApply(t, terraformOptions)

    instanceID := terraform.Output(t, terraformOptions, "instance_id")
    assert.NotEmpty(t, instanceID)
}
```

## File Patterns

Look for:
- `**/terraform/**/*.{tf,json}`
- `**/*.tf`
- `**/cloudformation/**/*.yaml`
- `**/pulumi/**/*.ts`
- `**/iac/**/*`
- `**/infrastructure/**/*`

## Keywords

Infrastructure as Code, IaC, Terraform, CloudFormation, Pulumi, AWS, GCP, Azure, infrastructure provisioning, automation, modules, state management, multi-environment, DevOps
