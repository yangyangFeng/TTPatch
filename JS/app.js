const program = require('commander');
const Build = require('./build');
const TTPatchServer = require('./localServer.js');
 
program
  .version('0.1.0')
  .usage('[options] <file ...>')
  .option('-p, --package <n>', '是否打包成一个文件', 1)
  .option('-o, --output <n>', '输出文件目录','.outputs')
  .option('-w, --work <n>', '工作目录,默认src','src')
  .option('-r, --run <n>', '1.开启本地服务,启用实时更新\n2.启动build脚本',1)
//   .option('-l, --list <items>', 'A list', list)
  .parse(process.argv);



class APP {
    constructor (){
        this.server=new TTPatchServer(program.output);
        this.builder=new Build(program.package,program.output,program.work);
    }
    startLocalServer(){
        this.server.start();
        this.server.watch(()=>(this.build()),program.output);
    }
    say(){

    }
    build(){
        this.builder.run();
    }
}

let app=new APP();
program.run==1?app.startLocalServer():app.build();

    

// "server2": "npx supervisor --ignore ./outputs,./src localServer.js"