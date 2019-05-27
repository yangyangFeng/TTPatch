let global = this;

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
        let cacheImp;
        this.__methodCache.forEach(({method_key,value})=>{
            if(method === method_key){
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
            let funcImp = this.__methodList[method];
            funcImp?
            this.__methodCache.push({[method]:funcImp}):null;
            return funcImp;
        }else{
            let funcImp = this.__cls.__methodList[method];
            funcImp?
            this.__methodCache.push({[method]:funcImp}):null;
            return funcImp;
        }
    }

}

class JSObject {
    constructor(className,instance) {
        this.__isa = instance ? instance : null;
        // this.__metaIsa;
        this.__className = className;
        // this.__isInstance = instance ? true : false;
		this.__isInstance = !!instance;
        this.__count=0;
        this.__instanceFlag='';
    }
    release(){
        if(this.__count === 0){
            
            return true;
        }
        this.__count -= 1;
        if(this.__count === 0){
            return true;
        }
        return true;
    }
    retain(){
        this.__count+=1;
    }

	__toOcObject(){
		return this.__isa?this.__isa:null;
	}
}

class MetaObject {
    constructor(className,instance) {
        this.__isa = instance ? instance : null;
        // this.__metaIsa;
        this.__className = className;
        // this.__isInstance = instance ? true : false;
		this.__isInstance = !!instance;
        this.__count=0;
        this.__instanceFlag='';
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
        return '{'+this.x+', '+this.y+'}';
    }
}

class TTSize {
    constructor(width,height){
        this.width = width;
        this.height = height;
    }
    toOcString(){
        return '{'+this.width+', '+this.height+'}';
    }
}

class TTEdgeInsets {
    constructor(top,left,bottom,right){
        this.top = top;
        this.left = left;
        this.bottom = bottom;
        this.right = right;
    }
    toOcString(){
        return '{'+this.top+',' + this.left + ',' + this.bottom + ',' + this.right + '}';
    }
    
}

 (function() {
    Object.prototype = new MetaObject();
    Object.prototype.call = function(msg){
        let obj = CLASS_MAP[this.__className];
		let isInstance = this.__isInstance;
		let result;
		let params;

		let jsMethod_IMP = pv_findJSMethodMap(obj,msg,isInstance);

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
        }
        
        
        // var jsObj = new JSObject('JSObject',result);
        return pv_toJSObject(result);
    };
    // JSObject.prototype=new Object();
    


    // 引入 UIKit class
    global._import=function(name){
		let files = name.split(',').forEach((file) => {
			let jsClassObj = new JSObject(file);
			let test = Object.valueOf(file);
            pv__import(file);
        });
    };

	 let pv__import = function(clsName) {
        if (!global[clsName]) {
          global[clsName] = new JSObject(clsName);
        } 
        console.log('引入文件：'+clsName);
        return global[clsName]
      };

    // 定义Class
    global.defineClass=function(interface,instanceMethods,classMethods){
		let classInfo = oc_define(interface);
        // 注册JS类
		let obj = pv_registClass(classInfo['self'],classInfo['super'],instanceMethods,classMethods);
        // 注册方法
        pv_registMethods(obj);

    };


    // js API
    // Oc 消息转发至 js
    global.js_msgSend=function(instance,className,method){
        // retain self
		let curSelf = new JSObject(className,instance);
        curSelf.__instanceFlag = className+'-'+method;
        pv_retainJsObject(curSelf);

        let params;
		for (let i=3;i< arguments.length;i++){
			if(!params) params = new Array();
			params.push(pv_toJSObject(arguments[i]));
		}
        console.log('🍎🍎🍎🍎oc------------->js'+'    _func_ '+className+' ************** '+method+'');
        // oc_sendMsg(instance);
		let obj         = CLASS_MAP[className];
		let imp         = obj.__methodList[method];
		let result      = imp.apply(undefined,pv_toConsumableArray(params));

        // release self
        pv_releaseJsObject(curSelf);
        console.log('self-->'+method+'释放');

		if (result instanceof JSObject) {
			return result.__toOcObject();
		} else {
			return result;
		}


    };

    function pv_retainJsObject(obj){
        obj.retain();
        if(!self && !lastSelf){
            self=obj;
            lastSelf=obj;
        }else{
            self=obj;
        }
    }

    function pv_releaseJsObject(obj){
        if(obj.release()){
            if(obj.__instanceFlag===lastSelf.__instanceFlag){
                console.log(obj.__instanceFlag+'--------self、lastSelf 已释放');
                self=lastSelf=null;
                
            }else{
                
                console.log(obj.__instanceFlag+'--------self 已释放, lastSelf替换self');
                obj=null;
                self = lastSelf;
                
            }
        }
    };

    /**
      * 查询是否是本地JS方法，如果是则直接执行
      */
     function pv_findJSMethodMap(obj,msg,isInstanceMethod){
        if (obj){
            return obj.__findMethod(msg,isInstanceMethod);
        }
        return null;
     }

    /**
      * 注册 jsClassObj
      */
    function pv_registClass(className,superClassName,instancesMethods,classMethods){
		let obj = new Class_obj(className,superClassName,instancesMethods,classMethods);
        console.log('register------'+className);
        CLASS_MAP[obj.__className]=obj;
        return obj;
    }

    /**
      * 注册 jsClassObj Method
      */
    function pv_registMethods(cls){
		let isInstanceMethod = true;
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

	 function pv_toConsumableArray(arr) {
		 if (Array.isArray(arr)) {
			 for (let i = 0, arr2 = Array(arr.length); i < arr.length; i++) {
				 arr2[i] = arr[i];
			 }
			 return arr2;
		 } else {
			 return Array.from(arr);
		 }
	 }
    /**
      * 将JS对象 转为OC 可用对象
      */
    function pv_toOcObject(arg){
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

	 function pv_toJSObject(arg){
		 if(arg instanceof Object){
			 if(arg.hasOwnProperty('__isa')){
				 if(arg['__isInstance']){
					 // return new JSObject(arg['__className'],arg.__isa);
					 let cls = arg['__className'];
					 let value = arg['__isa'];
					 if (value instanceof Array){
						 let result = new Array();
						 arg.__isa.forEach(element => {
							 let jsObj = new JSObject('JSObject',element);
							 result.push(jsObj);
						 });
						 return result
					 }
					 else if(cls === 'react'){
						 return new TTReact(value.x,value.y,value.width,value.height);
					 }else if(cls === 'point'){
						 return new TTPoint(value.x,value.y);
					 }else if(cls === 'size'){
						 return new TTSize(value.width,value.height);
					 }else if(cls === 'edge'){
						 return new TTEdgeInsets(value.top,value.left,value.bottom.value.right);
					 }else if(  cls === 'NSArray' ||
						 cls === 'NSMutableArray'){
						 let result = new Array();
						 arg.forEach(element => {
							 let jsObj = new JSObject('JSObject',element);
							 result.push(jsObj);
						 });
						 return result
					 }else if (  cls === 'NSDictionary' ||
						 cls === 'NSMutableDictionary'){
						 return arg.__isa;
					 }


				 }
				 return new JSObject(arg.__className,arg.__isa);
			 }
			 return new JSObject('JSObject',arg);
		 }else{
			 console.log('基础数据类型:'+arg);
			 return arg;
		 }
	 }
    
    global.CLASS_MAP={};
    global.self = null;
    global.lastSelf = null;
 })();






