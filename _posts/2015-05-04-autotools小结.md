---

layout: post   
title: Autotools小结  
category: articles  
tags: [automake, autoconf, autotools]  
author: JackyWu  
comments: true  

---  

## 构成

GNU build system == Autotools

* Autoconf
* Automake
* Libtool

## 步骤

1. autoscan 产生 configure.scan, 改名为 configure.ac
2. 修改 configure.ac


    The use of some macros has changed between different versions of Autoconf:
The package name and version was defined as arguments of AM_INIT_AUTOMAKE instead of AC_INIT.
AC_OUTPUT was getting the list of generated files instead of using the additional macro AC_CONFIG_FILES.

3. aclocal 产生 aclocal.m4
4. autoconf 产生 configure
5. 创建 Makefile.am  
6. automake --add-missing --foreign 产生 Makefile.in

    due to the switch `--add-missing` you get a few links to scripts necessary for building the project: `depcomp, install.sh and missing`. The other option `--foreign` tells to Automake that you don't want to follow GNU standard and you don't need mandatory documentation files: `INSTALL, NEWS, README, AUTHORS, ChangeLog and COPYING`. I have used it here to keep the number of created file to a minimum but else it is a good idea to provide these files, you can start with empty files.


7. configure 产生 Makefile
8. make 编译
9. make install 安装

## 工具

* autoreconf

    It is another tool part of the Autoconf package which is running all     scripts in the right order. To start a new project, you can just run autoreconf --install and it will call all necessary commands. 

    Run `autoconf' (and `autoheader', `aclocal', `automake', `autopoint'
(formerly `gettextize'), and `libtoolize' where appropriate)
repeatedly to remake the GNU Build System files in specified
DIRECTORIES and their subdirectories (defaulting to `.').

    
## 注意点

* configure.in is the name used in older version (before 2001) of Autoconf.    
* automake的参数



# 逻辑图

![](http://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Autoconf-automake-process.svg/400px-Autoconf-automake-process.svg.png)

# TODO

* 怎么写configure.ac
    * <http://www.gnu.org/software/autoconf/manual/autoconf.html#Writing-Autoconf-Input>    
* 怎么写Makefile.am
    * <http://www.gnu.org/software/autoconf/manual/automake.html>


# Reference

* Wiki GNU build system : <http://en.wikipedia.org/wiki/GNU_build_system>
* Gnome developt quick start : <https://developer.gnome.org/anjuta-build-tutorial/stable/create-autotools.html.en>
* GNU Autotools中文翻译 : <http://www.perfect-is-shit.com/GNU-autotools.html#tocAnchor-1-13-8>
* SourceForce Building a GNU Autotools Project : <http://inti.sourceforge.net/tutorial/libinti/autotoolsproject.html>
* GNU所有文档 : <http://www.gnu.org/manual/manual.html>
* Autoconf官方文档 : <http://www.gnu.org/software/autoconf/manual/autoconf.html#Writing-Autoconf-Input>
* Automake官方文档 : <http://www.gnu.org/software/automake/manual/html_node/Indices.html#Indices>

