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

[substrate](https://github.com/coolstar/substitute.git)  
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


## uncacheMubels.m  打印出所有不在dyld shared cache动态库的名字 

用task_info找出进程的信息,得到dyld_all_image_infos，遍历dyld_uuid_info数组来打印信息.
这个方法,比用_dyld_image_count  _dyld_get_image_name的方法准确，省去了名字匹配.   
现在是个人都知道hook _dyld_get_image_name来修改返回.


AppEnvCheck[13683:1851670] SubstrateBootstrap.dylib
AppEnvCheck[13683:1851670] /Developer/usr/lib/libBacktraceRecording.dylib
AppEnvCheck[13683:1851670] /Developer/Library/PrivateFrameworks/DTDDISupport.framework/libViewDebuggerSupport.dylib
AppEnvCheck[13683:1851670] /usr/lib/system/introspection/libdispatch.dylib
 AppEnvCheck[13683:1851670] SubstrateLoader.dylib
 AppEnvCheck[13683:1851670] /Library/MobileSubstrate/DynamicLibraries/AppAnalyze.dylib
 AppEnvCheck[13683:1851670] /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate
 AppEnvCheck[13683:1851670] /Library/MobileSubstrate/DynamicLibraries/AppEnvCheckHOOK.dylib
AppEnvCheck[13683:1851670] /Library/MobileSubstrate/DynamicLibraries/SSLKillSwitch2.dylib
AppEnvCheck[13683:1851670] /Library/MobileSubstrate/DynamicLibraries/TEMain.dylib
AppEnvCheck[13683:1851670] /Library/MobileSubstrate/DynamicLibraries/TSTweakEx.dylib
AppEnvCheck[13683:1851670] /Library/MobileSubstrate/DynamicLibraries/reveal2Loader.dylib

