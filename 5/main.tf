provider "null" {

}

resource "null_resource" "person" {
  triggers = {
    name = var.name
    age  = var.age
  }
}
