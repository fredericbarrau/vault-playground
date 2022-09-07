variable "kubernetes_host" {
  type        = string
  default     = "https://kubernetes:39217"
  description = "Should be picked using kubectl cluster-info. The domain should exists in DNS and be in the PEM cert below. If running on a minikube cluster, add 127.0.0.1 kubernetes to your /etc/hosts"

}

# Should be picked using kubectl cluster-info
# Various way to get this: 
# If already connected using kubectl:
# $ kubectl config view --raw -o json | jq -r '.clusters[0].cluster."certificate-authority-data"' | tr -d '"' | base64 --decode
# 
# Or, using an admin access to the cluster:
# kubectl get secret -o jsonpath="{.items[?(@.type==\"kubernetes.io/service-account-token\")].data['ca\.crt']}" | base64 --decode 
#
variable "kubernetes_ca_cert" {
  type    = string
  default = <<EOF
-----BEGIN CERTIFICATE-----
MIIC/jCCAeagAwIBAgIBADANBgkqhkiG9w0BAQsFADAVMRMwEQYDVQQDEwprdWJl
cm5ldGVzMB4XDTIyMDcwODA5MjUzNloXDTMyMDcwNTA5MjUzNlowFTETMBEGA1UE
AxMKa3ViZXJuZXRlczCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMx8
6T6KHDGZYKr2JO4Ia20fZ2cuVNXgRdJQ/QoZhlARHJBiIqyKvYFyMThvf7G8HiGx
SmsStOVuMg+Rx5KhGWsOOOyiBy2dFLKrfnEBQgEX2Q+cgGg9NAqZzzG+zS5nqT8l
sbELg81cfygNwE7SitxCY+nqMHnthZI6pSYf+JGexAswOgIJUFYZskZ9XNiL2n/Z
W9/QveuDrdVMyfRzmMa8QqTxQR3VVprvVLz/O5HYyaGiA2YpIX8hvHpOFO8lZAHJ
J0PV/WOlP29DoSX3AL5AjQwhc8vmcyr4c4xfzCLfYPiDoHnU/i5KvzVaNnssEGkP
jB91V+iaNyQX0RixvnsCAwEAAaNZMFcwDgYDVR0PAQH/BAQDAgKkMA8GA1UdEwEB
/wQFMAMBAf8wHQYDVR0OBBYEFElwb/kVT+Or+NoroqE5OedyrWisMBUGA1UdEQQO
MAyCCmt1YmVybmV0ZXMwDQYJKoZIhvcNAQELBQADggEBAH7wBL7QY75bFzokQD7b
EeqI33lRy6lVozwBma3TtKSXAPeKGMZw+bUoHWSUCcyPU2j5CRGSuJ9EiToS3sTL
88YuNrNGHd1/wxKFinQGA8PCt7uy/5Fz9A/EsGyCuI9vvCuca4SrKJIZDzc2lttz
sHCVLzelOFQypBuPipcqS7k4znRqKo/4LNKsL0Y3Lv3TgwHFqbznyzgGbyJuMC6Y
XahbRBpkf649BQTJKFvXTV4SO1Co4oEO5Ntn94a7+RGORakdO4QEoi0FE9nuLfN5
Z5AApVNNf9XRRAF6z1BqIIpb+fj+P4GZ8f21k057D/DFopirHsqgSDQ4eOxyKkMW
wiY=
-----END CERTIFICATE-----
EOF

}
