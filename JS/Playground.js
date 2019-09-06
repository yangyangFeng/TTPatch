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

		for (var i = 0; i < 9; i++) {
			let width = screenWidth / 3.5;
			let react = new TTReact(10 + (i % 3) * (width + 10), 64 + 15 + parseInt((i / 3)) * (width + 10), width, width);
			let witdh = react.size.width;
			let view = UIView.alloc().initWithFrame_(react);
			view.setBackgroundColor_(UIColor.blueColor());
			let label = UILabel.alloc().init();
			label.setFrame_(react)
			label.setText_(String(i)+'');
			label.setFont_(UIFont.systemFontOfSize_(20))
			label.setTextColor_(UIColor.whiteColor())
			label.setTextAlignment_(1);
			self.view().addSubview_(view);
			self.view().addSubview_(label);
			var tap = UITapGestureRecognizer.alloc().initWithTarget_action_(self, "action:");
			view.addGestureRecognizer_(tap);
			view.setUserInteractionEnabled_(true);
			label.setUserInteractionEnabled_(false);


		}

		var btn = UIButton.buttonWithType_(0);
		btn.setBackgroundColor_(UIColor.blackColor());
		btn.setTitle_forState_("测试1111", 0);
		btn.setFrame_(new TTReact(0, 500, screenWidth, 50));
		btn.addTarget_action_forControlEvents_(self, "btnDidAction:", 1 << 6);
		self.view().addSubview_(btn);
		// self.params1_params2_params3_params4_params5_params6_params7_(2, 2, 2, 2, 2, 2, 2);
		// self.ttparams1_params2_params3_params4_params5_params6_params7_(33333, 2, 2, 2, 2, 2, 2);
	},
	action_: function (tap) {
		tap.view().setBackgroundColor_(UIColor.whiteColor());
	},
	btnDidAction_: function (btn) {
		// tap.view().setBackgroundColor_(UIColor.whiteColor());
		self.setName_('我是你老爹11111');

		let  str = self.name();
		btn.setTitle_forState_(str, 0);
		btn.setBackgroundColor_(UIColor.blueColor());
		
		
		self.testCallVID_(function(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9){
			Util.log('--------JS接受回调---------'+arg1 +arg2+arg3+arg4+arg5+arg6+arg7+arg8,arg9);
		});
		self.runBlock();
		// self.callBlock_block2_(()=>{},()=>{})
	},
	testCallVID_:function (callBack){
		if(callBack){
            callBack("方法签名 (void/id)",1,2,3,4,5,6,7,'最后一个参数');
		}
	},
	callBlock_:function(callBack){
		if(callBack){
            callBack.invote("aaaaaaaaaaaaaaaaaaaa");
		}
	},
	callBlock_block2_:function(block1,block2){

			block1.invote("参数一");
			block2.invote("参数二");
	},
	configViewSize_:function(size){
		Util.log("size")
			Util.log(size)
	},
	configView_:function(view){
		Util.log("view")
		Util.log(view)
	},
	params1_params2_params3_params4_params5_params6_params7_: function (params1, params2, params3, params4, params5, params6, params7) {
		Util.log('--------多参数测试---------')
		Util.log(params1, params2, params3, params4, params5, params6, params7)
	}
}, {
	//静态方法
	testAction_:function (str) {
	}
})
