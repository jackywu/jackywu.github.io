---

layout: post   
title:  SaltStack proxy minion调研  
category: articles  
tags: [saltstack, proxy, minion]  
author: JackyWu  
comments: true  

---

# 1. 简介

Salt Minion Proxy 存在的意义

> 很多设备（例如手机，交换机，路由器）上无法安装Salt Minion，使用Minion Proxy机制就可以管理这些设备，并且在Master看来，每个设备都是一样的Minion，提供一些统一的接口。

参考 [Salt Proxy Minion](https://docs.saltstack.com/en/latest/topics/proxyminion/index.html)

## 1.1. 原理架构图

![架构图](https://docs.saltstack.com/en/latest/_images/proxy_minions.png)

# 2. 测试

使用官方的rest_sample测试。代码路径在salt-contrib：<https://github.com/saltstack/salt-contrib> 源码的proxyminion_rest_example目录下。

1. 安装bottle，argparse等模块
2. 启动该 rest 接口服务(proxyminion_rest_examplem目录下)：`python rest.py --address  192.168.33.20 --port 8888`
3. /etc/salt/proxy里添加master的地址：`master: <master ip>`
4. 配置Pillar：top.sls

    {% highlight  yaml %}
        
        #  
        base:
          'p8888':
            - p8888    
    
    {% endhighlight %} 

5. 配置pillar：p8888.sls

    {% highlight  yaml %}
        
        #      
        proxy:
          proxytype: rest_sample
          url: http://<IP your REST listens on>:port
    
    {% endhighlight %}   

6. 启动proxy进程：`salt-proxy --proxyid=p8888 -l debug`， salt-proxy脚本在salt github：<git@github.com:saltstack/salt.git>源码目录的script目录下找到了, yum安装了2015.8版本后居然没有。
7. 命令输出

    {% highlight  text %}  
    
        #
        [root@master pillar]# salt 'p8888' test.ping
        p8888:
            True
            
        [root@master pillar]# salt 'p8888' grains.item server_id
        p8888:
            ----------
            server_id:
                244897941
    
    {% endhighlight %} 

# 3. 开发

核心点是：参考规范，实现相应的接口。

开发手册

1. [Salt Proxy Minion End-To-End Example](https://docs.saltstack.com/en/latest/topics/proxyminion/demo.html)
2. [Salt Proxy Minion Ssh End-To-End Example](https://docs.saltstack.com/en/latest/topics/proxyminion/ssh.html)

# 4. 其他参考资料

1. [grains获取的命令手册](https://docs.saltstack.com/en/latest/topics/targeting/grains.html)
1. [proxy-minion](http://devopstarter.info/saltstack-xue-xi-zhi-proxy-minion/)

