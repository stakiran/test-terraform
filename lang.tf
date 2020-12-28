resource "null_resource" "study" {
}

locals {
  name = "stakiran"
  jpname = "吉良野すた"
}

output "name" {
  value = local.jpname
}
