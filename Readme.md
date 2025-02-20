### Install Terraform
---

dir: /terraform/eks/
```shell
terraform init
terraform apply
```
如果要分批 先建立vpc > iam & eks & alb_controller > codebuild
```shell
aws eks --region us-east-1 update-kubeconfig --name test --profile ${profile}
```

### Install App
---
dir: /helm/

```shell
helm install nginx . -f values.yaml
helm install nginx . -f 
```

### Install nginx controller and ingress
dir: /

```shell
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress-controller ingress-nginx/ingress-nginx -f nginx-value.yaml
```
nginx-ingress-controller 建立完成後 svc 那邊顯示的load balancer endpoint請幫我update到ingress.yaml內的spec.rules[0].host, 替換掉這邊的值
```shell
kubectl apply -f ingress.yaml
```

### Kubernetes allow codebuild access
---
這邊使用的docker image存放目錄是我自己個人的 

terraform variables.tf內有兩個變數是DOCKER_USER & DOCKER_PASS請替換為自己的

```shell
kubectl edit -n kube-system configmap/aws-auth
```

```yaml
---
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::{AWS_ACCOUNT}:role/{ROLE_NAME}
      username: system:node:{{EC2PrivateDNSName}}
    - rolearn: arn:aws:iam::{AWS_ACCOUNT}:role/example  # 幫我新增這幾行, role default我使用example
      username: example                                 #
      groups:                                           #
      - system:masters                                  #
---

