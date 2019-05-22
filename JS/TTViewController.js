_import('UIView,UILabel,UIColor,UIFont,UIScreen,UIImageView,UIImage')

var screenWidth = UIScreen.call('mainScreen').call('bounds').size.width;
var screenHeight = UIScreen.call('mainScreen').call('bounds').size.height;

defineClass('TTViewController:UIViewController', {
    loadJSCode: function() {
        self.call('cleanSubviews');
        // self.call('addSomeTestView');
    },
    cleanSubviews:function(){
        var selfView = self.call('view');
        var views = selfView.call('subviews');
        views.forEach(subview => {
            subview.call('removeFromSuperview');
        });
    },
    addSomeTestView:function(){
        for (var i =0;i < 10;i++){
            var view = UIView.call('alloc').call('initWithFrame_',new TTReact(0,50+i*60,screenWidth,50));
            view.call('setBackgroundColor_',UIColor.call('redColor'));
            self.call('view').call('addSubview_',view);
        }
    },
},{})
