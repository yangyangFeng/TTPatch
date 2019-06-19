_import('UIView,UILabel,UIColor,TTView,ViewController,UITableViewCell,UITableView')
defineClass('ViewController:UIViewController',{

    addView : function(){
        console.call("log",'viewDidLoad');
        // TT_viewDidLoad();
        var a = TTView.call("alloc").call("initWithFrame_",new TTReact(120,100,100,100));
        var color = UIColor.call("blackColor");
        a.call("setBackgroundColor_",color);

     
    },
    refresh:function(){

        var color = UIColor.call("redColor");
        self.call("tableview").call("setBackgroundColor_",color);

        console.call("log",'刷新');
    },
    viewDidLoad:function(){
        self.call("call",'ttviewDidLoad');
  
        
    },
    addTableView:function(){
        
    },
    // tableView_numberOfRowsInSection_:function(){
    //     log(2);
    //     return, 0;
    // },
    execJSCode_:function(obj) {
	}


},{})