provider "null" {

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
