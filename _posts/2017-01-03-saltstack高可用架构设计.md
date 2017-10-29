---
layout: post
title:  saltstack高可用架构设计
category: articles
tags: [saltstack,HA]
author: JackyWu
comments: true

---

### Contact me

![](/images/weixin-pic-jackywu.jpg)

## 一、待解决问题

1. Master负责的Minion数量过多，并发消息量过大，导致Master过载而丢消息

2. 如果使用MultiMaster模式，会导致Minion跟Master跨机房通信

3. 如果使用Syndic会导致MOM(MasterOfMaster)无法感知存活的Minion

4. Salt-API没有身份鉴定，命令审核功能

   ​

## 二、解决方案

### MultiMaster架构

为了解决如上问题，根据官方[Saltstack的高可用架构](https://docs.saltstack.com/en/latest/topics/highavailability/index.html)的描述，我们选择了MultiMaster-With-Failover模式作为基础，在此基础之上扩展出了MultiMaster-With-Failover-With-Proxy模式。此处我们将Syndic替换成自研的`Proxy`。

![salt高可用架构](/images/saltstack/salt高可用架构.png)

我们的架构中，同一个机房部署多台Master，Minion使用`master_type: failover`和  `master_shuffle=True`的方式随机连接本机房其中一个Master，并且让Minion根据`master_alive_interval` 定期检查所连Master的健康状态，发现当前Master故障后会自动连接其他Master实现Failover。

优点：该方案可以使得

1. Minion跟Master之间的通信不跨机房
2. 一个Minion同时只跟一个Master保持连接，避免了重复接收命令的问题，并且高可用
3. 通过水平扩展Master，使得Master和Minion的配比保持在一个合理的范围，分散了单个Master的压力



### 开发Proxy

为了实现如上的架构，我们还需要开发Proxy来替换Syndic，对Proxy的需求有

1. 部署在Master机器上，负责从消息管道Subscribe消息，匹配规则，匹配通过后转给本地的Master进而发送给Minion，不匹配则丢弃，规则有
   1. 如果使用minion id精确匹配，那么Minion需要与本Master直接相连
   2. 如果使用list、glob、regex等方式，则对连接本Master的Minion进行匹配计算，需要至少匹配到一个
   3. 待续
2. 将Minion返回给Master的执行结果写入中心的Database保存
3. 定期（如每10s）向Connector汇报本机Master所连接的Minion的连通性状态


优点：该方案可以使得

1. 尽可能减少无用命令的下发
2. 全局知晓Minion的连通性
3. 通过MQ将Connector跟Proxy进行解耦，Proxy也可以水平扩展，Connector也可以

### 开发Connector

对Connector的需求有

1. 以HTTP协议接收用户请求的命令，兼容原生Salt-API的接口格式
   1. 支持高并发
   2. 支持用户身份鉴定
   3. 支持调用方IP白名单
   4. 支持命令内容检查
   5. 支持限流，1分钟内调用不超过N次，可配
   6. 除了特权用户，其他用户匹配Minion不能用`*`，批量不超过30，可配
2. 将命令Publish到MQ中，等待Proxy来Subscribe
3. 接收来自所有Proxy的Minion连通状态数据，维护在状态表里，对于精确匹配和List匹配Minion id的API调用，如果其中有失联的Minion，根据用户参数决定是拒绝请求还是接受，如接受，则在返回结果里注明失联




优点：该方案使得

1. Connector可以水平扩展
2. Connector提供了更强的认证和审查机制


### 如何从日志中找出问题？

通过Flume将Proxy日志，Master日志，Minion日志，Connector日志统一采集汇总到ES

1. 被动模式：实时将错误日志通过邮件发送给开发人员进行问题排查
2. 主动模式：开发人员通过Kibana过滤错误日志进行问题排查

