from troposphere import GetAtt, Join, Output, Parameter, Ref, Template
from troposphere.ec2 import VPC, SecurityGroup, VPCGatewayAttachment, Subnet, InternetGateway, \
    Route, RouteTable, SubnetRouteTableAssociation, SecurityGroupRule, Instance, NetworkInterfaceProperty
from troposphere.rds import DBInstance, DBSubnetGroup

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
        CidrBlock='10.10.10.0/24',
        VpcId=Ref(vpc),
        AvailabilityZone='ap-northeast-2a'
    )
)

subnetDB = t.add_resource(
    Subnet(
        'TestDBSubnet',
        CidrBlock='10.10.20.0/24',
        VpcId=Ref(vpc),
        AvailabilityZone='ap-northeast-2b'
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

dbUser = t.add_parameter(
    Parameter(
        "DBUser",
        Type='String',
        MinLength='1',
        MaxLength='16',
        AllowedPattern='[a-zA-Z][a-zA-Z0-9]*'
    )
)

dbPassword = t.add_parameter(
    Parameter(
        "DBPassword",
        Type='String',
        MinLength='1',
        MaxLength='41',
        AllowedPattern='[a-zA-Z09]*'
    )
)

dbSubnetGroup = t.add_resource(
    DBSubnetGroup(
        "MyDBSubnetGroup",
        DBSubnetGroupDescription='Available Subnets',
        SubnetIds=[Ref(subnet), Ref(subnetDB)]
    )
)

dbInstanceParam = DBInstance(
    "TestDB",
    DBName='test_db',
    AllocatedStorage='5',
    DBInstanceClass='db.t2.micro',
    Engine='MySQL',
    EngineVersion='5.5',
    MasterUsername=Ref(dbUser),
    MasterUserPassword=Ref(dbPassword),
    DBSubnetGroupName=Ref(dbSubnetGroup),
    VPCSecurityGroups=[Ref(instanceSecurityGroup)]
)

dbInstance = t.add_resource(dbInstanceParam)

print(t.to_json())
