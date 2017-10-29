---

layout: post   
title:  SaltStack 监控调研  
category: articles  
tags: [saltstack,zeromq, 监控]  
author: JackyWu  
comments: true  

---

# 如何监控SaltStack

SaltStack的监控

1. Master和Minion的连通性监控
    2. Master到Minion的test.ping监控
    3. Minion从Master pull file的监控
    4. 日志监控
1. ZeroMQ的监控
    2. 监听Master和Minion端的EventPublisher
    3. 在Master和Minion的配置文件里开起`zmq_monitor`选项，并且设置log level为debug，在日志里会记录socket级别的行为日志，该功能需要`libzmq >= 4`
    3. 使用zeromq的zmq_socket_monitor接口监听底层socket的行为
    4. 日志监控



# 参考资料

1. zmq_socket_monitor函数
    1. [zmq_socket_monitor接口](http://api.zeromq.org/4-0:zmq-socket-monitor)，[中文翻译](http://www.cnblogs.com/fengbohello/p/4237721.html)
    2. [ZeroMQ(java)中监控Socket](http://blog.csdn.net/fjslovejhl/article/details/17790883)
    3. [Zeromq PUSH and PULL 模式用什么方法能够准确、及时知道连接断开？](http://www.zhihu.com/question/20194940)

2. 其他

    1. [如何通过zeromq拿到Sender的IP](http://stackoverflow.com/questions/14653937/is-there-any-way-to-tell-where-a-zeromq-message-came-from/14655860#14655860)
    2. [如何监控zeromq的queue里的长度](http://stackoverflow.com/questions/10677493/how-can-i-monitor-manage-queue-in-zeromq)，答案是没有办法。
    3. [github: simple_monitor.py](https://github.com/zeromq/pyzmq/blob/master/examples/monitoring/simple_monitor.py)
    4. [Devices in PyZMQ: MonitoredQueue](https://pyzmq.readthedocs.org/en/latest/devices.html#monitoredqueue)
    5. [Monitor Queue](http://learning-0mq-with-pyzmq.readthedocs.org/en/latest/pyzmq/pyzmqdevices/monitorqueue.html)
    

3. saltstack里的zeromq监控

    1. master和minion的配置里都留了监控的配置zmq_monitor，见saltstack源码`salt/transport/zeromq.py`，和 [文档说明](https://docs.saltstack.com/en/latest/ref/configuration/examples.html)

4. [saltstack minion端状态监控程序](http://6252961.blog.51cto.com/6242961/1710977)
    1. 通过master给所有minion发送uptime命令, 拿到结果, 若拿不到通过ssh重启minion, 若再次拿不到预期结果, 将该机器判定为故障.
5. [salt-minion自动修复代码，配合salt-minion监控使用](http://6252961.blog.51cto.com/6242961/1711925)
6. [一个开源的salt监控工具: salmon](https://github.com/lincolnloop/salmon), [salmon](http://www.shencan.net/index.php/2013/09/13/saltstack%EF%BC%88%E5%8D%81%E4%B8%89%EF%BC%89salmon-%E9%83%A8%E7%BD%B2/)