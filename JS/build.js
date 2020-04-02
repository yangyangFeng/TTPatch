console.log("████████╗████████╗██████╗  █████╗ ████████╗ ██████╗██╗  ██╗");
console.log("╚══██╔══╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██║  ██║");
console.log("   ██║      ██║   ██████╔╝███████║   ██║   ██║     ███████║");
console.log("   ██║      ██║   ██╔═══╝ ██╔══██║   ██║   ██║     ██╔══██║");
console.log("   ██║      ██║   ██║     ██║  ██║   ██║   ╚██████╗██║  ██║");
console.log("   ╚═╝      ╚═╝   ╚═╝     ╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝");
console.log("                                                           ");

const esprima = require('esprima');
const estraverse = require('estraverse');
const escodegen = require("escodegen");
const fs = require("fs");
const program = require('commander');

function range(val) {
	return val.split('..').map(Number);
  }
   
  function list(val) {
	return val.split(',');
  }
   
  function collect(val, memo) {
	memo.push(val);
	return memo;
  }
   
  function increaseVerbosity(v, total) {
	return total + 1;
  }



let isOnlyPackage = program.package;
let invokeFunc = '_c';
let outputPath = program.output;
let srcPath    =  program.work;

let Build=function(package,output,work){
	isOnlyPackage=parseInt(package);
	outputPath=output;
	srcPath=work;

	console.log(' 是否打包: %j', program.package);
	console.log(' 输出目录: %j', program.output);
	console.log(' 工作目录: %j', program.work);
}

Build.prototype.run=function(){
	fs.exists(outputPath,function (exists) {
		if(exists){
			console.log("clean file");
			// deleteall(outputPath);
		}else {
			fs.mkdir(outputPath,'0777',function (err) {
				if(err){
					return console.log(err);
				}else {
					console.log("create outputs dir");
				}
			})
		}
	})
	
	
	// const ast = "";
	// 转换JS代码为可执行代码
	function transformCode(code) {
		// console.log(code+"\n code------");
		const ast = esprima.parseScript(code);
		// console.log(ast+"\n AST---------");
		estraverse_traverse(ast);
		const transformCode = escodegen.generate(ast);
		// console.log(transformCode+"\n ---------");
		return transformCode
	}
	
	//AST解析
	function estraverse_traverse(ast) {
		estraverse.traverse(ast, {
			enter: function (node) {
				const name = node.name;
				// console.log('----------------\n' + JSON.stringify(node) + '\n')
				switch (node.type){
					case "Identifier":{
						// if (name === "view"){
						// 	node.name = "call('view')"
						// }
						// node.name = "call("+name+")";
					}break;
					case "MemberExpression":{
	
					}break;
					case "CallExpression":{
						if (node.callee && node.callee.object){
							let targetName = node.callee.object.name;
							if (targetName === 'Utils'){
								return;
							}
							// console.log('*******'+JSON.stringify(node));
							var str=node.callee.property.name;
							var argCount = 0;
							for (let i = 0; i < str.length; i++) {
								if (str.charAt(i) === '_') {
									argCount++;
								}
							}
							var argumentsCount =0;
							for (var i in node.arguments) {
								argumentsCount ++;
							}
							// if (argCount < argumentsCount){
							// 	node.arguments.splice(0,0,createNode((node.callee.property.name+'_')));
							
							// }else {
							// 	node.arguments.splice(0,0,createNode(node.callee.property.name))
							// }
							node.arguments.splice(0,0,createNode(node.callee.property.name))
								// console.log("出现最多次数的是:"+argCount+'实际参数: '+argumentsCount)
	
							// node.arguments.splice(0,0,createNode(node.callee.property.name))
							node.callee.property.name = invokeFunc;
						}
	
	
	
					}break;
				}
			},
			Identifier(path) {
				const name = path.node.name;
				// console.log('Identifier-----' + JSON.stringify(path.node))
				if (path.node.name === invokeFunc) {
					// console.log('Identifier-----' + JSON.stringify(path.node))
					path.findParent((superPath) => {
						// console.log('-----'+superPath.node.name)
					});
	
				}
	
				if (path.key === 'property') {
					let name = path.node.name;
					path.node.name = invokeFunc;
					path.node.loc.identifierName = invokeFunc;
				}
			}
		});
	}
	
	// const MytransformCode = escodegen.generate(ast)
	// console.log("--------转换后"+MytransformCode)
	
	
	function deleteall(path) {
		var files = [];
		if(fs.existsSync(path)) {
			files = fs.readdirSync(path);
			files.forEach(function(file, index) {
				var curPath = path + "/" + file;
				if(fs.statSync(curPath).isDirectory()) { // recurse
					deleteall(curPath);
				} else { // delete file
					fs.unlinkSync(curPath);
				}
			});
			fs.rmdirSync(path);
		}
	};
	
	
	
	fs.readdir("./"+srcPath,function (err,data) {
		if(err){
			console.log(err);
		}else {
			
			let files = JSON.parse(JSON.stringify(data));
			let isFirst = true;
			let filePath;
			if (files){
				console.log("----------------------遍历JS源文件------------");
				let package='';
				files.forEach((filename)=>{
					if (filename.endsWith(".js")){
						if(filename === "build.js"){return}
						if(filename === "TTPatch.js"){return}
						let basePath = "./"+outputPath+"/";
						 
						
						if (filename.endsWith(".js")){
							// console.log("----------------------read: "+srcPath);
							let code = transformCode(fs.readFileSync('./'+srcPath+'/'+filename,'utf-8'));
							let codeStr = code.toString();
								codeStr = codeStr.replace(/  /g,"");
								codeStr = codeStr.replace(/[\n]/g,"");
							if (isOnlyPackage){
								filePath= basePath+'hotfixPatch.js';
								package+=codeStr+'\n';
							}else{
								filePath= basePath+filename;
								console.log("----------------------read: "+filePath);
								//要写入的文件   要写入的内容       a追加|w写入（默认）|r（读取）  回调函数
								fs.writeFile(filePath,codeStr,{flag:'w'},function (err) {
									if(err){
										console.log("----------------------写入失败"+filename);
										return console.log(err);
									}else {
										console.log(basePath+filename+" 转换完成~！, 可直接下发供 app 使用");
									}
								})
							}
						}

						
					}
				})
				if (isOnlyPackage){
						//要写入的文件   要写入的内容       a追加|w写入（默认）|r（读取）  回调函数
						fs.writeFile(filePath,package,{flag:'w'},function (err) {
							if(err){
								console.log("----------------------写入失败"+filename);
								return console.log(err);
							}else {
								console.log(filePath+" 转换完成~！, 可直接下发供 app 使用");
							}
						})
				}
					
			}
		}
	})
	
}


function createNode(func) {
	return  {
		"type":"Literal",
		"value":func,
		"raw":func
	}
}


// Js 判断后缀
String.prototype.endsWith = function(suffix) {
	return this.indexOf(suffix, this.length - suffix.length) !== -1;
};

// Js 判断前缀
if (typeof String.prototype.startsWith != 'function') {
	// see below for better implementation!
	String.prototype.startsWith = function (str){
		return this.indexOf(str) == 0;
	};
}

// Js 判空(含全部是空格)
String.prototype.IsNullEmptyOrSpace = function()
{
	if (this== null) return true;
	return this.replace(/s/g, '').length == 0;
};

module.exports=Build; 