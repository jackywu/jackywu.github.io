---

layout: post   
title: SaltStack Multiple Master  
category: articles  
tags: [saltstack, master]  
author: JackyWu  
comments: true  

---

# 1. Salt Minion连接多Master

Salt Minion可以同时有多个Master，一旦连住就会保持长连接，并且会不断检测Master是否存活，然后重连。

多Master的连接场景有2种：

1. Hot connect模式：Minion同时连接多个Master，并且保持长连接。
2. Failover模式：Minion从中选择一个Master连接，一旦连住就保持长连接，但不会继续连接其他Master。只有发现当前Master故障时，才会去连接下一个Master。

有几个salt minion配置文件中的重要参数


{% highlight  text %}

    #
    master_type: str or failover //多master模式时热连接模式还是单连接failover模式
    random_master: True/False    //按照顺序选择master还是，随机选，在新版本里参数名改成了master_shuffle
    master_alive_check: 5        //在长链接里检查Master是否存活，若不存活，则重连
    auth_timeout: 2              //连接时的timeout时间
    auth_tries: 2                //连接失败的重试次数
    retry_dns: 5                 //由于上一次域名解析失败导致连接master失败的话，等待x秒再发起域名解析master去重连

{% endhighlight %} 



## 1.1. Hot Connect模式下的参数配置

原则：快速连接，多次稍长间隔重试

{% highlight  text %}

    #
    master_type: str 
    random_master: False    //这样主Master按照顺序可以先被连接
    master_alive_check: 10         
    auth_timeout: 2              
    auth_tries: 3                
    retry_dns: 5                 


{% endhighlight %} 


## 1.2. Failover模式下的参数配置

{% highlight  text %}

    #
    master_type: failover
    random_master: False    //这样主Master按照顺序可以先被连接
    master_alive_check: 10         
    auth_timeout: 2              
    auth_tries: 3                
    retry_dns: 5                 


{% endhighlight %} 

# 2. Multiple Master和大规模Minion场景下的性能调优

master和minion认证过程中计算signature的步骤时非常消耗CPU的，可以提前计算好master_pubkey_signature来进行优化。
参考 [Performance Tuning](https://docs.saltstack.com/en/2015.5/topics/tutorials/multimaster_pki.html#performance-tuning)

# 其他参考资料

- [官网 Multi Master Tutorial](https://docs.saltstack.com/en/latest/topics/tutorials/multimaster.html)
- [Multi-Master-Pki Tutorial With Failover](https://docs.saltstack.com/en/2015.5/topics/tutorials/multimaster_pki.html)
- [saltstack:multi-master configuration](http://www.cnblogs.com/silenceli/p/3387398.html)
- [【翻译】如何建立多Master的SaltStack环境](http://pengyao.org/howto_configure_a_multi_master_saltstack_setup.html)
- [SaltStack: Getting redundancy and scalability with multiple master servers](http://bencane.com/2014/02/04/saltstack-getting-redundancy-and-scalability-with-multiple-master-servers/)

