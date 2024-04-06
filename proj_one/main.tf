# 1.	Create an S3 bucket for the Terraform remote state file
provider "aws" {
  region  = "ap-southeast-1"
}

terraform {  
    backend "s3" {
        bucket         = "bucket-name"
        encrypt        = true
        key            = "terraform.tfstate"    
        region         = "region"
        dynamodb_table = "dynamodbtable-name"
    }
}