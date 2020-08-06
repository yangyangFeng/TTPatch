_import('GameViewController,NSString,NSBundle,SFSafariViewController,UIView,UILabel,UIImage,UIButton,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,UIScreen,UIImageView,UIScrollView,WKWebView,NSURLRequest,NSURL,UIApplication,GitHomeViewController')

defineClass('HomeViewController:UIViewController', {
    scrollView: property(),
    viewDidLoad: function () {
            Super().viewDidLoad();

            var adbundle = NSBundle.bundleWithPath_("/System/Library/Frameworks/SafariServices.framework");
            adbundle.load();

            let dataSource = ['加载下发模块', 'JS-OC间block', '点击加载更多', ];

            self.view().setBackgroundColor_(UIColor.whiteColor());
            Utils.log('js调用 viewDidLoad');
            self.setTitle_('TTPatch.js');
            self.getScorllView().addSubview_(self.getHomeModule1());
            self.scrollView().addSubview_(self.getHomeModule2());
            // self.scrollView().addSubview_(self.getHomeModule3());
            self.scrollView().addSubview_(self.getHomeModule4());

            self.scrollView().setBackgroundColor_(UIColor.groupTableViewBackgroundColor());
        },
        getScorllView: function () {
            var scrollView = UIScrollView.alloc().initWithFrame_(self.view().bounds());
            scrollView.setBackgroundColor_(UIColor.whiteColor());
            scrollView.setContentSize_(new TTSize(0, self.view().bounds().size.height));
            self.view().addSubview_(scrollView);
            self.setScrollView_(scrollView);
            return scrollView;
        },
        getHomeModule1: function () {
            var imgView = UIImageView.alloc().initWithFrame_(new TTReact(10, 10, self.view().frame().size.width - 20, self.view().frame().size.width * .75 - 20));
            imgView.setImage_(UIImage.imageNamed_("AppHome"));
            imgView.setContentMode_(1);
            imgView.setBackgroundColor_(UIColor.whiteColor());
            return imgView;
        },
        getHomeModule2: function () {
            var label = UILabel.new();
            label.setFont_(UIFont.systemFontOfSize_(18));
            label.setTextColor_(UIColor.blackColor());
            label.setFrame_(new TTReact(10, self.view().frame().size.width * .75, self.view().bounds().size.width - 20, self.view().frame().size.width * .75));
            label.setText_("本页面由纯JS编写,具体见 Home.js \n\n    开发项目的初衷是为了修复线上紧急bug,但是随着编写发现里面的内容比较有趣,又了解到有些公司通过下发js动态更新页面,因为有趣就扩展了热更新的部分功能 \n    现在开发成果已经可以热修复，热更新，动态调用Oc方法，参数返回值类型处理，方法hook\n\n列举一下使用场景:\n  1. 线上某段代码没做安全判断导致crash\n  2. 可以替换某个模块实现\n  3. 各大节日动态下发活动入口");
            label.setNumberOfLines_(0);
            return label;
        },

        getHomeModule4: function () {
            var button = UIButton.buttonWithType_(0);
            button.setFrame_(new TTReact(10, self.view().frame().size.width * .75 * 2 + 20, self.view().bounds().size.width - 20, 44));
            button.setTitle_forState_("查看使用详情", 0);
            button.addTarget_action_forControlEvents_(self, "btnDidAction", 1 << 6);
            button.setBackgroundColor_(UIColor.systemGreenColor());
            return button;
        },



        btnDidAction: function () {

            var gitHomeVC = SFSafariViewController.alloc().initWithURL_(NSURL.URLWithString_("https://github.com/yangyangFeng/TTPatch/blob/master/README.md"));
            self.navigationController().pushViewController_animated_(gitHomeVC, true);
        }

}, {

});




defineClass('GitHomeViewController:UIViewController', {
    viewDidLoad: function () {
            Super().viewDidLoad();
            self.view().addSubview_(self.getHomeModule3());
            self.setTitle_("README.md");
        },
        getHomeModule3: function () {
            var webview = WKWebView.alloc().initWithFrame_((new TTReact(10, 10, self.view().bounds().size.width - 20, self.view().bounds().size.height - 10 * 2)));
            webview.loadRequest_(NSURLRequest.requestWithURL_(NSURL.URLWithString_("https://github.com/yangyangFeng/TTPatch/blob/master/README.md")));

            return webview;
        },
}, {})