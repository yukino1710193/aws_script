#!/bin/bash

NODE_NAME=$1
REGION_NAME=$2
IPV4_PRIVATE=$3
VPC_NAME=$4
SECURITY_GROUP_NAME=$5
IP_RANGE=$6
KEY_NAME=$7
SUBNET_PUB=$8
SUBNET_PRI=$9
REGION_ID=${10}
GATEWAY_NAME=${11}
EIP_NAT_NAME=${12}
NATGW_NAME=${13}
ROUTE_TABLE_PUBLIC_NAME=${14}
ROUTE_TABLE_PRIVATE_NAME=${15}
IMAGE_ID=${16}
FLAVOR=${17}
STORAGE_SIZE=${18}
STORAGE_TYPE=${19}
AWS_PAGER=""
    # Query VPC_ID
    echo "Querying VPC_ID for VPC Name: $VPC_NAME in region: $REGION_ID"
    VPC_ID=$(aws ec2 describe-vpcs \
        --filters "Name=tag:Name,Values=$VPC_NAME" \
        --query "Vpcs[0].VpcId" \
        --output text \
        --region $REGION_ID)
    echo "VPC_ID = $VPC_ID"
    echo "$REGION_NAME"
    if [ "$NODE_NAME" == "Yukino01" ]; then
        SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=SUBNET_PUB" --query "Subnets[0].SubnetId" --output text --region $REGION_ID)
    else
        SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=SUBNET_PRI" --query "Subnets[0].SubnetId" --output text --region $REGION_ID)
    fi
    echo "$NODE_NAME"
    echo "SUBNET_ID = $SUBNET_ID"
    echo ""
    GROUP_ID=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=$SECURITY_GROUP_NAME" --query "SecurityGroups[0].GroupId" --output text --region $REGION_ID)
    echo "GROUP_ID = $GROUP_ID"
    aws ec2 run-instances --image-id $IMAGE_ID --instance-type $FLAVOR --key-name $KEY_NAME --subnet-id $SUBNET_ID --security-group-ids $GROUP_ID --no-associate-public-ip-address --private-ip-address $IPV4_PRIVATE --block-device-mappings --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":${STORAGE_SIZE},\"VolumeType\":\"${STORAGE_TYPE}\",\"DeleteOnTermination\":true}}]" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${NODE_NAME}}]" --region $REGION_ID --count 1 
