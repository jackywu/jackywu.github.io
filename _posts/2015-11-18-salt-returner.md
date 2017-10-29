---

layout: post   
title: SaltStack Returner调研  
category: articles  
tags: [saltstack, event, returner]  
author: JackyWu  
comments: true  

---

# 1. Salt Returner

概念解释returner

>minion接收到master发来的指令，将执行结果直接通过returner写入到其他地点。

作用

1. 可以直接将结果写入数据库，消息队列等，不需要返回给master，将消息流的处理灵活化了。
2. 通过给master发送异步的消息任务，结合returner，就可以利用salt的架构实现异步的任务。


## 1.1. MySQL Returner

要使用MySQL Returner的依赖

* 安装MySQL-python的python module，否则该Returner不会启用，而且没有报错

{% highlight  python %}

    # 见源码salt/returners/mysql.py
    try:
        import MySQLdb
        HAS_MYSQL = True
    except ImportError:
        HAS_MYSQL = False

{% endhighlight %} 

参考

- [官网RETURNERS](https://docs.saltstack.com/en/latest/ref/returners/index.html)
- [Saltstack系列（五）Saltstack returner](http://blog.cunss.com/?p=282)

## 1.2. 其他Returner

参考 [Full list of builtin returners](https://docs.saltstack.com/en/latest/ref/returners/all/index.html#all-salt-returners)


## 1.3. Returner的应用场景

1. 用Returner来做临时的监控采集器, 链接 [用Saltstack的returners实现监控及执行结果回调](http://rfyiamcool.blog.51cto.com/1030776/1264438)，[不同链接同一篇文章](http://rfyiamcool.blog.51cto.com/1030776/1264438)
2. [salt自动部署zabbix，并且自动添加服务器角色和zabbix模板](http://yoyolive.com/saltstack/2014/06/16/saltstack-zabbix-monitor.html)
3. [用Saltstack的 returner modules和grains实现实时监控平台](http://rfyiamcool.blog.51cto.com/1030776/1266437)
4. [利用salt local file returner 和 fluent采集数据](http://bbs.linuxtone.org/thread-24213-1-1.html)

# 2. Job Management

## 2.1. Job Cache

关于job-cache的解释

> master记录job和minion的返回结果的地方。
> 
> 默认的[job cache](https://docs.saltstack.com/en/develop/topics/jobs/job_cache.html)路径在linux上位置是：/var/cache/salt/master/jobs
> 


{% highlight  text %}

    #
    [root@master jobs]# pwd
    /var/cache/salt/master/jobs
    [root@master jobs]# tree 17/
    17/
    └── 96e856a660a104fdd94d6270642917
        ├── client.jacky.com
        │   └── return.p
        └── jid
        
{% endhighlight %} 

处理job cache的方式有两种

1. 如上存储在master本地目录是第一种
2. 第二种是存储在外部系统，又分为两种，优缺点参考 [这里](https://salt.readthedocs.org/en/stable/topics/jobs/external_cache.html)
    3. 由master来写数据，由master conf中的master_job_cache来控制
    4. 由minion来写数据，由minion conf中的ext_job_cache来控制


参考

- [官网JOB MANAGEMENT](https://docs.saltstack.com/en/latest/topics/jobs/index.html)
- [MANAGING THE JOB CACHE](https://docs.saltstack.com/en/develop/topics/jobs/job_cache.html)
- [STORING JOB RESULTS IN AN EXTERNAL SYSTEM](https://salt.readthedocs.org/en/stable/topics/jobs/external_cache.html)



# 3. 其他参考资料

- [job management](https://docs.saltstack.com/en/latest/topics/jobs/index.html)
- [使用Scheduling Job](https://docs.saltstack.com/en/latest/topics/jobs/index.html#scheduling-jobs)
- [master 配置手册](https://docs.saltstack.com/en/latest/ref/configuration/master.html#master-job-cache)
- [Salt Master外部Job Cache配置](http://pengyao.org/saltstack-master-external-job-cache.html)
