#!/bin/bash

# Nhận các tham số truyền vào
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

# Thông báo bắt đầu query
echo ""
echo "### Start querying resources ###"

# Query VPC_ID
echo "Querying VPC_ID for VPC Name: $VPC_NAME in region: $REGION_ID"
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=$VPC_NAME" \
    --query "Vpcs[0].VpcId" \
    --output text \
    --region $REGION_ID)
echo "VPC_ID = $VPC_ID"

# Query EIP
echo ""
echo "Querying EIP Allocation ID for EIP Name: $EIP_NAT_NAME"
EIP_NAT_ID=$(aws ec2 describe-addresses \
    --filters "Name=tag:Name,Values=$EIP_NAT_NAME" \
    --query "Addresses[0].AllocationId" \
    --output text \
    --region $REGION_ID)
echo "EIP_NAT_ID = $EIP_NAT_ID"

# Query NAT Gateway ID
echo ""
echo "Querying NAT Gateway ID for NAT Gateway Name: $NATGW_NAME"
NATGW_ID=$(aws ec2 describe-nat-gateways \
    --filter "Name=tag:Name,Values=$NATGW_NAME" \
    --region $REGION_ID \
    --query 'NatGateways[*].NatGatewayId' \
    --output text)
echo "NATGW_ID = $NATGW_ID"

# Query Route Table Private ID
echo ""
echo "Querying Private Route Table ID for Route Table Name: $ROUTE_TABLE_PRIVATE_NAME in VPC: $VPC_ID"
ROUTE_TABLE_PRIVATE_ID=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    "Name=tag:Name,Values=$ROUTE_TABLE_PRIVATE_NAME" \
    --query "RouteTables[0].RouteTableId" \
    --output text \
    --region $REGION_ID)
echo "ROUTE_TABLE_PRIVATE_ID = $ROUTE_TABLE_PRIVATE_ID"

# Xóa các tài nguyên
echo ""
echo "### Deleting resources ###"

# Xóa route trong Route Table Private
echo "Deleting route 0.0.0.0/0 from Route Table: $ROUTE_TABLE_PRIVATE_ID"
aws ec2 delete-route \
    --route-table-id $ROUTE_TABLE_PRIVATE_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --region $REGION_ID
echo "Route deleted."

# Xóa NAT Gateway
echo "Deleting NAT Gateway with ID: $NATGW_ID"
aws ec2 delete-nat-gateway \
    --nat-gateway-id $NATGW_ID \
    --region $REGION_ID

# Đợi đến khi NAT Gateway bị xóa hoàn toàn
echo "Waiting for NAT Gateway to be deleted..."
aws ec2 wait nat-gateway-deleted \
    --nat-gateway-ids $NATGW_ID \
    --region $REGION_ID
echo "NAT Gateway deleted."

# Giải phóng EIP sau khi NAT Gateway đã bị xóa
echo "Releasing EIP with Allocation ID: $EIP_NAT_ID"
aws ec2 release-address \
    --allocation-id $EIP_NAT_ID \
    --region $REGION_ID
echo "EIP released."

echo ""
echo "### All resources deleted successfully ###"
