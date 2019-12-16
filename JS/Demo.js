_import('UIView,UILabel,UIImage,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,TTTableView,UIScreen,UIImageView')

defineClass('ViewController:UIViewController',{
    data:property(),
	loadJSCode:function(){
		let dataSource = ['加载下发模块','JS-OC间block','点击加载更多',];
        self.setData_(dataSource);
		let data = self.data();
        let tableview = self.getTableview();
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
			dataSource.push('新增Cell');
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
	}

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
			title.setText_("------关于我们------");
			// title.setFont_(UIFont.fontWithName_size_("GillSans-UltraBold", 25));
			title.setTextAlignment_(1);
			title.setFrame_(new TTReact(50, 150, 200, 100));
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
		logo.setCenter_(new TTPoint(screenWidth/2,150));
		let title = UILabel.new();
		title.setText_("Apple");
		title.setFont_(UIFont.fontWithName_size_("GillSans-UltraBold", 25));
		title.setTextAlignment_(1);
		title.setFrame_(new TTReact(50, 150, 100, 100));
		title.setCenter_(new TTPoint(screenWidth/2,270));
		self.view().addSubview_(logo);
		self.view().addSubview_(title);
	},
	btnAction_:function(index){
			
		switch (index){
			case 0:{
				self.testCall0_(function(){
					Util.log('--------JS传入OC方法,接受到回调--------- 无参数,无返回值');
				});
			}break;
			case 1:{
				self.testCall1_(function(arg){
					Util.log('--------JS传入OC方法,接受到回调--------- 有参数,无返回值  '+arg);
				});
			}break;
			case 2:{
				self.testCall2_(function(arg){
					Util.log('--------JS传入OC方法,接受到回调--------- 有参数,有返回值:string  '+arg);
					return '这是有返回值的哦';
				});
			}break;
			case 3:{
				self.testCall3_(function(){
					Util.log('--------JS传入OC方法,接受到回调--------- 有参数,有返回值:string  ');
					return '这是有返回值的哦';
				});
			}break;
			case 4:{
				self.runBlock(); 
			}break;
			
			default:{
				self.testCallVID_(function(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9){
					Util.log('--------JS传入OC方法,接受到回调---------'+arg1 +arg2+arg3+arg4+arg5+arg6+arg7+arg8,arg9);
				});
				self.OCcallBlock_(function(arg1){
					Util.log("js与js block回调"+arg1);
				})
			}break;
		}

	},
	callBlock_:function(callback){
		if(callback){
			callback("js object");
		}
	},
	// testCall1_:function(){
	// },
	// testCall2_:function(){
	// },
	// testCall3_:function(){
	// },

},{});
