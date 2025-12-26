from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import JSONResponse
import boto3
from botocore.exceptions import ClientError
from enum import Enum
from typing import Optional
import os

app = FastAPI(title="S3 Object URL Retriever")

# Configuration
S3_BUCKET = os.getenv("S3_BUCKET", "your-bucket-name")
AWS_REGION = os.getenv("AWS_REGION", "ap-northeast-2")
URL_EXPIRATION = int(os.getenv("URL_EXPIRATION", "3600"))  # 1 hour default

# Initialize S3 client
s3_client = boto3.client("s3", region_name=AWS_REGION)


class ObjectType(str, Enum):
    """Supported object types"""
    DOCUMENT = "document"
    IMAGE = "image"
    REPORT = "report"
    INVOICE = "invoice"


def get_s3_key(unique_id: str, object_type: ObjectType) -> str:
    """
    Generate S3 object key based on type and ID.
    Adjust this logic based on your S3 structure.
    """
    # Example structure: {type}/{unique_id}.ext
    type_extensions = {
        ObjectType.DOCUMENT: "pdf",
        ObjectType.IMAGE: "png",
        ObjectType.REPORT: "pdf",
        ObjectType.INVOICE: "pdf",
    }
    
    ext = type_extensions.get(object_type, "bin")
    return f"{object_type.value}/{unique_id}.{ext}"


@app.get("/")
async def root():
    return {"message": "S3 Object URL Retriever API"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


@app.get("/object-url")
async def get_object_url(
    id: str = Query(..., description="Unique identifier for the object"),
    type: ObjectType = Query(..., description="Type of object to retrieve"),
    expiration: Optional[int] = Query(
        None, 
        description="URL expiration time in seconds (default: 3600)",
        gt=0,
        le=604800  # Max 7 days
    )
):
    """
    Retrieve a presigned URL for an S3 object.
    
    - **id**: Unique identifier for the object
    - **type**: Type of object (document, image, report, invoice)
    - **expiration**: Optional URL expiration in seconds (default: 3600, max: 604800)
    """
    try:
        # Generate S3 object key
        s3_key = get_s3_key(id, type)
        
        # Check if object exists
        try:
            s3_client.head_object(Bucket=S3_BUCKET, Key=s3_key)
        except ClientError as e:
            if e.response['Error']['Code'] == '404':
                raise HTTPException(
                    status_code=404,
                    detail=f"Object not found: {type.value}/{id}"
                )
            raise
        
        # Generate presigned URL
        url_exp = expiration if expiration else URL_EXPIRATION
        presigned_url = s3_client.generate_presigned_url(
            'get_object',
            Params={
                'Bucket': S3_BUCKET,
                'Key': s3_key
            },
            ExpiresIn=url_exp
        )
        
        return {
            "url": presigned_url,
            "object_key": s3_key,
            "bucket": S3_BUCKET,
            "expires_in": url_exp,
            "type": type.value,
            "id": id
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate URL: {str(e)}"
        )


@app.get("/object-url/public")
async def get_public_object_url(
    id: str = Query(..., description="Unique identifier for the object"),
    type: ObjectType = Query(..., description="Type of object to retrieve")
):
    """
    Get the public URL for an S3 object (if bucket allows public access).
    """
    try:
        s3_key = get_s3_key(id, type)
        
        # Check if object exists
        try:
            s3_client.head_object(Bucket=S3_BUCKET, Key=s3_key)
        except ClientError as e:
            if e.response['Error']['Code'] == '404':
                raise HTTPException(
                    status_code=404,
                    detail=f"Object not found: {type.value}/{id}"
                )
            raise
        
        # Generate public URL (works only if bucket/object is public)
        public_url = f"https://{S3_BUCKET}.s3.{AWS_REGION}.amazonaws.com/{s3_key}"
        
        return {
            "url": public_url,
            "object_key": s3_key,
            "bucket": S3_BUCKET,
            "type": type.value,
            "id": id,
            "note": "This URL works only if the object has public read permissions"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to generate public URL: {str(e)}"
        )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
