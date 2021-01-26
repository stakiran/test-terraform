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

output "fruit" {
  // triggers が邪魔なので隠蔽して返す
  value = null_resource.fruit.triggers
}
