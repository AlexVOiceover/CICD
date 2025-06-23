terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "alex_bucket" {
#   bucket = "alex-bucket-${random_id.suffix.hex}"
    bucket = "alex-bucket-2025-06-23"
}

# resource "random_id" "suffix" {
#   byte_length = 4
# }

resource "aws_s3_bucket_website_configuration" "alex_bucket" {
  bucket = aws_s3_bucket.alex_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "alex_bucket" {
  bucket = aws_s3_bucket.alex_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "alex_bucket" {
  bucket = aws_s3_bucket.alex_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.alex_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.alex_bucket]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.alex_bucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = filemd5("index.html")
}

output "bucket_name" {
  description = "Name of Alex's S3 bucket"
  value       = aws_s3_bucket.alex_bucket.id
}

output "bucket_arn" {
  description = "ARN of Alex's S3 bucket"
  value       = aws_s3_bucket.alex_bucket.arn
}

output "website_url" {
  description = "URL of Alex's website"
  value       = "http://${aws_s3_bucket.alex_bucket.id}.s3-website.${aws_s3_bucket.alex_bucket.region}.amazonaws.com"
}