provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  s3_use_path_style           = false
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    cloudwatch     = "http://localhost:4566"
    logs           = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "check" {
  module {
    source = "./tests"
  }

  assert {
    condition     = output.ddb_count > 0
    error_message = "fail"
  }
}