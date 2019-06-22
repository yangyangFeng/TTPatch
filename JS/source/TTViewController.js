_import('UIView,UILabel,UIColor,UIFont,UIScreen,UIImageView,UIImage,UITapGestureRecognizer,UIButton');
var screenWidth = UIScreen.call('mainScreen').call('bounds').size.width;
var screenHeight = UIScreen.call('mainScreen').call('bounds').size.height;
defineClass('TTViewController:UIViewController', {
    name: property(),
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
        self.call('params1_params2_params3_params4_params5_params6_params7_', 2, 2, 2, 2, 2, 2, 2);
        self.call('ttparams1_params2_params3_params4_params5_params6_params7_', 33333, 2, 2, 2, 2, 2, 2);
    },
    action_: function (tap) {
        Util.log('--------name---------' + self.call('name'));
        self.call('view').call('subviews').call('forEach', subview => {
            if (tap.call('view') !== subview) {
                subview.call('removeFromSuperview');
            }
        });
    },
    btnDidAction_: function (btn) {
        self.call('setName_', '我是你老爹');
        let str = self.call('name');
        btn.call('setTitle_forState_', str, 0);
        btn.call('setBackgroundColor_', UIColor.call('blueColor'));
    },
    params1_params2_params3_params4_params5_params6_params7_: function (params1, params2, params3, params4, params5, params6, params7) {
        Util.log('--------多参数测试---------');
        Util.log(params1, params2, params3, params4, params5, params6, params7);
    }
}, {});