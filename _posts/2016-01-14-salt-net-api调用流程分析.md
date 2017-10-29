---

layout: post   
title: Saltstack net-api 调用流程分析   
category: articles  
tags: [saltstack, api]  
author: JackyWu  
comments: true  

---

# 背景

该分析代码基于salt版本2015.5, 以下"/salt"为代码根目录.

源码路径在

{% highlight python linenos %}

    `https://github.com/saltstack/salt.git`中`/salt/netapi/rest_tornado` 

{% endhighlight %}

## 作用

通过net-api可以调用saltstack的服务, 包括执行master上的runner模块和给minion下发命令.

## 测试用例

执行指令方法为

1. 验证, 获取token
2. 发送指令

测试环境

- salt-master为 'master'
- salt-client为 'windows-client' , 'linux-client'

curl的测试模式为

```
[root@puppet pushguidepuppet]# curl -si localhost/login
    -H "Accept: application/json"
    -d username='salt'
    -d password='eAwCwXTpqoARrSxY'
    -d eauth='pam' -v
```

正常返回消息为:

```
{"return": [{"perms": ["@runner"], "start": 1433923934.308167,
"token": "a2b545d7b9147bb2880c6c1f533ed313", "expire": 1433967134.308168,
"user": "salt", "eauth": "pam"}]}
```

获取其中的token作为下次接口调用的参数上传.

curl测试为

```
curl -si "localhost/run"      -H "Accept: application/json"
    -d "token=a2b545d7b9147bb2880c6c1f533ed313"
    -v -d "client=runner" -d "fun=jobs.list_jobs"
```

整个测试不需要发布任务成功, 能调用 jobs.list_jobs 成功就行, 就可以验证api生效.

# 启动脚本

启动命令

{% highlight python linenos %}

    `/salt/pkg/rpm/salt-api`  or  `/etc/init.d/salt-api`
    `daemon --pidfile=/var/run/salt-api.pid --check salt-api /usr/bin/salt-api -d`
 
{% endhighlight %}

其他启动参数

{% highlight python linenos %}

    # salt-api --help

{% endhighlight %}
 

# 代码入口

入口代码为

{% highlight python linenos %}

    /salt/scripts/salt-api (/usr/bin/salt-api)
    ->
    /salt/salt/scripts.py
    -> 
    /salt/salt/cli/api.py
        SaltAPI.setup_config() 寻找/etc/salt/master文件进行配置设置
        ->
            /salt/salt/config.py
                api_config() -> client_config()
        ->
        SaltAPI.run():
            - parse_args()
            - /salt/salt/utils/parsers.py LogLevelMixIn.setup_logfile_logger()
            ->
            /salt/salt/client/netapi.py  NetapiClient
                self.process_manager = ProcessManager()
                self.netapi -> /salt/salt/loader.py LazyLoader : load rest_tornado模块
                self.process_manager.run()

{% endhighlight %} 

进入tornado

{% highlight python linenos %}

    /salt/salt/netapi/rest_tornado/__init__.py
        start()
            ```
           paths = [
            (r"/", saltnado.SaltAPIHandler),
            (r"/login", saltnado.SaltAuthHandler),
            (r"/minions/(.*)", saltnado.MinionSaltAPIHandler),
            (r"/minions", saltnado.MinionSaltAPIHandler),
            (r"/jobs/(.*)", saltnado.JobsSaltAPIHandler),
            (r"/jobs", saltnado.JobsSaltAPIHandler),
            (r"/run", saltnado.RunSaltAPIHandler),
            (r"/events", saltnado.EventsSaltAPIHandler),
            (r"/hook(/.*)?", saltnado.WebhookSaltAPIHandler),
            ] 
            ```
 
{% endhighlight %}

根据不同的url匹配到不同的类去处理.

# 参考资料

- [salt net-api源代码](https://github.com/saltstack/salt.git)
