terraform { # this important for tf test to inject provider from the test suite
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.80.1"
    }
  }
}
resource "null_resource" "start_redpanda" {

  provisioner "local-exec" {
    command     = "docker compose up -d && sleep 5"
    working_dir = path.module
  }
  provisioner "local-exec" {
    when        = destroy
    command     = "docker compose down"
    working_dir = path.module
  }
}

module "lambda" {
  depends_on              = [null_resource.start_redpanda]
  source                  = "../../"
  kafka_bootstrap_servers = "redpanda:9092" # just like the name of docker-compose service
}
