provider "null" {

}

resource "null_resource" "a-san" {
  triggers = {
    name  = "A taroh"
    weight = 75
  }
}
