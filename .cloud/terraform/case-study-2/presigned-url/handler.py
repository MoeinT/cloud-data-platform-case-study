import datetime
import json
import os

import boto3

s3 = boto3.client("s3")  # runs as the Lambda's role
PARTNER_FOLDERS = json.loads(os.environ["PARTNER_FOLDERS"])


def handler(event, context):
    # WHO is calling: the API key API Gateway authenticated, never the partner's input
    partner = PARTNER_FOLDERS.get(event["requestContext"]["identity"]["apiKeyId"])
    if partner is None:
        return {"statusCode": 403}

    # WHAT they send: only the file name (basename strips any "../")
    filename = os.path.basename(event["queryStringParameters"]["filename"])

    # WHERE: always their own folder, decided by us
    key = f"{partner}/{datetime.date.today()}/{filename}"

    url = s3.generate_presigned_url(
        "put_object",
        Params={"Bucket": os.environ["BUCKET"], "Key": key},
        ExpiresIn=900,  # 15 minutes
    )
    return {"statusCode": 200, "body": json.dumps({"upload_url": url})}
