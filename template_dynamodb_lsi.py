from troposphere import Template
from troposphere.dynamodb import (
    KeySchema,
    AttributeDefinition,
    ProvisionedThroughput,
    Projection,
    Table,
    LocalSecondaryIndex)

t = Template()

t.add_resource(
    Table(
        "TestLocalSecondaryIndexTable",
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
        ],
        ProvisionedThroughput=ProvisionedThroughput(
            ReadCapacityUnits=1,
            WriteCapacityUnits=1
        ),
        LocalSecondaryIndexes=[
            LocalSecondaryIndex(
                IndexName="LSISeasonId",
                KeySchema=[
                    KeySchema(
                        AttributeName="GameId",
                        KeyType="HASH"
                    ),
                    KeySchema(
                        AttributeName="SeasonId",
                        KeyType="RANGE"
                    )
                ],
                Projection=Projection(
                    ProjectionType="ALL"
                )
            )
        ]
    )
)

print(t.to_json())

