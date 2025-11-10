## AWS Best Practices

### Overview

Amazon Web Services (AWS) provides a comprehensive cloud computing platform with services for compute, storage, databases, networking, security, and more. This guide covers best practices for building secure, reliable, and cost-effective infrastructure on AWS.

**Core Services:**

- **EC2**: Virtual servers in the cloud
- **VPC**: Isolated virtual networks
- **IAM**: Identity and access management
- **S3**: Object storage service
- **RDS**: Managed relational databases
- **CloudFormation**: Infrastructure as code
- **CloudWatch**: Monitoring and observability

### Well-Architected Framework

AWS Well-Architected Framework provides best practices across six pillars:

1. **Operational Excellence**: Run and monitor systems
2. **Security**: Protect information and systems
3. **Reliability**: Recover from failures and meet demand
4. **Performance Efficiency**: Use resources efficiently
5. **Cost Optimization**: Avoid unnecessary costs
6. **Sustainability**: Minimize environmental impact

### VPC Design and Networking

**VPC Architecture**

```
Production VPC (10.0.0.0/16):
├── Public Subnets (DMZ)
│   ├── us-east-1a: 10.0.1.0/24
│   ├── us-east-1b: 10.0.2.0/24
│   └── us-east-1c: 10.0.3.0/24
├── Private Subnets (Application)
│   ├── us-east-1a: 10.0.11.0/24
│   ├── us-east-1b: 10.0.12.0/24
│   └── us-east-1c: 10.0.13.0/24
└── Private Subnets (Database)
    ├── us-east-1a: 10.0.21.0/24
    ├── us-east-1b: 10.0.22.0/24
    └── us-east-1c: 10.0.23.0/24
```

**VPC Best Practices:**

- Use multiple Availability Zones for high availability
- Separate public and private subnets
- Use /16 for VPC CIDR, /24 for subnets
- Reserve IP space for future growth
- Use VPC Flow Logs for network monitoring
- Implement Network ACLs and Security Groups

**VPC CloudFormation Example**

```yaml
Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: production-vpc

  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: production-igw

  AttachGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref VPC
      InternetGatewayId: !Ref InternetGateway

  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: public-subnet-1a

  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      CidrBlock: 10.0.11.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      Tags:
        - Key: Name
          Value: private-subnet-1a
```

**Security Groups**

```yaml
WebServerSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupDescription: Security group for web servers
    VpcId: !Ref VPC
    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 80
        ToPort: 80
        CidrIp: 0.0.0.0/0
        Description: Allow HTTP from anywhere
      - IpProtocol: tcp
        FromPort: 443
        ToPort: 443
        CidrIp: 0.0.0.0/0
        Description: Allow HTTPS from anywhere
      - IpProtocol: tcp
        FromPort: 22
        ToPort: 22
        SourceSecurityGroupId: !Ref BastionSecurityGroup
        Description: Allow SSH from bastion
    SecurityGroupEgress:
      - IpProtocol: -1
        CidrIp: 0.0.0.0/0
        Description: Allow all outbound traffic
    Tags:
      - Key: Name
        Value: web-server-sg

DatabaseSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupDescription: Security group for database servers
    VpcId: !Ref VPC
    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 3306
        ToPort: 3306
        SourceSecurityGroupId: !Ref WebServerSecurityGroup
        Description: Allow MySQL from web servers
    Tags:
      - Key: Name
        Value: database-sg
```

**Security Group Best Practices:**

- Use descriptive names and descriptions
- Follow principle of least privilege
- Reference security groups instead of CIDR blocks when possible
- Use separate security groups for different tiers
- Document all rules with descriptions
- Regularly audit and remove unused rules

**VPC Endpoints**

```yaml
S3VPCEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub 'com.amazonaws.${AWS::Region}.s3'
    RouteTableIds:
      - !Ref PrivateRouteTable
    VpcEndpointType: Gateway

SSMVPCEndpoint:
  Type: AWS::EC2::VPCEndpoint
  Properties:
    VpcId: !Ref VPC
    ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ssm'
    VpcEndpointType: Interface
    PrivateDnsEnabled: true
    SubnetIds:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2
    SecurityGroupIds:
      - !Ref VPCEndpointSecurityGroup

VPCEndpointSecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupDescription: Security group for VPC endpoints
    VpcId: !Ref VPC
    SecurityGroupIngress:
      - IpProtocol: tcp
        FromPort: 443
        ToPort: 443
        CidrIp: 10.0.0.0/16
        Description: Allow HTTPS from VPC
```

**VPC Endpoint Best Practices:**

- Use Gateway endpoints for S3 and DynamoDB (no cost)
- Use Interface endpoints for other AWS services
- Enable private DNS for Interface endpoints
- Restrict access with security groups
- Use VPC endpoint policies for additional security

### IAM Security

**IAM Best Practices:**

- Enable MFA for root account and privileged users
- Use IAM roles instead of access keys
- Follow principle of least privilege
- Use IAM policies with conditions
- Rotate credentials regularly
- Use AWS Organizations for multi-account management
- Enable CloudTrail for audit logging
- Use IAM Access Analyzer to identify overly permissive policies

**IAM Role for EC2**

```yaml
EC2Role:
  Type: AWS::IAM::Role
  Properties:
    RoleName: ec2-application-role
    AssumeRolePolicyDocument:
      Version: '2012-10-17'
      Statement:
        - Effect: Allow
          Principal:
            Service: ec2.amazonaws.com
          Action: sts:AssumeRole
    ManagedPolicyArns:
      - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
    Policies:
      - PolicyName: S3Access
        PolicyDocument:
          Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Action:
                - s3:GetObject
                - s3:ListBucket
              Resource:
                - !Sub 'arn:aws:s3:::${ApplicationBucket}'
                - !Sub 'arn:aws:s3:::${ApplicationBucket}/*'
    Tags:
      - Key: Name
        Value: ec2-application-role

EC2InstanceProfile:
  Type: AWS::IAM::InstanceProfile
  Properties:
    Roles:
      - !Ref EC2Role
```

**IAM Policy with Conditions**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringEquals": {
          "ec2:InstanceType": ["t3.micro", "t3.small"],
          "aws:RequestedRegion": "us-east-1"
        },
        "StringLike": {
          "ec2:ResourceTag/Environment": "dev"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "arn:aws:ec2:*:*:security-group/*",
      "Condition": {
        "StringEquals": {
          "ec2:Vpc": "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-12345678"
        }
      }
    }
  ]
}
```

**Service Control Policies (SCPs)**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances"
      ],
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringNotEquals": {
          "ec2:InstanceType": [
            "t3.micro",
            "t3.small",
            "t3.medium"
          ]
        }
      }
    },
    {
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": [
            "us-east-1",
            "us-west-2"
          ]
        }
      }
    }
  ]
}
```

### EC2 Best Practices

**Instance Selection:**

- Use appropriate instance types for workload
- Consider Graviton instances for cost savings
- Use Spot Instances for fault-tolerant workloads
- Use Reserved Instances or Savings Plans for steady-state workloads
- Right-size instances based on actual usage

**EC2 Launch Template**

```yaml
LaunchTemplate:
  Type: AWS::EC2::LaunchTemplate
  Properties:
    LaunchTemplateName: web-server-template
    LaunchTemplateData:
      ImageId: !Ref LatestAmiId
      InstanceType: t3.medium
      IamInstanceProfile:
        Arn: !GetAtt EC2InstanceProfile.Arn
      SecurityGroupIds:
        - !Ref WebServerSecurityGroup
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          yum update -y
          yum install -y amazon-cloudwatch-agent
          systemctl enable amazon-cloudwatch-agent
          systemctl start amazon-cloudwatch-agent
      BlockDeviceMappings:
        - DeviceName: /dev/xvda
          Ebs:
            VolumeSize: 30
            VolumeType: gp3
            Encrypted: true
            DeleteOnTermination: true
      MetadataOptions:
        HttpTokens: required
        HttpPutResponseHopLimit: 1
      TagSpecifications:
        - ResourceType: instance
          Tags:
            - Key: Name
              Value: web-server
            - Key: Environment
              Value: production
```

**EC2 Best Practices:**

- Use IMDSv2 (metadata service v2)
- Enable detailed monitoring
- Use encrypted EBS volumes
- Implement automated backups with snapshots
- Use Systems Manager Session Manager instead of SSH
- Tag all resources consistently
- Use Auto Scaling for elasticity

### Auto Scaling

**Auto Scaling Group**

```yaml
AutoScalingGroup:
  Type: AWS::AutoScaling::AutoScalingGroup
  Properties:
    AutoScalingGroupName: web-server-asg
    LaunchTemplate:
      LaunchTemplateId: !Ref LaunchTemplate
      Version: !GetAtt LaunchTemplate.LatestVersionNumber
    MinSize: 2
    MaxSize: 10
    DesiredCapacity: 2
    HealthCheckType: ELB
    HealthCheckGracePeriod: 300
    VPCZoneIdentifier:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2
      - !Ref PrivateSubnet3
    TargetGroupARNs:
      - !Ref TargetGroup
    Tags:
      - Key: Name
        Value: web-server
        PropagateAtLaunch: true

ScaleUpPolicy:
  Type: AWS::AutoScaling::ScalingPolicy
  Properties:
    AutoScalingGroupName: !Ref AutoScalingGroup
    PolicyType: TargetTrackingScaling
    TargetTrackingConfiguration:
      PredefinedMetricSpecification:
        PredefinedMetricType: ASGAverageCPUUtilization
      TargetValue: 70.0
```

**Auto Scaling Best Practices:**

- Use target tracking scaling policies
- Set appropriate health check grace periods
- Use multiple Availability Zones
- Implement lifecycle hooks for graceful shutdown
- Use warm pools for faster scaling
- Monitor scaling activities

### Load Balancing

**Application Load Balancer**

```yaml
ApplicationLoadBalancer:
  Type: AWS::ElasticLoadBalancingV2::LoadBalancer
  Properties:
    Name: web-alb
    Type: application
    Scheme: internet-facing
    IpAddressType: ipv4
    Subnets:
      - !Ref PublicSubnet1
      - !Ref PublicSubnet2
      - !Ref PublicSubnet3
    SecurityGroups:
      - !Ref ALBSecurityGroup
    Tags:
      - Key: Name
        Value: web-alb

TargetGroup:
  Type: AWS::ElasticLoadBalancingV2::TargetGroup
  Properties:
    Name: web-tg
    Port: 80
    Protocol: HTTP
    VpcId: !Ref VPC
    HealthCheckEnabled: true
    HealthCheckPath: /health
    HealthCheckProtocol: HTTP
    HealthCheckIntervalSeconds: 30
    HealthCheckTimeoutSeconds: 5
    HealthyThresholdCount: 2
    UnhealthyThresholdCount: 3
    TargetType: instance
    Matcher:
      HttpCode: 200

HTTPSListener:
  Type: AWS::ElasticLoadBalancingV2::Listener
  Properties:
    LoadBalancerArn: !Ref ApplicationLoadBalancer
    Port: 443
    Protocol: HTTPS
    Certificates:
      - CertificateArn: !Ref Certificate
    DefaultActions:
      - Type: forward
        TargetGroupArn: !Ref TargetGroup
    SslPolicy: ELBSecurityPolicy-TLS-1-2-2017-01

HTTPListener:
  Type: AWS::ElasticLoadBalancingV2::Listener
  Properties:
    LoadBalancerArn: !Ref ApplicationLoadBalancer
    Port: 80
    Protocol: HTTP
    DefaultActions:
      - Type: redirect
        RedirectConfig:
          Protocol: HTTPS
          Port: 443
          StatusCode: HTTP_301
```

**Load Balancer Best Practices:**

- Use HTTPS with valid certificates
- Redirect HTTP to HTTPS
- Enable access logs
- Use connection draining/deregistration delay
- Configure appropriate health checks
- Use multiple Availability Zones
- Enable deletion protection for production
- Use WAF for additional security

### S3 Best Practices

**S3 Bucket Configuration**

```yaml
ApplicationBucket:
  Type: AWS::S3::Bucket
  Properties:
    BucketName: !Sub '${AWS::StackName}-app-bucket'
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: AES256
    VersioningConfiguration:
      Status: Enabled
    LifecycleConfiguration:
      Rules:
        - Id: TransitionToIA
          Status: Enabled
          Transitions:
            - TransitionInDays: 30
              StorageClass: STANDARD_IA
            - TransitionInDays: 90
              StorageClass: GLACIER
        - Id: DeleteOldVersions
          Status: Enabled
          NoncurrentVersionExpirationInDays: 90
    PublicAccessBlockConfiguration:
      BlockPublicAcls: true
      BlockPublicPolicy: true
      IgnorePublicAcls: true
      RestrictPublicBuckets: true
    LoggingConfiguration:
      DestinationBucketName: !Ref LogBucket
      LogFilePrefix: s3-access-logs/
    Tags:
      - Key: Name
        Value: application-bucket
```

**S3 Bucket Policy**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyInsecureTransport",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::bucket-name",
        "arn:aws:s3:::bucket-name/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "AllowVPCEndpointAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::bucket-name/*",
      "Condition": {
        "StringEquals": {
          "aws:SourceVpce": "vpce-1234567"
        }
      }
    }
  ]
}
```

**S3 Best Practices:**

- Enable versioning for critical data
- Use lifecycle policies to optimize costs
- Enable server-side encryption
- Block public access by default
- Use bucket policies and IAM policies together
- Enable access logging
- Use S3 Object Lock for compliance
- Implement cross-region replication for DR
- Use S3 Intelligent-Tiering for unknown access patterns

### RDS Best Practices

**RDS Instance**

```yaml
DBSubnetGroup:
  Type: AWS::RDS::DBSubnetGroup
  Properties:
    DBSubnetGroupName: db-subnet-group
    DBSubnetGroupDescription: Subnet group for RDS
    SubnetIds:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2
      - !Ref PrivateSubnet3

RDSInstance:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: production-db
    Engine: postgres
    EngineVersion: '15.3'
    DBInstanceClass: db.t3.medium
    AllocatedStorage: 100
    StorageType: gp3
    StorageEncrypted: true
    KmsKeyId: !Ref DBEncryptionKey
    MasterUsername: !Sub '{{resolve:secretsmanager:${DBSecret}:SecretString:username}}'
    MasterUserPassword: !Sub '{{resolve:secretsmanager:${DBSecret}:SecretString:password}}'
    DBSubnetGroupName: !Ref DBSubnetGroup
    VPCSecurityGroups:
      - !Ref DatabaseSecurityGroup
    MultiAZ: true
    BackupRetentionPeriod: 7
    PreferredBackupWindow: '03:00-04:00'
    PreferredMaintenanceWindow: 'sun:04:00-sun:05:00'
    EnableCloudwatchLogsExports:
      - postgresql
    DeletionProtection: true
    CopyTagsToSnapshot: true
    Tags:
      - Key: Name
        Value: production-db
```

**RDS Best Practices:**

- Use Multi-AZ for production
- Enable automated backups
- Use encryption at rest
- Store credentials in Secrets Manager
- Enable Enhanced Monitoring
- Use appropriate instance types
- Implement read replicas for read-heavy workloads
- Use Parameter Groups for configuration
- Enable deletion protection
- Monitor performance with Performance Insights

### Monitoring and Logging

**CloudWatch Alarms**

```yaml
HighCPUAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: high-cpu-utilization
    AlarmDescription: Alert when CPU exceeds 80%
    MetricName: CPUUtilization
    Namespace: AWS/EC2
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 80
    ComparisonOperator: GreaterThanThreshold
    Dimensions:
      - Name: AutoScalingGroupName
        Value: !Ref AutoScalingGroup
    AlarmActions:
      - !Ref SNSTopic

DiskSpaceAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: low-disk-space
    MetricName: disk_used_percent
    Namespace: CWAgent
    Statistic: Average
    Period: 300
    EvaluationPeriods: 1
    Threshold: 80
    ComparisonOperator: GreaterThanThreshold
    AlarmActions:
      - !Ref SNSTopic
```

**CloudWatch Logs**

```yaml
LogGroup:
  Type: AWS::Logs::LogGroup
  Properties:
    LogGroupName: /aws/application/web-server
    RetentionInDays: 30
    KmsKeyId: !GetAtt LogEncryptionKey.Arn

MetricFilter:
  Type: AWS::Logs::MetricFilter
  Properties:
    LogGroupName: !Ref LogGroup
    FilterPattern: '[time, request_id, event_type = "ERROR", ...]'
    MetricTransformations:
      - MetricName: ErrorCount
        MetricNamespace: Application
        MetricValue: '1'
        DefaultValue: 0
```

**Monitoring Best Practices:**

- Enable CloudWatch detailed monitoring
- Create alarms for critical metrics
- Use CloudWatch Logs for centralized logging
- Implement log retention policies
- Use CloudWatch Insights for log analysis
- Enable VPC Flow Logs
- Use AWS X-Ray for distributed tracing
- Set up CloudWatch Dashboards
- Configure SNS for alarm notifications

### Cost Optimization

**Cost Optimization Strategies:**

1. **Right-sizing**: Use AWS Compute Optimizer
2. **Reserved Instances**: Commit for 1-3 years
3. **Savings Plans**: Flexible commitment options
4. **Spot Instances**: Up to 90% savings for fault-tolerant workloads
5. **S3 Lifecycle Policies**: Move data to cheaper storage classes
6. **Delete Unused Resources**: EBS volumes, snapshots, elastic IPs
7. **Use Auto Scaling**: Match capacity to demand
8. **Monitor with Cost Explorer**: Identify cost trends
9. **Set Budget Alerts**: Get notified of overspending
10. **Use AWS Graviton**: Better price-performance

**Cost Allocation Tags**

```yaml
Tags:
  - Key: Environment
    Value: production
  - Key: Project
    Value: web-application
  - Key: CostCenter
    Value: engineering
  - Key: Owner
    Value: team-backend
```

**Budget Alert**

```yaml
Budget:
  Type: AWS::Budgets::Budget
  Properties:
    Budget:
      BudgetName: monthly-budget
      BudgetLimit:
        Amount: 1000
        Unit: USD
      TimeUnit: MONTHLY
      BudgetType: COST
    NotificationsWithSubscribers:
      - Notification:
          NotificationType: ACTUAL
          ComparisonOperator: GREATER_THAN
          Threshold: 80
        Subscribers:
          - SubscriptionType: EMAIL
            Address: team@example.com
```

### Backup and Disaster Recovery

**Backup Strategies:**

1. **RTO (Recovery Time Objective)**: How quickly to recover
2. **RPO (Recovery Point Objective)**: How much data loss is acceptable

**DR Patterns:**

- **Backup and Restore**: Lowest cost, highest RTO/RPO
- **Pilot Light**: Minimal always-on infrastructure
- **Warm Standby**: Scaled-down but fully functional
- **Multi-Site Active/Active**: Lowest RTO/RPO, highest cost

**AWS Backup**

```yaml
BackupVault:
  Type: AWS::Backup::BackupVault
  Properties:
    BackupVaultName: production-backup-vault
    EncryptionKeyArn: !GetAtt BackupEncryptionKey.Arn

BackupPlan:
  Type: AWS::Backup::BackupPlan
  Properties:
    BackupPlan:
      BackupPlanName: daily-backup-plan
      BackupPlanRule:
        - RuleName: DailyBackup
          TargetBackupVault: !Ref BackupVault
          ScheduleExpression: 'cron(0 2 * * ? *)'
          StartWindowMinutes: 60
          CompletionWindowMinutes: 120
          Lifecycle:
            DeleteAfterDays: 30
            MoveToColdStorageAfterDays: 7

BackupSelection:
  Type: AWS::Backup::BackupSelection
  Properties:
    BackupPlanId: !Ref BackupPlan
    BackupSelection:
      SelectionName: production-resources
      IamRoleArn: !GetAtt BackupRole.Arn
      Resources:
        - !Sub 'arn:aws:ec2:${AWS::Region}:${AWS::AccountId}:instance/*'
        - !Sub 'arn:aws:rds:${AWS::Region}:${AWS::AccountId}:db:*'
      Conditions:
        StringEquals:
          - ConditionKey: 'aws:ResourceTag/Backup'
            ConditionValue: 'true'
```

### Infrastructure as Code

**CloudFormation Best Practices:**

- Use nested stacks for modularity
- Use parameters for flexibility
- Use mappings for environment-specific values
- Implement change sets before updates
- Use stack policies to prevent accidental updates
- Tag all resources
- Use drift detection
- Store templates in version control

**CloudFormation Parameters**

```yaml
Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues:
      - dev
      - staging
      - production
    Description: Environment name

  InstanceType:
    Type: String
    Default: t3.medium
    AllowedValues:
      - t3.small
      - t3.medium
      - t3.large
    Description: EC2 instance type

Mappings:
  EnvironmentConfig:
    dev:
      MinSize: 1
      MaxSize: 2
      DesiredCapacity: 1
    staging:
      MinSize: 2
      MaxSize: 4
      DesiredCapacity: 2
    production:
      MinSize: 3
      MaxSize: 10
      DesiredCapacity: 3

Resources:
  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      MinSize: !FindInMap [EnvironmentConfig, !Ref Environment, MinSize]
      MaxSize: !FindInMap [EnvironmentConfig, !Ref Environment, MaxSize]
      DesiredCapacity: !FindInMap [EnvironmentConfig, !Ref Environment, DesiredCapacity]
```

### Security Best Practices

**Security Checklist:**

- [ ] Enable MFA on root account
- [ ] Use IAM roles instead of access keys
- [ ] Enable CloudTrail in all regions
- [ ] Enable GuardDuty for threat detection
- [ ] Use AWS Config for compliance
- [ ] Enable VPC Flow Logs
- [ ] Encrypt data at rest and in transit
- [ ] Use AWS Secrets Manager for credentials
- [ ] Implement least privilege access
- [ ] Enable AWS Security Hub
- [ ] Use AWS WAF for web applications
- [ ] Implement network segmentation
- [ ] Regular security assessments
- [ ] Patch management strategy

**Secrets Manager**

```yaml
DBSecret:
  Type: AWS::SecretsManager::Secret
  Properties:
    Name: /production/database/credentials
    Description: Database credentials
    GenerateSecretString:
      SecretStringTemplate: '{"username": "admin"}'
      GenerateStringKey: password
      PasswordLength: 32
      ExcludeCharacters: '"@/\'
      RequireEachIncludedType: true
    KmsKeyId: !Ref SecretsEncryptionKey

SecretRotation:
  Type: AWS::SecretsManager::RotationSchedule
  Properties:
    SecretId: !Ref DBSecret
    RotationLambdaARN: !GetAtt RotationLambda.Arn
    RotationRules:
      AutomaticallyAfterDays: 30
```

**KMS Encryption Key**

```yaml
EncryptionKey:
  Type: AWS::KMS::Key
  Properties:
    Description: Encryption key for application data
    KeyPolicy:
      Version: '2012-10-17'
      Statement:
        - Sid: Enable IAM User Permissions
          Effect: Allow
          Principal:
            AWS: !Sub 'arn:aws:iam::${AWS::AccountId}:root'
          Action: 'kms:*'
          Resource: '*'
        - Sid: Allow services to use the key
          Effect: Allow
          Principal:
            Service:
              - logs.amazonaws.com
              - s3.amazonaws.com
          Action:
            - 'kms:Decrypt'
            - 'kms:GenerateDataKey'
          Resource: '*'

KeyAlias:
  Type: AWS::KMS::Alias
  Properties:
    AliasName: alias/application-key
    TargetKeyId: !Ref EncryptionKey
```

### Tagging Strategy

**Standard Tags:**

```yaml
Tags:
  - Key: Name
    Value: resource-name
  - Key: Environment
    Value: production
  - Key: Project
    Value: web-application
  - Key: Owner
    Value: team-backend
  - Key: CostCenter
    Value: engineering
  - Key: Compliance
    Value: pci-dss
  - Key: BackupPolicy
    Value: daily
  - Key: ManagedBy
    Value: terraform
```

**Tagging Best Practices:**

- Use consistent tag keys across all resources
- Implement tag policies with AWS Organizations
- Use tags for cost allocation
- Tag resources for automation
- Use tags for access control
- Document tagging standards
- Enforce tags with CloudFormation or Terraform
- Regular tag audits

### Multi-Account Strategy

**AWS Organizations Structure:**

```
Root
├── Security OU
│   ├── Log Archive Account
│   └── Security Tooling Account
├── Infrastructure OU
│   ├── Network Account
│   └── Shared Services Account
└── Workloads OU
    ├── Production Account
    ├── Staging Account
    └── Development Account
```

**Multi-Account Best Practices:**

- Use AWS Organizations for centralized management
- Implement Service Control Policies (SCPs)
- Centralize logging in dedicated account
- Use AWS Control Tower for governance
- Implement cross-account roles
- Use AWS SSO for user access
- Separate production and non-production
- Use separate accounts for different environments

### Terraform for AWS

**Terraform Best Practices:**

- Use remote state with S3 and DynamoDB locking
- Organize code with modules
- Use workspaces for environments
- Implement state file encryption
- Use data sources for existing resources
- Pin provider versions
- Use variables and locals
- Implement proper naming conventions

**Terraform Backend Configuration**

```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Project     = var.project_name
    }
  }
}
```

**Terraform Module Structure**

```hcl
# modules/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.environment}-vpc"
  }
}

# modules/vpc/variables.tf
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# modules/vpc/outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}
```

### Performance Optimization

**Performance Best Practices:**

- Use CloudFront for content delivery
- Implement caching strategies (ElastiCache)
- Use appropriate instance types
- Enable EBS optimization
- Use Provisioned IOPS for databases
- Implement read replicas
- Use Auto Scaling
- Optimize database queries
- Use connection pooling
- Implement asynchronous processing

**ElastiCache Redis**

```yaml
CacheSubnetGroup:
  Type: AWS::ElastiCache::SubnetGroup
  Properties:
    Description: Cache subnet group
    SubnetIds:
      - !Ref PrivateSubnet1
      - !Ref PrivateSubnet2

CacheCluster:
  Type: AWS::ElastiCache::ReplicationGroup
  Properties:
    ReplicationGroupId: production-redis
    ReplicationGroupDescription: Production Redis cluster
    Engine: redis
    EngineVersion: '7.0'
    CacheNodeType: cache.t3.medium
    NumCacheClusters: 2
    AutomaticFailoverEnabled: true
    MultiAZEnabled: true
    CacheSubnetGroupName: !Ref CacheSubnetGroup
    SecurityGroupIds:
      - !Ref CacheSecurityGroup
    AtRestEncryptionEnabled: true
    TransitEncryptionEnabled: true
    SnapshotRetentionLimit: 5
    SnapshotWindow: '03:00-05:00'
```

### Compliance and Governance

**Compliance Best Practices:**

- Use AWS Config for compliance monitoring
- Implement AWS Config Rules
- Enable AWS Security Hub
- Use AWS Audit Manager
- Implement AWS Systems Manager
- Regular compliance audits
- Document compliance requirements
- Implement data residency controls

**AWS Config Rule**

```yaml
S3BucketEncryptionRule:
  Type: AWS::Config::ConfigRule
  Properties:
    ConfigRuleName: s3-bucket-encryption-enabled
    Description: Checks that S3 buckets have encryption enabled
    Source:
      Owner: AWS
      SourceIdentifier: S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED
    Scope:
      ComplianceResourceTypes:
        - AWS::S3::Bucket
```
