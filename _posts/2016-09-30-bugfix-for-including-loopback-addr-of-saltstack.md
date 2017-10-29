---

layout: post
title: bugfix-for-including-loopback-addr-of-saltstack
category: articles
tags: [bugfix, saltstack]
author: JackyWu
comments: true

---

addrs.discard('127.0.0.1') already remove 127.0.0.1 out of addrs, and salt.utils.network.ip_addrs will ignore 127.0.0.1 by default, so the code of line 589 if ipv4 in addrs will not works forever, because 127.0.0.1 will never be in addrs.

refer to: <https://github.com/saltstack/salt/issues/36669>
