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

# Querry id
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

    echo ""
    GROUP_ID=$(aws ec2 describe-security-groups \
    --filters Name=vpc-id,Values=$VPC_ID \
              Name=group-name,Values=testbed_group \
    --region $REGION_ID \
    --query "SecurityGroups[0].GroupId" \
    --output text)
    echo "Group id = $GROUP_ID"

    echo ""
    SUBNET_PUB_ID=$(
    aws ec2 describe-subnets \
        --filters "Name=vpc-id,Values=$VPC_ID" \
                "Name=tag:Name,Values=SUBNET_PUB" \
        --query "Subnets[0].SubnetId" \
        --output text \
        --region $REGION_ID
    )
    echo "SUBNET_PUB_ID = $SUBNET_PUB_ID"

    echo ""
    SUBNET_PRI_ID=$(
    aws ec2 describe-subnets \
        --filters "Name=vpc-id,Values=$VPC_ID" \
                "Name=tag:Name,Values=SUBNET_PRI" \
        --query "Subnets[0].SubnetId" \
        --output text \
        --region $REGION_ID
    )
    echo "SUBNET_PRI_ID = $SUBNET_PRI_ID"

    echo ""
    IGW_ID=$(aws ec2 describe-internet-gateways \
          --filters "Name=tag:Name,Values=$GATEWAY_NAME" \
          --query "InternetGateways[0].InternetGatewayId" \
          --output text \
          --region $REGION_ID)
    echo "IGW_ID = $IGW_ID" 
        
    echo ""
    echo "Querying EIP Allocation ID for EIP Name: $EIP_NAT_NAME"
    EIP_NAT_ID=$(aws ec2 describe-addresses \
        --filters "Name=tag:Name,Values=$EIP_NAT_NAME" \
        --query "Addresses[0].AllocationId" \
        --output text \
        --region $REGION_ID)
    echo "EIP_NAT_ID = $EIP_NAT_ID"    

    echo ""
    echo "Querying NAT Gateway ID for NAT Gateway Name: $NATGW_NAME"
    NATGW_ID=$(aws ec2 describe-nat-gateways \
        --filter "Name=tag:Name,Values=$NATGW_NAME" \
        --region $REGION_ID \
        --query 'NatGateways[*].NatGatewayId' \
        --output text)
    echo "NATGW_ID = $NATGW_ID"
    
    echo ""
    ROUTE_TABLE_PUBLIC_ID=$(aws ec2 describe-route-tables \
                            --filters "Name=tag:Name,Values=$ROUTE_TABLE_PUBLIC_NAME" \
                                        "Name=vpc-id,Values=$VPC_ID" \
                            --query "RouteTables[0].RouteTableId" \
                            --output text \
                            --region $REGION_ID)
    echo "ROUTE_TABLE_PUBLIC_ID = $ROUTE_TABLE_PUBLIC_ID"

    echo ""
    ROUTE_TABLE_PRIVATE_ID=$(aws ec2 describe-route-tables \
                            --filters "Name=tag:Name,Values=$ROUTE_TABLE_PRIVATE_NAME" \
                                    "Name=vpc-id,Values=$VPC_ID" \
                            --query "RouteTables[0].RouteTableId" \
                            --output text \
                            --region $REGION_ID)
    echo "ROUTE_TABLE_PRIVATE_ID =$ROUTE_TABLE_PRIVATE_ID"

# Delete
    aws ec2 delete-security-group --group-id $GROUP_ID --region $REGION_ID
    echo "Deleted security group with ID: $GROUP_ID"

    aws ec2 delete-subnet --subnet-id $SUBNET_PRI_ID --region $REGION_ID
    echo "Deleted private subnet with ID: $SUBNET_PRI_ID"

    aws ec2 delete-subnet --subnet-id $SUBNET_PUB_ID --region $REGION_ID
    echo "Deleted public subnet with ID: $SUBNET_PUB_ID"

    aws ec2 delete-route-table --route-table-id $ROUTE_TABLE_PRIVATE_ID --region $REGION_ID
    echo "Deleted private route table with ID: $ROUTE_TABLE_PRIVATE_ID"

    aws ec2 delete-route-table --route-table-id $ROUTE_TABLE_PUBLIC_ID --region $REGION_ID
    echo "Deleted public route table with ID: $ROUTE_TABLE_PUBLIC_ID"

    aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region $REGION_ID
    echo "Detached internet gateway with ID: $IGW_ID from VPC: $VPC_ID"

    aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID --region $REGION_ID
    echo "Deleted internet gateway with ID: $IGW_ID"

    aws ec2 delete-nat-gateway --nat-gateway-id $NATGW_ID --region $REGION_ID
    echo "Waiting for NAT Gateway to be deleted..."
    aws ec2 wait nat-gateway-deleted \
        --nat-gateway-ids $NATGW_ID \
        --region $REGION_ID
    echo "Deleted NAT gateway with ID: $NATGW_ID"

    aws ec2 release-address --allocation-id $EIP_NAT_ID --region $REGION_ID
    echo "Released Elastic IP with Allocation ID: $EIP_NAT_ID"

    aws ec2 delete-vpc --vpc-id $VPC_ID --region $REGION_ID
    echo "Deleted VPC with ID: $VPC_ID"
