from troposphere import Template
from troposphere.route53 import RecordSetType

t = Template()

dns_record = t.add_resource(
    RecordSetType(
        "testDNS",
        HostedZoneName="innfisk.com..",
        Name="test.innfisk.com.",
        Type="CNAME",
        TTL="100",
        ResourceRecords=["aws.amazon.com"]
    )
)

print(t.to_json())

