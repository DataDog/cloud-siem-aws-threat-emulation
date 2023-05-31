#!/bin/bash

GREEN='\033[0;32m'  # Green color
NC='\033[0m'       # No color

run_attack() {
    echo -e "${GREEN}Running attack: $@${NC}"
    stratus detonate "$@"
}

attacks=(
    "aws.credential-access.ec2-get-password-data"
    "aws.credential-access.ec2-steal-instance-credentials"
    "aws.credential-access.secretsmanager-retrieve-secrets"
    "aws.credential-access.ssm-retrieve-securestring-parameters"
    "aws.defense-evasion.cloudtrail-delete"
    "aws.defense-evasion.cloudtrail-event-selectors"
    "aws.defense-evasion.cloudtrail-lifecycle-rule"
    "aws.defense-evasion.cloudtrail-stop"
    "aws.defense-evasion.organizations-leave"
    "aws.defense-evasion.vpc-remove-flow-logs"
    "aws.discovery.ec2-download-user-data"
    "aws.discovery.ec2-enumerate-from-instance"
    "aws.execution.ec2-launch-unusual-instances"
    "aws.execution.ec2-user-data"
    "aws.exfiltration.ec2-security-group-open-port-22-ingress"
    "aws.exfiltration.ec2-share-ami"
    "aws.exfiltration.ec2-share-ebs-snapshot"
    "aws.exfiltration.rds-share-snapshot"
    "aws.exfiltration.s3-backdoor-bucket-policy"
    "aws.initial-access.console-login-without-mfa"
    "aws.persistence.iam-backdoor-role"
    "aws.persistence.iam-backdoor-user"
    "aws.persistence.iam-create-admin-user"
    "aws.persistence.iam-create-user-login-profile"
    "aws.persistence.lambda-backdoor-function"
    "aws.persistence.lambda-overwrite-code"
    "aws.persistence.rolesanywhere-create-trust-anchor"
)

for attack in "${attacks[@]}"; do
    run_attack "$attack"
done