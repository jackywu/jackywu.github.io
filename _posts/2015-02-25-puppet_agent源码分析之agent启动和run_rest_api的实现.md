---
layout: post
title: Puppet Agent源码分析之Agent启动和Run Rest-API的实现
category: articles
tags: [puppet, 源码分析, ruby]
author: JackyWu
comments: true

---

###  Puppet Agent的启动

> author: 燃烧 <jacky.wucheng@gmail.com>
> 本代码分析基于 puppet-2.7.19, 编写于2014-03-14
> 如下的讲解中可能尽量讲述较关键的地方，其他地方可能会省略。


`sbin/puppetd`脚本是agent启动入口，其中调用`Puppet::Application[:agent].run` 启动agent daemon。
其调用的是`lib/puppet/application/agent.rb`中的`class Puppet::Application::Agent`里的run方法。
`class Puppet::Application::Agent`的run方法是从`Puppet::Application`中继承的。


class Puppet::Application 中

{% highlight ruby %}

```
# This is the main application entry point
def run
  exit_on_fail("initialize")                                   { hook('preinit')       { preinit } }
  exit_on_fail("parse options")                                { hook('parse_options') { parse_options } }
  exit_on_fail("parse configuration file")                     { Puppet.settings.parse } if should_parse_config?
  exit_on_fail("prepare for execution")                        { hook('setup')         { setup } }
  exit_on_fail("configure routes from #{Puppet[:route_file]}") { configure_indirector_routes }
  exit_on_fail("run")                                          { hook('run_command')   { run_command } }
end
```
{% endhighlight %}

显然代码了做了

- 预初始化。
- 解析配置文件。
- 配置indirector，其用途可参考 [indirection](http://docs.puppetlabs.com/references/latest/indirection.html)。
- 执行run_command，此run_command方法是在`class Puppet::Application::Agent`中定义的，其覆盖了父类`Puppet::Application`中的run_command方法。
- run_command方法中调用main方法执行了@daemon.start来启动puppetd的客户端。


### Puppet Agent Run Rest-API的实现
通过[Puppet官方文档Rest_API](http://docs.puppetlabs.com/guides/rest_api.html#run)，可知我们可以通过给Puppet Agent发送http请求来触发Agent进行更新，那么通过此run接口可以实现多少需求呢？是否可以实现[noop更新](http://docs.puppetlabs.com/references/3.4.0/man/agent.html) 、[noop参数的解释](http://docs.puppetlabs.com/references/latest/configuration.html#noop)的呢？我们分析一下接口的实现。


在`lib/puppet/network/handler/runner.rb`中定义了

{% highlight ruby %}

```
class Puppet::Network::Handler
  class MissingMasterError < RuntimeError; end # Cannot find the master client
  # A simple server for triggering a new run on a Puppet client.
  class Runner < Handler
    desc "An interface for triggering client configuration runs."

    @interface = XMLRPC::Service::Interface.new("puppetrunner") { |iface|
      iface.add_method("string run(string, string)")
    }

    side :client

    # Run the client configuration right now, optionally specifying
    # tags and whether to ignore schedules
    def run(tags = nil, ignoreschedules = false, fg = true, client = nil, clientip = nil)
      options = {}
      options[:tags] = tags if tags
      options[:ignoreschedules] = ignoreschedules if ignoreschedules
      options[:background] = !fg

      runner = Puppet::Run.new(options)

      runner.run

      runner.status
    end
  end
end
```
{% endhighlight %}

从中可见，支持的参数只有tags，ignoreschedules，background。所以，此run接口目前的功能是非常若弱的，如果要实现我们的功能，我们需要考察下是否可以定制。
其中`Puppet::Run`定义在`lib/puppet/run.rb`中，
{% highlight ruby %}

```
class Puppet::Run
...

  def initialize(options = {})
    if options.include?(:background)
      @background = options[:background]
      options.delete(:background)
    end

    valid_options = [:tags, :ignoreschedules]
    options.each do |key, value|
      raise ArgumentError, "Run does not accept #{key}" unless valid_options.include?(key)
    end

    @options = options
  end


  def run
    if agent.running?
      @status = "running"
      return self
    end

    log_run

    if background?
      Thread.new { agent.run(options) }
    else
      agent.run(options)
    end

    @status = "success"

    self
  end
...
end
```
{% endhighlight %}

其中进行了参数检查，只支持[:tags, :ignoreschedules]这几个参数。这就比较悲剧了，如果要实现更多的参数，没有合适的插件模式，而是需要改原生代码。从puppet-3.1中，依然没有看到改进。

{% highlight ruby %}

```
from puppet-3.1

  def initialize(options = {})
    if options.include?(:background)
    ¦ @background = options[:background]
    ¦ options.delete(:background)
    end

    valid_options = [:tags, :ignoreschedules, :pluginsync]
    options.each do |key, value|
    ¦ raise ArgumentError, "Run does not accept #{key}" unless valid_options.include?(key)
    end

    @options = options
  end
```
{% endhighlight %}



