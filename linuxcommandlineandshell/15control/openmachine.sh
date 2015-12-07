#########################################################################
# File Name: openmachine.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 18时44分08秒
#########################################################################
#!/bin/bash
#linux 开机过程
#System V init过程
.读取/etc/inittab inittab中含有运行级别
.其他一些采用/etc/init.rd/rc.d
.还有一些采用/etc/rc#.d目录

基于Debian发行版
0 关机
1 单用户
2~5 多用户 网络 图形化X Window
6 重启

基于Red Hat
0 关机
1 单用户
2 多用户 不支持网络（通常）
3 全功能多用户 支持网络
4 可自定义用户
5 多用户 网络 图形化 X Window
6 重启

#Upstart init
#/etc/event.d /etc/init 许多Upstart仍会调用较早的init.d 和 rc#.d中的脚本
#不关注运行级 关注时间 比如系统开机

#定义自己的开机脚本
#debian /etc/init.d/rc.local 
#fedora /etc/rc.d/rc.local
#mandriva /etc/rc.local
#opensuse /etc/init.d/boot.local
#ubuntu /etc/rc.local 
#制定特定的命令或语句 全路径名


#shell启动脚本
#.bashrc .bash_profile设置自启动脚本和环境变量
#.bash_profile新登录生成的新shell
#.bashrc新shell启动或者新登录情况
#/etc/bashrc所有用户在系统上启动一个新shell时

