#!/bin/zsh
SCAN_ID=$(aws cloudformation start-resource-scan --region ap-northeast-2 | jq -r .ResourceScanId)

SET=$(seq 0 10)
for i in $SET
do
  SCAN_STATUS=$(aws cloudformation describe-resource-scan --region ap-northeast-2 --resource-scan-id $SCAN_ID | jq -r .Status)

  if [[ "$SCAN_STATUS" == "COMPLETE" ]]; then
    aws cloudformation list-resource-scan-resources --resource-scan-id $SCAN_ID --resource-identifier cf-test > ./resources.json
    aws cloudformation list-resource-scan-related-resources --resource-scan-id $SCAN_ID --resources file://resources.json >> ./resources.json
    TEMPLATE_ARN=$(aws cloudformation create-generated-template --region ap-northeast-2 --generate-template-name cf-test-template --resources file://resources.json | jq -r .Arn)

    # TODO: handle errors?
    echo "cloudformation template arn: $TEMPLATE_ARN"
  else
    continue
  fi
done

echo "timeout exceed"
exit 1