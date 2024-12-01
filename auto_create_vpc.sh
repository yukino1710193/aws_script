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

    ## Create VPC get VPC_ID -> and tag VPC_NAME
    VPC_ID=$(aws ec2 create-vpc --region $REGION_ID --cidr-block $IP_RANGE --query "Vpc.VpcId" --output text) && aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$VPC_NAME --region $REGION_ID
    
    ## Create subnet
    #PUBLIC
    SUBNET_PUB_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_PUB --availability-zone ${REGION_ID}a --region $REGION_ID --query "Subnet.SubnetId" --output text) && aws ec2 create-tags --resources $SUBNET_PUB_ID --tags Key=Name,Value=SUBNET_PUB --region $REGION_ID

    #PRIVATE
    SUBNET_PRI_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_PRI --availability-zone ${REGION_ID}a --region $REGION_ID --query "Subnet.SubnetId" --output text) && aws ec2 create-tags --resources $SUBNET_PRI_ID --tags Key=Name,Value=SUBNET_PRI --region $REGION_ID

    ## Create an Internet Gateway
    IGW_ID=$(aws ec2 create-internet-gateway --region $REGION_ID --query "InternetGateway.InternetGatewayId" --output text) && aws ec2 create-tags --resources $IGW_ID --tags Key=Name,Value=$GATEWAY_NAME --region $REGION_ID
    # Attach IGW to VPC
    aws ec2 attach-internet-gateway --region $REGION_ID --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
    
    ## Create an NAT Gateway
    EIP_NAT_ID=$(aws ec2 allocate-address --domain vpc --region $REGION_ID --query "AllocationId" --output text) && aws ec2 create-tags --resources $EIP_NAT_ID --tags Key=Name,Value=$EIP_NAT_NAME --region $REGION_ID

    NATGW_ID=$(aws ec2 create-nat-gateway --subnet-id $SUBNET_PUB_ID --allocation-id $EIP_NAT_ID --region $REGION_ID --query "NatGateway.NatGatewayId" --output text) && aws ec2 create-tags --resources $NATGW_ID --tags Key=Name,Value=$NATGW_NAME --region $REGION_ID

    ## Create a custom route table
# Public   
    ROUTE_TABLE_PUBLIC_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --region $REGION_ID --query "RouteTable.RouteTableId" --output text) && aws ec2 create-tags --resources $ROUTE_TABLE_PUBLIC_ID --tags Key=Name,Value=$ROUTE_TABLE_PUBLIC_NAME --region $REGION_ID
# Private    
    ROUTE_TABLE_PRIVATE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --region $REGION_ID --query "RouteTable.RouteTableId" --output text) && aws ec2 create-tags --resources $ROUTE_TABLE_PRIVATE_ID --tags Key=Name,Value=$ROUTE_TABLE_PRIVATE_NAME --region $REGION_ID
    
    # Config route-tables
# Public
    aws ec2 create-route --route-table-id $ROUTE_TABLE_PUBLIC_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --region $REGION_ID
# Private
    aws ec2 create-route --route-table-id $ROUTE_TABLE_PRIVATE_ID --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NATGW_ID --region $REGION_ID
    
    # Associate subnet with custom route table to make public
# Public
    aws ec2 associate-route-table  --region $REGION_ID --subnet-id $SUBNET_PUB_ID --route-table-id $ROUTE_TABLE_PUBLIC_ID
# Private
    aws ec2 associate-route-table  --region $REGION_ID --subnet-id $SUBNET_PRI_ID --route-table-id $ROUTE_TABLE_PRIVATE_ID
    ## Configure subnet to issue a public IP to EC2 instances
# Public
    aws ec2 modify-subnet-attribute --region $REGION_ID --subnet-id $SUBNET_PUB_ID --map-public-ip-on-launch
# Private
    aws ec2 modify-subnet-attribute --region $REGION_ID --subnet-id $SUBNET_PRI_ID --no-map-public-ip-on-launch
