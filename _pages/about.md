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
**学历**：本科  
**邮箱** ：<a href="mailto:jacky.wucheng@foxmail.com">jacky.wucheng@foxmail.com</a>  
**手机**：18612624987（同微信）     
**籍贯**：浙江杭州    
**目前所在地**：北京      
**工作时间** ：自2008年   

# 二、工作经历

- 2017.11 ~ 2021.01，量化健康（北京），在系统架构部担任“技术经理”岗位，负责团队管理（30人）和“宏基因组测序分析平台”、“微生物知识图谱系统”的架构设计与核心模块编码工作。

- 2014.10 ~ 2017.04，汽车之家（北京），在系统平台部担任“高级架构师”岗位，负责技术团队管理（20人）和“DevOps平台”的架构设计与核心模块编码工作。

- 2009.01 ~ 2014.09，新浪（北京）

  - 在“研发部”先后担任“高级系统开发工程师”和“技术主管”岗位，负责团队管理（15人）和“新浪图床系统”、“新浪CDN平台”、“新浪多媒体转码系统”的架构设计与核心模块编码工作。

  - 在“公共服务部”担任“系统管理员”和“PHP开发工程师”岗位，负责“新浪登录注册系统”的运维和后端开发工作，负责“新浪IM在线系统”的架构改造工作。

- 2008.06 ~ 2008.12，网易（北京），在网络系统部担任“IDC系统工程师”岗位，负责IDC服务器和网络设备的上下线、机架部署、网络布线、巡检和故障处理，在云计算数据中心的大规模系统部署和运维方面积累了丰富经验。

  

# 三、专业技能

技术方面

- 熟练掌握Golang/Python/Java技术栈，了解C/C++技术栈，熟悉微服务技术架构，能够进行大规模分布式系统设计和开发。
- 熟练掌握DevOps技术栈，利用Gitlab/Jenkins结合Kubernetes8S/Docker实现CI和CD，提升工程交付效率。
- 熟悉MySQL/PostgreSQL等RDBMS，Redis/MongoDB等NOSQL，HDFS/HBase/GlusterFS/Ceph等分布式存储，Neo4j/OrientDB等图数据库。
- 熟悉大数据生态圈相关知识，如Hadoop，Kafka，Spark，ELK。
- 良好的自我驱动能力，积极参与并贡献开源项目。

管理方面

- 规划团队长期目标和短期目标，制定绩效考核方法。
- 人员招聘，团队组建，对团队人员进行指导培养。
- 组织公司内的知识分享，组织跟行业其他公司的线下交流，参加论坛或者大型会议。
- 技术选型，方案设计，架构设计，模块设计。
- 研发团队日常管理，使用Scrum和Kanban方法进行团队协作。



# 四、项目经历

## 2017.11 ~ 2021.01，量化健康（北京）

### 宏基因组测序分析平台

背景

- 项目背景：业务模式是通过对人体肠道菌群进行DNA测序进而评估人体健康状况/疾病风险。
- 待解决问题：原系统数据建模不合理、workflow模型设计不合理、代码结构混乱，导致无法适应新业务。

解决方法

- 梳理新业务逻辑，进行领域建模，清晰定义领域实体的Schema，并配套相应设计文档。
- 将系统拆分为3个子模块：客户服务系统、实验室工单系统、workflow计算框架。
- 用Vue+Golang进行前后端分离，将主要业务逻辑转移到后端，封装在工单体系内，集中控制业务流程。
- 采用MongoDB存储业务数据，采用GlusterFS存储海量基因组数据，兼容生物信息行业的现有工具。
- 兼容团队的Golang技术栈，引入[Argo Workflow on Kubernetes](https://github.com/argoproj/argo)进行二次开发实现workflow工作流自动化，解决生物信息团队和系统架构团队的工作耦合问题。
- 基于Kubernetes和Gitlab实现CI和CD，提升开发和交付效率。

结果

- 系统设计更加合理，可维护性更高，提升了生物信息团队和基础架构团队的工作效率。
- 为接下来的新冠病毒检测业务提供了良好的平台支撑。

我的职责

- 项目管理和团队管理、技术选型、架构设计、核心组件编码。



### 微生物知识图谱系统

背景

- 项目背景：肠道菌群被业界称为“人体第二基因组”，为了开发功能菌株和微生态药物，科研人员需要深层探索这些细菌跟人体各方面的相互关系。
- 待解决的问题：行业领域知识庞大、数据分散、检索工具使用不便、体力劳动繁重拖累科研效率。

解决方法

- 梳理领域知识，提出“知识图谱系统”技术方案，进行领域建模和系统架构设计。
- 将系统拆分为6个子模块：爬虫模块、知识抽取模块、数据分析模块、数据存储模块、ApiServer、WebUI。
- 用Python开发爬虫从多个生物信息数据源抓取数据，针对各数据源开发解析抽取程序，将数据写入后端的数据存储模块。
- 以Spark为工具对结构化数据进行分布式处理和分析，将结果写入数据存储模块。
- 数据存储模块由ElasticSearch和OrientDB组成，ElasticSearch中主要存储医学文献，OrientDB中存储各知识点组成的知识网络。
- 以Vue+Golang技术栈分别实现WebUI和ApiServer，科研人员通过WebUI检索后端知识库。

结果

- 提升了科研人员的知识获取效率，为公司节省了时间成本。
- 通过数据分析为公司的科研决策提供了数据支撑。

我的职责

- 项目管理和团队管理、技术选型、架构设计、核心组件编码。



## 2014.10 ~ 2017.04，汽车之家（北京）

### DevOps平台

背景

- 项目背景：当时所属部门叫系统平台部，是所有业务部门的基础设施支持部门。
- 待解决问题：运维体系不规范、自动化运维程度低、上线代码靠人肉、监控系统漏报误报、资产盘点屡屡出错、服务交付效率低下。

解决方法

- 梳理当前技术问题，提出“DevOps平台”技术方案，进行领域建模和系统架构设计。
- 拆分为5个子系统：配置管理系统、代码发布系统、资产管理系统、监控系统、资源交付系统。
- 配置管理系统；基于Puppet ENC架构开发插件实现对常用应用软件的自动化安装和配置管理。详见《[汽车之家运维团队倾力打造的配置管理系统AutoCMS](http://mp.weixin.qq.com/s?__biz=MzA3MzYwNjQ3NA==&mid=2651296455&idx=1&sn=ae9ff5e7f3a103559d690b79dfae1962&scene=0#wechat_redirect)》。
- 代码发布系统：基于SaltStack Execution Module二次开发实现了并行命令分发和并行代码上线，接入了公司所有核心业务，彻底杜绝了人肉上线现象。
- 资产管理系统：基于Puppet Facter开发插件实现了服务器配置参数自动化采集功能，基于“状态机模型”实现了服务器全生命周期自动化管理，用“工单模式”保证了运维操作过程中的“强流程+自动化”，从而保证资产数据准确无误。详见《[汽车之家CMDB设计思路](http://mp.weixin.qq.com/s?__biz=MzA5NTAxNjQyMA==&mid=2654543617&idx=1&sn=f97d01906a52919cd059308933c7d6cd&scene=4#wechat_redirect)》, 《[OpsWorld2016-运维的数据银行](https://du-uu.com/article/58744eb7d28f910011718bce)》。
- 监控系统：基于OpenFalcon建设大型分布式监控系统，自研报警故障定位模块和上层产品方案（Golang技术栈），承受住了每秒10万级metric上报的压力，告警及时且能够溯源故障原因。
- 资源交付系统：用“工单模式”实现需求对接和内部工序流转，且在工单中对接其他子系统API实现后台自动化，实现在小时级别完成资源交付。

结果

- 大幅提升了本部门的工作效率，显著提升了业务部门的满意度。

我的职责

- 项目管理和团队管理、技术选型、架构设计、核心组件编码。



## 2009.01 ~ 2014.09，新浪（北京）

### 新浪CDN平台

背景

- 项目背景：新浪微博和微盘业务带来了视频、音频、图片流量的爆发式增长。
- 待解决问题：控制商业CDN的投入成本、提升访问性能和稳定性。

解决方法

- 调研行业技术，汇总和梳理业务部门的需求，提出“SinaEdge CDN平台”技术方案。
- 拆分为3个子系统：全局调度器、L1主干节点/L2边缘节点、OLAP中心。
- 全局调度器负责用户流量调度和服务器回源流量调度，通过PowerDNS的backend实现了自定义IP库和RoundRobin、WeightedRoundRobin调度算法，支持DNS调度和HTTP重定向调度功能。
- L1和L2节点由单臂模式的LVS和二次开发的TrafficServer组成，节点集群架构高可用，且规模可横向扩展。整个平台支撑了每秒250G的带宽输出。
- OLAP中心基于Hadoop技术栈构建，实时汇集边缘节点日志，定期运行MapReduce任务分析业务指标。

结果

- 性能超越商业CDN 30%，成本低10%。

我的职责

- 项目管理和团队管理、技术选型、架构设计、核心组件编码。

### 新浪图床平台

背景

- 项目背景：新浪微博和微盘业务带来流量激增。
- 待解决问题：原系统不具备水平扩展能力，并且使用的商业存储极其昂贵。

解决方法

- 梳理当前系统痛点，提出架构改造方案。
- 采用异地多活架构，多IDC间数据使用MQ进行异步同步。
- 采用HAProxy+多PC Server架构替代掉商业存储服务器。
- HAProxy一致性Hash + PC Server集群内分布式缓存策略实现水平扩展架构。

结果

- 单集群成本下降300万。
- 集群更加高可靠，运维成本极大降低。

我的职责

- 技术选型、架构设计、核心组件编码。



### 新浪多媒体转码平台

背景

- 项目背景： 微博上激增的海量音视频需要跨设备访问。
- 待解决问题：不同设备能够支持的音视频格式不同，需要格式转换。

解决方法

- 调研行业技术，提出“SinaTrans多媒体转码平台”技术方案。 
- 拆分为3个子模块：任务队列、调度器和转码服务器。
- 调度器基于Twisted Python实现，支持FIFO、Priority和抢占式调度模式。转码服务器任务管理程序也由Python开发，底层由FFMPEG实现格式转换。集群规模可以自由扩展，且无单点故障。

结果

- 平稳支撑了业务的快速增长，且系统可水平扩展，运维成本极低。

我的职责

- 技术选型、架构设计、CodeReview。



# 五、个人作品

- Blog：http://jackywu.github.io/about 

- Github：https://github.com/jackywu 

- 个人贡献过的开源项目

  - [jackywu/argo: Container-native workflows for Kubernetes](https://github.com/jackywu/argo). 
  - [jackywu/bee: Bee is a tool for helping develop with beego app framework](https://github.com/jackywu/bee). 
  - [jackywu/salt: Software to automate the management and configuration of any infrastructure](https://github.com/jackywu/salt). 
  - [AutohomeCorp/Assets_Report: A assets report plugin for puppet-master based on Facter，https://github.com/AutohomeCorp/Assets_Report](https://github.com/AutohomeCorp/Assets_Report).
  - [jackywu/vagrant: Vagrant is a tool for building and distributing development environments](https://github.com/jackywu/vagrant).
  - [jackywu/kraken-extension: utility extension software of kraken](https://github.com/jackywu/kraken-extension).

- 原创技术文章：http://jackywu.site/categories/technology/ 