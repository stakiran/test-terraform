provider "null" {

}

variable name {
  type = string
}

variable age {
  type = number
}

resource "null_resource" "person" {
  triggers = {
    name = var.name
    age  = var.age
  }
}

locals {
  isOzisan       = var.age >= 35 ? 1 : 0
  isNotOzisanYet = var.age <= 30 ? 1 : 0
}

resource "null_resource" "おじさんですね" {
  count = local.isOzisan
  triggers = {
    name = var.name
    age  = var.age
  }
}

resource "null_resource" "まだおじさんではない" {
  count = local.isNotOzisanYet
  triggers = {
    name = var.name
    age  = var.age
  }
}
