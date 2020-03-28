_import('UIView,UILabel,UIColor,UIFont,UIScreen,UIImageView,UIImage,UITapGestureRecognizer,UIButton,TTPlaygroundModel')



defineClass('TTPlaygroundController:UIViewController', {

	name: property(),
	viewDidLoad:function () {

	},
	loadJSCode: function () {
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
		label.setText_("本页面为Native声明创建的空页面\n修改 Playground.js 实时查看修改效果");
		label.setNumberOfLines_(0);
		self.view().addSubview_(label);

		for (var i = 0; i < 9; i++) {
			let width = screenWidth / 3.5;
			let react = new TTReact(10 + (i % 3) * (width + 10), 120+64 + 15 + parseInt((i / 3)) * (width + 10), width, width);
			let witdh = react.size.width;
			let view = UIButton.buttonWithType_(0);
			view.setFrame_(react);
			//greenColor blackColor blueColor
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
		btn.setTitle_forState_("按钮", 0);
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
		self.setName_('按钮文字已改变');

		let  str = self.name();
		btn.setTitle_forState_(str, 0);
		btn.setBackgroundColor_(UIColor.systemGreenColor());
		
		self.test();
		// self.jsInvocationOcWithBlock_(null);
		self.jsInvocationOcWithBlock_(block(""),function(){
			Utils.log('--------多参数测试---------')
		}
		);
	},
	params1_params2_params3_params4_params5_params6_params7_: function (params1, params2, params3, params4, params5, params6, params7) {
		Utils.log('--------多参数测试---------')
		Utils.log(params1, params2, params3, params4, params5, params6, params7)
	}
}, {
	//静态方法
	testAction_:function (str) {
	}
})
