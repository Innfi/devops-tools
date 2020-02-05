from troposphere import GetAtt, Join, Output, Parameter, Ref, Template
from troposphere.ec2 import VPC, SecurityGroup, VPCGatewayAttachment, Subnet, InternetGateway, \
    Route, RouteTable, SubnetRouteTableAssociation

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

print(t.to_json())
