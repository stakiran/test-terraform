provider "null" {

}

resource "null_resource" "apple" {
  triggers = {
    jpname = "りんご"
    color  = "red"
    price  = 300
  }
}

output "var1" {
  value = null_resource.apple.triggers.color
}
