_import('UIView,UILabel,UIColor,UIFont,UIScreen,UIImageView,UIImage,UITapGestureRecognizer');
var screenWidth = UIScreen.call('mainScreen').call('bounds').size.width;
var screenHeight = UIScreen.call('mainScreen').call('bounds').size.height;
defineClass('TTViewController:UIViewController', {
    loadJSCode: function () {
        self.call('addSomeTestView');
    },
    cleanSubviews: function () {
    },
    addSomeTestView: function () {
        self.call('view').call('subviews').call('forEach', subview => {
            subview.call('removeFromSuperview');
        });
        for (var i = 0; i < 9; i++) {
            let width = screenWidth / 3.5;
            let react = new TTReact(10 + i % 3 * (width + 10), 64 + 15 + i / 3 * (width + 10), width, width);
            let witdh = react.size.width;
            let view = UIView.call('alloc').call('initWithFrame_', react);
            view.call('setBackgroundColor_', UIColor.call('redColor'));
            let label = UILabel.call('alloc').call('init');
            label.call('setFrame_', react);
            label.call('setText_', String(i));
            label.call('setFont_', UIFont.call('systemFontOfSize_', 20));
            label.call('setTextColor_', UIColor.call('whiteColor'));
            label.call('setTextAlignment_', 1);
            self.call('view').call('addSubview_', view);
            self.call('view').call('addSubview_', label);
        }
    },
    action_: function (view) {
        view.call('setBackgroundColor_', UIColor.call('redColor'));
        console.call('log', '--------点击---------');
    }
}, {});