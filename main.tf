provider "null" {

}

module "apple" {
  source = "./modules/fruit"

  jpname = "りんご"
  color  = "red"
  price  = 300
}

module "lemon" {
  source = "./modules/fruit"

  jpname = "レモン"
  color  = "yellow"
  price  = 95
}

output "var1" {
  value = module.apple.fruit.jpname
}
