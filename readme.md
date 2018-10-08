## [Fish Hook](https://github.com/facebook/fishhook)

自已的代码编译生成的函数，都存放于macho文件的`__TEXT`区  
如果是系统的原函数，则位于`__DATA`区

如果检测到系统的函数(如open,getenv等)，它的函数地址位于`__TEXT`区，则可断定它被fish hook重绑定了

### 环境: arm64 
### tested in: iOS11, iOS9
### 程序运行结果

```
open hooked: 0
dladdr hooked: 0
read hooked: 0
getenv hooked: 0

2018-10-08 19:20:41.697 AppEnvCheck[12374:1659019] my getenv
2018-10-08 19:20:41.697 AppEnvCheck[12374:1659019] my getenv
2018-10-08 19:20:41.697 AppEnvCheck[12374:1659019] my getenv
2018-10-08 19:20:41.697 AppEnvCheck[12374:1659019] my open
2018-10-08 19:20:41.698 AppEnvCheck[12374:1659019] my getenv
2018-10-08 19:20:41.698 AppEnvCheck[12374:1659019] my getenv
2018-10-08 19:20:41.698 AppEnvCheck[12374:1659019] my getenv
2018-10-08 19:20:41.698 AppEnvCheck[12374:1659019] my getenv

open hooked: 1
dladdr hooked: 0
read hooked: 0
getenv hooked: 1
```

## InLine Hook

[substrate]((https://github.com/coolstar/substitute.git))  
[HookZz](https://github.com/jmpews/HookZz)  

检测函数前几个汇编指令是否为跳转指令即可。 

### 环境: arm64 ,tested in: iOS9

```
open hooked: 0
dladdr hooked: 0
read hooked: 0
getenv hooked: 0
getchar hooked: 1
```



