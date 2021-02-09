resource "null_resource" "company" {
  triggers = {
    name         = local.personal.preferences.name
    main_product = "iPhone"
  }
}
