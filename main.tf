provider "null" {

}

resource "null_resource" "apple" {
  triggers = {
    jpname = "りんご"
    color  = "red"
    price  = 300
  }
}

module "lemon" {
  source = "./modules/fruit"

  jpname = "レモン"
  color  = "yellow"
  price  = 95
}

output "var1" {
  value = null_resource.apple.triggers.color
}
