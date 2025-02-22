## Demo only, you should not keep secrets like this in TF

resource "aws_secretsmanager_secret" "kafka_basic_auth" {
  name = "kafka-basic-auth"
}

resource "aws_secretsmanager_secret_version" "kafka_basic_auth" {
  secret_id = aws_secretsmanager_secret.kafka_basic_auth.id
  secret_string = jsonencode({
    username = "kafka-user",
    password = "kafka-password"
  })
}