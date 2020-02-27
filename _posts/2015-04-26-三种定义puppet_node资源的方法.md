---

   
title: 三种定义puppet node资源的方法  
category: technology  
tags: [puppet, hiera, enc, node.pp]  
author: JackyWu  
  

---

## Contact me

![](/assets/images/weixin-pic-jackywu.jpg)

或者用邮件交流 <a href="mailto:jacky.wucheng@foxmail.com">jacky.wucheng@foxmail.com</a>

## 1. node.pp

node.pp文件里定义parameter + include class

## 2. ENC

ENC输出YAML格式string: class + parameter

## 3. Hiera
在Hierarchy里定义(yaml格式或者json格式): class + parameter(datasource)
