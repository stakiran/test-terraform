provider "github" {

}

resource "github_repository" "test-from-terraform" {
  name        = "test-from-terraform"
  description = "Terraform からつくってみたものです"

  // private = false
  visibility = "public"

  has_wiki     = true
  has_issues   = true
  has_projects = true
}

