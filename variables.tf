variable "kafka_bootstrap_servers" {
  type = string
}

variable "topics" {
  type    = list(string)
  default = ["building_permits"]
}