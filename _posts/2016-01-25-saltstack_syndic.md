---

layout: post   
title: SaltStack Syndic   
category: articles  
tags: [saltstack, syndic]  
author: JackyWu  
comments: true  

---


## 简介

syndic是master和minion之间的一个代理层, 用来转发来自master的指令给minion. syndic可以扩展整个saltstack的架构规模.

## 组成

一个syndic node包含2个组件

1. a salt-syndic daemon
1. a salt-master daemon

## 配置

CONFIGURING THE SYNDIC

- The id option is used by the salt-syndic daemon to identify with the Master node and if unset will default to the hostname or IP address of the Syndic just as with a Minion.

CONFIGURING THE SYNDIC WITH MULTIMASTER

- If the master_id value is set in the master config on the higher level masters, job results are returned to the master that originated the request in a best effort fashion. Events/jobs without a master_id are returned to any available master.


## 命令和结果的传递

详情参考 [这里](https://docs.saltstack.com/en/latest/topics/topology/syndic.html#topology)

## SYNDIC WAIT

- syndic_wait: master等待syndic返回结果的时间, 默认是5s. 该选项在发送指令的master上`/etc/salt/master`文件里配置.   

## Debug执行日志

发送一条指令 

    [root@master vagrant]# salt 'client.jacky.com' cmd.run 'uptime'
    client.jacky.com:
         11:43:21 up  2:56,  1 user,  load average: 0.00, 0.00, 0.00

**Master**

![](/images/saltstack/master.png)

**Syndic**

![](/images/saltstack/syndic.png)

**Minion**

![](/images/saltstack/minion.png)


## 源码分析

salt代码版本是`2015.8`.

Syndic的源码在`/salt/salt/minion.py`中`class Syndic`. 核心主逻辑在`tune_in`方法.



{% highlight python linenos %}

    .
    # Syndic Tune In
    def tune_in(self, start=True):
        '''
        Lock onto the publisher. This is the main event loop for the syndic
        '''
        signal.signal(signal.SIGTERM, self.clean_die)
        log.debug('Syndic {0!r} trying to tune in'.format(self.opts['id']))

        if start:
            self.sync_connect_master() # 以'sub'的角色连接到master的pub端口.

        # Instantiate the local client # 实例化LocalClient对象
        self.local = salt.client.get_local_client(self.opts['_minion_conf_file'])
        self.local.event.subscribe('')
        self.local.opts['interface'] = self._syndic_interface

        # add handler to subscriber
        self.pub_channel.on_recv(self._process_cmd_socket) # 在连接上添加回调函数, 只要接到新命令就解密, 并且转发给local的master.
                                                           # `_process_cmd_socket`调用了`_handle_decoded_payload`, 又调用了`self.syndic_cmd(data)`
                                                           # 在`syndic_cmd`方法里调用了`self.local.pub`将从上级Master接收的指令通过LocalClient转发给本地
                                                           # 的Master.

        # register the event sub to the poller
        self._reset_event_aggregation()
        self.local_event_stream = zmq.eventloop.zmqstream.ZMQStream(self.local.event.sub, io_loop=self.io_loop)
        self.local_event_stream.on_recv(self._process_event) # 监听本地的event pub接口获取minion的命令执行结果

        # forward events every syndic_event_forward_timeout
        self.forward_events = tornado.ioloop.PeriodicCallback(self._forward_events, # 通过`_forward_events`方法调用`self._return_pub`将结果转发回上级Master.
                                                              self.opts['syndic_event_forward_timeout'] * 1000,
                                                              io_loop=self.io_loop)
        self.forward_events.start() 

        # Send an event to the master that the minion is live
        self._fire_master_syndic_start()

        # Make sure to gracefully handle SIGUSR1
        enable_sigusr1_handler()

        if start:
            self.io_loop.start() 

{% endhighlight %}

## 任务异步

提交异步任务: `salt 'client.jacky.com' cmd.run 'uptime' --async --show-jid`

执行结果异步化接收的方法有如下几种, 参考 [这里](https://docs.saltstack.com/en/latest/topics/jobs/external_cache.html)

1. Default Job Cache (大规模架构下不适合)
1. 使用 Master Job Cache(MASTER-SIDE RETURNER)
1. 使用 EXTERNAL JOB CACHE(MINION-SIDE RETURNER)

基于Syndic的架构, 将执行结果异步化可以减小最顶级Master的压力. 方法也有两种

1. 在最顶层Master(也就是MoM)使用returner
1. 在syndic的Master上使用returner

考虑到扩展性, 方法2是最合适的. 以returner为'mysql'为例, 预测到这种情况下, 多个syndic-master会同时写jid和event, 所以会碰到duplicated key的问题, 不过这种情况并不影响数据的完整性.

## 参考资料

- [Saltstack 高可用架构漫谈](http://devopstarter.info/saltstack-ha-arch/), [作者联系方式](https://github.com/Colstuwjx)
- [Salt中Syndic那点事](http://pengyao.org/salt-syndic-01.html)