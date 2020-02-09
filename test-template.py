from troposphere import GetAtt, Join, Output, Parameter, Ref, Template
from troposphere.ec2 import VPC, SecurityGroup, VPCGatewayAttachment, Subnet, InternetGateway, \
    Route, RouteTable, SubnetRouteTableAssociation, SecurityGroupRule, Instance, NetworkInterfaceProperty

t = Template()

t.set_description("Sample script for creating vpc")

vpc = t.add_resource(
    VPC(
        'TestVPC',
        CidrBlock="10.10.0.0/16"
    ))

subnet = t.add_resource(
    Subnet(
        'TestSubnet',
        CidrBlock='10.10.0.0/24',
        VpcId=Ref(vpc)
    )
)

gateway = t.add_resource(
    InternetGateway(
        'TestGateway'
    )
)

gatewayAttachment = t.add_resource(
    VPCGatewayAttachment(
        'TestAttachGateway',
        VpcId=Ref(vpc),
        InternetGatewayId=Ref(gateway)
    )
)

routeTable = t.add_resource(
    RouteTable(
        'TestRouteTable',
        VpcId=Ref(vpc)
    )
)

route = t.add_resource(
    Route(
        'TestRoute',
        GatewayId=Ref(gateway),
        RouteTableId=Ref(routeTable),
        DestinationCidrBlock='0.0.0.0/0'
    )
)

subnetRouteTableAssociation = t.add_resource(
    SubnetRouteTableAssociation(
        'TestSubnetRoute',
        SubnetId=Ref(subnet),
        RouteTableId=Ref(routeTable)
    )
)

instanceSecurityGroup = t.add_resource(
    SecurityGroup(
        'TestSecurityGroup',
        GroupDescription='Test SG',
        SecurityGroupIngress=[
            SecurityGroupRule(
                IpProtocol='tcp',
                FromPort='22',
                ToPort='22',
                CidrIp='10.10.0.0/32'
            ),
            SecurityGroupRule(
                IpProtocol='tcp',
                FromPort='80',
                ToPort='80',
                CidrIp='0.0.0.0/0'
            )
        ],
        VpcId=Ref(vpc)
    )
)

instance = t.add_resource(
    Instance(
        'TestEC2Instance',
        ImageId='ami-0bea7fd38fabe821a',
        InstanceType='t2.micro',
        NetworkInterfaces=[
            NetworkInterfaceProperty(
                GroupSet=[Ref(instanceSecurityGroup)],
                AssociatePublicIpAddress='true',
                DeviceIndex='0',
                DeleteOnTermination='true',
                SubnetId=Ref(subnet)
            )
        ]
    )
)

print(t.to_json())
