---
layout: post
title: Zabbix_server源码分析
category: articles
tags: [源码分析, zabbix, zabbix_server, 监控]
author: JackyWu
comments: true

---


本分析基于zabbix-2.2

方法:

1. 查看源码
2. Zabbix_Server.conf里设置 DebugLevel=4 For Debug.

## 重要组件

![](/images/zabbix/Zabbix_core_logic.jpg)

### 1. `main_dbconfig_loop`


{% highlight text %}

    main_dbconfig_loop()
    
    每60s, 同步数据库的hosts, items, 等等表数据到内存, 用hash表的形式存储.
    
    Debug Log:
    184  15026:20150923:022235.897 server #1 started [configuration syncer #1]
    185  15026:20150923:022235.897 configuration syncer [waiting 60 sec for processes]
    2857  15026:20150923:022335.946 configuration syncer [connecting to the database]
    2862  15026:20150923:022335.947 configuration syncer [synced configuration in 0.000000 sec, syncing configuration]
    2973  15026:20150923:022335.971 configuration syncer [synced configuration in 0.023196 sec, idle 60 sec]
    
    1. 查询conf_result.
    
    2. 查询所有host_result:
    select hostid,proxy_hostid,host,ipmi_authtype,ipmi_privilege,ipmi_username,ipmi_password,maintenance_status,maintenance_type,maintenance_from,errors_from,available,disable_until,snmp_errors_from,snmp_available,snmp_disable_until,ipmi_errors_from,ipmi_available,ipmi_disable_until,jmx_errors_from,jmx_available,jmx_disable_until,status,name from hosts where status in (0,1,5,6) and flags<>2
    
    3. 查询所有item_result:
    
    select i.itemid,i.hostid,i.status,i.type,i.data_type,i.value_type,i.key_,i.snmp_community,i.snmp_oid,i.port,i.snmpv3_securityname,i.snmpv3_securitylevel,i.snmpv3_authpassphrase,i.snmpv3_privpassphrase,i.ipmi_sensor,i.delay,i.delay_flex,i.trapper_hosts,i.logtimefmt,i.params,i.state,i.authtype,i.username,i.password,i.publickey,i.privatekey,i.flags,i.interfaceid,i.snmpv3_authprotocol,i.snmpv3_privprotocol,i.snmpv3_contextname,i.lastlogsize,i.mtime,i.delta,i.multiplier,i.formula,i.history,i.trends,i.inventory_link,i.valuemapid,i.units,i.error from items i,hosts h where i.hostid=h.hostid and h.status in (0,1) and i.flags<>2;
    
    4. 继续查询
    
    - trig_result (trigger)
    - tdep_result (trigger依赖关系)
    - func_result (function)
    - hi_result (host inventory关系)
    - htmpl_result (host template)
    - gmacro_result (global macro)
    - hmacro_result (host macro)
    - if_result (interface)
    - expr_result (regex, expression)
    
    如上所有的数据都存储在 static ZBX_DC_CONFIG	*config = NULL; 里.

{% endhighlight %}



### 2. `main_timer_loop`

分析程序的核心逻辑在process_time_functions里. 定时对Trigger求值, 如果值改变, 则触发Event的产生, 写入events表.


{% highlight text %}

    main_timer_loop()
    
    -> (L860)process_time_functions()
        -> evaluate_expressions()
            -> substitute_simple_macros()
            -> substitute_functions()
                    -> zbx_evaluate_item_functions()
                        -> evaluate_function()
                            -> evaluate_LAST()
                            -> evaluate_MIN()
                            -> evaluate_MAX()
                            -> ...
            -> evaluate()
        -> process_triggers()
            -> process_trigger()
        -> process_events()
            -> save_events()
            -> process_actions()
    
    -> (L880)process_maintenance()
        -> update_maintenance_hosts
            -> generate_events
                -> add_event
                    -> process_events()
                        -> save_events()
                        -> process_actions()

{% endhighlight %}




#### 2.1 `process_time_functions`


{% highlight c %}

    static void	process_time_functions(int *triggers_count, int *events_count)
    {
    	const char		*__function_name = "process_time_functions";
    	DC_TRIGGER		*trigger_info = NULL;
    	zbx_vector_ptr_t	trigger_order;
    
    	zabbix_log(LOG_LEVEL_DEBUG, "In %s()", __function_name);
    
    	zbx_vector_ptr_create(&trigger_order);
    
    	while (1)
    	{
    		DCconfig_get_time_based_triggers(&trigger_info, &trigger_order, ZBX_TRIGGERS_MAX, process_num);
    
    		if (0 == trigger_order.values_num)
    			break;
    
    		*triggers_count += trigger_order.values_num;
    
    		evaluate_expressions(&trigger_order); <<=======================
    
    		DBbegin();
    
    		process_triggers(&trigger_order);     <<=======================
    
    		*events_count += process_events();    <<=======================
    
    		DBcommit();
    	}
    
    	zbx_free(trigger_info);
    	zbx_vector_ptr_destroy(&trigger_order);
    
    	zabbix_log(LOG_LEVEL_DEBUG, "End of %s()", __function_name);
    }

{% endhighlight %}


#### 2.2 `evaluate_expressions`

将表达式解析为zabbix里的函数.


{% highlight text %}

    evaluate_expressions()
    
    Debug Log:
     85098  15562:20150923:041234.113 In evaluate_expressions() tr_num:1
     85099  15562:20150923:041234.113 In substitute_simple_macros() data:'{13186}#1'
     85100  15562:20150923:041234.113 End substitute_simple_macros() data:'{13186}#1'
     85101  15562:20150923:041234.113 In substitute_functions()
     85102  15562:20150923:041234.113 In zbx_extract_functionids() tr_num:1
     85103  15562:20150923:041234.113 End of zbx_extract_functionids() functionids_num:1
     85104  15562:20150923:041234.113 In zbx_populate_function_items() functionids_num:1
     85105  15562:20150923:041234.113 End of zbx_populate_function_items() ifuncs_num:1
     85106  15562:20150923:041234.113 In zbx_evaluate_item_functions() ifuncs_num:1
     85107  15562:20150923:041234.113 In evaluate_function() function:'Zabbix_agent:net.tcp.listen[80].last()'
     85108  15562:20150923:041234.113 In evaluate_LAST()
     85109  15562:20150923:041234.113 In __get_function_parameter_uint31() parameters:'' Nparam:1
     85110  15562:20150923:041234.113 In substitute_simple_macros() data:EMPTY
     85111  15562:20150923:041234.113 __get_function_parameter_uint31() flag:1 value:1
     85112  15562:20150923:041234.113 End of __get_function_parameter_uint31():SUCCEED
     85113  15562:20150923:041234.113 In zbx_vc_get_value_range() itemid:23719 value_type:3 seconds:0 count:1 timestamp:1442981549
     85114  15562:20150923:041234.113 End of zbx_vc_get_value_range():SUCCEED count:1 cached:1
     85115  15562:20150923:041234.113 End of evaluate_LAST():SUCCEED
     85116  15562:20150923:041234.113 End of evaluate_function():SUCCEED value:'1'
     85117  15562:20150923:041234.113 End of zbx_evaluate_item_functions()
     85118  15562:20150923:041234.113 In zbx_substitute_functions_results() ifuncs_num:1 tr_num:1
     85119  15562:20150923:041234.113 zbx_substitute_functions_results() expression[0]:'{13186}#1' => '1#1'
     85120  15562:20150923:041234.113 End of zbx_substitute_functions_results()
     85121  15562:20150923:041234.113 End of substitute_functions()
     85122  15562:20150923:041234.113 In evaluate() expression:'1#1'
     85123  15562:20150923:041234.114 End of evaluate() value:0.000000
     85124  15562:20150923:041234.114 End of evaluate_expressions()
    
    
    zbx_vc_get_value_range() 从ValueCache读history value.
    
    361418  15562:20150923:060512.882 In zbx_vc_get_value_range() itemid:23719 value_type:3 seconds:0 count:1 timestamp:1442988304
    361419  15562:20150923:060512.882 End of zbx_vc_get_value_range():SUCCEED count:1 cached:1
    
    
    DCmass_add_history() -> zbx_vc_add_value()

{% endhighlight %}


#### 2.2.1 `zbx_vc_get_value_range`


{% highlight c %}

    value_cache 是一个 hash table.
    
    /* the value cache data  */
    typedef struct
    {
    	/* the number of cache hits, used for statistics */
    	zbx_uint64_t	hits;
    
    	/* the number of cache misses, used for statistics */
    	zbx_uint64_t	misses;
    
    	/* the number of database queries performed, used only for unit tests */
    	zbx_uint64_t	db_queries;
    
    	/* the low memory mode flag */
    	int		low_memory;
    
    	/* timestamp of the last low memory warning message */
    	int		last_warning_time;
    
    	/* the minimum number of bytes to be freed when cache runs out of space */
    	size_t		min_free_request;
    
    	/* the cached items */
    	zbx_hashset_t	items;
    
    	/* the string pool for str, text and log item values */
    	zbx_hashset_t	strpool;
    }
    zbx_vc_cache_t;
    
    
    typedef struct
    {
    	ZBX_HASHSET_ENTRY_T	**slots;
    	int			num_slots;
    	int			num_data;
    	zbx_hash_func_t		hash_func;
    	zbx_compare_func_t	compare_func;
    	zbx_clean_func_t	clean_func;
    	zbx_mem_malloc_func_t	mem_malloc_func;
    	zbx_mem_realloc_func_t	mem_realloc_func;
    	zbx_mem_free_func_t	mem_free_func;
    }
    zbx_hashset_t;

{% endhighlight %}


#### 2.3 `process_triggers`

对trigger求值.


{% highlight text %}

    process_triggers
    
    Debug Log:
     1534  15564:20150923:033801.829 In process_triggers() values_num:1
     1535  15564:20150923:033801.829 In process_trigger() triggerid:13578 value:1(0) new_value:0
     1536  15564:20150923:033801.838 End of process_trigger():SUCCEED || OR "363565  15561:20150923:060602.913 End of process_trigger():FAIL"
     1537  15564:20150923:033801.838 query [txnlev:1] [update triggers set lastchange=1442979479,value=0 where triggerid=13578;
     1538 ]
     1539  15564:20150923:033801.851 End of process_triggers()
    
    
    mysql> select items.itemid, items.hostid, items.name, hosts.name as host_name from items, hosts  where items.name like '%port%' and items.hostid = hosts.hostid;
    +--------+--------+------------+----------------+
    | itemid | hostid | name       | host_name      |
    +--------+--------+------------+----------------+
    |  23718 |  10107 | nginx_port | Agent_Template |
    |  23719 |  10106 | nginx_port | Zabbix_agent   |
    +--------+--------+------------+----------------+
    2 rows in set (0.00 sec)
    
    
    mysql> select * from triggers where triggerid=13583\G
    *************************** 1. row ***************************
      triggerid: 13583
     expression: {13186}#1
    description: ngx_port_down
            url:
         status: 0
          value: 0
       priority: 5
     lastchange: 1442981544
       comments:
          error:
     templateid: 13582
           type: 0
          state: 0
          flags: 0
    1 row in set (0.01 sec)

{% endhighlight %} 


#### 2.4 `process_events`

处理事件. 包括写入events表, 并且写入escalation表.


{% highlight text %}

    process_events()
    
    Debug Log:
     84723  15561:20150923:041229.110 In process_events() events_num:1
     84724  15561:20150923:041229.111 In DCget_nextid() table:'events' num:1
     84725  15561:20150923:041229.111 End of DCget_nextid() table:'events' [177:177]
     84726  15561:20150923:041229.111 query [txnlev:1] [insert into events (eventid,source,object,objectid,clock,ns,value) values (177,0,0,13583,1442981544,682033248,0);
     84727 ]
     84728  15561:20150923:041229.120 In process_actions() events_num:1
     84729  15561:20150923:041229.120 query [txnlev:1] [select actionid,evaltype from actions where status=0 and eventsource=0]
     84730  15561:20150923:041229.122 In check_action_conditions() actionid:3
     84731  15561:20150923:041229.122 query [txnlev:1] [select conditionid,conditiontype,operator,value from conditions where actionid=3 order by conditiontype]
     84732  15561:20150923:041229.123 In check_action_condition() actionid:3 conditionid:6 cond.value:'1'
     84733  15561:20150923:041229.124 In check_trigger_condition()
     84734  15561:20150923:041229.124 End of check_trigger_condition():FAIL
     84735  15561:20150923:041229.124 End of check_action_condition():FAIL
     84736  15561:20150923:041229.124 End of check_action_conditions():FAIL
     84737  15561:20150923:041229.124 query [txnlev:1] [select actionid,triggerid,itemid from escalations where eventid is not null and actionid=3]
     84738  15561:20150923:041229.124 In DCget_nextid() table:'escalations' num:1
     84739  15561:20150923:041229.124 End of DCget_nextid() table:'escalations' [7:7]
     84740  15561:20150923:041229.124 query [txnlev:1] [insert into escalations (escalationid,actionid,status,triggerid,itemid,eventid,r_eventid) values (7,3,0,13583,null,null,177);
     84741 ]
     84742  15561:20150923:041229.125 End of process_actions()
     84743  15561:20150923:041229.125 In DBupdate_itservices()
     84744  15561:20150923:041229.125 In its_flush_updates()
     84745  15561:20150923:041229.125 In its_load_services_by_triggerids()
     84746  15561:20150923:041229.125 query [txnlev:1] [select serviceid,triggerid,status,algorithm from services where triggerid=13583]
     84747  15561:20150923:041229.125 End of its_load_services_by_triggerids()
     84748  15561:20150923:041229.125 End of its_flush_updates():SUCCEED
     84749  15561:20150923:041229.125 End of DBupdate_itservices():SUCCEED
     84750  15561:20150923:041229.125 End of process_events()
    
    
    int process_events(void)
    {
    	const char	*__function_name = "process_events";
    	int		ret = (int)events_num;
    
    	zabbix_log(LOG_LEVEL_DEBUG, "In %s() events_num:" ZBX_FS_SIZE_T, __function_name, (zbx_fs_size_t)events_num);
    
    	if (0 != events_num)
    	{
    		save_events();
    
    		process_actions(events, events_num);
    
    		DBupdate_itservices(events, events_num);
    
    		clean_events();
    	}
    
    	zabbix_log(LOG_LEVEL_DEBUG, "End of %s()", __function_name);
    
    	return ret;		/* performance metric */
    }

{% endhighlight %}




{% highlight text %}

    process_events
    -> save_events (写入events表)
    -> process_actions(process all actions of each event in a list) -> escalation_add_values(往escalations表里insert数据)

{% endhighlight %}


### 3. `main_escalator_loop`

escalation表将action, trigger, event关联起来.


{% highlight text %}

    main_escalator_loop
        -> execute_escalation(往escalations表里取数据)
            -> execute_operations
                -> add_message_alert(网alerts表里写入alert消息)
{% endhighlight %}




### 4. `main_alerter_loop`

每隔CONFIG_SENDER_FREQUENCY=30秒的时间从alerts表里获取未发送的告警发出去, 发送成功后修改告警状态值ALERT_STATUS_NOT_SENT为ALERT_STATUS_SENT.

>select a.alertid,a.mediatypeid,a.sendto,a.subject,a.message,a.status,mt.mediatypeid,mt.type,mt.description,
>mt.smtp_server,mt.smtp_helo,mt.smtp_email,mt.exec_path,mt.gsm_modem,mt.username,mt.passwd,a.retries from alerts a,media_type mt where a.mediatypeid=mt.mediatypeid and a.status=0 and a.alerttype=0 order by a.alertid


{% highlight text %}
    
    main_alerter_loop
        -> execute_action(根据media_type发送alert消息)

{% endhighlight %}


## 其他

Zabbix_Proxy Report


{% highlight text %}

    Zabbix_Proxy汇报给Zabbix_Server的数据
    
     13559:20150922:102016.199 trapper got '{
            "request":"history data",
            "host":"Zabbix_proxy",
            "data":[
                    {
                            "host":"Zabbix_agent",
                            "key":"net.tcp.listen[80]",
                            "clock":1442917214,
                            "ns":881325974,
                            "value":"0"}],
            "clock":1442917216,
            "ns":147147306}'

{% endhighlight %}



## 参考

### Server源码分析

- [zabbix源码阅读——zabbix_server](http://blog.csdn.net/liujian0616/article/details/7946492)
- [Zabbix数据库表浅析](http://www.xiaomastack.com/2014/07/03/zabbixdbtable/)
- [zabbix告警邮件、短信发送错误快速排查方法](http://www.furion.info/628.html)
- [zabbix数据库表结构-持续更新](http://www.furion.info/623.html#alerts)
- [Zabbix 数据库表结构](http://www.ipython.me/centos/zabbix-datatable-struc.html)

### Agent源码分析

- [跟我来看zabbix源码之zabbix_agentd.c客户端代码分析](http://xiaorui.cc/2014/11/15/%E8%B7%9F%E6%88%91%E6%9D%A5%E7%9C%8Bzabbix%E6%BA%90%E7%A0%81%E4%B9%8Bzabbix_agentd-c%E5%AE%A2%E6%88%B7%E7%AB%AF%E6%B5%81%E7%A8%8B%E5%88%86%E6%9E%90/)
- [跟我一起看zabbix源码之zabbix alerter.c报警逻辑](http://xiaorui.cc/2014/11/15/%E8%B7%9F%E6%88%91%E4%B8%80%E8%B5%B7%E7%9C%8Bzabbix%E6%BA%90%E7%A0%81%E4%B9%8Bzabbix-alerter-c%E6%8A%A5%E8%AD%A6%E9%80%BB%E8%BE%91/)
- [zabbix源代码阅读--zabbix_agent](http://blog.csdn.net/liujian0616/article/details/7932323)
