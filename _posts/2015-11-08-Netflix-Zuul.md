---

layout: post   
title: Netflix Zuul调研
category: articles  
tags: [Netflix, Cloud, Wireless, Gateway]  
author: JackyWu  
comments: true  

---

## 1. 介绍

Zuul是一个缘边网关服务, 接收来自各种设备的请求转发到后端. 有如下功能:

1. 动态路由
2. 监控
3. 弹性扩展
4. 安全检查

## 2. 原理

关于Filter的核心概念

- Type
    - Pre
    - Routing
    - Post
- Error
- Execution Order
- Criteria
- Action

原理图

![Zuul Request Lifecycle](https://camo.githubusercontent.com/4eb7754152028cdebd5c09d1c6f5acc7683f0094/687474703a2f2f6e6574666c69782e6769746875622e696f2f7a75756c2f696d616765732f7a75756c2d726571756573742d6c6966656379636c652e706e67)


## 3. Zuul的使用方式

Zuul在Netflix的使用方式

![](https://camo.githubusercontent.com/5e596c573110bffb608614a09c97611107205d0d/687474703a2f2f6e6574666c69782e6769746875622e696f2f7a75756c2f696d616765732f7a75756c2d706879736963616c2d617263682e706e67)

## 4. 入门

### 4.1 Getting Start

[Getting Started](https://github.com/Netflix/zuul/wiki/Getting-Started)

Zuul使用了[Gradle](http://gradle.org/)进行build。

用Gradle进行编译的方法：


{% highlight bash %}
    
    #
    $ git clone git@github.com:Netflix/zuul.git  
    $ cd zuul/  
    $ ./gradlew build  
    清理  
    ./gradlew clean build  

{% endhighlight %}


### 4.2 从Zuul Simple Webapp入手

[zuul simple webapp](https://github.com/Netflix/zuul/wiki/zuul-simple-webapp)

### 4.3 开发Filter

[Writing Filter](https://github.com/Netflix/zuul/wiki/Writing-Filters)

## 5. 使用者

- Pivotal的Spring Cloud套件
- 携程
- Netflix 

## 6. 参考

- [Zuul-github](https://github.com/Netflix/zuul)
- [Zuul-wiki](https://github.com/Netflix/zuul/wiki)
- [Zuul原理介绍－How it works](https://github.com/Netflix/zuul/wiki/How-it-Works)
- [Zuul在Netflix的使用方式－How-We-Use-Zuul-At-Netflix](https://github.com/Netflix/zuul/wiki/How-We-Use-Zuul-At-Netflix)， [还有Netflix的blog对此的描述](http://techblog.netflix.com/2013/06/announcing-zuul-edge-service-in-cloud.html)
- [Spring Cloud 1.0 正式发布](http://www.linuxeden.com/html/news/20150320/159789.html)
- [netflix的所有开源组建的简单介绍列表](http://www.douban.com/note/489683323/)
- [Spring Cloud Github Repo](https://github.com/spring-cloud)
- [Netflix OSS](https://netflix.github.io/)：Open Source Software， 
- [如何利用Spring Cloud构建起自我修复型分布式系统](http://cloud.51cto.com/art/201505/477946_all.htm)， 其中介绍了netflix的Eureka、Ribbon、Hystrix、Zuul组件。
