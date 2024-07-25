#!/bin/zsh
BUCKET=(bucket name)
KEY=(key name)
BODY=(source file)

aws s3api put-object --bucket $BUCKET --key $KEY --acl public-read --body $BODY
