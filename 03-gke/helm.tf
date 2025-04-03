
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"

  create_namespace = true

  values = [
    <<EOF
controller:
  publishService:
    enabled: true
  service:
    annotations:
      cloud.google.com/load-balancer-type: "External"
EOF
  ]
}