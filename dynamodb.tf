module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 4.2.0"

  name         = "building-permits"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "permit_id"
  range_key    = "applicant_name"
  attributes = [
    {
      name = "permit_id"
      type = "S"

    },
    {
      name = "applicant_name"
      type = "S"
    }
  ]
}