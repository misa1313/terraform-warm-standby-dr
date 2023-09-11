##########################################################################
# S3 bucket for config files.
##########################################################################

resource "aws_s3_bucket" "apache-bucket-07" {
  bucket = "apache-bucket-07"

  tags = {
    Name        = "apache-bucket-07"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "ansible-playbook" {
  bucket = aws_s3_bucket.apache-bucket-07.id
  key    = "setup-play.yaml"
  source = "../setup-play.yaml"
}

resource "aws_s3_object" "apache-index" {
  bucket = aws_s3_bucket.apache-bucket-07.id
  key    = "index.html"
  source = "../index.html"
}

resource "aws_s3_object" "config_json" {
  bucket = aws_s3_bucket.apache-bucket-07.id
  key    = "config.json"
  source = "../config.json"
}
