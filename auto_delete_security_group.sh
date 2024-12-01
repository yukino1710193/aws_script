#!/bin/bash

REGION_NAME=$1
VPC_NAME=$2
SECURITY_GROUP_NAME=$3
IP_RANGE=$4
KEY_NAME=$5
SUBNET_PUB=$6
SUBNET_PRI=$7
REGION_ID=$8
GATEWAY_NAME=$9
EIP_NAT_NAME=${10}
NATGW_NAME=${11}
ROUTE_TABLE_PUBLIC_NAME=${12}
ROUTE_TABLE_PRIVATE_NAME=${13}

# Querry 

    echo "Querying VPC_ID for VPC Name: $VPC_NAME in region: $REGION_ID"
    VPC_ID=$(aws ec2 describe-vpcs \
        --filters "Name=tag:Name,Values=$VPC_NAME" \
        --query "Vpcs[0].VpcId" \
        --output text \
        --region $REGION_ID)
    echo "VPC_ID = $VPC_ID"

    GROUP_ID=$(aws ec2 describe-security-groups \
    --filters Name=vpc-id,Values=$VPC_ID \
              Name=group-name,Values=testbed_group \
    --region $REGION_ID \
    --query "SecurityGroups[0].GroupId" \
    --output text)
    echo "Group id = $GROUP_ID"

    aws ec2 delete-security-group \
        --group-id $GROUP_ID \
        --region $REGION_ID
        > /dev/null 2>$1
    echo "Deleted Security_group"