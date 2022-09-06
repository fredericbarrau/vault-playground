provider "vault" {
  address = "http://127.0.0.1:8200"
}
module "configuration" {
  source          = "../../modules/configuration"
  kubernetes_host = var.kubernetes_host
}
