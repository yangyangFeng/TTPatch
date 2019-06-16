


_import('UIView,UILabel,UIColor,UIFont,UIScreen,UIImageView,UIImage,UITapGestureRecognizer')

var screenWidth = UIScreen.mainScreen().bounds().size.width;
var screenHeight = UIScreen.mainScreen().bounds().size.height;

defineClass('TTViewController:UIViewController', {
    loadJSCode: function() {
        // self.call('cleanSubviews');
        self.addSomeTestView();
    },
    cleanSubviews:function(){

    },
    addSomeTestView:function(){
		self.view().subviews().forEach(subview=>{
			subview.removeFromSuperview()
		})

        for (var i =0;i < 9;i++){
			let width = screenWidth/3.5;
			let react = new TTReact(10+(i%3)*(width+10),64+15+(i/3)*(width+10),width,width);
			let witdh = react.size.width;
			let view =UIView.alloc().initWithFrame_(react);
			view.setBackgroundColor_(UIColor.redColor());
			let label = UILabel.alloc().init();
			label.setFrame_(react)
			label.setText_(String(i));
			label.setFont_(UIFont.systemFontOfSize_(20))
			label.setTextColor_(UIColor.whiteColor())
			label.setTextAlignment_(1);
            self.view().addSubview_(view);
			self.view().addSubview_(label);
			// var  tap = UITapGestureRecognizer.alloc().initWithTarget_action(view, "action:") ;
			// view.addGestureRecognizer_(tap);


		}

		// var selfView = self.call('view');
		// var views = selfView.call('subviews');
		// views.call('forEach', subview => {
		// 	subview.call('removeFromSuperview');
		// });
    },
	action_:function (view) {
		view.setBackgroundColor_(UIColor.redColor());
		console.log('--------点击---------')
	}
},{})
