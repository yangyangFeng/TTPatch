var global = this;

class Class_obj {
    constructor(className, superClassName, instancesMethods, classMethods) {
        this.__cls;
        this.__className = className;
        this.__superClassName = superClassName;
        this.__methodList = instancesMethods;
        this.__cls = classMethods ? new Class_obj(className, superClassName, classMethods, false) : null;

        this.__methodCache=new Array(3);
    }
    __findMethod(method,isInstanceMethod){
        var cacheImp;
        this.__methodCache.forEach(({method_key,value})=>{
            if(method == method_key){
                cacheImp=value;
            }
        });
        this.__methodCache.forEach(item => {
            if(item.hasOwnProperty(method)){
                cacheImp=item[method];
            }
        });
        if (cacheImp){
            return cacheImp;
        }
        if (isInstanceMethod) {
            var funcImp = this.__methodList[method];
            funcImp?
            this.__methodCache.push({[method]:funcImp}):null;
            return funcImp;
        }else{
            var funcImp = this.__cls.__methodList[method];
            funcImp?
            this.__methodCache.push({[method]:funcImp}):null;
            return funcImp;
        }
    }
}

class JSObject {
    constructor(className,instance) {
        this.__isa = instance ? instance : null;
        this.__metaIsa;
        this.__className = className;
        this.__isInstance = instance ? true : false;
    }
}



class TTReact {
    constructor(x, y, width, height){
        this.origin = new TTPoint(x,y);
        this.size = new TTSize(width,height);
    }
    toOcString(){
        return '{{'+this.origin.x+', '+this.origin.y+'}, {'+this.size.width+', '+this.size.height+'}}';
    }
}

class TTPoint {
    constructor(x,y){
        this.x = x;
        this.y = y;
    }
    toOcString(){
        return '{'+this.origin.x+', '+this.origin.y+'}';
    }
}

class TTSize {
    constructor(width,height){
        this.width = width;
        this.height = height;
    }
    toOcString(){
        return '{'+this.size.width+', '+this.size.height+'}';
    }
    
}

 (function() {

    JSObject.prototype.call = function(msg){
        var obj = CLASS_MAP[this.__className];
        var isInstance = this.__isInstance;
        var result;
        var params;

        var jsMethod_IMP = pv_findJSMethodMap(obj,msg,isInstance);

        for (var i=1;i< arguments.length;i++){
            if(!params) params = new Array();
            params.push(
                jsMethod_IMP?
                arguments[i]:
                pv_toOcObject(arguments[i]));
        }
   
        if (jsMethod_IMP){
            result = jsMethod_IMP(params?params:null);
        }
        else if (isInstance){
            result = oc_sendMsg(this.__isa,msg,params);
        }else{
            result = oc_sendMsg(this.__className,msg,params);
            // this.__isa = result;
            // this.__isInstance = true;
        }
        
        
        var jsObj = new JSObject('JSObject',result);
        return jsObj;
    }
    
   

    // 引入 UIKit class
    global._import=function(name){
        var files = name.split(',').forEach((file) => {
            var jsClassObj = new JSObject(file);
            var test = Object.valueOf(file);
            pv__import(file);
        });
        console.log('引入文件：'+files);
    

    }

    var pv__import = function(clsName) {
        if (!global[clsName]) {
          global[clsName] = new JSObject(clsName);
        } 
        return global[clsName]
      }

    // 定义Class
    global.defineClass=function(interface,instanceMethods,classMethods){
        var classInfo = oc_define(interface)
        // 注册JS类
        var obj = pv_registClass(classInfo['self'],classInfo['super'],instanceMethods,classMethods);
        // 注册方法
        pv_registMethods(obj);

    };

    // js API
    // Oc 消息转发至 js
    global.js_msgSend=function(instance,className,method,args){
        // 记录当前self
        self = new JSObject(className,instance);
        
        console.log(instance+'调用到js func');
        // oc_sendMsg(instance);
        var obj         = CLASS_MAP[className];
        var imp         = obj.__methodList[method];
        var result      = imp();
        //清空
        self=null;
        return result;
    };

    /**
      * 查询是否是本地JS方法，如果是则直接执行
      */
     pv_findJSMethodMap=function(obj,msg,isInstanceMethod){
        if (obj){
            return obj.__findMethod(msg,isInstanceMethod);
        }
        return null;
     }

    /**
      * 注册 jsClassObj
      */
    pv_registClass=function(className,superClassName,instancesMethods,classMethods){
        var obj = new Class_obj(className,superClassName,instancesMethods,classMethods);
        console.log('register------'+className);
        CLASS_MAP[obj.__className]=obj;
        return obj;
    }

    /**
      * 注册 jsClassObj Method
      */
    pv_registMethods=function(cls){
        var isInstanceMethod = true;
        if(cls.__cls == null){
            isInstanceMethod = false;
        }
        for (const key in cls.__methodList) {
            if (cls.__methodList.hasOwnProperty(key)) {
                const method = cls.__methodList[key];
                oc_replaceMethod(cls.__className,cls.__superClassName,key,isInstanceMethod);
            }
        }
        return isInstanceMethod?pv_registMethods(cls.__cls):null;
    }

    /**
      * 将JS对象 转为OC 可用对象
      */
    pv_toOcObject=function(arg){
        if(arg instanceof JSObject){
            return arg.__isa?arg.__isa:null;
        }else if(arg instanceof TTReact){
            return new JSObject('react',arg.toOcString());
        }
        else if(arg instanceof TTSize){
            return new JSObject('size',arg.toOcString());
        }
        else if(arg instanceof TTPoint){
            return new JSObject('point',arg.toOcString());
        }
        else {
            return arg;
        }
    }
    
    global.CLASS_MAP={};
    global.self = null;
 })();






