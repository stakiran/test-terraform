provider "null" {

}

variable name {
  type        = string
}

variable age {
  type        = number
}

resource "null_resource" "person" {
  triggers = {
    name  = var.name
    age = var.age
  }
}

resource "null_resource" "おじさんですね" {
  count = var.age >= 35 ? 1 : 0
  triggers = {
    name  = var.name
    age = var.age
  }
}

resource "null_resource" "まだおじさんではない" {
  count = var.age <= 30 ? 1 : 0
  triggers = {
    name  = var.name
    age = var.age
  }
}
