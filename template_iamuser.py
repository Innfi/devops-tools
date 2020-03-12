from troposphere import Template
from troposphere.iam import User, Policy, LoginProfile
from awacs.aws import Allow, Statement, PolicyDocument, Action

t = Template()

t.add_resource(
    User(
        "ec2user",
        UserName="tester",
        Path="/",
        LoginProfile=LoginProfile(Password="myP@ssW000rd"),
        Policies=[
            Policy(
                PolicyName="ec2Policy",
                PolicyDocument=PolicyDocument(
                    Statement=[
                        Statement(
                            Effect=Allow,
                            Action=[Action("ec2", "RunInstances")],
                            Resource=["*"]
                        )
                    ]
                )
            )
        ]
    )
)


print(t.to_json())
