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

    VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$VPC_NAME" --query "Vpcs[0].VpcId" --output text --region $REGION_ID)
    SECURITY_GROUP_ID=$(aws ec2 create-security-group --region $REGION_ID --group-name testbed_group --description Hello --vpc-id $VPC_ID --output text)
    aws ec2 authorize-security-group-ingress --region $REGION_ID --group-id $SECURITY_GROUP_ID --protocol -1 --port all --cidr 0.0.0.0/0