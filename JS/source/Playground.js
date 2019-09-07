_import('UIView,UILabel,UIColor,UIFont,UIScreen,UIImageView,UIImage,UITapGestureRecognizer,UIButton,TTPlaygroundModel');
defineClass('TTPlaygroundController:UIViewController', {
    name: property(),
    viewDidLoad: function () {
    },
    loadJSCode: function () {
        self.call('cleanSubviews');
        self.call('addSomeTestView');
    },
    cleanSubviews: function () {
    },
    addSomeTestView: function () {
        let screenWidth = UIScreen.call('mainScreen').call('bounds').size.width;
        let screenHeight = UIScreen.call('mainScreen').call('bounds').size.height;
        for (var i = 0; i < 9; i++) {
            let width = screenWidth / 3.5;
            let react = new TTReact(10 + i % 3 * (width + 10), 64 + 15 + parseInt(i / 3) * (width + 10), width, width);
            let witdh = react.size.width;
            let view = UIView.call('alloc').call('initWithFrame_', react);
            view.call('setBackgroundColor_', UIColor.call('blueColor'));
            let label = UILabel.call('alloc').call('init');
            label.call('setFrame_', react);
            label.call('setText_', String(i) + '');
            label.call('setFont_', UIFont.call('systemFontOfSize_', 20));
            label.call('setTextColor_', UIColor.call('whiteColor'));
            label.call('setTextAlignment_', 1);
            self.call('view').call('addSubview_', view);
            self.call('view').call('addSubview_', label);
            var tap = UITapGestureRecognizer.call('alloc').call('initWithTarget_action_', self, 'action:');
            view.call('addGestureRecognizer_', tap);
            view.call('setUserInteractionEnabled_', true);
            label.call('setUserInteractionEnabled_', false);
        }
        var btn = UIButton.call('buttonWithType_', 0);
        btn.call('setBackgroundColor_', UIColor.call('blackColor'));
        btn.call('setTitle_forState_', '测试1111', 0);
        btn.call('setFrame_', new TTReact(0, 500, screenWidth, 50));
        btn.call('addTarget_action_forControlEvents_', self, 'btnDidAction:', 1 << 6);
        self.call('view').call('addSubview_', btn);
    },
    action_: function (tap) {
        tap.call('view').call('setBackgroundColor_', UIColor.call('whiteColor'));
    },
    btnDidAction_: function (btn) {
        self.call('setName_', '我是你老爹11111');
        let str = self.call('name');
        btn.call('setTitle_forState_', str, 0);
        btn.call('setBackgroundColor_', UIColor.call('blueColor'));
    },
    params1_params2_params3_params4_params5_params6_params7_: function (params1, params2, params3, params4, params5, params6, params7) {
        Util.log('--------多参数测试---------');
        Util.log(params1, params2, params3, params4, params5, params6, params7);
    }
}, {
    testAction_: function (str) {
    }
});