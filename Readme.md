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
nginx-ingress-controller 建立完成後 svc 那邊顯示的load balancer 

的 endpoint請幫我update到ingress.yaml內的spec.rules[0].host, 替換掉這邊的值
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
    - rolearn: arn:aws:iam::{AWS_ACCOUNT}:role/example  # 幫我新增這幾行, 
      username: example                                 # role default我使用example
      groups:                                           #
      - system:masters                                  #
---
```

#### Build Result

![CodeBuild Result](https://github.com/ashchang/gama-hw/blob/main/codebuild-result.png)

#### Final Result

![Final Result](https://github.com/ashchang/gama-hw/blob/main/final-result.png)

---

## About Q5 & Q6
---
Q5:

以目前的Q4提供的提供的「簡單的CI/CD pipeline」是除了CI part build image那段以外, CD的部分全部都要打掉重做, 可以使用ARGOCD來達成, ARGOCD可以自動去掃repo的image變更然後deploy甚至回寫版號
CI那邊需要做的調整是 在gitlab, github上針對題目所述的特定Branch去觸發CI流程打包image然後push到image repository即可;

根據以前實作這段的經驗 RD 從feature branch開merge request 到dev後, 就會觸發unittest, 合併後則會觸發image packaging的動作, push到ECR後, argocd掃到有新的image被推上去後就會抓下來自己deploy到各環境,

如果是prd環境的話 argocd可以把autosync關掉改為人工去deploy

Q6:
我認為要識別是否為terraform建立的資源可以透過aws tags去實踐, 這點可以針對需求再進一步討論

---
因為目前工作繁忙, 幾乎都是使用零碎的時間處理, 改進跟完善的空間還很大, 但應該大部分都有符合題目的要求, 如果有問題或是想討論的歡迎來電討論, 電話請找HR拿, 謝謝
