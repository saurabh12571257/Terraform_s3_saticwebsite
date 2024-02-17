terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "AKIA4VXVPIFZ3U"
  secret_key = "OYK5u6jtb9h1+wN9FPiwhLnVeO7vm6S1ip"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucketname
}

resource "aws_s3_bucket_ownership_controls" "my_bucket_owner" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "my_bucket_ACL" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.my_bucket_owner,
    aws_s3_bucket_public_access_block.my_bucket_ACL
  ]

  bucket = aws_s3_bucket.my_bucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "inec" {
  bucket = aws_s3_bucket.my_bucket.id 
  key    = "inec.html"
  source =  "inec.html"
  acl = "public-read"
  content_type = "text/html"

}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.my_bucket.id 
  key    = "error.html"
  source =  "error.html"
  acl = "public-read"
  content_type = "text/html"
  
}

resource "aws_s3_bucket_website_configuration" "website" {
    bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
    depends_on = [ aws_s3_bucket_acl.example ]

}
