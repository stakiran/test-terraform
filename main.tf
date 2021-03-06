provider "null" {

}

variable users {
  default = {
    A = {
      age = 13
    }
    B = {
      age = 26
    }
  }
}

resource "null_resource" "user" {
  for_each = var.users

  triggers = {
    name = "${each.key}さん"
    age  = each.value.age
  }
}

resource "null_resource" "A" {
  triggers = {
    name = "Aさん"
    age  = 13
  }
}

resource "null_resource" "B" {
  triggers = {
    name = "Bさん"
    age  = 26
  }
}
