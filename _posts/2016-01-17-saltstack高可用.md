---

layout: post   
title: SaltStack 高可用   
category: articles  
tags: [saltstack, ha, 高可用]  
author: JackyWu  
comments: true  

---


# 参考资料

1. [HIGH AVAILABILITY FEATURES IN SALT](https://docs.saltstack.com/en/latest/topics/highavailability/index.html)
    1. MULTIMASTER
        1. 每个master需要有相同的私钥, minion的key在每个master上单独accept.
        1. file_roots和pillar_roots里的东西, 使用外部方法在各个master上保持一致.
    1. MULTIMASTER WITH FAILOVER
        1. master_type模式为failover时代表一个minion只连接一个master. 每个master_alive_check周期都会检查当前连接是否有效, 若否就连接下一个master.
        1. master_shuffle: True可以让minion随机连接master.
    1. SYNDIC
        1. 可以在架构拓扑上扩展master的能力, 扩大集群的规模.
    1. SYNDIC WITH MULTIMASTER
        1. 让一个SYNDIC可以连接多个master, 提升冗余度.
        
1. [Saltstack 高可用架构漫谈](http://devopstarter.info/saltstack-ha-arch/)
    1. 推荐使用 Multi-Master + Multi-Syndic + Minion 的架构.
    1. ext job cache + returner 使得同步调用变成异步成为可能.
    1. 调整salt api的调用方式（从同步改成异步）, 极大的减轻Master的负载，将压力均摊到了redis cache.
    1. nginx + UWSGI 给 salt api 做负载均衡.
    1. Syndic的逻辑是接收Minion的执行结果然后返回给Master, 相当于Master下发一条命令会受到一次ddos, 这个问题需要更好的异步方案来解决.
    1. 将syndic的job event吐到了统一的外部的 redis job cache
1. [SaltConf15 - Thomas Jackson, LinkedIn - SaltStack at Web Scale…Better, Stronger, Faster](https://www.youtube.com/watch?v=qjFOY-QrW_k)
1. [salt multi-master + syndic + heartbeat构造salt高可用集群](http://www.mageyoyo.com/?p=537). 用heartbeat保证两台syndic处于冷备的高可用状态.
1. [用DNS实现高可用的multi-master架构](http://www.cnblogs.com/renolei/p/4725455.html)
1. [saltstack与docker结合构建高可用和自动发现服务](http://liuping0906.blog.51cto.com/2516248/1575975)