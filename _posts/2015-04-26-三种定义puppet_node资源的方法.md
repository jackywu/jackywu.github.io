---

layout: post   
title: 三种定义puppet node资源的方法  
category: articles  
tags: [puppet, hiera, enc, node.pp]  
author: JackyWu  
comments: true  

---


## 1. node.pp

node.pp文件里定义parameter + include class

## 2. ENC

ENC输出YAML格式string: class + parameter

## 3. Hiera
在Hierarchy里定义(yaml格式或者json格式): class + parameter(datasource)
