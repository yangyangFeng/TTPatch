# TTPatch


[![Cocoapods](https://img.shields.io/cocoapods/l/TTDFKit)](https://cocoapods.org/pods/TTDFKit)
[![Cocoapods](https://img.shields.io/cocoapods/v/TTDFKit)](https://cocoapods.org/pods/TTDFKit)
[![CocoaPods](https://img.shields.io/badge/platform-iOS8.0+-yellowgreen)](https://cocoapods.org/pods/TTDFKit)

*热修复、热更新、JS代码动态下发、动态创建类*

> **1.0 master分支:** 通过消息转发实现
> 
> **2.0 libffi分支:** 通过通过libffi动态生成函数实现

**以上代码均已开源**

---
> TTPatch升级为2.0,核心实现替换为libffi实现.同时将代码重构,修改敏感命名.TTPatch更新为TTDFKit
>
> 风险提示: 仅供技术交流使用,上架有风险!!!!
>
> **热更新交流群:978337686**

[1. 使用文档](https://github.com/yangyangFeng/TTPatch/wiki/%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3)

[2. 基础用法](https://github.com/yangyangFeng/TTPatch/wiki/%E5%9F%BA%E7%A1%80%E7%94%A8%E6%B3%95)

[3. 在线工具](https://yangyangfeng.github.io/TTPatch_Convertor/.)

[4. 常见问题](https://github.com/yangyangFeng/TTPatch/wiki/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)

[5. 进阶用法](https://github.com/yangyangFeng/TTPatch/wiki/%E8%BF%9B%E9%98%B6%E7%94%A8%E6%B3%95)






## 1. 功能列表 

|功能特性|备注限制|
|------|-------|
|**支持手动设置系统Block签名**               | 如WKWebView一些系统级`block`缺失签名,无法动态调用|
|**替换指定`ObjectC`方法实现**          | 实例/静态方法均可替换实现|
|**动态创建方法供Native/Js调用**          | 需传入方法签名|
|**支持`block`**                      |`ObjectC`传入`JS`,  `JS`传入`ObjectC`均已支持|
|**支持添加属性**                     |为已存在的`class`添加属性|
|**支持基础数据类型**                   |非id类型,如`int`,`bool`均已支持|
|**支持下发纯`JS`页面**                    |纯`JS`代码映射原生代码,动态发布|
|**实现协议**                        | 2020年04月01日新增|
|**支持真机无线预览**                 | [详细说明](https://github.com/yangyangFeng/TTPatch/wiki/%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3#%E5%AE%9E%E9%99%85%E4%BD%BF%E7%94%A8-iii)|
|**支持`Native`代码转成`JS`脚本**                        | [在线地址](https://yangyangfeng.github.io/TTPatch_Convertor/)|
|**支持原生网络请求**                        |[使用示例](https://github.com/yangyangFeng/TTPatch/wiki/%E8%BF%9B%E9%98%B6%E7%94%A8%E6%B3%95#2-%E5%A6%82%E6%9E%9C%E5%86%99%E4%B8%80%E4%B8%AA%E7%BD%91%E7%BB%9C%E8%AF%B7%E6%B1%82) |
|**支持自定义插件**                        |[使用示例](https://github.com/yangyangFeng/TTPatch/wiki/%E8%BF%9B%E9%98%B6%E7%94%A8%E6%B3%95#1-%E8%87%AA%E5%AE%9A%E4%B9%89%E6%8F%92%E4%BB%B6) |
|**支持日志输出**                        |`debug/info/error` 方便错误排查,异常上报|


## 2. 安装


### CocoaPods `pod 2.1.2`

1. 在 Podfile 中添加  `pod 'TTDFKit'`。
2. 执行 `pod install` 或 `pod update`。
3. 导入 "TTDFKit.h"



> 您的喜欢就是我更新的动力

