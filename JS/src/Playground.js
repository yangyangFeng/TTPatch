/**
 * 引入UI组件,不引入无法直接使用
 */ 
_import('ASIdentifierManager,UIDevice,UIView,UILabel,UIColor,UIFont,UIScreen,UIImageView,UIImage,UITapGestureRecognizer,UIButton,TTPlaygroundModel')

/**
 *  @params:1.要替换的Class名,`:`标识继承关系
 *  @params:2.声明实例方法
 *  @params:3.声明静态方法
 *  声明Class,如无需在Oc中动态创建,可不设置父类,直接在js中创建类
 *  声明Class,如Native不存在,则动态创建Class
 */
defineClass('TTPlaygroundController:UIViewController', {
    /**
	 * 添加属性,自动生成`setter`/`getter`方法,取值和赋值必须使用`setter`/`getter`方法.
	 */ 
	name: property(),
	/**
	 * 声明实例方法,如已存在则替换原有方法,如Native不存在,直接在js中添加方法实现
	 */ 
	viewDidLoad:function () {
		/**
		 * super 使用
		 */
		Super().viewDidLoad();
		/**
		 * self 使用
		 */ 
		self.refresh();
	}
	/**
	 * 方法与方法之间 使用 , 分割
	 */
	,
	refresh: function () {
		// Super().testSuper();
		// self.testSuper();
		self.cleanSubviews();
		self.addSomeTestView();
	},
	cleanSubviews: function () {
		self.view().subviews().forEach(subview => {
			subview.removeFromSuperview()
		})
	},
	addSomeTestView: function () {
		let screenWidth = UIScreen.mainScreen().bounds().size.width;
		let screenHeight = UIScreen.mainScreen().bounds().size.height;

		var label = UILabel.new();
        label.setFont_(UIFont.systemFontOfSize_(18));
        label.setTextColor_(UIColor.blackColor());
        label.setFrame_(new TTReact(10, 64+20, self.view().bounds().size.width-20, 80));
		label.setText_("------本页面为Native声明创建的空页面\n修改 Playground.js 实时查看修改效果");
		label.setNumberOfLines_(0);
		self.view().addSubview_(label);

		for (var i = 0; i < 9; i++) {
			let width = screenWidth / 3.5;
			let react = new TTReact(10 + (i % 3) * (width + 10), 120+64 + 15 + parseInt((i / 3)) * (width + 10), width, width);
			let witdh = react.size.width;
			let view = UIButton.buttonWithType_(0);
			view.setFrame_(react);
			//systemGreenColor blackColor blueColor
			view.setBackgroundColor_(UIColor.systemGreenColor());
			let label = UILabel.alloc().init();
			label.setFrame_(react)
			label.setText_(String(i)+'🍓');
			label.setFont_(UIFont.systemFontOfSize_(20))
			label.setTextColor_(UIColor.whiteColor())
			label.setTextAlignment_(1);
			self.view().addSubview_(view);
			self.view().addSubview_(label);
			view.addTarget_action_forControlEvents_(self,"action:",1 << 6);
			view.setUserInteractionEnabled_(true);
			label.setUserInteractionEnabled_(false);


		}

		var btn = UIButton.buttonWithType_(0);
		btn.setBackgroundColor_(UIColor.blackColor());
		btn.setTitle_forState_("UUID", 0);
		btn.setFrame_(new TTReact(0, 600, screenWidth, 50));
		btn.addTarget_action_forControlEvents_(self, "btnDidAction:", 1 << 6);
		self.view().addSubview_(btn);
		// self.params1_params2_params3_params4_params5_params6_params7_(2, 2, 2, 2, 2, 2, 2);
		// self.ttparams1_params2_params3_params4_params5_params6_params7_(33333, 2, 2, 2, 2, 2, 2);
	},
	action_: function (btn) {
		btn.setSelected_(!btn.isSelected());
		if(btn.isSelected()){
			btn.setBackgroundColor_(UIColor.whiteColor());
		}else{
			btn.setBackgroundColor_(UIColor.systemGreenColor());
		}

	},
	btnDidAction_: function (btn) {
		// tap.view().setBackgroundColor_(UIColor.whiteColor());
		var uuid = UIDevice.currentDevice().identifierForVendor().UUIDString();
		Utils.log_info('uuid->'+uuid.value());
		let  str = self.name();
		btn.setTitle_forState_(uuid, 0);
		btn.setBackgroundColor_(UIColor.systemGreenColor());
	}
}, {
	//静态方法
	testAction_:function (str) {
	}
})
