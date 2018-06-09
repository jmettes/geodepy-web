resource "aws_s3_bucket" "source_bucket" {
    bucket = "${local.name_tag_prefix}-frontend-source"
    acl = "public-read"
    policy = <<EOF
{
  "Id": "bucket_policy_site",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "bucket_policy_site_main",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.name_tag_prefix}-frontend-source/*",
      "Principal": "*"
    }
  ]
}
EOF
    website {
        index_document = "index.html"
    }
    tags {
    }
    force_destroy = true
}

output "source_bucket" {
  value = "${aws_s3_bucket.source_bucket.id}"
}

output "website" {
  value = "${aws_s3_bucket.source_bucket.website_endpoint}"
}
