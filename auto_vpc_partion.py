import csv
import sys
import os

class Vpc_info:
    def __init__(self, region_name, vpc_name, security_group_name, ip_range, key_name,
                 subnet_pub, subnet_pri, region_id, gateway_name, eip_nat_name,
                 natgw_name, route_table_public_name, route_table_private_name):
        self.region_name = region_name
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

    def __repr__(self):
        return (f"Vpc_info(region_name={self.region_name}, vpc_name={self.vpc_name}, "
                f"security_group_name={self.security_group_name}, ip_range={self.ip_range}, "
                f"key_name={self.key_name}, subnet_pub={self.subnet_pub}, "
                f"subnet_pri={self.subnet_pri}, region_id={self.region_id}, "
                f"gateway_name={self.gateway_name}, eip_nat_name={self.eip_nat_name}, "
                f"natgw_name={self.natgw_name}, route_table_public_name={self.route_table_public_name}, "
                f"route_table_private_name={self.route_table_private_name})")

def read_VPC_info_from_csv(file_path):
    configurations = []
    with open(file_path, mode='r', newline='', encoding='utf-8') as csvfile:
        csvreader = csv.reader(csvfile)
        # Giả sử dòng đầu tiên là tiêu đề, bỏ qua nó
        # next(csvreader)
        for row in csvreader:
            if len(row) == 13:  # Đảm bảo rằng mỗi dòng có đủ 13 trường
                config = Vpc_info(*row)
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

vpc_list = read_VPC_info_from_csv(file_path)
exec_file = sys.argv[2]
# In ra các cấu hình đã đọc
for vpc in vpc_list:
    print(f"\nProcessing in vpc {vpc.vpc_name}\n")
    command = f"./{exec_file} " + " ".join(f"{value}" for value in vpc.__dict__.values())
    os.system(command)