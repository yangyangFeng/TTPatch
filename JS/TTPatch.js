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
MessageQueue.block = function (obj, params) {
	return MessageQueue_oc_block(obj, params);
};
MessageQueue.define = function (className) {
	return MessageQueue_oc_define(className);
};
MessageQueue.replaceMethod = function (className, superClassName, key, isInstanceMethod, propertys) {
	return MessageQueue_oc_replaceMethod(className, superClassName, key, isInstanceMethod, propertys);
};
MessageQueue.registerProperty = function (className, superClassName, propertys) {
	return MessageQueue_oc_addPropertys(className, superClassName, propertys);
};
MessageQueue.MessageQueue_oc_setBlock = function (jsFunc) {
	return MessageQueue_oc_setBlock(jsFunc);
};

class Util {
}

Util.log=function (msg) {
	if (Util.isDebug()){
		let params;
		for (let i = 0; i < arguments.length; i++) {
			if (!params) params = new Array();
			params.push(arguments[i]);
		}
		console.log.apply(null,params);
	}
};
Util.isDebug=function () {
	return APP_IsDebug();
};

this.block=function(signature){
	return new Block(signature)
}

class Class_obj {
	constructor(className, superClassName, instancesMethods, classMethods, propertys) {
		this.__cls;
		this.__className = className;
		this.__superClassName = superClassName;
		this.__methodList = instancesMethods;
		this.__property_list = propertys;
		// this.__findPropertys();
		this.__methodCache = new Array(3);
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
}

class JSObject extends MetaObject{
	constructor(className, instance) {
		super(className, instance);
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

	__toOcObject() {
		return this.__isa ? this.__isa : null;
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
		Util.log('-------'+params);
		// return this.__isa.apply(null,params);
		return this.__isa(params);
	}
	getBlock(){
		let isJsFunc = false;
		if (typeof this.__isa === 'function'){isJsFunc = true}
		let params;
		for (let i = 0; i < arguments.length; i++) {
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
			return MessageQueue.block(this.__isa,params);
		}
	}
	getFuncSignature(){
		return this.__signature;
	}
}

// class BlockOC {
// 	constructor(key, isHasParams) {
	
// 	}
// }


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
	// Object.prototype = new MetaObject();
	Object.prototype.call = function (msg) {
		let obj = CLASS_MAP[this.__className];
		let isInstance = this.__isInstance;
		let result;
		let params;

		let jsMethod_IMP = pv_findJSMethodMap(obj, msg, isInstance);

		let paramsIsHasBlock = false;
		for (let i = 1; i < arguments.length; i++) {
			if (!params) params = new Array();
			if (jsMethod_IMP){
				params.push(arguments[i]);
			}else{
				let param = arguments[i];
				if (param instanceof Block) {
					let blockKey = msg+i;
					let isHasParams = false;
					if (param.length){
						isHasParams = true;
					}
					if (i+1 >= arguments) {
						Util.log('error 参数个数不匹配');
					}
					let blockImp = arguments[i+1];
					let blockOC = new Block(param.getFuncSignature(),blockImp,blockKey,isHasParams);
					global.curExecFuncArguments[blockKey] = blockOC;
					params.push(pv_toOcObject(blockOC));
					i++;
				}else {
					params.push(pv_toOcObject(param));
				}
			}
		}
		// if (this instanceof Block | typeof this === 'NSBlock'){
		// 	this.__isa.apply(this.params);
		// }
		// else
		if (jsMethod_IMP && !ttpatch__isSuperInvoke) {
			result = jsMethod_IMP.apply(this, params ? params : null);
		}
		else if (!this.__isa && !this.__className && !ttpatch__isSuperInvoke) {
			jsMethod_IMP = this[msg];
			jsMethod_IMP.apply(this, params);
		}
		else if (isInstance) {
			result = MessageQueue.call(this.__isa, ttpatch__isSuperInvoke, isInstance,msg, params);
		} else {
			result = MessageQueue.call(this.__className, ttpatch__isSuperInvoke, isInstance,msg, params);
		}

		// var jsObj = new JSObject('JSObject',result);
		//super调用已完成，将状态重新置为false
		global.ttpatch__isSuperInvoke=false;
		// this.__isa=null;
		return pv_toJSObject(result);
	};

	pv__getFuncParams=function (arguments) {
		let params;
		for (let i = 1; i < arguments.length; i++) {
			if (!params) params = new Array();
			params.push(arguments[i]);
		}
		return params;
	}

	// 引入 UIKit class
	global._import = function (name) {
		let files = name.split(',').forEach((file) => {
			pv__import(file);
		});
	};

	let pv__import = function (clsName) {
		if (!global[clsName]) {
			global[clsName] = new JSObject(clsName);
		}
		Util.log('引入文件：' + clsName);
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
		Util.log('🍎🍎🍎🍎oc------------->js' + '    _func_ ' + className + ' ************** ' + method + '');
		let obj = CLASS_MAP[className].__obj(isInstance);
		let imp = obj.__methodList[method];
		let result = imp.apply(undefined, params);

		// release self
		pv_releaseJsObject(curSelf);
		Util.log('self-->' + method + '释放');

		if (result instanceof JSObject) {
			return result.__toOcObject();
		} else {
			return result;
		}


	};

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
				Util.log(obj.__instanceFlag + '--------self、lastSelf 已释放');
				self = lastSelf = null;

			} else {

				Util.log(obj.__instanceFlag + '--------self 已释放, lastSelf替换self');
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
		for (let key in instancesMethods) {
			let value = instancesMethods[key];
			if (value instanceof Property) {
				value['__name'] = key;
				property_list.push(value);
			}else {
				methodList[key]=value;
			}
		}
		let obj = new Class_obj(className, superClassName, methodList, classMethods, property_list);
		Util.log('register------' + className);
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
			if (cls.__methodList.hasOwnProperty(key)) {
				const method = cls.__methodList[key];
				MessageQueue.replaceMethod(cls.__className, cls.__superClassName, key, isInstanceMethod, cls.__property_list);
			}
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
		else if (arg instanceof JSObject) {
			return arg.__isa ? arg.__isa : null;
		}
		else if (typeof arg === 'function') {
			//暂时不做多余处理
			// MessageQueue.MessageQueue_oc_setBlock(arg);
			obj=arg;
		}
		else {
			obj = arg;
		}
		obj.call=null;
		return obj;
	}

	function pv_toJSObject(arg) {
		if (arg instanceof Object) {
			if (arg.hasOwnProperty('__isa')) {
				if (arg['__isInstance']) {
					// return new JSObject(arg['__className'],arg.__isa);
					let cls = arg['__className'];
					let value = arg['__isa'];
					if (value instanceof Array) {
						let result = new Array();
						arg.__isa.forEach(element => {
							let jsObj = pv_toJSObject(element);
							result.push(jsObj);
						});
						return result
					}
					else if (cls === 'block') {
						let block = new Block('block', arg.__isa);
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
					} else if (cls === 'NSArray' ||
						cls === 'NSMutableArray') {
						let result = new Array();
						arg.forEach(element => {
							let jsObj = pv_toJSObject(element);
							result.push(jsObj);
						});
						return result
					} else if (cls === 'NSDictionary' ||
						cls === 'NSMutableDictionary') {
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
		return funcBlock.__isa.apply(null,params);
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