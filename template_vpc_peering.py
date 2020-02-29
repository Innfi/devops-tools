from troposphere import Template, Ref
from troposphere.ec2 import VPC, VPCPeeringConnection

t = Template()

vpc1 = t.add_resource(
    VPC(
        "TestVpc1",
        CidrBlock="10.10.0.0/16"
    )
)

vpc2 = t.add_resource(
    VPC(
        "TestVpc2",
        CidrBlock="172.10.0.0/16"
    )
)

t.add_resource(
    VPCPeeringConnection(
        "TestPeering",
        VpcId=Ref(vpc1),
        PeerVpcId=Ref(vpc2)
    )
)

print(t.to_json())

