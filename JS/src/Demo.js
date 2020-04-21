_import('NSMutableDictionary,NSMutableArray,UIView,UILabel,UIImage,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,UIScreen,UIImageView,TaoBaoHome')

defineClass('ViewController:UIViewController<UITableViewDelegate,UITableViewDataSource>',{
	data:property(),
	viewDidLoad:function () {
		/**
		 * super 使用
		 */
		Super().viewDidLoad();
		/**
		 * self 使用
		 */ 
		self.refresh();
	},
	refresh: function () {
		// Super().testSuper();
		// self.testSuper();
		self.cleanSubviews();
		self.addSomeTestView();
	},
	cleanSubviews: function () {
		if(MessageQueue.ProjectConfig_IS_USE_NATIVE_DATA()){
			var subviewsArr = self.view().subviews();
			for (var i=0;i<subviewsArr.count();i++){
				var subview = subviewsArr.objectAtIndex_(i);
				subview.removeFromSuperview()
			}
		}else{
			self.view().subviews().forEach(subview => {
				subview.removeFromSuperview()
			})
		}
	},
	addSomeTestView:function(){
		let dataSource = ['加载纯J1S模块','JS-OC block调用示例','淘宝大事故修复方案','动态添加数据',];
        self.setData_(dataSource);
		let data = self.data();
		let tableview = self.getTableview();
		tableview.setTableHeaderView_(self.createPageHeader());
		self.setTableview_(tableview);
        self.view().addSubview_(tableview);
		self.setTitle_('Demo.js');
    },
    tableView_numberOfRowsInSection_:function(tableview,section){
		let data = self.data();
		
        return MessageQueue.ProjectConfig_IS_USE_NATIVE_DATA()?data.count():data.length;
    },

    tableView_cellForRowAtIndexPath_:function(tableview,indexPath){
        let cell = UITableViewCell.alloc().initWithStyle_reuseIdentifier_(1,'cell');
		let data;
		if (MessageQueue.ProjectConfig_IS_USE_NATIVE_DATA()){
			data = self.data().objectAtIndex_(indexPath.row()).value();
		}else{
			data = self.data()[indexPath.row()]
		}

		
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
		else if(indexPath.row() === 2){
			let vc = TaoBaoHome.new();
			self.navigationController().pushViewController_animated_(vc,true);
			vc=null;
		}
		else {
			let dataSource = self.data();
			
			if (MessageQueue.ProjectConfig_IS_USE_NATIVE_DATA()){
				dataSource=dataSource.arrayByAddingObject_('点击加载更多Cell');
			}else{
				dataSource.push('点击加载更多Cell');
			}
			self.setData_(dataSource);
			self.tableview().reloadData();
		}
	},
	getTableview: function() {
		_tableview = UITableView.alloc().initWithFrame_style_(self.view().bounds(), 0);
		_tableview.setDelegate_(self);
		_tableview.setDataSource_(self);
		return _tableview;
	},
	params1_params2_params3_params4_params5_params6_params7_: function (params1, params2, params3, params4, params5, params6, params7) {
		Util.nLog(0,'--------多参数测试---------')
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
defineClass('JSRootViewController:RootViewController',{
	dealloc:function () {
		Utils.log('TestViewController->已释放');
	},
	viewDidLoad:function () {
		Super().viewDidLoad();
		self.addSomeTestView();
	},
	refresh: function () {
		self.cleanSubviews();
		self.addSomeTestView();
		Utils.log_error('refresh');
	},
	cleanSubviews: function () {
		if(MessageQueue.ProjectConfig_IS_USE_NATIVE_DATA()){
			var subviewsArr = self.view().subviews();
			for (var i=0;i<subviewsArr.count();i++){
				var subview = subviewsArr.objectAtIndex_(i);
				subview.removeFromSuperview()
			}
		}else{
			self.view().subviews().forEach(subview => {
				subview.removeFromSuperview()
			})
		}
	},
	addSomeTestView:function(){
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
		Utils.log('BlockViewController->已释放');
	},
	viewDidLoad:function () {
		Super().viewDidLoad();
		self.addSomeTestView()
	},
	refresh: function () {
		// Super().testSuper();
		// self.testSuper();
		self.cleanSubviews();
		self.addSomeTestView();
	},
	cleanSubviews: function () {
		if(MessageQueue.ProjectConfig_IS_USE_NATIVE_DATA()){
			var subviewsArr = self.view().subviews();
			for (var i=0;i<subviewsArr.count();i++){
				var subview = subviewsArr.objectAtIndex_(i);
				if (subview != 'UITableView'){
					subview.removeFromSuperview();
				}else{
					self.tableView().reloadData();
				}
			}
		}else{
			self.view().subviews().forEach(subview => {
				if (subview != 'UITableView'){
					subview.removeFromSuperview();
				}else{
					self.tableView().reloadData();
				}
			})
		}
	},
	sendMessage_:function(msg){
		Utils.log_info(msg);
	},
	sendMessageVC_:function(vc){
	vc.view().setBackgroundColor_(UIColor.blackColor());	
	},
	addSomeTestView:function(){
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
					Utils.log('--------JS传入OC方法,接受到回调--------- 无参数,无返回值');
					Utils.log_info('--------JS传入OC方法,接受到回调--------- 无参数,无返回值');
				});
			}break;
			case 1:{
				self.testCall1_(block('void,id,int'),function(arg1,arg2){
					var dic = JSON.parse(arg1);
					Utils.log_info('--------JS传入OC方法,接受到回调--------- 有参数,无返回值  '+dic.name+'-'+arg2);
				});
			}break;
			case 2:{
				self.testCall2_(block("id,id"),function(arg){
					Utils.log('--------JS传入OC方法,接受到回调--------- 有参数,有返回值:string  '+arg);
					Utils.log_info('--------JS传入OC方法,接受到回调--------- 有参数,有返回值:string  '+arg);
					// arg.view().setBackgroundColor_(UIColor.blackColor());
					return arg;
				});
			}break;
			case 3:{
				self.testCall3_(block("id,void"),function(){
					Utils.log('--------JS传入OC方法,接受到回调--------- 无参数,有返回值:string  ');
					Utils.log_info('--------JS传入OC方法,接受到回调--------- 无参数,有返回值:string  ');
					return '这是有返回值的哦';
				});
			}break;
			case 4:{
				self.runBlock(); 
			}break;
			
			default:{
				//方法签名第一位 是返回值,如果返回为void可以不填,但是要以","分割
				self.testCallVID_(block("id, id, id, int, bool, float, id"),function(arg1,arg2,arg3,arg4,arg5,arg6){
					Utils.log('--------JS传入OC方法,接受到回调---------'+arg1+"\n"+arg2+"\n"+arg3+"\n"+arg4+"\n"+arg5+"\n"+arg6);
					Utils.log_info('--------JS传入OC方法,接受到回调---------'+arg1+"\n"+arg2+"\n"+arg3+"\n"+arg4+"\n"+arg5+"\n"+arg6);
				});
				self.OCcallBlock_(block(",id"),function(arg1){
					Utils.log("js与js block回调"+arg1);
					Utils.log_info("js与js block回调"+arg1);
				})
			}break;
		}

	},
	callBlock_:function(callback){
		if(callback){
			callback(10);
		}
	}

},{});
