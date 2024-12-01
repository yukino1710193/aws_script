#!/bin/bash
    REGION_NAME1="$1"
    VPC_NAME1="$2"
    SECURITY_GROUP_NAME1="$3"
    IP_RANGE1="$4"
    KEY_NAME1="$5"
    SUBNET_PUB1="$6"
    SUBNET_PRI1="$7"
    REGION_ID1="$8"
    GATEWAY_NAME1="$9"
    EIP_NAT_NAME1="${10}"
    NATGW_NAME1="${11}"
    ROUTE_TABLE_PUBLIC_NAME1="${12}"
    ROUTE_TABLE_PRIVATE_NAME1="${13}"

    # Gán các giá trị cho biến môi trường từ VPC 2
    REGION_NAME2="${14}"
    VPC_NAME2="${15}"
    SECURITY_GROUP_NAME2="${16}"
    IP_RANGE2="${17}"
    KEY_NAME2="${18}"
    SUBNET_PUB2="${19}"
    SUBNET_PRI2="${20}"
    REGION_ID2="${21}"
    GATEWAY_NAME2="${22}"
    EIP_NAT_NAME2="${23}"
    NATGW_NAME2="${24}"
    ROUTE_TABLE_PUBLIC_NAME2="${25}"
    ROUTE_TABLE_PRIVATE_NAME2="${26}"
    # Bỏ tinh năng ngắt trang 
    AWS_PAGER=""
    # Querry
    echo "Start query"
    VPC_ID1=$(aws ec2 describe-vpcs \
        --region $REGION_ID1 \
        --filters "Name=tag:Name,Values=$VPC_NAME1" \
        --query "Vpcs[0].VpcId" \
        --output text)
    echo "VPC_ID1 = $VPC_ID1"

    VPC_ID2=$(aws ec2 describe-vpcs \
        --region $REGION_ID2 \
        --filters "Name=tag:Name,Values=$VPC_NAME2" \
        --query "Vpcs[0].VpcId" \
        --output text)
    echo "VPC_ID1 = $VPC_ID2"

    ROUTE_TABLE_PUBLIC_ID1=$(aws ec2 describe-route-tables \
        --region $REGION_ID1 \
        --filters "Name=tag:Name,Values=$ROUTE_TABLE_PUBLIC_NAME1" \
                "Name=vpc-id,Values=$VPC_ID1" \
        --query 'RouteTables[*].RouteTableId' \
        --output text)
    echo "Route pub 1 = $ROUTE_TABLE_PUBLIC_ID1"

    ROUTE_TABLE_PRIVATE_ID1=$(aws ec2 describe-route-tables \
        --region $REGION_ID1 \
        --filters "Name=tag:Name,Values=$ROUTE_TABLE_PRIVATE_NAME1" \
                "Name=vpc-id,Values=$VPC_ID1" \
        --query 'RouteTables[*].RouteTableId' \
        --output text)
    echo "Route pri 1 = $ROUTE_TABLE_PRIVATE_ID1"

    ROUTE_TABLE_PUBLIC_ID2=$(aws ec2 describe-route-tables \
        --region $REGION_ID2 \
        --filters "Name=tag:Name,Values=$ROUTE_TABLE_PUBLIC_NAME2" \
                "Name=vpc-id,Values=$VPC_ID2" \
        --query 'RouteTables[*].RouteTableId' \
        --output text)
    echo "Route pub 2 = $ROUTE_TABLE_PUBLIC_ID2"

    ROUTE_TABLE_PRIVATE_ID2=$(aws ec2 describe-route-tables \
        --region $REGION_ID2 \
        --filters "Name=tag:Name,Values=$ROUTE_TABLE_PRIVATE_NAME2" \
                "Name=vpc-id,Values=$VPC_ID2" \
        --query 'RouteTables[*].RouteTableId' \
        --output text)
    echo "Route pri 2 = $ROUTE_TABLE_PRIVATE_ID2"
    
    PCX_ID=$(aws ec2 describe-vpc-peering-connections \
        --region $REGION_ID1 \
        --query "VpcPeeringConnections[? \
            RequesterVpcInfo.VpcId=='$VPC_ID1' && \
            AccepterVpcInfo.VpcId=='$VPC_ID2' && \
            Status.Code=='active'].VpcPeeringConnectionId" \
        --output text)
    echo ""
    echo "Query PCX_ID =$PCX_ID"


#    Delete peering
    aws ec2 delete-vpc-peering-connection \
    --vpc-peering-connection-id $PCX_ID \
    --region $REGION_ID1
    echo "peering $REGION_NAME1 to $REGION_NAME2 deleted"
    aws ec2 delete-route \
        --route-table-id $ROUTE_TABLE_PUBLIC_ID1 \
        --destination-cidr-block $IP_RANGE2 \
        --region $REGION_ID1
    echo "delete route 01"
    aws ec2 delete-route \
        --route-table-id $ROUTE_TABLE_PRIVATE_ID1 \
        --destination-cidr-block $IP_RANGE2 \
        --region $REGION_ID1
    echo "delete route 02"
    aws ec2 delete-route \
        --route-table-id $ROUTE_TABLE_PUBLIC_ID2 \
        --destination-cidr-block $IP_RANGE1 \
        --region $REGION_ID2
    echo "delete route 03"
    aws ec2 delete-route \
        --route-table-id $ROUTE_TABLE_PRIVATE_ID2 \
        --destination-cidr-block $IP_RANGE1 \
        --region $REGION_ID2
    echo "delete route 04"