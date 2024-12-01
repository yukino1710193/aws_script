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

## Querry ID
    # Query VPC_ID
    echo "Querying VPC_ID for VPC Name: $VPC_NAME in region: $REGION_ID"
    VPC_ID=$(aws ec2 describe-vpcs \
        --filters "Name=tag:Name,Values=$VPC_NAME" \
        --query "Vpcs[0].VpcId" \
        --output text \
        --region $REGION_ID)
    echo "VPC_ID = $VPC_ID"
    echo "$REGION_NAME"
    
    SUBNET_PUB_ID=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=SUBNET_PUB" --query "Subnets[0].SubnetId" --output text --region $REGION_ID)
    echo $SUBNET_PUB_ID
    ROUTE_TABLE_PUBLIC_ID=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=$ROUTE_TABLE_PUBLIC_NAME" --query "RouteTables[0].RouteTableId" --output text --region $REGION_ID)
    echo $ROUTE_TABLE_PUBLIC_ID
    ROUTE_TABLE_PRIVATE_ID=$(aws ec2 describe-route-tables \
                            --filters "Name=tag:Name,Values=$ROUTE_TABLE_PRIVATE_NAME" \
                                    "Name=vpc-id,Values=$VPC_ID" \
                            --query "RouteTables[0].RouteTableId" \
                            --output text \
                            --region $REGION_ID)
    echo "ROUTE_TABLE_PRIVATE_ID =$ROUTE_TABLE_PRIVATE_ID"

    ## Create an NAT Gateway
    EIP_NAT_ID=$(aws ec2 allocate-address --domain vpc --region $REGION_ID --query "AllocationId" --output text) && aws ec2 create-tags --resources $EIP_NAT_ID --tags Key=Name,Value=$EIP_NAT_NAME --region $REGION_ID

    NATGW_ID=$(aws ec2 create-nat-gateway --subnet-id $SUBNET_PUB_ID --allocation-id $EIP_NAT_ID --region $REGION_ID --query "NatGateway.NatGatewayId" --output text) && aws ec2 create-tags --resources $NATGW_ID --tags Key=Name,Value=$NATGW_NAME --region $REGION_ID
    # Config route-tables
while true; do
    STATE=$(aws ec2 describe-nat-gateways --nat-gateway-ids $NATGW_ID --region $REGION_ID --query 'NatGateways[0].State' --output text)
    echo "Current NAT Gateway state: $STATE"
    
    if [ "$STATE" == "available" ]; then
        echo "NAT Gateway is available. Creating route..."
        break
    fi
    
    # Đợi một chút trước khi kiểm tra lại
    sleep 10
done
# Private
    aws ec2 create-route --route-table-id $ROUTE_TABLE_PRIVATE_ID --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NATGW_ID --region $REGION_ID