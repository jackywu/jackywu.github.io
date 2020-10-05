---

layout: post
title: coc.nvim troubleshoot
category: technology
tags: [vim]
author: JackyWu
toc: true
comments: true

---

如果有兴趣，可以跟我联系交流：[这里](/contact/)

---

[toc]

## 前言

neoclide/coc.nvim: Intellisense engine for Vim8 & Neovim, full language server protocol support as VSCode，https://github.com/neoclide/coc.nvim/
在自动补齐方面的提示做的非常好，而且有丰富的语言插件可以用，如 coc-java，coc-python，coc-go 等等，基本都是开箱即用，可以不折腾。

但是coc后端封装的组件非常多，虽然会自动通过网络下载，但是由于身在国内，网络情况非常糟糕，造成安装失败的几率极高。这里记录一下自己安装过程中的问题解决方法。主要是安装 coc-java 过程中的一些问题。

## 修改NPM源为国内源

    npm config set registry https://registry.npm.taobao.org

## eclipse.jdt.ls

coc-java 使用的 language server 是 eclipse.jdt.ls, 但是下载速度极慢，所以最好的办法是使用国内镜像。
修改文件 `~/.config/coc/extensions/node_modules/coc-java/lib/index.js`，把 `http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz` 修改成 `http://mirrors.ustc.edu.cn/eclipse/jdtls/snapshots/jdt-language-server-latest.tar.gz`。

## gradle

gradle站点的下载速度也很慢，自己翻墙去官网下载 `gradle-6.6.1-all.zip`, 然后放到类似 `~/.gradle/wrapper/dists/gradle-6.6.1-bin/du4tvj86lhti6iga1v8h7pckb/gradle-6.6.1` 这样的目录里。

然后进入到java project根目录，打开任意文件，coc-java就会自动下载其他依赖进行环境配置，其自动补全功能就开箱即用了。如果肉身在墙外，那么更加简单，上面的问题全都不存在。
