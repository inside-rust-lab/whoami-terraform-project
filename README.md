# Highly Available AWS Web Application Infrastructure with Terraform

## Overview

This project demonstrates the deployment of a highly available web application architecture on AWS using **Terraform Infrastructure as Code (IaC)**.

The goal of this project was to build a production-style AWS environment that is repeatable, scalable, and automated. Instead of manually creating resources through the AWS Console, all infrastructure is defined using Terraform configuration files.

The architecture includes:

* Custom VPC networking
* Public and private subnets across multiple Availability Zones
* Internet Gateway and NAT Gateway configuration
* Security Groups following least-privilege principles
* EC2 Launch Templates
* Application Load Balancer
* Target Groups
* Auto Scaling Groups
* Automated instance provisioning
* EC2 instances running a traefik/whoami Docker container

---

## Application URL

The deployed application is available at:

**http://whoami.eddieeby.com**

This URL routes traffic through the AWS Application Load Balancer, which distributes requests across EC2 instances managed by an Auto Scaling Group.

---

# Architecture

```
                         Internet
                            |
                            |
                    Internet Gateway
                            |
                            |
              Application Load Balancer
                  (Public Subnets)
                            |
                            |
                    Target Group
                            |
              -------------------------
              |                       |
          EC2 Instance            EC2 Instance
        (Private Subnet)        (Private Subnet)
              |                       |
              -------------------------
                            |
                     Auto Scaling Group
```

---

# AWS Resources Created

## Networking

### VPC

A custom VPC provides the networking foundation for the application.

Example CIDR:

```
10.0.0.0/16
```

The VPC spans the AWS Region while subnets are deployed within individual Availability Zones.

### Subnets

The architecture uses separate public and private subnets.

Public subnets:

* Host internet-facing resources
* Application Load Balancer
* NAT Gateway resources

Private subnets:

* Host application servers
* Prevent direct inbound internet access

Example:

```
Public Subnet A
10.0.1.0/24

Public Subnet B
10.0.2.0/24

Private Subnet A
10.0.101.0/24

Private Subnet B
10.0.102.0/24
```

---

# Routing

## Public Route Table

Public resources use the Internet Gateway for internet access.

```
0.0.0.0/0 → Internet Gateway
```

## Private Route Table

Private resources use the NAT Gateway for outbound internet access.

```
0.0.0.0/0 → NAT Gateway
```

Private instances can download updates or access external services without being directly reachable from the internet.

---

# Security

## Application Load Balancer Security Group

Allows public web traffic:

```
Inbound:
HTTP  : 80
HTTPS : 443
Source: 0.0.0.0/0
```

## EC2 Security Group

Only allows traffic from the Application Load Balancer:

```
Inbound:
HTTP : 80
Source: ALB Security Group
```

This prevents direct access to application servers from the internet.

---

# Launch Template

The Launch Template defines the EC2 instance configuration:

* AMI
* Instance type
* Security Groups
* IAM Instance Profile
* Storage configuration

The Auto Scaling Group uses this template whenever a new instance is required.

---

# Application Load Balancer

The ALB provides:

* Public entry point for users
* Traffic distribution across instances
* Health checking
* High availability across Availability Zones

Traffic flow:

```
Client
 |
 v
ALB Listener
 |
 v
Target Group
 |
 v
Healthy EC2 Instances
```

---

# Auto Scaling Group

The Auto Scaling Group maintains application availability.

Example configuration:

```
Minimum instances: 2
Desired instances: 2
Maximum instances: 4
```

The ASG automatically:

* Launches instances from the Launch Template
* Registers instances with the Target Group
* Replaces unhealthy instances
* Maintains desired capacity

---

# Terraform Workflow

Initialize Terraform:

```bash
terraform init
```

Review planned changes:

```bash
terraform plan
```

Deploy infrastructure:

```bash
terraform apply
```

Remove infrastructure:

```bash
terraform destroy
```

---

# Future Improvements

Potential enhancements:

* Route 53 DNS configuration
* HTTPS using AWS Certificate Manager
* CloudWatch alarms and Auto Scaling policies
* CI/CD pipeline for Terraform deployments
* Container deployment using ECS or Kubernetes
* Design a more robust and realistic web application

---

# Skills Demonstrated

This project demonstrates experience with:

* AWS networking
* Infrastructure as Code
* Terraform
* VPC architecture
* Load balancing
* Auto Scaling
* IAM security practices
* Cloud architecture design
* DevOps automation principles
