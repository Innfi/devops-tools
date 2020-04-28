from troposphere import Template
from troposphere.dynamodb import (
    KeySchema,
    AttributeDefinition,
    ProvisionedThroughput,
    Table,
    GlobalSecondaryIndex,
    Projection
    )

t = Template()

t.add_resource(
    Table(
        "TestGlobalSecondaryIndexTable",
        KeySchema=[
            KeySchema(
                AttributeName="GameId",
                KeyType="HASH"
            ),
            KeySchema(
                AttributeName="GameType",
                KeyType="RANGE"
            )
        ],
        AttributeDefinitions=[
            AttributeDefinition(
                AttributeName="GameId",
                AttributeType="N"
            ),
            AttributeDefinition(
                AttributeName="GameType",
                AttributeType="N"
            ),
            AttributeDefinition(
                AttributeName="SeasonId",
                AttributeType="N"
            ),
            AttributeDefinition(
                AttributeName="KeyPlayerId",
                AttributeType="N"
            )
        ],
        ProvisionedThroughput=ProvisionedThroughput(
            ReadCapacityUnits=1,
            WriteCapacityUnits=1
        ),
        GlobalSecondaryIndexes=[
            GlobalSecondaryIndex(
                IndexName="GSIKeyPlayer",
                KeySchema=[
                    KeySchema(
                        AttributeName="SeasonId",
                        KeyType="HASH"
                    ),
                    KeySchema(
                        AttributeName="KeyPlayerId",
                        KeyType="RANGE"
                    ),
                ],
                Projection=Projection(
                    ProjectionType="ALL"
                ),
                ProvisionedThroughput=ProvisionedThroughput(
                    ReadCapacityUnits=5,
                    WriteCapacityUnits=1
                )
            )
        ]
    )
)

print(t.to_json())

