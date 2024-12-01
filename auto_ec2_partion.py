import csv
import sys
import os


class Ec2_info:
    def __init__(self, node_name, region_name, ipv4_private, vpc_name, security_group_name, ip_range, key_name,
                 subnet_pub, subnet_pri, region_id, gateway_name, eip_nat_name,
                 natgw_name, route_table_public_name, route_table_private_name, image_id, flavor, storage_size, storage_type):
        self.node_name = node_name
        self.region_name = region_name
        self.ipv4_private = ipv4_private
        self.vpc_name = vpc_name
        self.security_group_name = security_group_name
        self.ip_range = ip_range
        self.key_name = key_name
        self.subnet_pub = subnet_pub
        self.subnet_pri = subnet_pri
        self.region_id = region_id
        self.gateway_name = gateway_name
        self.eip_nat_name = eip_nat_name
        self.natgw_name = natgw_name
        self.route_table_public_name = route_table_public_name
        self.route_table_private_name = route_table_private_name
        self.image_id = image_id
        self.flavor = flavor
        self.storage_size = storage_size
        self.storage_type = storage_type

    def display_info(self):
        return f"""
        Node Name: {self.node_name}
        Region Name: {self.region_name}
        Private IPv4: {self.ipv4_private}
        VPC Name: {self.vpc_name}
        Security Group Name: {self.security_group_name}
        IP Range: {self.ip_range}
        Key Name: {self.key_name}
        Public Subnet: {self.subnet_pub}
        Private Subnet: {self.subnet_pri}
        Region ID: {self.region_id}
        Gateway Name: {self.gateway_name}
        EIP NAT Name: {self.eip_nat_name}
        NAT Gateway Name: {self.natgw_name}
        Public Route Table: {self.route_table_public_name}
        Private Route Table: {self.route_table_private_name}
        Image ID: {self.image_id}
        Flavor: {self.flavor}
        Storage Size: {self.storage_size}
        Storage Type: {self.storage_type}
        """


def read_Ec2_info_from_csv(file_path):
    configurations = []
    with open(file_path, mode='r', newline='', encoding='utf-8') as csvfile:
        csvreader = csv.reader(csvfile)
        # Giả sử dòng đầu tiên là tiêu đề, bỏ qua nó
        # next(csvreader)
        for row in csvreader:
            if len(row) == 19:  # Đảm bảo rằng mỗi dòng có đủ 19 trường (theo số lượng trong hàm __init__ của Ec2_info)
                config = Ec2_info(*row)
                configurations.append(config)
    return configurations


# Kiểm tra xem có đủ đối số được cung cấp không
if len(sys.argv) < 2:
    print("Vui lòng cung cấp đường dẫn đến file CSV , Script")
    sys.exit(1)  # Thoát chương trình với mã lỗi
elif len(sys.argv) == 2:
    print("Vui lòng cung cấp đường dẫn đến file CSV , Script")
    sys.exit(2)

# Lấy đường dẫn file từ đối số đầu tiên
file_path = sys.argv[1]

ec2_list = read_Ec2_info_from_csv(file_path)
exec_file = sys.argv[2]
# In ra các cấu hình đã đọc
for ec2 in ec2_list:
    print(f"\nProcessing {ec2.node_name}\n")
    command = f"./{exec_file} " + " ".join(f"{value}" for value in ec2.__dict__.values())
    os.system(command)