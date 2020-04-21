let global = this;

class MessageQueue {
}

MessageQueue.call = function (obj,isSuperInvoke,isInstance, msg, params) {
    /***
	 * 	params1	: target
	 * 			: 是否是super()
	 * 			: 是否是实例方法
	 * 			: 方法名
	 * 			: 参数
	 */
	return MessageQueue_oc_sendMsg(obj,isSuperInvoke,isInstance, msg, params);
};
MessageQueue.block = function (obj, params, signature) {
    
    return MessageQueue_oc_block(obj, params,signature);
};
MessageQueue.define = function (className) {
    return MessageQueue_oc_define(className);
};
MessageQueue.replaceMethod = function (className, superClassName, key, isInstanceMethod, propertys) {
    return MessageQueue_oc_replaceMethod(className, superClassName, key, isInstanceMethod, propertys);
};
MessageQueue.replaceDynamicMethod = function (className, superClassName, key, isInstanceMethod, propertys, signature) {
    return MessageQueue_oc_replaceDynamicMethod(className, superClassName, key, isInstanceMethod, propertys, signature);
};
MessageQueue.registerProperty = function (className, superClassName, propertys) {
    return MessageQueue_oc_addPropertys(className, superClassName, propertys);
};
MessageQueue.MessageQueue_oc_setBlock = function (jsFunc) {
    return MessageQueue_oc_setBlock(jsFunc);
};
MessageQueue.ProjectConfig_IS_USE_NATIVE_DATA = function (){
    var flag = ProjectConfig_IS_USE_NATIVE_DATA();
    return flag;
}

class Utils {
}
log_level_debug=1;
log_level_info=2;
log_level_error=3;

Utils.log_error = function (params) {
    Utils_Log(log_level_error,params);
}
Utils.log_info = function (params) {
    Utils_Log(log_level_info,params);
    Utils.log(params);
}
Utils.log=function (msg) {
    if (Utils.isDebug()){
        let params;
        for (let i = 0; i < arguments.length; i++) {
            if (!params) params = new Array();
            params.push(arguments[i]);
        }
        console.debug.apply(null,params);
    }
};

Utils.isDebug=function () {
    return APP_IsDebug();
};


this.block=function(signature,callback){
    return new Block(signature,callback);
}

class MetaObject {
    constructor(className, instance) {
        this.__isa = instance ? instance : null;
        // this.__metaIsa;
        this.__className = className;
        // this.__isInstance = instance ? true : false;
        this.__isInstance = !!instance;
        this.__count = 0;
        this.__instanceFlag = '';
    }

    release() {
        if (this.__count === 0) {

            return true;
        }
        this.__count -= 1;
        if (this.__count === 0) {
            return true;
        }
        return true;
    }

    retain() {
        this.__count += 1;
    }
}

class Class_obj extends MetaObject{
    constructor(className, superClassName, instancesMethods, classMethods, propertys, dynamicSignatureList) {
        super(className)
        this.__superClassName = superClassName;
        this.__methodList = instancesMethods;
        this.__property_list = propertys;
        this.__methodCache = new Array(3);
        this.__dynamicSignatureList = dynamicSignatureList;
        this.__cls = classMethods ? new Class_obj(className, superClassName, classMethods, false,null) : null;
    }

    __obj(isInstance){
        if (isInstance){
            return this;
        }else {
            return this.__cls;
        }
    }

    __findMethod(method, isInstanceMethod) {
        let cacheImp;
        this.__methodCache.forEach(({method_key, value}) => {
            if (method === method_key) {
                cacheImp = value;
            }
        });
        this.__methodCache.forEach(item => {
            if (item.hasOwnProperty(method)) {
                cacheImp = item[method];
            }
        });
        if (cacheImp) {
            return cacheImp;
        }
        if (isInstanceMethod) {
            let funcImp = this.__methodList[method];
            funcImp ?
                this.__methodCache.push({[method]: funcImp}) : null;
            return funcImp;
        } else {
            let funcImp = this.__cls.__methodList[method];
            funcImp ?
                this.__methodCache.push({[method]: funcImp}) : null;
            return funcImp;
        }
    }

}


class JSObject extends MetaObject{
    constructor(className, instance) {
        super(className, instance);
    }

    __toOcObject() {
        return this.__isa ? this.__isa : null;
    }
    //获取当前Value
    value(){
        return this.__toOcObject();
    }
}

class Block extends JSObject{
    constructor(signature, instance,key,isHasParams) {
        super('block',instance);
        this.__isHasParams = isHasParams;
        this.__key = key;
        this.__signature = signature;
    }
    invocate(){
        
        let params;
        for (let i = 0; i < arguments.length; i++) {
            if (!params) params = new Array();
            params.push(arguments[i]);
        }
        // Utils.log('-------'+params);
        // return this.__isa.apply(null,params);
        return this.__isa(params);
    }
    getBlock(arg){
        let isJsFunc = false;
        let indexOffset = 0;
        if (typeof this.__isa === 'function'){isJsFunc = true}
        if (arg instanceof Block) {
            indexOffset=1;
            this.__signature=arg.__signature;
        }
        let params;
        for (let i = indexOffset; i < arguments.length; i++) {
            if (!params) params = new Array();
                params.push(
                    isJsFunc ?
                    arguments[i] :
                    pv_toOcObject(arguments[i])
                );
        }
        
        //jsfunction
        if (isJsFunc){
            return this.__isa.apply(null,params);
        }else{
            return MessageQueue.block(this.__isa,params,this.__signature);
        }
    }
    getFuncSignature(){
        return this.__signature;
    }
}

class Dynamic extends JSObject{
    constructor(signature, func) {
        super('dynamic',null);
        this.__signature = signature;
        this.__imp = func;
		this.__imp = func; 
        this.__imp = func;
    }
    getImp(){
        return this.__imp;
    }
    getSignature(){
        return this.__signature;
    }
}

this.dynamic=function(signature,func){
    if(func == null) {func=signature;signature=null;}
    if(signature==null || signature=='') signature=','
    return new Dynamic(signature,func);
}


class Property {
    constructor(adorn, instance) {
        this.__adorn = adorn;
        this.__instance = instance;
        this.__name = '';
    }
}

class TTReact {
    constructor(x, y, width, height) {
        this.origin = new TTPoint(x, y);
        this.size = new TTSize(width, height);
    }

    toOcString() {
        return '{{' + this.origin.x + ', ' + this.origin.y + '}, {' + this.size.width + ', ' + this.size.height + '}}';
    }
}

class TTPoint {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }

    toOcString() {
        return '{' + this.x + ', ' + this.y + '}';
    }
}

class TTSize {
    constructor(width, height) {
        this.width = width;
        this.height = height;
    }

    toOcString() {
        return '{' + this.width + ', ' + this.height + '}';
    }
}

class TTEdgeInsets {
    constructor(top, left, bottom, right) {
        this.top = top;
        this.left = left;
        this.bottom = bottom;
        this.right = right;
    }

    toOcString() {
        return '{' + this.top + ',' + this.left + ',' + this.bottom + ',' + this.right + '}';
    }

}

(function () {
    // 引入 UIKit class
    global._import = function (name) {
        let files = name.split(',').forEach((file) => {
            pv__import(file);
        });
    };

    let pv__import = function (clsName) {
        if (!global[clsName]) {
            global[clsName] = new JSObject(clsName);
            Utils.log('import：' + clsName);
        }
        return global[clsName]
    };

    // 定义Class
    global.defineClass = function (interface, instanceMethods, classMethods) {
        let classInfo = MessageQueue.define(interface);
        // 在JS全局声明Class
        let obj = pv_registClass(classInfo['self'], classInfo['super'], instanceMethods, classMethods);
        pv__import(classInfo['self']);
        pv_addPropertys(obj);
        // 在Native环境中创建并注册方法
        pv_registMethods(obj);

    };

    global.property = function (adorn, obj) {
        return new Property(adorn, obj);
    };

    Object.prototype._c = function (msg) {
        let obj = CLASS_MAP[this.__className];
        let isInstance = this.__isInstance;
        let result;
        let params;
        let curSelf=self;
        self=this;

        let jsMethod_IMP = pv_findJSMethodMap(obj, msg, isInstance);

        for (let i = 1; i < arguments.length; i++) {
            if (!params) params = new Array();
            if (jsMethod_IMP){
                params.push(arguments[i]);
            }else{
                let param = arguments[i];
                if (param instanceof Block) {
                    let blockKey = msg+i;
                    param.__key=blockKey;
                    global.curExecFuncArguments[blockKey] = param;
                    params.push(pv_toOcObject(param));
                }else {
                    params.push(pv_toOcObject(param));
                }
            }
        }
        // if (this instanceof Block | typeof this === 'NSBlock'){
        //     this.__isa.apply(this.params);
        // }
        // else
        if (jsMethod_IMP && !ttpatch__isSuperInvoke) {
            result = jsMethod_IMP.apply(this, params ? params : null);
        }
        else if (this[msg] || (!this.__isa && !this.__className && !ttpatch__isSuperInvoke) ) {
            jsMethod_IMP = this[msg];
            self=curSelf;
            return jsMethod_IMP.apply(this, params);
        }
        else if (isInstance) {
            result = MessageQueue.call(this.__isa, ttpatch__isSuperInvoke, isInstance,msg, params);
        } else {
            result = MessageQueue.call(this.__className, ttpatch__isSuperInvoke, isInstance,msg, params);
        }

        //super调用已完成，将状态重新置为false
        global.ttpatch__isSuperInvoke=false;
        self=curSelf;
        return pv_toJSObject(result);
    };

    // native call js
    // Oc 消息转发至 js
    global.js_msgSend = function (instance, className, method, isInstance) {
        //当前方法显示参数长度，解析 params 时使用
        let funcTargetActionLength = 4;
        // retain self
        let curSelf = new JSObject(className, instance);
        curSelf.__instanceFlag = className + '-' + method;
        pv_retainJsObject(curSelf);

        let params;
        for (let i = funcTargetActionLength; i < arguments.length; i++) {
            if (!params) params = new Array();
            params.push(pv_toJSObject(arguments[i]));
        }
        // Utils.log('oc------------->js' + '[' + className + ']:' + method + '');
        let obj = CLASS_MAP[className].__obj(isInstance);
        let imp = obj.__methodList[method];
        let result = imp.apply(undefined, params);

        // release self
        pv_releaseJsObject(curSelf);
        // Utils.log('[self] ' + method + ' release');

        if (result instanceof JSObject) {
            return result.__toOcObject();
        } else {
            return result;
        }
    };

    // function pv__getFuncParams(arguments) {
    //     let params;
    //     for (let i = 1; i < arguments.length; i++) {
    //         if (!params) params = new Array();
    //         params.push(arguments[i]);
    //     }
    //     return params;
    // }

    function pv_retainJsObject(obj) {
        obj.retain();
        if (!self && !lastSelf) {
            self = obj;
            lastSelf = obj;
        } else {
            self = obj;
        }
    }

    function pv_releaseJsObject(obj) {
        if (obj.release()) {
            if (obj.__instanceFlag === lastSelf.__instanceFlag) {
                // Utils.log(obj.__instanceFlag + 'self and lastSelf release');
                self = lastSelf = null;

            } else {
                // Utils.log(obj.__instanceFlag + 'self release, lastSelf replace self');
                obj = null;
                self = lastSelf;
            }
        }
    };

    /**
     * 查询是否是本地JS方法，如果是则直接执行
     */
    function pv_findJSMethodMap(obj, msg, isInstanceMethod) {
        if (obj) {
            return obj.__findMethod(msg, isInstanceMethod);
        }
        return null;
    }

    /**
     * 注册 jsClassObj
     */
    function pv_registClass(className, superClassName, instancesMethods, classMethods) {
        let methodList = {};
        let property_list = [];
        let dynamicSignatureList = {};
        for (let key in instancesMethods) {
            let value = instancesMethods[key];
            if (value instanceof Property) {
                value['__name'] = key;
                property_list.push(value);
            }
            else if(value instanceof Dynamic){
                methodList[key]=value.getImp();
                dynamicSignatureList[key]=value.getSignature();
            }
            else {
                methodList[key]=value;
            }
        }

        let obj = new Class_obj(className, superClassName, methodList, classMethods, property_list, dynamicSignatureList);
        Utils.log('register: [ ' + className+' ]');
        CLASS_MAP[obj.__className] = obj;
        pv__import(className);
        return obj;
    }

    /**
     * 添加属性
     */
    function pv_addPropertys(cls) {
        MessageQueue.registerProperty(cls.__className,cls.__superClassName,cls.__property_list);
    }

    /**
     * 注册 jsClassObj Method
     */
    function pv_registMethods(cls) {
        let isInstanceMethod = true;
        if (cls.__cls == null) {
            isInstanceMethod = false;
        }
        for (const key in cls.__methodList) {
            // if (key != '_c' && cls.__methodList.hasOwnProperty(key) && cls.__dynamicSignatureList.hasOwnProperty(key)) {
                if (key == '_c') continue;
                let method = cls.__methodList[key];
                
                let signature = cls.__dynamicSignatureList?cls.__dynamicSignatureList[key]:'';
                signature=signature?signature:'';
                // Utils.log_info(key+'----signature:'+signature);
                MessageQueue.replaceDynamicMethod(cls.__className, cls.__superClassName, key, isInstanceMethod, cls.__property_list, signature);
            // }else{
            //     let method = cls.__methodList[key];
            //     MessageQueue.replaceMethod(cls.__className, cls.__superClassName, key, isInstanceMethod, cls.__property_list);
            // }
        }
        return isInstanceMethod ? pv_registMethods(cls.__cls) : null;
    }
    
    /**
     * 将JS对象 转为OC 可用对象
     */
    pv_toOcObject=function (arg) {
        if (arg == null) {
            return null;
        }
        let obj;
        if (arg instanceof Block) {
            obj = arg;
            MessageQueue.MessageQueue_oc_setBlock(arg.__isa);
        }
        else if (arg instanceof TTReact) {
            obj = new JSObject('react', arg.toOcString());
        }
        else if (arg instanceof TTSize) {
            obj = new JSObject('size', arg.toOcString());
        }
        else if (arg instanceof TTPoint) {
            obj = new JSObject('point', arg.toOcString());
        }
        else if (arg instanceof Array) {
            let result = new Array();
            arg.forEach(element => {
                let jsObj = pv_toOcObject(element);
                result.push(jsObj);
            });
            return result;
        }
        else if (typeof arg === 'function') {
            //暂时不做多余处理
            // MessageQueue.MessageQueue_oc_setBlock(arg);
            obj=arg;
        }
        else if (arg instanceof JSObject) {
            return arg.__isa ? arg.__isa : null;
        }
        else {
            obj = arg;
        }
        obj._c=null;
        return obj;
    }

    function pv_toJSObject(arg) {
        if (arg instanceof Object) {
            if (arg.hasOwnProperty('__isa')) {
                if (arg['__isInstance']) {
                    // return new JSObject(arg['__className'],arg.__isa);
                    let cls = arg['__className'];
                    Utils.log('class:'+cls);
                    let value = arg['__isa'];
                    if (cls === 'block') {
                        let block = new Block('', arg.__isa);
                        return block.getBlock.bind(block);
                    }
                    else if (cls === 'react') {
                        return new TTReact(value.x, value.y, value.width, value.height);
                    } else if (cls === 'point') {
                        return new TTPoint(value.x, value.y);
                    } else if (cls === 'size') {
                        return new TTSize(value.width, value.height);
                    } else if (cls === 'edge') {
                        return new TTEdgeInsets(value.top, value.left, value.bottom.value.right);
                    } else if (!MessageQueue.ProjectConfig_IS_USE_NATIVE_DATA() &&
                                (cls === 'NSArray' || cls === 'NSMutableArray')) {
                        let result = new Array();
                        arg.__isa.forEach(element => {
                            let jsObj = pv_toJSObject(element);
                            result.push(jsObj);
                        });
                        return result
                    } else if (!MessageQueue.ProjectConfig_IS_USE_NATIVE_DATA() &&
                        (cls === 'NSDictionary' ||
                        cls === 'NSMutableDictionary' ||
                        cls === 'NSString' ||
                        cls === 'NSNumber')) {
                        return arg.__isa;
                    }
                }
                let obj = new JSObject(arg.__className, arg.__isa);
                arg=null;
                return obj;
            }
            // return arg;
            return new JSObject('JSObject', arg);
        } else {
            // console.log('基础数据类型:'+arg);
            return arg;
        }
    }

    jsBlock=function(index){
        let params;
        for (let i = 1; i < arguments.length; i++) {
            if (!params) params = new Array();
                params.push(
                    arguments[i]
                );
        }
        let funcBlock = curExecFuncArguments[index];//block
        return pv_toOcObject(pv_toJSObject(funcBlock.__isa.apply(null,params)));
    }

    

    global.CLASS_MAP = {};
    global.curExecFuncArguments = {};
    global.self = null;
    global.lastSelf = null;
    global.ttpatch__isSuperInvoke = false;
    global.Super=function () {
        ttpatch__isSuperInvoke = true;
        return self;
    }
})();








// 获取函数的参数名
// function getParameterName(fn) {
//     if(typeof fn !== 'object' && typeof fn !== 'function' ) return;
//     const COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg;
//     const DEFAULT_PARAMS = /=[^,)]+/mg;
//     const FAT_ARROWS = /=>.*$/mg;
//     let code = fn.prototype ? fn.prototype.constructor.toString() : fn.toString();
//     code = code
//         .replace(COMMENTS, '')
//         .replace(FAT_ARROWS, '')
//         .replace(DEFAULT_PARAMS, '');
//     let result = code.slice(code.indexOf('(') + 1, code.indexOf(')')).match(/([^\s,]+)/g);
//     return result === null ? [] :result;
// }
