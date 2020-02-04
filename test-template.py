from troposphere import GetAtt, Join, Output, Parameter, Ref, Template
from troposphere.ec2 import VPC, SecurityGroup

t = Template()

t.set_description("Sample script for creating vpc")

vpc_resource = t.add_resource(
    VPC(
        'TestVPC',
        CidrBlock="10.10.0.0/16"
    ))

print(t.to_json())
