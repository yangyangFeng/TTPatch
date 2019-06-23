_import('UIView,UILabel,UIColor,UIFont,UIScreen,UIImageView,UIImage,UITapGestureRecognizer,UIButton');
let screenWidth = UIScreen.call('mainScreen').call('bounds').size.width;
let screenHeight = UIScreen.call('mainScreen').call('bounds').size.height;
defineClass('TTViewController:UIViewController', {
    viewDidLoad: function () {
    },
    testAction_: function (str) {
        Util.log('---------原值' + str + '---------js--------');
    }
}, {
    testAction_: function (str) {
        Util.log('---------原值' + str + '---------js--------');
    }
});