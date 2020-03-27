_import('UIView,UILabel,UIImage,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,TTTableView,UIScreen,UIImageView')

defineClass('ViewController:UIViewController',{
    data:property(),
	loadJSCode:function(){
		let dataSource = ['加载纯JS模块','JS-OC block调用示例','动态添加数据',];
        self.setData_(dataSource);
		let data = self.data();
		let tableview = self.getTableview();
		tableview.setTableHeaderView_(self.createPageHeader());
		self.setTableview_(tableview);
        self.view().addSubview_(tableview);
		// let aaa = TTView.new();
		// aaa.__isa = null;
		// aaa=null;
		Util.log('js调用 viewDidLoad');
		self.setTitle_('Demo.js');
    },
    tableView_numberOfRowsInSection_:function(tableview,section){
        let data = self.data();
        return data.length;
    },

    tableView_cellForRowAtIndexPath_:function(tableview,indexPath){
        let cell = UITableViewCell.alloc().initWithStyle_reuseIdentifier_(1,'cell');
		let data = self.data()[indexPath.row()];
        cell.textLabel().setText_("<"+ data+">");
        return cell;
    },
	tableView_didSelectRowAtIndexPath_:function (tableview,indexPath) {
		if (indexPath.row() === 0){
			let vc = JSRootViewController.new();
			self.navigationController().pushViewController_animated_(vc,true);
			vc=null;
		} else if(indexPath.row() === 1){
			let vc = BlockViewController.new();
			self.navigationController().pushViewController_animated_(vc,true);
			vc=null;
		}
		else {
			let dataSource = self.data();
			dataSource.push('点击加载更多Cell');
			self.setData_(dataSource);
			self.tableview().reloadData();
		}
	},
	getTableview: function() {
		_tableview = TTTableView.alloc().initWithFrame_style_(self.view().bounds(), 0);
		_tableview.setDelegate_(self);
		_tableview.setDataSource_(self);
		return _tableview;
	},
	params1_params2_params3_params4_params5_params6_params7_: function (params1, params2, params3, params4, params5, params6, params7) {
		Util.log('--------多参数测试---------')
		Util.log(params1, params2, params3, params4, params5, params6, params7)
	},
	createPageHeader: function(){
		var label = UILabel.new();
        label.setFont_(UIFont.systemFontOfSize_(18));
		label.setTextColor_(UIColor.whiteColor());
		label.setBackgroundColor_(UIColor.systemGreenColor());
        label.setFrame_(new TTReact(10, self.view().frame().size.width * .75, self.view().bounds().size.width-20, self.view().frame().size.height * .15));
		label.setText_("具体功能实例 \n\n    动态加载纯JS页面, JS与OC之间的Block传递,调用");
		label.setNumberOfLines_(0);
		return label;
	},

},{

});

//动态生成模块
defineClass('JSRootViewController:UIViewController',{
	dealloc:function () {
		Util.log('TestViewController->已释放');
	},
	viewDidLoad:function () {
		Super().viewDidLoad();
		self.setTitle_('动态下发模块');
		self.view().setBackgroundColor_(UIColor.whiteColor());
		let screenWidth = UIScreen.mainScreen().bounds().size.width;
		let screenHeight = UIScreen.mainScreen().bounds().size.height;

		let logo = UIImageView.new();
		logo.setImage_(UIImage.imageNamed_("applelogo"));
		logo.setFrame_(new TTReact(50, 50, 100, 100));
		logo.setCenter_(new TTPoint(screenWidth/2,150));
		let title = UILabel.new();
		title.setText_("Apple");
		title.setFont_(UIFont.fontWithName_size_("GillSans-UltraBold", 25));
		title.setTextAlignment_(1);
		title.setFrame_(new TTReact(50, 150, 100, 100));
		title.setCenter_(new TTPoint(screenWidth/2,270));
		self.view().addSubview_(logo);
		self.view().addSubview_(title);

		{
			let title = UILabel.new();
			title.setText_("------------------------\n本页面由纯JS编写,具体使用场景可结合自身业务使用\n------------------------");
			title.setNumberOfLines_(0);
			title.setTextAlignment_(1);
			title.setFrame_(new TTReact(50, 150, 200, 300));
			title.setCenter_(new TTPoint(screenWidth/2,370));
			// self.view().addSubview_(logo);
			self.view().addSubview_(title);
		}
	}
},{});

defineClass('BlockViewController:UITableViewController',{
	dealloc:function () {
		Util.log('BlockViewController->已释放');
	},
	viewDidLoad:function () {
		Super().viewDidLoad();
		self.setTitle_('动态下发模块');
		self.view().setBackgroundColor_(UIColor.whiteColor());
		let screenWidth = UIScreen.mainScreen().bounds().size.width;
		let screenHeight = UIScreen.mainScreen().bounds().size.height;

		let logo = UIImageView.new();
		logo.setImage_(UIImage.imageNamed_("applelogo"));
		logo.setFrame_(new TTReact(50, 50, 100, 100));
		logo.setCenter_(new TTPoint(screenWidth/2,screenHeight-250));
		let title = UILabel.new();
		title.setText_("Apple");
		title.setFont_(UIFont.fontWithName_size_("GillSans-UltraBold", 25));
		title.setTextAlignment_(1);
		title.setFrame_(new TTReact(50, 150, 150, 100));
		title.setCenter_(new TTPoint(screenWidth/2,screenHeight-150));
		self.view().addSubview_(logo);
		self.view().addSubview_(title);
	},
	btnAction_:function(index){
			
		switch (index){
			case 0:{
				self.testCall0_(block(""),function(){
					Util.log('--------JS传入OC方法,接受到回调--------- 无参数,无返回值');
				});
			}break;
			case 1:{
				self.testCall1_(block('void,NSString*,int'),function(arg1,arg2){
					Util.log('--------JS传入OC方法,接受到回调--------- 有参数,无返回值  '+arg1+arg2);
				});
			}break;
			case 2:{
				self.testCall2_(block("NSString*,NSString*"),function(arg){
					Util.log('--------JS传入OC方法,接受到回调--------- 有参数,有返回值:string  '+arg);
					return '这是有返回值的哦';
				});
			}break;
			case 3:{
				self.testCall3_(block("NSString*,void"),function(){
					Util.log('--------JS传入OC方法,接受到回调--------- 无参数,有返回值:string  ');
					return '这是有返回值的哦';
				});
			}break;
			case 4:{
				self.runBlock(); 
			}break;
			
			default:{
				//方法签名第一位 是返回值,如果返回为void可以不填,但是要以","分割
				self.testCallVID_(block(",NSString *, NSString *, int, bool, float , NSNumber* "),function(arg1,arg2,arg3,arg4,arg5,arg6){
					Util.log('--------JS传入OC方法,接受到回调---------'+arg1+"\n"+arg2+"\n"+arg3+"\n"+arg4+"\n"+arg5+"\n"+arg6);
				});
				self.OCcallBlock_(block(""),function(arg1){
					Util.log("js与js block回调"+arg1);
				})
			}break;
		}

	},
	callBlock_:function(callback){
		if(callback){
			callback(10);
		}
	},
	// testCall1_:function(){
	// },
	// testCall2_:function(){
	// },
	// testCall3_:function(){
	// },

},{});
