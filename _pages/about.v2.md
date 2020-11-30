---
permalink: /about/
title: "ABOUT ME"
layout: single
author_profile: true
toc: true
---

# 一、基本资料

**姓名** ：吴城  
**出生年份** ：1984  
**毕业院校** ：哈尔滨工程大学  
**专业** ：机械设计制造   
**学历**：本科  
**邮箱** ：<a href="mailto:jacky.wucheng@foxmail.com">jacky.wucheng@foxmail.com</a>  
**手机**：18612624987（同微信）     
**籍贯**：浙江杭州    
**目前所在地**：北京      
**工作时间** ：2008年至今   

# 二、工作经历

- 2017.11 ~ 至今，量化健康，在IT部担任“技术总监”岗位，负责IT部团队管理和“宏基因组测序分析平台”、“微生物知识图谱系统”的架构设计与核心模块编码工作。
- 2014.10 ~ 2017.04，汽车之家，在系统平台部担任“高级架构师”岗位，负责技术团队管理和“devops平台”的架构设计与核心模块编码工作。
- 2009.01 ~ 2014.09，新浪

  1. 在“研发部”先后担任“高级系统开发工程师”和“技术主管”岗位，负责团队管理和“新浪图床系统”、“新浪CDN平台”、“新浪多媒体转码系统”的架构设计与核心模块编码工作。
  2. 在“公共服务部”担任“系统管理员”和“PHP开发工程师”岗位，负责“新浪登录注册系统”的运维和后端开发工作，负责“新浪IM在线系统”的架构改造工作。
- 2008.06 ~ 2008.12，网易，在网络系统部担任“IDC系统工程师”岗位，负责IDC服务器和网络设备的上下线、机架部署、网络布线、巡检和故障处理，在云计算数据中心的大规模系统部署和运维方面积累了丰富经验。

  

# 三、专业技能

技术方面

- 熟练掌握Golang/Python/PHP开发，熟悉Java/C/C++的开发
- 熟练掌握Linux下的系统开发和自动化运维的生态知识
- 熟练掌握TCP/IP，DNS，HTTP，Restful等互联网相关技术标准
- 熟练掌握LVS，HAProxy，Nginx等7/4层负载均衡技术
- 熟悉MySQL/PostgreSQL等RDBMS，Redis/Memcached/MongoDB等NOSQL，HDFS/HBase/Ceph等分布式存储，Neo4j/OrientDB等图数据库
- 熟悉Kubernetes/Docker容器技术
- 熟悉大数据生态圈，如Hadoop，Kafka，Spark，ELK
- 具备大规模分布式系统的架构设计和开发经验
- 具备研发项目规划管理能力，具备技术团队管理能力
- 良好的自我驱动能力，积极参与并贡献开源项目

管理

- 规划团队长期目标和短期目标，制定绩效考核方法
- 人员招聘，团队组建，对团队人员进行指导培养
- 组织公司内的知识分享，组织跟行业其他公司的线下交流，参加论坛或者大型会议
- 技术选型，方案设计，架构设计，模块和功能设计
- 研发团队的日常管理，包括任务分配、进度跟踪、过程质量控制等等
- 定期项目总结，向下管理，向上汇报



# 四、项目经历


## 2017.11-至今，量化健康

在[量化健康](https://quantibio.com/cn/zh/)，我以IT部总监的角色负责公司重点项目"生物资源挖掘平台"，其包含“知识图谱”和“生物样本库”的建设，这两项均为公司的核心资产。

带领团队从零建设知识库（知识图谱）

- 基于Kubernetes平台，用Golang开发了整个IT基础架构的API平台，封装了后端知识图谱数据的存储和访问。
- 基于 Kubernetes和[argoproj/argo: Container-native workflows for Kubernetes.](https://github.com/argoproj/argo)进行了二次开发构建了“生物信息分析平台”，并且编写了大量的脚本和文档降低平台的使用门槛，为生物信息团队提供培训，极大提高了其工作效率，增加了“知识库”的知识产量。Refer：[Argo Contribution - JackyWu’s](http://jackywu.site/technology/argo-contribution/)
- 开发爬虫从公开数据源爬取知识信息, 如从NCBI爬取PubMed文献，物种的Taxonomy和Genome，从JGI Gold爬取物种信息，从公开词库爬取生物领域专有词汇翻译表，从KOMODO爬取微生物培养基信息等等,  通过数据清洗、抽取、转换等操作后，将知识及知识之间的关联关系导入搜索引擎ElasticSearch和图数据库OrientDB组成知识图谱, 科研部门通过Web或者接口调取这些信息。

带领团队从零建设生物样本库

- 调研行业生物样本库的建设方案(如[-80˚C自动化样品存储方案](https://jackywu.github.io/articles/80-C自动化样品存储方案/), [中国最大的菌库调研](https://jackywu.github.io/articles/中国最大的菌种库调研/)), 基于成本和公司目前所处的阶段，建立自己的样本库标准，采购硬件设备，定制各种机械配件和实验器皿，开发IT管理系统来进行统筹管理。开源项目[jackywu/CustomizedFreezerRack: 生物样本库冷冻盒和支架定制](https://github.com/jackywu/CustomizedFreezerRack)。
- 跟实验室团队深入探讨微生物生产流水线的标准化建设方案，开发IT管理系统辅助该流水线的运营，实现样本入库，样本分离，菌株培养，质谱鉴定，测序，菌株冻存和活化，生信流程分析这一完整闭环流程，提升流水线效率超过行业水平2倍以上。
- 为了提升生信团队对微生物物种鉴定的效率，开发了[jackywu/kraken-extension: utility extension software of kraken](https://github.com/jackywu/kraken-extension)来对kraken进行性能优化。

通过这几年的积累，自己在 基因组数据分析和IT平台建设、团队建设和管理、公司运营 方面有了很大的提升。

主要技术或软件关键词：Golang，Python，C++，Kubernetes，Argo，Workflow，MongoDB，ElasticSearch，Neo4j，OrientDB

## 2017.4-2017.11，离职期间

遇到职业平台期，思考下一个阶段的职业定位。

在这期间，阅读了这些书籍

- 华大基因-国家基因库系列《生物信息数据库建设、使用与管理指南》，科学出版社，张勇
- 《生物信息学》，人民卫生出版社，李霞
- 《大数据云计算时代数据中心经典案例赏析》，人民邮电出版社， [美]阿尔杰
- 《Hadoop构建数据仓库实践》，清华大学出版社，王雪迎
- 《Hadoop权威指南》，清华大学出版社，[美] Tom White
- 《Spark MLlib机器学习实践》，清华大学出版社，王晓华
- 《Scala编程思想》，机械工业出版社，Bruce Eckel
- 《一本书读懂人工智能》，人民邮电出版社，李连德



## 2014.10-2017.4，汽车之家

负责汽车之家系统平台部的研发管理工作

* 带领团队，基于Puppet ENC架构，从零研发“配置管理系统CMS”，支持linux上的Tomcat，Nginx，LVS，Codis和windows上的IIS的自动化安装配置。可以参考 [汽车之家运维团队倾力打造的配置管理系统AutoCMS](http://mp.weixin.qq.com/s?__biz=MzA3MzYwNjQ3NA==&mid=2651296455&idx=1&sn=ae9ff5e7f3a103559d690b79dfae1962&scene=0#wechat_redirect)
* 带领团队，基于SaltStack Execution Module二次开发，从零建设标准，开发”代码发布系统PushGuide”，接入了公司所有核心业务线的发布工作。可以参考 [终结人肉上线，使用代码发布系统PushGuide](http://mp.weixin.qq.com/s?__biz=MzA3MzYwNjQ3NA==&mid=2651296847&idx=1&sn=9f5c03364f36032a390b0929d3b8e558#rd)
* 带领团队，基于“生命周期管理 + 状态机”的思路，从零开发”资产管理系统CMDB“，以”强流程 + 自动化“的方法保证数据准确。可以参考 [汽车之家CMDB设计思路](http://mp.weixin.qq.com/s?__biz=MzA5NTAxNjQyMA==&mid=2654543617&idx=1&sn=f97d01906a52919cd059308933c7d6cd&scene=4#wechat_redirect), [OpsWorld2016-运维的数据银行](https://du-uu.com/article/58744eb7d28f910011718bce)
* 带领团队，基于OpenFalcon作为底层，自研上层产品方案，开发自有监控系统。可以参考[汽车之家监控系统的第一次里程碑](http://autohomeops.corpautohome.com/articles/%E6%B1%BD%E8%BD%A6%E4%B9%8B%E5%AE%B6%E7%9B%91%E6%8E%A7%E7%B3%BB%E7%BB%9F%E7%9A%84%E7%AC%AC%E4%B8%80%E6%AC%A1%E9%87%8C%E7%A8%8B%E7%A2%91/),  [监控系统故障定位之事件关联分析的设计](http://autohomeops.corpautohome.com/articles/%E7%9B%91%E6%8E%A7%E7%B3%BB%E7%BB%9F%E6%95%85%E9%9A%9C%E5%AE%9A%E4%BD%8D%E4%B9%8B%E4%BA%8B%E4%BB%B6%E5%85%B3%E8%81%94%E5%88%86%E6%9E%90%E7%9A%84%E8%AE%BE%E8%AE%A1/)
* 带领团队，开发”私有云平台“，以”工单 + 状态机"的思路，整合系统平台部内部的子系统，对业务部门提供统一的服务申请入口，向PaaS转型。可以参考 [汽车之家__私有云建设](https://myslide.cn/slides/1746)
* 带领团队，协调Kubernetes容器平台跟“代码发布系统PushGuide”的对接，实现基于容器的DevOps流程打通。

除了技术和日常管理事务之外，还对团队成员的非技术能力进行了培训

* [事务管理GTD](http://jackywu.github.io/articles/事务管理分享/)
* [知识管理](http://jackywu.github.io/articles/知识管理/)
* [招聘方法](http://jackywu.github.io/articles/招聘方法/)
* [项目管理](http://jackywu.github.io/articles/项目管理方法/)

通过这两年的经验累积，自己的技术和管理能力提升了一个台阶。

主要技术或软件关键词：Python，Ruby，Golang，Puppet，SaltStack，OpenFalcon，Docker，Kubernetes



## 2009.1-2014.9，新浪

**1、2012-2014.9，研发部平台架构组，技术主管**

负责SinaEdge CDN平台的研发工作，带领团队进行技术研发。做了如下重点开发工作：

GSLB全局流量调度器优化，提升可靠性和精准度

- 调度器配合EdgeServer实现回源Failover功能，以提升回源成功率。
- 调度器自动化IP库更新机制开发，提升调度精准度。
- 权威DNS和递归DNS实现Edns-Subnet功能，以实现用户精准调度和回源精准调度的目的。
- 自动化调度系统的原型开发，以提高平台稳定性和服务质量。

运维自动化，提升运维效率

- 基于puppet的自动化配置管理系统。

还负责视频转码平台SinaTrans的研发和运维工作。该平台实现了常见视频格式的编解码功能，承载了新浪原生视频，新浪微盘，秒拍这几个主要产品。主要特性包括：

- 输出ts+m3u8，mp4，flv等格式，支持pc端和手机端的视频播放。
- 制定了该平台的数据体系，分析和考评该平台的性能和可靠性。
- 基于 NVIDIA GPU NVENC 转码工具的原型开发。

除了技术工作之外，还包括：

- 引导团队根据公司目标自主进行技术调研，行业调研，共同制定年度绩效目标，制定开发计划。
- 组织团队内、外的技术分享，加强技术交流和学习。
- 组织线下活动，培养团队成员的融入感，增加团队交流活跃度。

主要技术或软件关键词：C++，Ruby，Python，Puppet，Traffic Server，PowerDNS，CDN，边缘计算

**2、2011-2012，研发部平台架构组，高级系统开发工程师**

负责全新项目新浪CDN平台SinaEdge的架构设计和关键组件系统开发，带领10人的团队，建立了针对大/小文件优化的加速平台，统一配置管理部署中心，自动化系统和服务监控中心，自动化数据分析中心，全局流量调度器等子系统。在2011年中完成了SinaEdge-1.0的release，提供了静态加速和动态加速的平台，在2012年底完成了SinaEdge-2.0的release，提高了加速节点和调度器的性能。当时SinaEdge平台承担了新浪大部分静态业务的加速服务，如微博图片，微盘，视频等等，提供了250G的带宽输出。

主要技术或软件关键词：C++，Ruby，Python，Puppet，Traffic Server，PowerDNS，CDN，边缘计算

**3、2010-2011，研发部平台架构组，系统开发工程师**

负责新浪全站图片服务系统(最大业务是微博图片)的应用运维和开发，并且在后续的架构改造中负责了架构设计和编码工作，去除了架构中的瓶颈Netapp Filer，实现了单IDC的Scale Out，实现了多IDC异步快速的数据同步，为公司节省了300万左右的Filer采购成本。

主要技术或软件关键词：Python，MemcacheQ，MySQL

**4、2009-2010，公共服务事业部，系统管理员，PHP开发工程师**

负责新浪注册登录系统的运维和开发，负责团队并行开发的配置管理和代码发布(quickbuild)，负责“IM在线系统”的运维和后续架构优化项目的架构设计、开发和多IDC冗余部署方案的设计。改造后的系统满足了容量翻倍的业务需求，并且具备了Scale Out的能力，简化了业务流程，降低了运维成本。 

主要技术或软件关键词：Shell，PHP，Python，MySQL



## 2008.6-2008.12，网易

**网络系统部，IDC系统工程师**

负责IDC服务器/网络设备上下线，机架部署，网络布线，故障处理和巡检，掌握了IDC相关工作的规范和流程，对大规模系统的工业化部署和运维提供了技术积累。

主要技术或软件关键词：Shell，Python



## 2004.9-2008.6，在校

**网络信息中心，开源实验室负责人和HPC管理员**

负责Linux和开源活动在学校的宣传和科普。并且维护者网络信息中心的浪潮HPC高性能Linux计算集群。

主要技术或软件关键词：Shell，PHP，Python，Linux



# 五、个人作品

* Blog：<http://jackywu.github.io>
* Github：<https://github.com/jackywu>
* 个人贡献过的开源项目
    * [jackywu/argo: Container-native workflows for Kubernetes.](https://github.com/jackywu/argo)  
    * [jackywu/bee: Bee is a tool for helping develop with beego app framework.](https://github.com/jackywu/bee)  
    * [jackywu/kraken-extension: utility extension software of kraken](https://github.com/jackywu/kraken-extension)
	* [jackywu/salt: Software to automate the management and configuration of any infrastructure or application at scale. ](https://github.com/jackywu/salt) 
	* [jackywu/vagrant: Vagrant is a tool for building and distributing development environments.](https://github.com/jackywu/vagrant)
* 原创文章
    * [GTD事务管理](http://jackywu.github.io/articles/事务管理分享/)
    * [Saltstack net-api Runner/Local模块调用分析](http://jackywu.github.io/articles/saltstack_net_api_runner_local_call/)
    * [SaltStack源码分析 - 任务处理机制](http://jackywu.github.io/articles/saltstack源码分析/)
    * [Zabbix_server源码分析](http://jackywu.github.io/articles/zabbix_server源码分析/)
    * [PDNS-Recursor源码分析之dns server的选择原理](http://jackywu.github.io/articles/pdns_recursor源码分析之dns_server的选择原理/)
    * [Puppet Agent源码分析之Agent启动和Run Rest-API的实现](http://jackywu.github.io/articles/puppet_agent源码分析之agent启动和run_rest_api的实现/)
* 管理和审核 [汽车之家运维团队技术文章](http://autohomeops.corpautohome.com)

