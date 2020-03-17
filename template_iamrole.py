from troposphere import Template
from troposphere.iam import Role
from awacs.aws import Allow, Statement, PolicyDocument, Principal
from awacs.sts import AssumeRole

t = Template()

t.add_resource(
    Role(
        'TestRole',
        AssumeRolePolicyDocument=PolicyDocument(
            Statement=[
                Statement(
                    Effect=Allow,
                    Action=[AssumeRole],
                    Principal=Principal("Service", ["codebuild.amazonaws.com"])
                )
            ]
        )
    )
)

print(t.to_json())
