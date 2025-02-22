data "external" "dynamodb_count" {

  program = ["bash", "-c", <<EOT
    sleep 3
    count=$(aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name building-permits --query 'Count' --output text)
    echo "{\"count\": \"$count\"}"
  EOT
  ]
}


output "ddb_count" {
  value = try(tonumber(data.external.dynamodb_count.result["count"]), 0)
}