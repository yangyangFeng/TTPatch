# TTPatch
热修复、热更新、JS代码动态下发、动态创建类


[简书地址](https://www.jianshu.com/p/1daf20977c4a)

[使用文档](https://github.com/yangyangFeng/TTPatch/blob/master/%E4%BD%BF%E7%94%A8%E6%96%87%E6%A1%A3.md)

---

## 关系方法注册和方法覆盖设计方案
* Oc 不存在的方法，无需注册到Oc中，只在Js端保留方法信息，供Js端代码直接调用
* Oc 已存在方法，需要先获取 `original IMP`，将原方法 IMP 替换成我们的消息转发，然后重新添加一个以 `original IMP` 为实现，`***` 为前缀的新方法。

## JS中声明Oc中的Class设计方案
**首先我们要搞清楚JS中引入新Class**

1、Class能被识别(非`undefined`)
2、Class能调用方法

**第一步让我们看看怎么做，如何让Oc Class能被JS识别呢？**

我们可以将Oc Class注册到global中，这样我们的Class就能被JS识别，而不是`undefined`类型.

**Class能识别了，那么在JS中如何才能调用Oc的方法而不报错呢？**

这个问题其实很简单,我的解决方案将 `impoet Class`包装成类似于`NSObject`的`JSObject`
```
class JSObject {
    constructor(className,instance) {
        this.__isa = instance ? instance : null;
        this.__metaIsa;
        this.__className = className;
        this.__isInstance = instance ? true : false;
    }
}
```
这样子的，`JSObject`作为操作对象就使我们接下来的方法调用变得可行。
因为如果以`String`的方式存到`global`中是不合理，首先当前调用者的信息我们无法全部保存，然后就是`String`如何像对象一样调用方法，所以看上去这是唯一可行的方案。

现在知道了我们所有的对象都是`JSObject`,下面看一段实际场景下的JS代码
``` 
UIView.call('alloc').call('initWithFrame:',new TTReact(120,100,100,100))
```
相信了解JS的人心里已经有了答案,其实我们只需要给`JSObject` 添加一个` call()`方法，这样所有的方法调用都经由` call()`方法做发送处理.

我之前看过`JSPatch`的使用文档，贴上一段代码：
``` 
UIView.alloc().init()
```
很好奇他是怎么做的,竟然可以在JS端调用Oc的方法.实现这个功能的方法是把所有的Oc方法注册到 `JSObject` 中，但是了解iOS的开发者知道，这是不友好的，任何一个`class`的继承关系都是很复杂的，感觉不是一个很小的工作。
所以这也是我没有像`JSPatch`这么写的原因。

**但是，可但是其实不是这样子的，`JSPatch`并不是真的可以在JS中调用Oc方法，他其实在Native端加载前做了转换，将**
```
UIView.alloc().init()
```
转成了
```
UIView.c('alloc').().c('init').()
```
大概就是这样吧，毕竟我是要自己写一套热更新机制，所以没有过多的看`JSPatch`具体实现，只是拿来和我的方案做比较，如何做更适合。



## Commit问题记录
###### 1.内存问题

解决方式 使用 `__unsafe_unretained` 修饰临时变量，防止 `strong`修饰的临时变量在局部方法结束时隐式调用 `release`，导致出现僵尸对象

###### 2.Oc调用js方法，多参数传递问题

这里面利用arguments和js中的```apply```,就可以以多参数调用，而不是一个为数组的```obj```对象

###### 3.关于添加`addTarget——action`方法

为View对象添加手势响应以及button添加action时，`action(sender){sender为当前控制器 self}` 为什么`Oc`中使用的时候`sender`为当前的手势orbutton对象？
如果```Native```未实现```action```方法，那么会导致获取方法签名失败而导致我们无法拿到正确参数，所以获得的参数为当前```self```.
这里要记录强调一下，如添加不存在的```action```时，要注意```action```参数不为当前的事件响应者.

###### 4.JS调用Oc方法，如何支持 `多参数`、`多类型` 调用

首先，我们要讲目标`Class`的`forwardingInvocation:`方法替换成我们自己的实现`TTPatch_Message_handle`，
然后通过替换方法的方式，将目标方法的`IMP`替换为`msg__objc_msgForward`,直接开始消息住转发，这样直接通过消息转发最终会运行到我们的`TTPatch_Message_handle`函数中，在函数中我们可以拿到当前正在执行方法的`invocation`对象，这也就意味着我们可以拿到当前调用方法的全部信息，并且可以操作以及修改。我们也是通过这个方法来实现，返回值类型转换。返回值类型转发这里涉及到

然后通过替换方法的方式，将目标方法的`IMP`替换为`msg__objc_msgForward`,直接开始消息住转发，这样直接通过消息转发最终会运行到我们的`TTPatch_Message_handle`函数中，在函数中我们可以拿到当前正在执行方法的`invocation`对象，这也就意味着我们可以拿到当前调用方法的全部信息，并且可以操作以及修改。我们也是通过这个方法来实现，返回值类型转换。返回值类型转发这里涉及的细节比较多，暂时只说一下最好的一种解决方案。
