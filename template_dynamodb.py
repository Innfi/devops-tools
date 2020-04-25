from troposphere import Template
from troposphere.dynamodb import Table, KeySchema, AttributeDefinition, ProvisionedThroughput

t = Template()

testDB = t.add_resource(
    Table(
        "testDynamoDBTable",
        KeySchema=[
            KeySchema(
                AttributeName="UserName",
                KeyType="HASH"
            )
        ],
        AttributeDefinitions=[
            AttributeDefinition(
                AttributeName="UserId",
                AttributeType="N"
            )
        ],
        ProvisionedThroughput=ProvisionedThroughput(
            ReadCapacityUnits=1,
            WriteCapacityUnits=1
        )
    )
)

print(t.to_json())
