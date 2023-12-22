from troposphere import Template
from troposphere.codebuild import Source, Project, Artifacts, Environment


t = Template()

source = Source(
    Location='https://github.com/Innfi/SampleNodeJs.git',
    Type='GITHUB'
)

artifacts = Artifacts(
    Type='NO_ARTIFACTS'
)

environment = Environment(
    ComputeType="BUILD_GENERAL1_SMALL",
    Image='aws/codebuild/standard:3.0',
    Type='LINUX_CONTAINER'
)

t.add_resource(
    Project(
        "TestProject",
        Name='TestProject',
        ServiceRole='arn:aws:iam::0123456789:role/codebuild-role',
        Artifacts=artifacts,
        Source=source,
        Environment=environment
    )
)

print(t.to_json())

