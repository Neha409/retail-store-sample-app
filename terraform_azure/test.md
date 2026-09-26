argocd_admin_password_command = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
kube_config_command = "az aks get-credentials --resource-group myapp-rg --name myapp-aks-wb2i3 --overwrite-existing"
kube_config_raw = <sensitive>
nginx_ingress_ip_command = "kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
resource_group_name = "myapp-rg"