from troposphere import Template, Join, Ref, GetAtt
from troposphere.awslambda import Function, Code, Permission
from troposphere.events import Rule, Target

t = Template()

code = [
    "var response=require('cfn-response');",
    "exports.handler=function(event, context) {",
    " return 'test'; ",
    "}; "
]

test_function = t.add_resource(
    Function(
        "TestFunction",
        Code=Code(
            ZipFile=Join("", code)
        ),
        Handler="index.handler",
        Role=GetAtt("LambdaExecutionRole", "Arn"),
        Runtime="nodejs"
    )
)

test_target = Target(
    "TestTarget",
    Arn=GetAtt('TestFunction', 'Arn'),
    Id="TestFunction1"
)

rule = t.add_resource(
    Rule(
        "TestRule",
        EventPattern={
            "source": ["aws.ec2"],
            "detail-type": ["test notification"],
            "detail": {
                "state": ["stopping"]
            }
        },
        Description="Test Cloudwatch Event",
        State="DISABLED",
        Targets=[test_target]
    )
)

permission = t.add_resource(
    Permission(
        "TestPermission",
        Action='lambda:invokeFunction',
        Principal='events.amazonaws.com',
        FunctionName=Ref(test_function),
        SourceArn=GetAtt(rule, 'Arn')
    )
)

print(t.to_json())

