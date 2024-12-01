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

    AWS_PAGER=""
    # SET PARAM
    VPC_ID1=$(aws ec2 describe-vpcs \
        --region $REGION_ID1 \
        --filters "Name=tag:Name,Values=$VPC_NAME1" \
        --query "Vpcs[0].VpcId" \
        --output text)

    VPC_ID2=$(aws ec2 describe-vpcs \
        --region $REGION_ID2 \
        --filters "Name=tag:Name,Values=$VPC_NAME2" \
        --query "Vpcs[0].VpcId" \
        --output text)

    ROUTE_TABLE_PUBLIC_ID1=$(aws ec2 describe-route-tables \
        --filters "Name=tag:Name,Values=$ROUTE_TABLE_PUBLIC_NAME1" \
                "Name=vpc-id,Values=$VPC_ID1" \
        --region $REGION_ID1 \
        --query 'RouteTables[*].RouteTableId' \
        --output text)

    ROUTE_TABLE_PRIVATE_ID1=$(aws ec2 describe-route-tables \
        --filters "Name=tag:Name,Values=$ROUTE_TABLE_PRIVATE_NAME1" \
                "Name=vpc-id,Values=$VPC_ID1" \
        --region $REGION_ID1 \
        --query 'RouteTables[*].RouteTableId' \
        --output text)

    ROUTE_TABLE_PUBLIC_ID2=$(aws ec2 describe-route-tables \
        --filters "Name=tag:Name,Values=$ROUTE_TABLE_PUBLIC_NAME2" \
                "Name=vpc-id,Values=$VPC_ID2" \
        --region $REGION_ID2 \
        --query 'RouteTables[*].RouteTableId' \
        --output text)

    ROUTE_TABLE_PRIVATE_ID2=$(aws ec2 describe-route-tables \
        --filters "Name=tag:Name,Values=$ROUTE_TABLE_PRIVATE_NAME2" \
                "Name=vpc-id,Values=$VPC_ID2" \
        --region $REGION_ID2 \
        --query 'RouteTables[*].RouteTableId' \
        --output text)

    # Create a peering connection from region_1 -> region_2 
    PCX_ID=$(aws ec2 create-vpc-peering-connection --no-cli-pager \
        --vpc-id $VPC_ID1 \
        --peer-vpc-id $VPC_ID2 \
        --region $REGION_ID1 \
        --peer-region $REGION_ID2 \
        --query "VpcPeeringConnection.VpcPeeringConnectionId" \
        --output text)

    while true; do
        echo "Attempting to accept VPC peering connection..."
        aws ec2 accept-vpc-peering-connection --no-cli-pager \
            --vpc-peering-connection-id $PCX_ID \
            --region $REGION_ID2 > /dev/null 2>&1
        
        # Kiểm tra trạng thái của VPC peering connection
        STATUS=$(aws ec2 describe-vpc-peering-connections \
            --vpc-peering-connection-ids $PCX_ID \
            --region $REGION_ID1 \
            --query 'VpcPeeringConnections[0].Status.Code' \
            --output text)

        echo "Current VPC Peering Connection status: $STATUS"
        
        # Nếu trạng thái là "active", thoát vòng lặp
        if [ "$STATUS" == "active" ]; then
            echo "VPC Peering Connection is active. Proceeding with further actions..."
            break
        fi
        
        # Đợi một chút trước khi thử lại
        sleep 5
    done

    aws ec2 create-tags --no-cli-pager \
    --resources $PCX_ID \
    --tags Key=Name,Value="peering_${VPC_NAME1}_to_${VPC_NAME2}" \
    --region $REGION_ID1
    aws ec2 create-tags --no-cli-pager \
    --resources $PCX_ID \
    --tags Key=Name,Value="peering_${VPC_NAME1}_to_${VPC_NAME2}" \
    --region $REGION_ID2
    
    #Create route for Public Route Table in Region 1
    aws ec2 create-route \
        --route-table-id $ROUTE_TABLE_PUBLIC_ID1 \
        --destination-cidr-block $IP_RANGE2 \
        --vpc-peering-connection-id $PCX_ID \
        --region $REGION_ID1
echo -e "Created route Pub for ${VPC_NAME1}"

    # Create route for Private Route Table in Region 1
    aws ec2 create-route \
        --route-table-id $ROUTE_TABLE_PRIVATE_ID1 \
        --destination-cidr-block $IP_RANGE2 \
        --vpc-peering-connection-id $PCX_ID \
        --region $REGION_ID1
echo -e "Created route Pri for ${VPC_NAME1}"

    # Create route for Public Route Table in Region 2
    aws ec2 create-route \
        --route-table-id $ROUTE_TABLE_PUBLIC_ID2 \
        --destination-cidr-block $IP_RANGE1 \
        --vpc-peering-connection-id $PCX_ID \
        --region $REGION_ID2
echo -e "Created route Pub for ${VPC_NAME2}"

    # Create route for Private Route Table in Region 2
    aws ec2 create-route \
        --route-table-id $ROUTE_TABLE_PRIVATE_ID2 \
        --destination-cidr-block $IP_RANGE1 \
        --vpc-peering-connection-id $PCX_ID \
        --region $REGION_ID2
echo -e "Created route Pri for ${VPC_NAME2}"