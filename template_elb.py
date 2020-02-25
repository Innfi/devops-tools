from troposphere import Ref, Template
import troposphere.ec2 as ec2
from troposphere.ec2 import VPC, Subnet, SecurityGroup, SecurityGroupRule, \
    NetworkInterfaceProperty, InternetGateway, VPCGatewayAttachment
import troposphere.elasticloadbalancingv2 as elb

t = Template()


vpc = t.add_resource(
    VPC(
        'TestVPC',
        CidrBlock="10.10.0.0/16"
    ))

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

subnet1 = t.add_resource(
    Subnet(
        'TestSubnet1',
        CidrBlock='10.10.10.0/24',
        VpcId=Ref(vpc),
        AvailabilityZone='ap-northeast-2a'
    )
)

subnet2 = t.add_resource(
    Subnet(
        'TestSubnet2',
        CidrBlock='10.10.20.0/24',
        VpcId=Ref(vpc),
        AvailabilityZone='ap-northeast-2c'
    )
)

instance_sg = t.add_resource(
    SecurityGroup(
        'TestSecurityGroup',
        GroupDescription='Test SG',
        SecurityGroupIngress=[
            SecurityGroupRule(
                IpProtocol='tcp',
                FromPort='8080',
                ToPort='8080',
                CidrIp='0.0.0.0/0'
            ),
            SecurityGroupRule(
                IpProtocol='tcp',
                FromPort='3000',
                ToPort='3000',
                CidrIp='0.0.0.0/0'
            )
        ],
        VpcId=Ref(vpc)
    )
)

web_instance = t.add_resource(
    ec2.Instance(
        "TestWebInstance",
        ImageId='ami-0bea7fd38fabe821a',
        InstanceType='t2.micro',
        NetworkInterfaces=[
            NetworkInterfaceProperty(
                GroupSet=[Ref(instance_sg)],
                AssociatePublicIpAddress='true',
                DeviceIndex='0',
                SubnetId=Ref(subnet1)
            )
        ]
    )
)

api_instance = t.add_resource(
    ec2.Instance(
        "TestApiInstance",
        ImageId='ami-0bea7fd38fabe821a',
        InstanceType='t2.micro',
        NetworkInterfaces=[
            NetworkInterfaceProperty(
                GroupSet=[Ref(instance_sg)],
                AssociatePublicIpAddress='true',
                DeviceIndex='0',
                SubnetId=Ref(subnet2)
            )
        ]
    )
)

application_elb = t.add_resource(
    elb.LoadBalancer(
        "TestELB",
        Name="TestELB",
        Scheme="internet-facing",
        Subnets=[Ref(subnet1), Ref(subnet2)]
    )
)

target_group_web = t.add_resource(
    elb.TargetGroup(
        "TestTargetGroupWeb",
        HealthCheckIntervalSeconds="60",
        HealthCheckProtocol="HTTP",
        HealthCheckTimeoutSeconds="30",
        HealthyThresholdCount="4",
        UnhealthyThresholdCount="3",
        Matcher=elb.Matcher(HttpCode="200"),
        Name="WebTarget",
        Port="8080",
        Protocol="HTTP",
        Targets=[elb.TargetDescription(
            Id=Ref(web_instance),
            Port="8080"
        )],
        VpcId=Ref(vpc)
    )
)

target_group_api = t.add_resource(
    elb.TargetGroup(
        "TestTargetGroupApi",
        HealthCheckIntervalSeconds="30",
        HealthCheckProtocol="HTTP",
        HealthCheckTimeoutSeconds="10",
        HealthyThresholdCount="4",
        UnhealthyThresholdCount="3",
        Matcher=elb.Matcher(HttpCode="200"),
        Name="ApiTarget",
        Port="3000",
        Protocol="HTTP",
        Targets=[elb.TargetDescription(
            Id=Ref(api_instance),
            Port="3000"
        )],
        VpcId=Ref(vpc)
    )
)

elb_listener = t.add_resource(
    elb.Listener(
        "TestListener",
        Port="80",
        Protocol="HTTP",
        LoadBalancerArn=Ref(application_elb),
        DefaultActions=[elb.Action(
            Type="forward",
            TargetGroupArn=Ref(target_group_web)
        )]
    )
)

t.add_resource(
    elb.ListenerRule(
        "TestListenerRule",
        ListenerArn=Ref(elb_listener),
        Conditions=[elb.Condition(
            Field="path-pattern",
            Values=["/api/*"]
        )],
        Actions=[elb.Action(
            Type="forward",
            TargetGroupArn=Ref(target_group_api)
        )],
        Priority="1"
    )
)

print(t.to_json())

