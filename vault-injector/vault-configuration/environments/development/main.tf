provider "vault" {}
module "configuration" {
  source             = "../../modules/configuration"
  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = var.kubernetes_ca_cert
}
