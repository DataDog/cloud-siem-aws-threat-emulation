#!/bin/bash

GREEN='\033[0;32m'  
RED='\033[0;31m'    
CHECKMARK='\xE2\x9C\x85' 
CROSS='\xE2\x9D\x8C'  
NC='\033[0m'      

successful_attacks=()
failed_attacks=()

start_time=$(date +%s.%N)  
run_attack() {
    echo -e "${REFRESH}${GREEN}Running attack: $@${NC}"
    output=$(stratus detonate "$@" 2>&1)
    if [[ $output =~ "Error" ]]; then
        echo -e "${RED}${CROSS} Attack: $@ did not run successfully${NC}"
        error_message=$(echo "$output" | sed -n '/Error: /s/.*Error: //p')
        echo -e "${RED}$error_message${NC}"
        failed_attacks+=("$@ - Error: $error_message")
    else
        echo -e "${GREEN}${CHECKMARK} Successful${NC}"
        successful_attacks+=("$@")
    fi
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

for (( i = 0; i < ${#attacks[@]}; i++ )); do
    run_attack "${attacks[$i]}"
    if (( i + 1 < ${#attacks[@]} )); then
        echo -e "\nNext attack: ${attacks[$i + 1]}"
    fi
done

end_time=$(date +%s.%N)  
execution_time=$(echo "($end_time - $start_time)" | bc -l)  
minutes=$(printf "%.0f" $(echo "$execution_time / 60" | bc -l))  
seconds=$(printf "%.2f" $(echo "$execution_time % 60" | bc -l)) 

echo -e "${GREEN}\n---- ${CHECKMARK}Successful Attacks ----${NC}"
for attack in "${successful_attacks[@]}"; do
    echo "$attack"
done

echo -e "${RED}\n---- ${CROSS}Failed Attacks ----${NC}"
for attack in "${failed_attacks[@]}"; do
    echo "$attack"
done

echo -e "\n---- Overall Execution Time ----"
echo "Total Execution Time: ${minutes}m ${seconds}s"
