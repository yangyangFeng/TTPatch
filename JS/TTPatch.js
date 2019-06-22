let global = this;

class MessageQueue {
}

MessageQueue.call = function (obj, msg, params) {
	return MessageQueue_oc_sendMsg(obj, msg, params);
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

	__findPropertys(){
		let property_list = [];
		let methodList = [];
		for (const key in this.__methodList) {
			let value = this.__methodList[key];
			if (value instanceof Property) {
				value['__name'] = key;
				property_list.push(value);
			}else {
				methodList.push(value);
			}
		}
		this.__methodList = methodList;
		// this.__property_list = property_list;
		return property_list;
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

class JSObject {
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

	__toOcObject() {
		return this.__isa ? this.__isa : null;
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

		for (let i = 1; i < arguments.length; i++) {
			if (!params) params = new Array();
			params.push(
				jsMethod_IMP ?
					arguments[i] :
					pv_toOcObject(arguments[i]));
		}

		if (jsMethod_IMP) {
			result = jsMethod_IMP.apply(this, params ? params : null);
		}
		else if (!this.__isa && !this.__className) {
			jsMethod_IMP = this[msg];
			jsMethod_IMP.apply(this, params);
		}
		else if (isInstance) {
			result = MessageQueue.call(this.__isa, msg, params);
		} else {
			result = MessageQueue.call(this.__className, msg, params);
		}


		// var jsObj = new JSObject('JSObject',result);
		return pv_toJSObject(result);
	};
	// JSObject.prototype=new Object();


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

		pv_addPropertys(obj);
		// 在Native环境中创建并注册方法
		pv_registMethods(obj);

	};

	global.property = function (adorn, obj) {
		return new Property(adorn, obj);
	};

	// js API
	// Oc 消息转发至 js
	global.js_msgSend = function (instance, className, method) {
		// retain self
		let curSelf = new JSObject(className, instance);
		curSelf.__instanceFlag = className + '-' + method;
		pv_retainJsObject(curSelf);

		let params;
		for (let i = 3; i < arguments.length; i++) {
			if (!params) params = new Array();
			params.push(pv_toJSObject(arguments[i]));
		}
		Util.log('🍎🍎🍎🍎oc------------->js' + '    _func_ ' + className + ' ************** ' + method + '');
		let obj = CLASS_MAP[className];
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
		return isInstanceMethod ?null: pv_registMethods(cls.__cls);
	}

	/**
	 * 将JS对象 转为OC 可用对象
	 */
	function pv_toOcObject(arg) {
		let obj;
		if (arg instanceof JSObject) {
			return arg.__isa ? arg.__isa : null;
		} else if (arg instanceof TTReact) {
			obj = new JSObject('react', arg.toOcString());
		}
		else if (arg instanceof TTSize) {
			obj = new JSObject('size', arg.toOcString());
		}
		else if (arg instanceof TTPoint) {
			obj = new JSObject('point', arg.toOcString());
		}
		else {
			return arg;
		}
		obj.call = null;
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
							let jsObj = new JSObject('JSObject', element);
							result.push(jsObj);
						});
						return result
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
							let jsObj = new JSObject('JSObject', element);
							result.push(jsObj);
						});
						return result
					} else if (cls === 'NSDictionary' ||
						cls === 'NSMutableDictionary') {
						return arg.__isa;
					}
				}
				return new JSObject(arg.__className, arg.__isa);
			}
			return new JSObject('JSObject', arg);
		} else {
			// console.log('基础数据类型:'+arg);
			return arg;
		}
	}

	global.CLASS_MAP = {};
	global.self = null;
	global.lastSelf = null;
})();






