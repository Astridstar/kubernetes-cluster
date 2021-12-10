
Steps taken from https://www.golinuxcloud.com/setup-kubernetes-cluster-on-aws-ec2/ 

## 1. Configure Network on AWS
* * [root@client ~]VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query "Vpc.VpcId" --output text)

* * [root@client ~]echo $VPC_ID
vpc-0f13fdd748798c149

## 2. Enable DNS Support
* * [root@client ~]aws ec2 modify-vpc-attribute --enable-dns-support --vpc-id $VPC_ID
* * [root@client ~]aws ec2 modify-vpc-attribute --enable-dns-hostnames --vpc-id $VPC_ID

## 3. Add tags to the VPC and subnet
* * root@client ~]aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=golinuxcloud Key=kubernetes.io/cluster/golinuxcloud,Value=shared
* * [root@client ~]PRIVATE_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC_ID --query "RouteTables[0].RouteTableId" --output=text)

* * [root@client ~]echo $PRIVATE_ROUTE_TABLE_ID
rtb-0027af99433929578

* * [root@client ~]PUBLIC_ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query "RouteTable.RouteTableId" --output text)

* * [root@client ~]echo $PUBLIC_ROUTE_TABLE_ID
rtb-0cf752bd6a8174062

* * [root@client ~]aws ec2 create-tags --resources $PUBLIC_ROUTE_TABLE_ID --tags Key=Name,Value=golinuxcloud-public
* * [root@client ~]aws ec2 create-tags --resources $PRIVATE_ROUTE_TABLE_ID --tags Key=Name,Value=golinuxcloud-private

## 4. Create private and public subnets for cluster
* * [root@client ~]aws ec2 describe-availability-zones

* * [root@client ~]PRIVATE_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --availability-zone us-east-2c --cidr-block 10.0.0.0/24 --query "Subnet.SubnetId" --output text)

* * [root@client ~]echo $PRIVATE_SUBNET_ID
subnet-096e2d0c20be8d483

* * [root@client ~]aws ec2 create-tags --resources $PRIVATE_SUBNET_ID --tags Key=Name,Value=golinuxcloud-private-1a Key=kubernetes.io/cluster/golinuxcloud,Value=owned Key=kubernetes.io/role/internal-elb,Value=1
[root@client ~]PUBLIC_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --availability-zone us-east-2c --cidr-block 10.0.16.0/24 --query "Subnet.SubnetId" --output text)

* * [root@client ~]echo $PUBLIC_SUBNET_ID
subnet-09d11bc91c34aec80

* * [root@client ~]aws ec2 create-tags --resources $PUBLIC_SUBNET_ID --tags Key=Name,Value=golinuxcloud-public-1a Key=kubernetes.io/cluster/golinuxcloud,Value=owned Key=kubernetes.io/role/elb,Value=1
* * [root@client ~]aws ec2 associate-route-table --subnet-id $PUBLIC_SUBNET_ID --route-table-id $PUBLIC_ROUTE_TABLE_ID
{
    "AssociationId": "rtbassoc-0cc0cc6e747c71c60",
    "AssociationState": {
        "State": "associated"
    }
}




















