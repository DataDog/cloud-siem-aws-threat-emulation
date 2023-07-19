# Datadog AWS Threat Emulation 

## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Emulating Attacks](#emulating-attacks)
- [Validating Detections](#validating-detections)
- [Contributing](#contributing)


## Introduction
The Datadog AWS Threat Emulation Guide is designed to simplify the process of evaluating Datadog's Cloud SIEM security capabilities to detect AWS threats and alert in real time by simulating attacks using [Stratus Red Team](https://github.com/DataDog/stratus-red-team).

## Prerequisites
- A functional Datadog trial or production environment with:
    - [Cloud SIEM enabled](https://docs.datadoghq.com/getting_started/cloud_siem/)
    - [AWS CloudTrail logging](https://docs.datadoghq.com/security/cloud_siem/guide/aws-config-guide-for-cloud-siem/)
- AWS Sandbox account - Stratus Red Team is supposed to be used against a sandbox cloud account that does not handle production workloads or infrastructure.
- Prior AWS authentication via cli using either `aws-vault` or static credentials in `~/.aws/config` with `AdministratorAccess`
- An endpoint for installing Stratus Red Team and executing attack techniques against AWS infrastructure.
    - Stratus [supports](https://stratus-red-team.cloud/user-guide/getting-started/) MacOS, Linux, Windows & Docker.

***Although Stratus Red Team supports attacks for other platforms including Azure, Google Cloud and Kubernetes, this guide is currenty limited to AWS.***

## Installation
To install Stratus Red Team within your threat emulation environment, follow the [Stratus Red Team installation guide](https://stratus-red-team.cloud/user-guide/getting-started/#installation).

## Emulating Attacks

### Detonate all attacks
Utilizing the **stratus.sh** script you can detonate all available stratus attacks in one go. Bear in mind that this process takes around 30 mins to complete.

### Detonate individual attacks

Alternatively, you can detonate the stratus attacks individually as shown below.

- Detonate an attack technique:
```
stratus detonate aws.exfiltration.s3-backdoor-bucket-policy
```

- Detonate multiple attack techniques:
```
stratus detonate aws.exfiltration.s3-backdoor-bucket-policy aws.defense-evasion.cloudtrail-stop
```

- Detonate an attack technique, then automatically clean up any resources deployed on AWS
```
stratus detonate aws.exfiltration.s3-backdoor-bucket-policy --cleanup
```

### Cleanup 
- Cleanup a specific attack technique
```
stratus cleanup aws.defense-evasion.cloudtrail-stop
```

- Cleanup all detonated attack techniques
```
stratus cleanup --all
```


For more details on usage, refer to the [Stratus Red Team Usage Guide](https://stratus-red-team.cloud/user-guide/usage/) and [Stratus Red Team Command Reference](https://stratus-red-team.cloud/user-guide/commands/)

## Validating Detections
***Note that Datadog's OOTB Cloud SIEM Rules are **not** limited to the attack techniques available from Stratus Red Team.***

Within the Datadog app, navigate to **Security** > **Cloud SIEM** > **Signals** and filter by `source:cloudtrail @http.useragent:*stratus-red-team*` in order to validate the signals generated by the emulation.

You should expect the following the detections for the corresponding detonated Stratus Techniques:


| **Stratus Attack Technique**                         	| **Cloud SIEM OOTB Detection**                                                                                                                                                                                                                                                                                                             	|
|------------------------------------------------------	|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	|
| Retrieve EC2 Password Data                           	| [Encrypted administrator password retrieved for Windows EC2 instance](https://docs.datadoghq.com/security/default_rules/aws-ec2-getpasswordata-error/)                                                                                                                                                                                    	|
| Steal EC2 Instance Credentials                       	| [AWS GuardDuty finding - Credentials for instance role stratus-red-team-ec2-steal-credentials-role used from external IP address](https://docs.datadoghq.com/security/default_rules/aws-guardduty-third-party/)                                                                                                                           	|
| Delete CloudTrail Trail                              	| [AWS CloudTrail configuration modified](https://docs.datadoghq.com/security/default_rules/aws-cloudtrail-configuration-modified/)                                                                                                                                                                                                         	|
| Disable CloudTrail Logging Through Event Selectors   	| [AWS Disable Cloudtrail with event selectors](https://docs.datadoghq.com/security/default_rules/cloudtrail-aws-cloudtrail-disable-through-event-selectors/)                                                                                                                                                                               	|
| CloudTrail Logs Impairment Through S3 Lifecycle Rule 	| [An AWS S3 bucket lifecycle policy expiration is set to < 90 days](https://docs.datadoghq.com/security/default_rules/aws-s3-lifecycle-expiration-below-90-days/)                                                                                                                                                                          	|
| Stop CloudTrail Trail                                	| [AWS CloudTrail configuration modified](https://docs.datadoghq.com/security/default_rules/aws-cloudtrail-configuration-modified/)                                                                                                                                                                                                         	|
| Attempt to Leave the AWS Organization                	| [An AWS account attempted to leave the AWS Organization](https://docs.datadoghq.com/security/default_rules/aws-organizations-leave-organization/)                                                                                                                                                                                         	|
| Remove VPC Flow Logs                                 	| [AWS VPC Flow Log deleted](https://docs.datadoghq.com/security/default_rules/aws-cloudtrail-vpc-flow-log-deleted/)                                                                                                                                                                                                                        	|
| Execute Discovery Commands on an EC2 Instance        	| [An EC2 instance attempted to enumerate S3 bucket](https://docs.datadoghq.com/security/default_rules/aws-s3-buckets-enumerated/)                                                                                                                                                                                                          	|
| Execute Commands on EC2 Instance via User Data       	| [Possible AWS EC2 privilege escalation via the modification of user data](https://docs.datadoghq.com/security/default_rules/cloudtrail-aws-ec2-modify-user-data-priv-escalation/)                                                                                                                                                         	|
| Open Ingress Port 22 on a Security Group             	| [AWS security group created, modified or deleted](https://docs.datadoghq.com/security/default_rules/aws-ec2-security-group-modified/)<br>[Potential administrative port open to the world via AWS security group](https://docs.datadoghq.com/security/default_rules/cloudtrail-aws-ec2-security-group-administrative-port-open-to-world/) 	|
| Exfiltrate an AMI by Sharing It                      	| [Amazon EC2 AMI exfiltration attempt](https://docs.datadoghq.com/security/default_rules/cloudtrail-aws-ec2-ami-exfil/)                                                                                                                                                                                                                    	|
| Exfiltrate EBS Snapshot by Sharing It                	| [AWS EBS Snapshot possible exfiltration](https://docs.datadoghq.com/security/default_rules/cloudtrail-aws-ebs-snapshot-possible-exfiltration/)                                                                                                                                                                                            	|
| Exfiltrate RDS Snapshot by Sharing                   	| [Possible RDS Snapshot Exfiltration](https://docs.datadoghq.com/security/default_rules/cloudtrail-aws-rds-snapshot-exfiltration/)                                                                                                                                                                                                         	|
| Backdoor an S3 Bucket via its Bucket Policy          	| [Amazon S3 Bucket policy modified](https://docs.datadoghq.com/security/default_rules/aws-s3-bucket-policy-modified/)                                                                                                                                                                                                                      	|
| Console Login without MFA                            	| [AWS Console login without MFA](https://docs.datadoghq.com/security/default_rules/aws-cloudtrail-console-login-no-mfa/)                                                                                                                                                                                                                   	|
| Backdoor an IAM Role                                 	| [AWS IAM AdministratorAccess policy was applied to a role](https://docs.datadoghq.com/security/default_rules/cloudtrail-aws-iam-apply-privilegedpolicy-to-role/)                                                                                                                                                                          	|
| Create an administrative IAM User                    	| [AWS IAM AdministratorAccess policy was applied to a user](https://docs.datadoghq.com/security/default_rules/cloudtrail-aws-iam-apply-privilegedpolicy-to-user/)                                                                                                                                                                          	|
| Create a Login Profile on an IAM User                	| [Possible privilege escalation via AWS login profile manipulation](https://docs.datadoghq.com/security/default_rules/cloudtrail-aws-iam-login-profile-manipulated/)                                                                                                                                                                       	|

## Contributing
At this time, the repository is not accepting contributions.
