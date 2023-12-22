from troposphere import Parameter, Ref, Template
from troposphere.autoscaling import AutoScalingGroup, LaunchConfiguration
from troposphere.policies import AutoScalingReplacingUpdate, AutoScalingRollingUpdate, UpdatePolicy
from troposphere.ec2 import VPC, Subnet, SecurityGroup, SecurityGroupRule


t = Template()

vpc = t.add_resource(
    VPC(
        'TestVPC',
        CidrBlock="10.10.0.0/16"
    ))

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
        AvailabilityZone='ap-northeast-2b'
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

launch_config = t.add_resource(
    LaunchConfiguration(
        "TestLaunchConfiguration",
        ImageId='ami-0c276975654214bf3',
        KeyName='InnfisKey',
        SecurityGroups=[Ref(instanceSecurityGroup)],
        InstanceType="t2.small"
    )
)

as_group = t.add_resource(
    AutoScalingGroup(
        "TestAutoscalingGroup",
        DesiredCapacity=5,
        MinSize=3,
        MaxSize=10,
        LaunchConfigurationName=Ref(launch_config),
        VPCZoneIdentifier=[Ref(subnet1), Ref(subnet2)],
        AvailabilityZones=['ap-northeast-2a', 'ap-northeast-2b'],
        HealthCheckType="EC2",
        UpdatePolicy=UpdatePolicy(
            AutoScalingReplacingUpdate=AutoScalingReplacingUpdate(
                WillReplace=True
            ),
            AutoScalingRollingUpdate=AutoScalingRollingUpdate(
                PauseTime='PT5M',
                MinInstancesInService='1',
                MaxBatchSize='2',
                WaitOnResourceSignals=True
            )
        )
    )
)


print(t.to_json())
