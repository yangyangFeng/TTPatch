_import('UIView,UILabel,UIImage,UIButton,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,TTTableView,UIScreen,UIImageView,UIScrollView,WKWebView,NSURLRequest,NSURL,UIApplication,GitHomeViewController');
defineClass('HomeViewController:UIViewController', {
    scrollView: property(),
    viewDidLoad: function () {
        Super().call('viewDidLoad');
        let dataSource = [
            '加载下发模块',
            'JS-OC间block',
            '点击加载更多'
        ];
        self.call('view').call('setBackgroundColor_', UIColor.call('whiteColor'));
        Util.log('js调用 viewDidLoad');
        self.call('setTitle_', 'TTPatch.js');
        self.call('getScorllView').call('addSubview_', self.call('getHomeModule1'));
        self.call('scrollView').call('addSubview_', self.call('getHomeModule2'));
        self.call('scrollView').call('addSubview_', self.call('getHomeModule4'));
        self.call('scrollView').call('setBackgroundColor_', UIColor.call('groupTableViewBackgroundColor'));
    },
    getScorllView: function () {
        var scrollView = UIScrollView.call('alloc').call('initWithFrame_', self.call('view').call('bounds'));
        scrollView.call('setBackgroundColor_', UIColor.call('whiteColor'));
        scrollView.call('setContentSize_', new TTSize(0, self.call('view').call('bounds').size.height));
        self.call('view').call('addSubview_', scrollView);
        self.call('setScrollView_', scrollView);
        return scrollView;
    },
    getHomeModule1: function () {
        var imgView = UIImageView.call('alloc').call('initWithFrame_', new TTReact(10, 10, self.call('view').call('frame').size.width - 20, self.call('view').call('frame').size.width * 0.75 - 20));
        imgView.call('setImage_', UIImage.call('imageNamed_', 'AppHome'));
        imgView.call('setContentMode_', 1);
        imgView.call('setBackgroundColor_', UIColor.call('whiteColor'));
        return imgView;
    },
    getHomeModule2: function () {
        var label = UILabel.call('new');
        label.call('setFont_', UIFont.call('systemFontOfSize_', 18));
        label.call('setTextColor_', UIColor.call('blackColor'));
        label.call('setFrame_', new TTReact(10, self.call('view').call('frame').size.width * 0.75, self.call('view').call('bounds').size.width - 20, self.call('view').call('frame').size.width * 0.75));
        label.call('setText_', '本页面由纯JS编写,具体见 Home.js \n\n    开发项目的初衷是为了修复线上紧急bug,但是随着编写发现里面的内容比较有趣,又了解到有些公司通过下发js动态更新页面,因为有趣就扩展了热更新的部分功能 \n    现在开发成果已经可以热修复\uFF0C热更新\uFF0C动态调用Oc方法\uFF0C参数返回值类型处理\uFF0C方法hook\n\n列举一下使用场景:\n  1. 线上某段代码没做安全判断导致crash\n  2. 可以替换某个模块实现\n  3. 各大节日动态下发活动入口');
        label.call('setNumberOfLines_', 0);
        return label;
    },
    getHomeModule4: function () {
        var button = UIButton.call('buttonWithType_', 0);
        button.call('setFrame_', new TTReact(10, self.call('view').call('frame').size.width * 0.75 * 2 + 20, self.call('view').call('bounds').size.width - 20, 44));
        button.call('setTitle_forState_', '查看使用详情', 0);
        button.call('addTarget_action_forControlEvents_', self, 'btnDidAction', 1 << 6);
        button.call('setBackgroundColor_', UIColor.call('systemGreenColor'));
        return button;
    },
    btnDidAction: function () {
        var gitHomeVC = GitHomeViewController.call('new');
        self.call('navigationController').call('pushViewController_animated_', gitHomeVC, true);
    }
}, {});
defineClass('GitHomeViewController:UIViewController', {
    viewDidLoad: function () {
        Super().call('viewDidLoad');
        self.call('view').call('addSubview_', self.call('getHomeModule3'));
        self.call('setTitle_', 'README.md');
    },
    getHomeModule3: function () {
        var webview = WKWebView.call('alloc').call('initWithFrame_', new TTReact(10, 10, self.call('view').call('bounds').size.width - 20, self.call('view').call('bounds').size.height - 10 * 2));
        webview.call('loadRequest_', NSURLRequest.call('requestWithURL_', NSURL.call('URLWithString_', 'https://github.com/yangyangFeng/TTPatch/blob/master/README.md')));
        return webview;
    }
}, {});