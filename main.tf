provider "null" {

}

locals {
  myfavorites = {
    name = "Apple"
  }
}

resource "null_resource" "fruit" {
  triggers = {
    name  = local.myfavorites.name
    color = "Red"
    price = 150
  }
}
