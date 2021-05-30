## S3 bucket for Static Website
resource "aws_s3_bucket" "hopper_static_s3" {
  bucket = var.website_domain
  acl    = "public-read"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": [ "arn:aws:s3:::${var.website_domain}/*"]
        }
    ]
}
  POLICY

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

## Local value for upload all website data in path (Mass Upload)
locals {
  src_dir = var.website_path
  content_type_map = {
    html = "text/html",
    js   = "application/javascript",
    css  = "text/css",
    svg  = "image/svg+xml",
    jpg  = "image/jpeg",
    ico  = "image/x-icon",
    png  = "image/png",
    gif  = "image/gif",
    pdf  = "application/pdf"
  }
}

## S3 object upload (HTML)
resource "aws_s3_bucket_object" "hopper" {
  for_each     = fileset(local.src_dir, "**")
  bucket       = aws_s3_bucket.hopper_static_s3.bucket
  key          = each.value
  source       = "${local.src_dir}/${each.value}"
  content_type = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension, "application/octet-stream")
}