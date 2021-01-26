provider "null" {

}

locals {
  personal = {
    preferences = {
      name = "Apple"
    }
  }
}

resource "null_resource" "fruit" {
  triggers = {
    name  = local.personal.preferences.name
    color = "Red"
    price = 150
  }
}
