terraform {
  backend "s3" {
    # Replace these placeholders only when configuring a real AWS backend.
    bucket         = "REPLACE_WITH_TERRAFORM_STATE_BUCKET"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "REPLACE_WITH_TERRAFORM_LOCK_TABLE"
    encrypt        = true
  }
}
