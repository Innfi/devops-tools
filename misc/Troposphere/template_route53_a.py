from troposphere.ec2 import Instance
from troposphere import Template, Join
from troposphere.route53 import RecordSetType, RecordSet

t = Template()

t.add_resource(
    RecordSetType(
        "TestRecord",
        HostedZoneName="innfisk.com.",
        Name="ennfi.innfisk.com.",
        Type="A",
        TTL="900",
        ResourceRecords=["172.16.0.1"]
    )
)

print(t.to_json())
