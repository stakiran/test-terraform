variable "jpname" {
  type = string
}

variable "color" {
  type = string
}

variable "price" {
  type = number
}

resource "null_resource" "fruit" {
  triggers = {
    jpname = var.jpname
    color  = var.color
    price  = var.price
  }
}
