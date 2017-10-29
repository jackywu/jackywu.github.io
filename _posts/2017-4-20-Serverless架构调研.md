---
layout: post
title: Serverless架构调研
category: articles
tags: [Serverless,PaaS,BaaS,FaaS,调研]
author: JackyWu
comments: true

---



# 概念

Serverless是一种技术架构。该技术的意义是：站在开发者的角度，自己不再关心IaaS层的基础设施的购买、运维、配置，也不关心自己应用的配置、部署、高可用这些PaaS层的东西，而是专注于实现业务逻辑的核心代码，其他的东西全部借助于公有云提供的服务实现。这种架构里，开发者自己并不接触Server，所以有了Serverless这个词。该模式下，开发者的效率是最高的，基本是100%的核心业务+0的业务支撑，而传统的IaaS架构里，我们在用20%的时间开发核心业务 + 80%的时间提供周边业务支撑。  



Serverless的技术最早来自于AWS在2014年推出的Lambda服务，该服务目前支持Javascript, Python和JVM系语言(Java、Clojure、Scala等)。

# 技术原理

Serverless架构里使用到了两种技术：

- BaaS：Backend as a Service，如AWS RDS。BaaS可以认为是PaaS中提供纯服务的那部分Service。
- FaaS：Function as a Service，如AWS Lambda。

FaaS中的Function就是我们需要100%专注的核心业务。Function又是由事件Event驱动的，再结合上公有云提供的BaaS的服务，我们就能实现出一套完整的业务架构。

{% highlight text %}

```
           +--------+        +--------+        +--------+
  Request  |        | Event  |        |        |        |
---------->|  BaaS  |------->|Function|------->|  BaaS  |
           |        |        |        |        |        |
           +--------+        +--------+        +--------+
```

{% endhighlight %}

FaaS的核心是

- 我们开发核心业务代码Function，FaaS包含了运行核心代码的一切必要条件。
- Function通过Event得到触发，Event由FaaS框架定义。
- Function生命周期短，随时创建，运行完就销毁。如AWS的Lambda最长运行时间是5分钟。
- Function代码必须做到完全无状态。
- FaaS负责水平扩展问题。

# 优势

- 让开发者只专注于自己的核心业务，极大提升开发效率，直接推动了一种NoOps的团队模式的发展。
- 每个Function在独立的进程中运行，且完全无状态，FaaS自动负责水平扩展。
- 大量节省成本，我们只为Function运行时间付费。

# 劣势/局限

- 受到Event触发事，FaaS才创建出新进程来服务，这里有启动时延。
- Serverless架构无法用于极高并发环境，该环境下进程的创建和销毁代价太高。
- Function运行时间受限，且无法常驻内存。
- Function完全无状态，需要借助外部服务才能实现状态共享，提升架构复杂度。
- 极大依赖厂商的BaaS服务，且各厂商的BaaS服务接口不同，导致迁移困难。
- 集成测试困难，调试困难，监控困难。

# Serverless架构原则

- Serverless架构是SOA概念的自然延伸，按照特性的需求编写特定的函数。
- 编写单一用途的无状态函数，让测试更加容易，让后期灵活编排成复杂服务更加容易。
- 最灵活、最强大的无服务器设计是事件驱动型的，在合适的情况下，构建事件驱动的、基于推送的系统常常有利于降低成本和系统复杂性。
- 创建更强大的前端。数据签名的令牌让前端可以与不同的服务直接通信，从而让函数的执行尽可能快，可以提升性能，降低成本。
- 尽量使用第三方BaaS服务减少核心代码的复杂度。

# 应用场景

由上述的优势和劣势，可见Serverless适用于“简单应用后端架构”，而不适用于“大型复杂应用后端架构”。在一个大型应用架构中，我们可以将其中无状态，事件触发的业务拆成Serverless架构，让他成为复杂应用架构的一种有效补充。

# 市场格局



- [AWS的Lambda服务](https://aws.amazon.com/cn/lambda/)
- [Google Cloud Functions](https://cloud.google.com/functions/)
- [Iron.io](https://www.iron.io/)
- [IBM的OpenWhisk](https://www.ibm.com/cloud-computing/bluemix/zh/openwhisk)
- [Serverless Framework](https://github.com/serverless/serverless)
- [Azure WebJobs](https://docs.microsoft.com/en-us/azure/app-service/web-sites-create-web-jobs)

其他项目

- [GitHub - anaibol/awesome-serverless: A curated list of awesome services, solutions and resources for serverless / nobackend applications.](https://github.com/anaibol/awesome-serverless)
- [Fission](https://github.com/fission/fission): 运行在Kubernetes上的Serverless架构
- [OpenLambda](https://github.com/open-lambda/open-lambda)



# 参考资料

- [Serverless架构综述 - DockOne.io](https://www.instapaper.com/read/973303695)
- [Serverless，后端小程序的未来](https://www.instapaper.com/read/973303607)
- [2017年会是Serverless爆发之年吗？](https://www.instapaper.com/read/973305579)
- [The Twelve-Factor App （简体中文）](https://12factor.net/zh_cn/)
- [Get functional 5 open source frameworks for serverless computing](https://www.infoworld.com/article/3193119/open-source-tools/get-functional-5-open-source-frameworks-for-serverless-computing.html)

