
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.44.0"
    }
  }
}
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