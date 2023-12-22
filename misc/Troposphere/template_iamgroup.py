from troposphere import Template
from troposphere.iam import Group


t = Template()

view_group = t.add_resource(
    Group(
        "ViewOnlyGroup",
        ManagedPolicyArns=["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
    )
)

print(t.to_json())
