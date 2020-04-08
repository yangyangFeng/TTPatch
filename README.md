# TTPatch
*热修复、热更新、JS代码动态下发、动态创建类*


[1. 使用文档](https://github.com/yangyangFeng/TTPatch/blob/master/%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3.md)

[2. 基础用法](https://github.com/yangyangFeng/TTPatch/wiki/%E5%9F%BA%E7%A1%80%E7%94%A8%E6%B3%95)




## 1. 功能列表 

|功能特性|备注限制|
|------|-------|
|**替换指定`ObjectC`方法实现**          | 实例/静态方法均可替换实现|
|**支持`block`**                      |`ObjectC`传入`JS`,  `JS`传入`ObjectC`均已支持|
|**支持添加属性**                     |为已存在的`class`添加属性|
|**支持基础数据类型**                   |非id类型,如`int`,`bool`均已支持|
|**支持下发纯`JS`页面**                    |纯`JS`代码映射原生代码,动态发布|
|**实现协议**                        | 2020年04月01日新增|
|**支持真机无线预览**                 | [详细说明](https://github.com/yangyangFeng/TTPatch/blob/master/%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3.md#%E7%AE%80%E5%8D%95%E4%BD%93%E9%AA%8C-ii)|



## 2. 安装


### CocoaPods `pod 0.3.0`

1. 在 Podfile 中添加  `pod 'TTPatch'`。
2. 执行 `pod install` 或 `pod update`。
3. 导入 "TTPatch.h"


**演示项目**:Example.xcodeproj 
#### 运行效果图

![效果图.gif](https://wos2.58cdn.com.cn/DeFazYxWvDti/frsupload/cc8621a9531f405a65118f2a4fe1bfc1_demo1.gif)


#### 在线下发补丁执行
![在线下发补丁执行.gif](https://wos2.58cdn.com.cn/DeFazYxWvDti/frsupload/f5a7fff60c8cf40308cca5d783981204_demo2.gif)


#### 重启后加载已下发补丁
![重启后加载已下发补丁.gif](https://wos2.58cdn.com.cn/DeFazYxWvDti/frsupload/cc1be957bfb4597aefd42aa3c579f30b_demo3.gif)


> 您的喜欢就是我更新的动力

