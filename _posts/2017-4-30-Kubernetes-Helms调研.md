---
title: Kubernetes-Helms调研
category: articles
tags: [Kubernetes,helm,PaaS,调研]
author: JackyWu
---



# 一、概念

Helm是Kubernetes生态中的一个资源管理器，类似于debian上的apt和centos上的yum用来管理软件包，而Helm用来管理Kubernetes集群里运行的软件资源。

该软件资源用Chart这个概念来表述，其中包含了运行一个应用所需要的镜像、依赖和资源定义等一系列定义文件，用来描述一整套软件服务。

另外一个概念叫Release，指的是根据Chart在Kubernetes集群上运行的一个实例。在同一个集群上，一个 Chart 可以安装多次，每次安装都会创建一个新的 release。



# 二、意义

要在Kubernetes上安装配置一套复杂的service，需要编写一大堆定义文件，为了解决这些文件的重复定义和管理问题，把这些文件集成到Chart包里统一管理，提升了重用性和管理效率。

# 三、原理

Helm包含2个组件

- tiller：Server端，运行在Kubernetes集群里面，用来统一管理Chart。
- helm：客户端，用来跟tiller通信。

Chart至少需要包含两样东西：

- 包描述文件Chart.yaml
- 若干个模板，包含了Kubernetes manifest files


Repository：用于发布和存储 Chart 的仓库。



![helm架构](https://yqfile.alicdn.com/356a3bd722c6434180f1b30fb75c9822adc3c9dd.jpeg "from aliyun")

官方的架构描述可以参考 [https://docs.helm.sh/architecture/](https://docs.helm.sh/architecture/)



# 四、使用

## 1、helm的使用

安装方法参考 [这里](https://github.com/kubernetes/helm#install)

快速入门：[Quick Start Guide](https://docs.helm.sh/using_helm/#quickstart-guide)



默认情况下helm会从<gcr.io/kubernetes-helm/tiller>下载镜像安装tiller服务，然后将[https://kubernetes-charts.storage.googleapis.com](https://kubernetes-charts.storage.googleapis.com/?spm=5176.100239.blogcont159601.28.uMhvPo)作为默认的镜像下载地址，因国内无法访问"gcr.io", "storage.googleapis.com" 这些域名，所以用阿里云的镜像作为代替

```
helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.5.1 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
```

repository信息被保存在` ~/.helm/repository/repositories.yaml`。

安装tiller组件

```
helm init，安装
helm init --upgrade 安装，如果已经安装就升级
```

查询repository里所有chart

```
helm search
```

更新所有chart列表

```
helm repo update 
```

查询所有已安装的chart

```
helm list 
```

查看chart详细信息

```
helm inspect stable/mysql
```

查看chart自定义项

```
helm inspect values stable/mysql
```

查询服务列表

```
helm ls
```

查询某服务的状态

```
helm status mysql-test
```

安装mysql

```
helm install --name mysql-test stable/mysql
```

```
MySQL can be accessed via port 3306 on the following DNS name from within your cluster:
mysql-test-mysql.default.svc.cluster.local

To get your root password run:

    kubectl get secret --namespace default mysql-test-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo

To connect to your database:

1. Run an Ubuntu pod that you can use as a client:

    kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il

2. Install the mysql client:

    $ apt-get update && apt-get install mysql-client -y

3. Connect using the mysql cli, then provide your password:
    $ mysql -h mysql-test-mysql -p
```



安装nginx-ingress

```
$ helm install stable/nginx-ingress
```

```
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace default get services -o wide -w yodeling-quail-nginx-ingress-controller'

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```



社区开源的chart资源在：[https://kubeapps.com/](https://kubeapps.com/?spm=5176.100239.blogcont159601.32.uMhvPo)



# 五、开发

helm client-side plugin 开发：[helm plugins 开发手册](https://github.com/kubernetes/helm/blob/master/docs/plugins.md)，该插件在helm client端执行，插件代码不属于helm的自身代码仓库。

现有的一些插件：

- https://github.com/kubernetes/helm/blob/master/docs/related.md#helm-plugins
- https://github.com/search?q=topic%3Ahelm-plugin&type=Repositories

开发插件可以如下几个插件作为上手对象

- [helm-env](https://github.com/adamreese/helm-env)
- [helm-hello](https://github.com/jackywu/helm-hello)

模板开发参考：[Developing Templates](https://docs.helm.sh/chart_template_guide/chart_template_guide)

最佳实践：[Best Practices](https://docs.helm.sh/chart_best_practices/)



# 六、参考资料

- [利用Helm简化Kubernetes应用部署-博客-云栖社区-阿里云](https://yq.aliyun.com/articles/159601)
- [kubernetes/helm: The Kubernetes Package Manager](https://github.com/kubernetes/helm)
- [Helm Docs](https://docs.helm.sh/)
- [跟helm相关的项目](https://docs.helm.sh/related/)