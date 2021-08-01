resource "aws_s3_bucket" "codepipeline" {
  acl = "private"
}

resource "aws_s3_bucket_policy" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id
  policy = jsonencode(
    {
      Id = "SSEAndSSLPolicy"
      Statement = [
        {
          Action = "s3:PutObject"
          Condition = {
            StringNotEquals = {
              "s3:x-amz-server-side-encryption" = "aws:kms"
            }
          }
          Effect    = "Deny"
          Principal = "*"
          Resource  = "${aws_s3_bucket.codepipeline.arn}/*"
          Sid       = "DenyUnEncryptedObjectUploads"
        },
        {
          Action = "s3:*"
          Condition = {
            Bool = {
              "aws:SecureTransport" = "false"
            }
          }
          Effect    = "Deny"
          Principal = "*"
          Resource  = "${aws_s3_bucket.codepipeline.arn}/*"
          Sid       = "DenyInsecureConnections"
        },
      ]
      Version = "2012-10-17"
    }
  )
}
