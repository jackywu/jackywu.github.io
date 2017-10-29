---
layout: post
title: PDNS-Recursor源码分析之dns server的选择原理
category: articles
tags: [powerdns, 源码分析, dns]
author: JackyWu
comments: true

---

> author: 燃烧 <jacky.wucheng@gmail.com>
>
> 本代码分析基于pdns-recursor-3.5.3，编写于2014-1-5

## 如何挑选最快的Authoritative DNS Server？

{% highlight c++ %}

```
SyncRes::doResolve
↘︎
SyncRes::doResolveAt
↘︎
doCNAMECacheCheck
doCacheCheck
shuffleInSpeedOrder
↘︎
random_shuffle(rnameservers.begin(),rnameservers.end(), dns_random);
speedOrder so(speeds);
stable_sort(rnameservers.begin(),rnameservers.end(), so);
```
{% endhighlight %}


**解释**

	在shuffleInSpeedOrder中，利用stable_sort函数对authoritative dns server按照so(speeds) 的规则进行排序。so(speeds)实现的就是根据dns查询速度进行比较。

代码见

{% highlight c++ %}

```

syncres.cc
758:
struct speedOrder
{
  speedOrder(map<string,double> &speeds) : d_speeds(speeds) {}
  bool operator()(const string &a, const string &b) const
  {
    return d_speeds[a] < d_speeds[b];
  }
  map<string, double>& d_speeds;
};


```
{% endhighlight %}


{% highlight c++ %}

```
syncres.cc
769:
inline vector<string> SyncRes::shuffleInSpeedOrder(set<string, CIStringCompare> &tnameservers, const string &prefix)
{
  vector<string> rnameservers;
  rnameservers.reserve(tnameservers.size());
  BOOST_FOREACH(const string& str, tnameservers) {
    rnameservers.push_back(str);
  }
  map<string, double> speeds;
  BOOST_FOREACH(const string& val, rnameservers) {
    double speed;
    speed=t_sstorage->nsSpeeds[val].get(&d_now);
    speeds[val]=speed;
  }
  random_shuffle(rnameservers.begin(),rnameservers.end(), dns_random);
  speedOrder so(speeds);
  stable_sort(rnameservers.begin(),rnameservers.end(), so);

  if(doLog()) {
    LOG(prefix<<"Nameservers: ");
    for(vector<string>::const_iterator i=rnameservers.begin();i!=rnameservers.end();++i) {
      if(i!=rnameservers.begin()) {
        LOG(", ");
        if(!((i-rnameservers.begin())%3)) {
          LOG(endl<<prefix<<"             ");
        }
      }
      LOG(*i<<"(" << (boost::format("%0.2f") % (speeds[*i]/1000.0)).str() <<"ms)");
    }
    LOG(endl);
  }
  return rnameservers;
}
```

{% endhighlight %}


SyncRes::doResolveAt中如下代码就按照排好序的rnameservers进行查询。

{% highlight c++ %}

```
syncres.cc
838:
vector<string > rnameservers = shuffleInSpeedOrder(nameservers, doLog() ? (prefix+qname+": ") : string() );

for(vector<string >::const_iterator tns=rnameservers.begin();;++tns) {
	...
}

```
{% endhighlight %}

查询结束后将本次的查询时间更新到全局速度表中

{% highlight c++ %}

```
syncres.cc
1001:        t_sstorage->nsSpeeds[*tns].submit(*remoteIP, lwr.d_usec, &d_now);

```

{% endhighlight %}


## 如果Authoritative DNS Server查询失败，怎么处理？
pdns recursor中有一个很重要的数据结构，记录了一些全局信息。

{% highlight c++ %}

```
syncres.hh
365:
  struct StaticStorage {
    negcache_t negcache;
    nsspeeds_t nsSpeeds; # 速度列表
    ednsstatus_t ednsstatus;
    throttle_t throttle; # 请求控制
    domainmap_t* domainmap;
  };
```

{% endhighlight %}

在错误处理方面，有一个重要的技术就是 `throttle` ，作用是来控制发往某些特定的 authoritative dns server 的请求，也即错误处理，或者叫请求控制。
每次开始dns查询的时候都会进行一次判断, 目标authoritative dns server是否是throttle的，如果是直接continue到下一个authoritative dns server进行查询，按照pdns官方的说法，这样可以节省时间和流量。代码如下：

{% highlight c++ %}

```
if(t_sstorage->throttle.shouldThrottle(d_now.tv_sec, make_tuple(*remoteIP, qname,qtype.getCode()))) {
  LOG(prefix<<qname<<": query throttled "<<endl);
  s_throttledqueries++; d_throttledqueries++;
  continue;
}
```

{% endhighlight %}

关于throttle的解释可以参考 what-s-in-the-throttle-map[^1] ， pdns recursor design[^2]。

[^1]: http://wiki.powerdns.com/trac/wiki/RecursorFAQ#what-s-in-the-throttle-map
[^2]: http://doc.powerdns.com/html/recursor-design-and-engineering.html

pdns recursor错误处理的逻辑都在如下代码中。
从中可知，`resolveret=1`时表示query成功，其他情况均为失败，失败后都能continue到下一个authoritative dns server进行查询，同时利用`t_sstorage->throttle.throttle()`方法更新throttle中的信息。

{% highlight c++ %}

```
syncres.cc
926:

s_outqueries++; d_outqueries++;
TryTCP:
if(doTCP) {
  LOG(prefix<<qname<<": using TCP with "<< remoteIP->toStringWithPort() <<endl);
  s_tcpoutqueries++; d_tcpoutqueries++;
}

resolveret=asyncresolveWrapper(*remoteIP, qname,  qtype.getCode(),
               doTCP, sendRDQuery, &d_now, &lwr);    // <- we go out on the wire!
if(resolveret != 1) {
  if(resolveret==0) {
LOG(prefix<<qname<<": timeout resolving "<< (doTCP ? "over TCP" : "")<<endl);
d_timeouts++;
s_outgoingtimeouts++;
  }
  else if(resolveret==-2) {
LOG(prefix<<qname<<": hit a local resource limit resolving"<< (doTCP ? " over TCP" : "")<<", probable error: "<<stringerror()<<endl);
g_stats.resourceLimits++;
  }
  else {
s_unreachables++; d_unreachables++;
LOG(prefix<<qname<<": error resolving"<< (doTCP ? " over TCP" : "") <<", possible error: "<<strerror(errno)<< endl);
  }

//! returns -2 for OS limits error, -1 for permanent error that has to do with remote **transport**, 0 for timeout, 1 for success
if(resolveret!=-2) { // don't account for resource limits, they are our own fault
{
    LOG(prefix<< "<<<2 " << remoteIP->toString());
    LOG(prefix<< " <<3 " << *tns);
    t_sstorage->nsSpeeds[*tns].submit(*remoteIP, 1000000, &d_now); // 1 sec
}
LOG(prefix<< "<<< " << remoteIP->toString());
if(resolveret==-1)
  t_sstorage->throttle.throttle(d_now.tv_sec, make_tuple(*remoteIP, qname, qtype.getCode()), 60, 100); // unreachable, 1 minute or 100 queries
else
  t_sstorage->throttle.throttle(d_now.tv_sec, make_tuple(*remoteIP, qname, qtype.getCode()), 10, 5);  // timeout
  }
  continue;
}

if(lwr.d_rcode==RCode::ServFail || lwr.d_rcode==RCode::Refused) {
  LOG(prefix<<qname<<": "<<*tns<<" returned a "<< (lwr.d_rcode==RCode::ServFail ? "ServFail" : "Refused") << ", trying sibling IP or NS"<<endl);
  t_sstorage->throttle.throttle(d_now.tv_sec,make_tuple(*remoteIP, qname, qtype.getCode()),60,3); // servfail or refused
  continue;
}

break;  // this IP address worked!
wasLame:; // well, it didn't
LOG(prefix<<qname<<": status=NS "<<*tns<<" ("<< remoteIP->toString() <<") is lame for '"<<auth<<"', trying sibling IP or NS"<<endl);
t_sstorage->throttle.throttle(d_now.tv_sec, make_tuple(*remoteIP, qname, qtype.getCode()), 60, 100); // lame
}

```
{% endhighlight %}

throttle的类定义如下, 每次shouldThrottle方法被调用都会清理掉5分钟之前的记录信息，然后查询make_tuple(*remoteIP, qname, qtype.getCode()))这个key是否存在，存在则不向此dns server发送query请求, continue到下一个，如果不存在，则进行查询流程。如果查询失败，则会将此make_tuple(*remoteIP, qname, qtype.getCode()))信息新加到throttle中去，

{% highlight c++ %}

```
syncres.hh
39:
template<class Thing> class Throttle : public boost::noncopyable
{
public:
  Throttle()
  {
    d_limit=3;
    d_ttl=60;
    d_last_clean=time(0);
  }
  bool shouldThrottle(time_t now, const Thing& t)
  {
    if(now > d_last_clean + 300 ) {

      d_last_clean=now;
      for(typename cont_t::iterator i=d_cont.begin();i!=d_cont.end();) {
    	//std::cout << "===shouldThrottle " << *i << std::endl;
        if( i->second.ttd < now) { //删除时间早于now的元素
          d_cont.erase(i++);
        }
        else
          ++i;
      }
    }

    typename cont_t::iterator i=d_cont.find(t);
    if(i==d_cont.end())
      return false;
    if(now > i->second.ttd || i->second.count-- < 0) { //throttle中的ttl小于now，表示过期的，删除之。或者被throttle block过的次数用完了，也删除之。表示本次请求可以不被block了。
      d_cont.erase(i);
      return false;
    }

    return true; // still listed, still blocked
  }

  // typedef Throttle<tuple<ComboAddress,string,uint16_t> > throttle_t;
  void throttle(time_t now, const Thing& t, unsigned int ttl=0, unsigned int tries=0)
  {
    typename cont_t::iterator i=d_cont.find(t);
    entry e={ now+(ttl ? ttl : d_ttl), tries ? tries : d_limit}; //从now开始计时的ttl秒内，被block tries次内，再来新的查询请求，会被直接block掉。

    if(i==d_cont.end()) {
      d_cont[t]=e;
    }
    else if(i->second.ttd > e.ttd || (i->second.count) < e.count) //使用较小的ttl，或者使用较大的被block次数
      d_cont[t]=e;
  }

  unsigned int size()
  {
    return (unsigned int)d_cont.size();
  }
private:
  int d_limit;
  int d_ttl;
  time_t d_last_clean;
  struct entry
  {
    time_t ttd;
    int count;
  };
  typedef map<Thing,entry> cont_t;
  cont_t d_cont;
};
```

{% endhighlight %}

如下的代码表示的含义

* 如果目标dns server unreachable，那么接下来的查询请求，在60秒内或者100次尝试内，会直接continue到下一个dns server。
* 如果目标dns server 超时，那么接下来的查询请求在10秒内或者5次尝试内，会直接continue到下一个dns server。
* 如果目标dns server servfail或者refused，那么接下来的查询请求在60秒内或者3次尝试内，会直接continue到下一个dns server。
* 其他的含义以此类推。

{% highlight c++ %}

```
if(resolveret==-1)
  t_sstorage->throttle.throttle(d_now.tv_sec, make_tuple(*remoteIP, qname, qtype.getCode()), 60, 100); // unreachable, 1 minute or 100 queries
else
  t_sstorage->throttle.throttle(d_now.tv_sec, make_tuple(*remoteIP, qname, qtype.getCode()), 10, 5);  // timeout
     }
     continue;
   }

t_sstorage->throttle.throttle(d_now.tv_sec,make_tuple(*remoteIP, qname, qtype.getCode()),60,3); // servfail or refused
```

{% endhighlight %}



## Authoritative DNS Server速度变慢之后又变快，速度列表如何更新？
dns server 速度变慢之后，在shuffleInSpeedOrder排序的时候就会被排到后面，这样被query到的几率就会变小。当此dns server速度又变快之后，什么时候会被重新查询到呢？

nsspeeds是一个这样的map

{% highlight c++ %}

```
typedef map<string, DecayingEwmaCollection, CIStringCompare> nsspeeds_t;
```

{% endhighlight %}

{% highlight c++ %}

```
double DecayingEwmaCollection::get(struct timeval* now)
{
  if(d_collection.empty())
    return 0;
  double ret=std::numeric_limits<double>::max();
  double tmp;
  for(collection_t::iterator pos=d_collection.begin(); pos != d_collection.end(); ++pos) {
    // pos : pair<ComboAddress, DecayingEwma>
	  if((tmp=pos->second.get(now)) < ret) {
      ret=tmp;
      d_best=pos->first;
    }
  }

  return ret;
}

typedef vector<pair<ComboAddress, DecayingEwma> > collection_t;
collection_t d_collection;

```

{% endhighlight %}

其中最重要的是

{% highlight c++ %}

```
syncres.hh: 109
/** Class that implements a decaying EWMA指数加权移动平均.
This class keeps an exponentially weighted moving average which, additionally, decays over time.
    The decaying is only done on get.
*/
class DecayingEwma {
  void submit(int val, struct timeval* tv)
  {
    struct timeval now=getOrMakeTime(tv);

    if(d_needinit) {
      d_last=now;
      d_lastget=now;
      d_needinit=false;
      d_val = val;
    }
    else {
      float diff= makeFloat(d_last - now);

      d_last=now;
      double factor=exp(diff)/2.0; // might be '0.5', or 0.0001
      d_val=(float)((1-factor)*val+ (float)factor*d_val);
      // 越是最近submit的，factor越接近0.5，越是很久没有submit过的，越小于0.5, 那么最近一次的val的值的权重就越大。
    }
  }

  double get(struct timeval* tv)
  {
    struct timeval now=getOrMakeTime(tv);
    float diff=makeFloat(d_lastget-now);
    d_lastget=now;
    float factor=exp(diff/60.0f); // is 1.0 or less
    return d_val*=factor; //如果频繁对每个dns的DecayingEwma进行get函数调用，那么factor基本接近于1. 越是长时间没有被get，越是小于1。
  }

  double peek(void)
  {
    return d_val;
  }

  bool stale(time_t limit) const
  {
    return limit > d_lastget.tv_sec;
  }

private:
  struct timeval d_last;          // stores time
  struct timeval d_lastget;       // stores time
  float d_val;
  bool d_needinit;
};
}

```

{% endhighlight %}

根据官方文档的描述，如果一个dns server被排到很后面而长时间没有被query到，那么随着时间的推移，该函数将此dns server的响应时间会变小（速度变快），使得它有机会被重新query到。参考 [pdns recursor design]

原因是，根据SyncRes::doResolve函数的查询逻辑，会先查cache，miss之后再去查询dns server。所以，只要cache命中，那么shuffleInSpeedOrder函数就不会被调用，等到ttl过期之后cache失效，shuffleInSpeedOrder再次被调用的时候，根据get函数的逻辑，factor必然小于1，那么d_val的值必然会比上一次小，随着时间的推移，除非前面的dns server速度加快的速度一直能够保持领先于d_val变小的速度，否则，后面的dns server肯定会有机会被query到。这也符合pdns设计的初衷，使得最快的dns server总是排在最前面。

对DecayingEwma算法的总结：

- submit方法的作用是实现EWMA算法，使得对某个dns server速度的评价主要参考最近的速度值。
- get方法的的作用是使得dns server的响应时间随着时间的推移进行衰减，也就是速度变快。

另外，有一个情况，如果ttl的值设置的非常长的话，那么后面dns server很久都不会经历速度排序，也就没有d_val的衰减。所以，pdns还有一个houseKeeping机制，当整个dns接受的query超过2万次后（见下面代码中的注释），就启动houseKeeping线程去做速度列表的清理，默认清理最近5分钟内speed值没有被get过的dns server。那么当下次shuffleInSpeedOrder函数被调用的时候，get得到的speed值就是0(见DecayingEwmaCollection::get)，也就是最快的值，那么这些dns server就有机会被query到了。

{% highlight c++ %}

```
pdns_recursor.cc
1866：
void* recursorThread(void* ptr){
  counter=0; // used to periodically execute certain tasks
  for(;;) {
    while(MT->schedule(&g_now)); // MTasker letting the mthreads do their thing

    if(!(counter%500)) { //cout代表的是total dns查询数，当查询次数正好模以500，就启动houseKeeping线程
      MT->makeThread(houseKeeping, 0);
    }

    if(!(counter%55)) {
      typedef vector<pair<int, FDMultiplexer::funcparam_t> > expired_t;
      expired_t expired=t_fdm->getTimeouts(g_now);

      for(expired_t::iterator i=expired.begin() ; i != expired.end(); ++i) {
        shared_ptr<TCPConnection> conn=any_cast<shared_ptr<TCPConnection> >(i->second);
        if(g_logCommonErrors)
          L<<Logger::Warning<<"Timeout from remote TCP client "<< conn->d_remote.toString() <<endl;
        t_fdm->removeReadFD(i->first);
      }
    }

    counter++;

}


1136：
static void houseKeeping(void *){
    std::cout << "cleanCounter " << cleanCounter << std::endl;
    if(!((cleanCounter++)%40)) {  // this is a full scan! 当houseKeeping线程启动的次数正好可以模以40，就清理nsSpeeds列表。
      time_t limit=now.tv_sec-300; //5分钟前
      std::cout << " housekeep work " << std::endl;
      for(SyncRes::nsspeeds_t::iterator i = t_sstorage->nsSpeeds.begin() ; i!= t_sstorage->nsSpeeds.end(); )
        if(i->second.stale(limit)){
          t_sstorage->nsSpeeds.erase(i++);
      	  std::cout << " housekeep clean " << i->first << std::endl;
        }
        else
          ++i;
    }
//    L<<Logger::Warning<<"Spent "<<dt.udiff()/1000<<" msec cleaning"<<endl;
    last_prune=time(0);
  }
}

```
{% endhighlight %}
