from troposphere import Template
from troposphere.codecommit import Code, Repository

t = Template()

t.add_resource(
    Repository(
        "InnfisRepo",
        RepositoryName="TestRepository",
        RepositoryDescription="test repo by troposphere",
    )
)


print(t.to_json())
