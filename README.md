# TTPatch
*热修复、热更新、JS代码动态下发、动态创建类*


[1. 使用文档](https://github.com/yangyangFeng/TTPatch/wiki/%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3)

[2. 基础用法](https://github.com/yangyangFeng/TTPatch/wiki/%E5%9F%BA%E7%A1%80%E7%94%A8%E6%B3%95)


> 风险提示: 请配合服务器下发开关使用, 通过配置决定`APP`是否初始化`TTPatch`模块

**审核问题请加群:978337686**
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

## 3. 基础用法
[我要参照TTPatch-JS模板](https://github.com/yangyangFeng/TTPatch/wiki/TTPatch-JS%E4%BD%BF%E7%94%A8%E6%A8%A1%E6%9D%BF)
### 0. build
`TTPatch`的使用流程
1. 源文件编写(伪`js`代码,不可直接执行).
2. 执行 `build.js`脚本
3. 通过`build.js`语法转义,变成`js`可执行代码.输出路径./outputs(具体要下发到app的js文件)


**⚠️`./outputs目录`不要修改,每次执行过`build.js`后会替换`./outputs`目录**
### 1. import
在使用Objective-C类之前需要调用 `_import('className’)` :

```js
_import('UIView')
var view = UIView.alloc().init()
```

可以用逗号 `,` 分隔，一次性导入多个类:

```js
_import('UIView, UIColor')
var view = UIView.alloc().init()
var red = UIColor.redColor()
```

### 2. 调用OC方法

#### 调用类方法

```js
var redColor = UIColor.redColor();
```

#### 调用实例方法

```js
var view = UIView.alloc().init();
view.setNeedsLayout();
```

#### 参数传递
跟在OC一样传递参数:

这里要注意下有参数的情况,参数前需要加`_`
`Obj-C`方法中的`:`和js中的`_`是一一对应的,如果有遗漏会error
```
var view = UIView.alloc().init();
var superView = UIView.alloc().init()
superView.addSubview_(view)
```

#### Property
声明和实例方法平级
```js
data:property(),
```
获取/修改 要通过 getter / setter 方法，获取时记得加 `()`:

```js
view.setBackgroundColor_(redColor);
var bgColor = view.backgroundColor();
```

#### 方法名转换

多参数方法名使用 `_` 分隔：

```js
var indexPath = NSIndexPath.indexPathForRow_inSection_(0, 1);
```

若原 OC 方法名里包含下划线 `_`，在 JS 使用双下划线 `__` 代替：

```js
// Obj-C: [JPObject _privateMethod];
JPObject.__privateMethod()
```
### 3. defineClass
声明Class,实现协议Protocol
#### API
```
// class:superClass<protocolA,protocolB,...>
defineClass('ViewController:UIViewController<UITableViewDelegate,UITableViewDataSource>',
{
    instanceMethods...
},
{
    classMethods...
});
```

@param `classDeclaration`: 字符串: `类名:父类名<Protocol>  `
@param `instanceMethods`: 要添加或覆盖的实例方法  
@param `classMethods`: 要添加或覆盖的类方法  

#### 覆盖方法

1.在 defineClass 里定义 OC 已存在的方法即可覆盖，方法名规则与调用规则一样，使用 `_` 分隔:

```objc
// OC
@implementation JPTableViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
@end
```
```js
// JS
defineClass("JPTableViewController", {
  tableView_didSelectRowAtIndexPath: function(tableView, indexPath) {
    ...
  },
})
```

2.使用双下划线 `__` 代表原OC方法名里的下划线 `_` :

```objc
// OC
@implementation JPTableViewController
- (NSArray *) _dataSource {
}
@end
```

```js
// JS
defineClass("JPTableViewController", {
  __dataSource: function() {
  },
})
```

3.在方法名前加 `tt` 即可调用未覆盖前的 OC 原方法:

```objc
// OC
@implementation JPTableViewController
- (void)viewDidLoad {
}
@end
```

```js
// JS
defineClass("JPTableViewController", {
  viewDidLoad: function() {
     self.ttviewDidLoad();
  },
})
```

#### 覆盖类方法

`defineClass()` 第三个参数就是要添加或覆盖的类方法，规则与上述覆盖实例方法一致：

```objc
// OC
@implementation JPTestObject
+ (void)shareInstance
{
}
@end
```
```js
// JS
defineClass("JPTableViewController", {
  //实例方法
}, {
  //类方法
  shareInstance: function() {
    ...
  },
})
```

#### 覆盖 Category 方法

覆盖 Category 方法与覆盖普通方法一样：

```objc
@implementation UIView (custom)
- (void)methodA {
}
+ (void)clsMethodB {
}
@end
```
```js
defineClass('UIView', {
  methodA: function() {
  }
}, {
  clsMethodB: function() {
  }
});
```

#### 添加新方法
  *TTPatch动态添加的方法分两类*
  1. 仅供JS端调用,此种方法因供JS端调用,所以采用普通方式声明即可.
  2. 供JS&Oc调用,此种访问因`Native`调用所以需要提供动态方法签名,写法如下

     方法名    关键字        返回值,参数        方法实现

        funcName:`dynamic("void, int", function(){})`

        如方法只有一个参数/返回值(id类型)可简化:dynamic(function(){}),也可以不写`dynamic`.

        Native动态方法签名默认: `v@:v'

[方法签名对照表](https://github.com/yangyangFeng/TTPatch/wiki/%E6%96%B9%E6%B3%95%E7%AD%BE%E5%90%8D%E5%AF%B9%E7%85%A7%E8%A1%A8#%E5%85%B3%E4%BA%8E%E6%96%B9%E6%B3%95%E7%AD%BE%E5%90%8D)
```objc
// OC
@implementation JPTableViewController
- (void)viewDidLoad
{
    [self funcWithParams:@"悟空"];
    [self funcWithParams:@"熊大" param2:@"熊二"];
    [self funcWithParams:@"百度" param2:@"腾讯" param3:@"阿里"];
}
@end
```
```js
// JS

defineClass("JPTableViewController", {
 	funcWithParams_:dynamic('void,id',function(param1){
		Utils.log_info('[1]动态方法入参:'+param1);
	}),
	funcWithParams_param2_:dynamic('void,id,id',function(param1,param2){
		Utils.log_info('[2]动态方法入参:'+param1+','+param2);
	}),
	funcWithParams_param2_param3_:dynamic('void,id,id,id',function(param1,param2,param3){
		Utils.log_info('[3]动态方法入参:'+param1+','+param2+','+param3);
	}),
})
```

#### Super

使用 `Super()` 接口代表 super 关键字，调用 super 方法:

```js
// JS
defineClass("JPTableViewController", {
  viewDidLoad: function() {
     Super().viewDidLoad();
  }
})
```

#### Property
##### 获取/修改 OC 定义的 Property
用调用 getter / setter 的方式获取/修改已在 OC 定义的 Property:

##### 动态新增 Property


可以在 name:property() 为属性

```
defineClass("JPTableViewController", {
  //添加属性
  name:property(),
  totalCount:property(),
  viewDidLoad: function() {
     Super().viewDidLoad();
     self.setName_("TTPatch");   //设置 Property 值
     var name = self.name();    //获取 Property 值
     var totalCount = self.totalCount()
  },
},{});
```

#### 私有成员变量

使用 `valueForKey()` 和 `setValue_forKey()` 获取/修改私有成员变量:

```objc
// OC
@implementation JPTableViewController {
     NSArray *_data;
}
@end
```
```js
// JS
defineClass("JPTableViewController", {
  viewDidLoad: function() {
     var data = self.valueForKey_("_data")     //get member variables
     self.setValue_forKey_(["Patch"], "_data")     //set member variables
  },
})
```



### 4. 特殊类型

#### Struct

支持 CGRect / CGPoint / CGSize / UIEdgeInsets 这四个 struct 类型，用 JS 对象表示:

```objc
// Obj-C
UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
[view setCenter:CGPointMake(10,10)];
[view sizeThatFits:CGSizeMake(100, 100)];



```

```js
// JS
var view = UIView.alloc().initWithFrame(new TTReact(x:20, y:20, width:100, height:100))
view.setCenter_(new TTPoint(x: 10, y: 10))
view.sizeThatFits_(new TTSize(width: 100, height:100))


```


#### Selector
在JS使用字符串代表 Selector:

```objc
//Obj-C
[self performSelector:@selector(viewWillAppear:) withObject:@(YES)];
```

```js
//JS
self.performSelector_withObject_("viewWillAppear:", 1)
```

### 5. Block

#### 新增Native方法中
调用Obj-C传入的block,需传入方法签名`?`代表block
动态生成的方法参数中包含`block`,要注意`block`是否包含`signature`信息,如确实则不可动态调用
> iOS 13下 WKWebView delegate 方法中 `block`缺少`signature`.

上述情况需要在调用时手动设置签名:
```
    decisionHandler(block(',int'),1);
```
'block(',int')'为签名,规则如下

[方法签名对照表](https://github.com/yangyangFeng/TTPatch/wiki/%E6%96%B9%E6%B3%95%E7%AD%BE%E5%90%8D%E5%AF%B9%E7%85%A7%E8%A1%A8#%E5%85%B3%E4%BA%8E%E6%96%B9%E6%B3%95%E7%AD%BE%E5%90%8D)
```

callBlock_:dynamic(',?',function(callback){
    if(callback){
        //自动获取签名
        callback(10);
    })
},

webView_decidePolicyForNavigationAction_decisionHandler_:dynamic(',id,id,?',function(webView, navigationAction, 
decisionHandler) {
    //手动设置签名
    decisionHandler(block(',int'),1);
}),
```
#### 新增纯JS方法中
```
callBlock_:function(callback){
    if(callback){
	callback(10);
    }
},
```

#### Obj-C调用js传入block,并接受回调
`JavaScript`的`block`传入`Obj-c`时要注意, `block`应声明方法参数及返回值类型 `,` 分割.
返回值在第一位
```
runBlock:function(){

    self.testCall2_(block("id,id"),function(arg){
        Utils.log_info('--------JS传入OC方法,接受到回调--------- 有参数,有返回值:string  '+arg);
        return '这是有返回值的哦';
    });
}

```

### 6. 调试
目前支持3中级别日志

`Utils.log` 只会在`debug`环境下的js中输出
`Utils.log_info` 在js 和 xcode中输出
`Utils.log_error` 在js 和 xcode中输出,并输出error信息

log不支持多参数,只支持参数拼接
```
var view = UIView.alloc().init();
var str = "test";
var num = 1;
Utils.log(str + num);   //直接在JS拼接字符串
```

也可以通过 Safari 的调试工具对 JS 进行断点调试，详见 [JS 断点调试](https://github.com/bang590/JSPatch/wiki/JS-%E6%96%AD%E7%82%B9%E8%B0%83%E8%AF%95)

## 4. 环境配置及使用

### 简单体验 I

首先要下载我们的demo工程,然后你只要修改`src`目录下的`.js`文件，然后运行 `npm run build`.这条命令会将我们刚刚修改的工作区代码(`src`)经过转义压缩输出到`outputs`目录下, `outputs`目录下的文件供app读取使用.

⚠️⚠️app不能直接读取`src`工作区的文件哦!!!!

### 简单体验 II
如果你已经熟练使用了`步骤 I`是不是觉得每次要经过下面三步,很麻烦. 那么你可以往下看
* `save`
* `run build`
* `run xocde`

目前`demo`已经支持模拟器/真机 在线实时预览修改内容了~~~~~

**下面为实时预览的准备工作**

1. 将`JS`目录下的`node.js`依赖下载成功.执行`npm install`即可.
2. 执行`npm run server` 开启本地服务
3. 将真机/模拟器调至同一`WIFI`下
4. 运行`demo`

> 如步骤1.失败请检查本地`npm,node`版本,下面给出我电脑版本供参考`npm -v  6.9.0`
/` node -v v10.16.0`


此时你的准备工作已经全部完成, 接下来用你最喜欢的`IDE`打开`src`目录下的任意`js`文件进行编辑, 在点击保存之后你会发现手机数据也跟着刷新了~~~~

### 实际使用 III

实际使用的话，就需要一些JS相关的支持，要确保本机已安装`npm`.如果不知道的同学可以百度安装。
如果已经安装好`npm`可以往下操作

1. `cd` /demo/JS  执行 `npm install`
2. `npm run server`



⚠️⚠️执行后，我们本地已经有可以执行`js`的环境了.
然后我们就可以在`/src`文件夹内修改`.js`源文件，修改后本地服务会自动执行打包更新并预览.


⚠️⚠️实际使用不要直接修改`outputs`目录, 因为每次`build`后 `outputs`目录会被全量替换

**关于build说明**
> 执行`npm run build` 将文件转成各自对应的js.

> 执行`npm run package` 将`src`目录下文件打包成一个文件.(demo中使用此种方式进行演示).





> 您的喜欢就是我更新的动力

