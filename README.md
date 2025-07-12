# StuntFlySvr
## 简述
本仓库仅同步有关**StuntFlySvr**服务器的Pawn源代码，即通过`pawncc`与仓库源代码文件能编译输出所有服务器".amx"文件的最小源代码文件集。  
其他资源通过[Release](https://github.com/ChaseOne1/StuntFlySvr/releases/latest)页面打包发布，例如`config.json`、`sscanf.dll`、`scriptfiles/*`等。

## 构建
1. 从[open.mp](https://open.mp/)获取合适的默认服务端；
2. 拉取本仓库后移动源码至默认服务端，使用默认服务端内`qwano/pawncc`编译`filterscripts`与`gamemodes`下的源码；
3. 从[Release](https://github.com/ChaseOne1/StuntFlySvr/releases/latest)页面下载服务端资源并移动至默认服务端；
4. 配置并运行。