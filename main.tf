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
