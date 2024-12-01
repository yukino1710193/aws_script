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
echo ""

EC2_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$NODE_NAME" "Name=instance-state-name,Values=stopped" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --region $REGION_ID \
    --output text)
echo "EC2_ID :" $EC2_ID
aws ec2 start-instances --instance-ids $EC2_ID --region $REGION_ID
