_import('UIView,UILabel,UIImage,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,TTTableView,UIScreen,UIImageView')

defineClass('ViewController:UIViewController',{
    data:property(),
	loadJSCode:function(){
		let dataSource = ['加载下发模块','点击加载更多'];
        self.setData_(dataSource);
		let data = self.data();
        let tableview = self.getTableview();
        self.setTableview_(tableview);
        self.view().addSubview_(tableview);
		// let aaa = TTView.new();
		// aaa.__isa = null;
		// aaa=null;
		Util.log('js调用 viewDidLoad');
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
		}else {
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
	}
},{});
