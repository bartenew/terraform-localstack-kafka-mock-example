resource "random_pet" "this" {
  length = 2
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.20.0"

  function_name = "${random_pet.this.id}-lambda-dynamodb-kafka"
  handler       = "main.lambda_handler"
  runtime       = "python3.12"
  publish       = true

  # Non-VPC Kafka Source
  event_source_mapping = {
    kafka = {
      batch_size        = 1
      starting_position = "TRIM_HORIZON"
      topics            = var.topics
      self_managed_event_source = [
        {
          endpoints = {
            KAFKA_BOOTSTRAP_SERVERS = var.kafka_bootstrap_servers
          }
        }
      ]
      source_access_configuration = [
        {
          type = "SASL_SCRAM_512_AUTH"
          uri  = aws_secretsmanager_secret.kafka_basic_auth.arn
        }
      ]
    }
  }

  source_path = "${path.module}/src"
  environment_variables = {
    DYNAMODB_TABLE = module.dynamodb_table.dynamodb_table_id
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb_rw = {
      effect = "Allow",
      actions = [
        "dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem", "dynamodb:DeleteItem"
      ],
      resources = [
        module.dynamodb_table.dynamodb_table_arn
      ]
    }
    secret = {
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret" # you'll likely need KMS permissions as secrets often encrypted by custom keys
      ]
      resources = [aws_secretsmanager_secret.kafka_basic_auth.arn]
    }
  }

}
