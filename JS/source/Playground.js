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
        self.call('view').call('subviews').call('forEach', subview => {
            subview.call('removeFromSuperview');
        });
    },
    addSomeTestView: function () {
        let screenWidth = UIScreen.call('mainScreen').call('bounds').size.width;
        let screenHeight = UIScreen.call('mainScreen').call('bounds').size.height;
        var label = UILabel.call('new');
        label.call('setFont_', UIFont.call('systemFontOfSize_', 18));
        label.call('setTextColor_', UIColor.call('blackColor'));
        label.call('setFrame_', new TTReact(10, 64 + 20, self.call('view').call('bounds').size.width - 20, 80));
        label.call('setText_', '本页面为Native声明创建的空页面\n修改 Playground.js 实时查看修改效果');
        label.call('setNumberOfLines_', 0);
        self.call('view').call('addSubview_', label);
        for (var i = 0; i < 9; i++) {
            let width = screenWidth / 3.5;
            let react = new TTReact(10 + i % 3 * (width + 10), 120 + 64 + 15 + parseInt(i / 3) * (width + 10), width, width);
            let witdh = react.size.width;
            let view = UIButton.call('buttonWithType_', 0);
            view.call('setFrame_', react);
            view.call('setBackgroundColor_', UIColor.call('systemGreenColor'));
            let label = UILabel.call('alloc').call('init');
            label.call('setFrame_', react);
            label.call('setText_', String(i) + '\uD83C\uDF53');
            label.call('setFont_', UIFont.call('systemFontOfSize_', 20));
            label.call('setTextColor_', UIColor.call('whiteColor'));
            label.call('setTextAlignment_', 1);
            self.call('view').call('addSubview_', view);
            self.call('view').call('addSubview_', label);
            view.call('addTarget_action_forControlEvents_', self, 'action:', 1 << 6);
            view.call('setUserInteractionEnabled_', true);
            label.call('setUserInteractionEnabled_', false);
        }
        var btn = UIButton.call('buttonWithType_', 0);
        btn.call('setBackgroundColor_', UIColor.call('blackColor'));
        btn.call('setTitle_forState_', '按钮', 0);
        btn.call('setFrame_', new TTReact(0, 600, screenWidth, 50));
        btn.call('addTarget_action_forControlEvents_', self, 'btnDidAction:', 1 << 6);
        self.call('view').call('addSubview_', btn);
    },
    action_: function (btn) {
        btn.call('setSelected_', !btn.call('isSelected'));
        if (btn.call('isSelected')) {
            btn.call('setBackgroundColor_', UIColor.call('whiteColor'));
        } else {
            btn.call('setBackgroundColor_', UIColor.call('systemGreenColor'));
        }
    },
    btnDidAction_: function (btn) {
        self.call('setName_', '按钮文字已改变');
        let str = self.call('name');
        btn.call('setTitle_forState_', str, 0);
        btn.call('setBackgroundColor_', UIColor.call('systemGreenColor'));
        self.call('test');
        self.call('jsInvocationOcWithBlock_', block(''), function () {
            Util.log('--------多参数测试---------');
        });
    },
    params1_params2_params3_params4_params5_params6_params7_: function (params1, params2, params3, params4, params5, params6, params7) {
        Util.log('--------多参数测试---------');
        Util.log(params1, params2, params3, params4, params5, params6, params7);
    }
}, {
    testAction_: function (str) {
    }
});