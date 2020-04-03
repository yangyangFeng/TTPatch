_import('UIView,UILabel,UIImage,UIButton,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,UIScreen,UIImageView,UIScrollView,WKWebView,NSURLRequest,NSURL,UIApplication,GitHomeViewController');defineClass('HomeViewController:UIViewController', {scrollView: property(),viewDidLoad: function () {Super()._c('viewDidLoad');let dataSource = ['加载下发模块','JS-OC间block','点击加载更多'];self._c('view')._c('setBackgroundColor_', UIColor._c('whiteColor'));Utils.log('js调用 viewDidLoad');self._c('setTitle_', 'TTPatch.js');self._c('getScorllView')._c('addSubview_', self._c('getHomeModule1'));self._c('scrollView')._c('addSubview_', self._c('getHomeModule2'));self._c('scrollView')._c('addSubview_', self._c('getHomeModule4'));self._c('scrollView')._c('setBackgroundColor_', UIColor._c('groupTableViewBackgroundColor'));},getScorllView: function () {var scrollView = UIScrollView._c('alloc')._c('initWithFrame_', self._c('view')._c('bounds'));scrollView._c('setBackgroundColor_', UIColor._c('whiteColor'));scrollView._c('setContentSize_', new TTSize(0, self._c('view')._c('bounds').size.height));self._c('view')._c('addSubview_', scrollView);self._c('setScrollView_', scrollView);return scrollView;},getHomeModule1: function () {var imgView = UIImageView._c('alloc')._c('initWithFrame_', new TTReact(10, 10, self._c('view')._c('frame').size.width - 20, self._c('view')._c('frame').size.width * 0.75 - 20));imgView._c('setImage_', UIImage._c('imageNamed_', 'AppHome'));imgView._c('setContentMode_', 1);imgView._c('setBackgroundColor_', UIColor._c('whiteColor'));return imgView;},getHomeModule2: function () {var label = UILabel._c('new');label._c('setFont_', UIFont._c('systemFontOfSize_', 18));label._c('setTextColor_', UIColor._c('blackColor'));label._c('setFrame_', new TTReact(10, self._c('view')._c('frame').size.width * 0.75, self._c('view')._c('bounds').size.width - 20, self._c('view')._c('frame').size.width * 0.75));label._c('setText_', '本页面由纯JS编写,具体见 Home.js \n\n开发项目的初衷是为了修复线上紧急bug,但是随着编写发现里面的内容比较有趣,又了解到有些公司通过下发js动态更新页面,因为有趣就扩展了热更新的部分功能 \n现在开发成果已经可以热修复\uFF0C热更新\uFF0C动态调用Oc方法\uFF0C参数返回值类型处理\uFF0C方法hook\n\n列举一下使用场景:\n1. 线上某段代码没做安全判断导致crash\n2. 可以替换某个模块实现\n3. 各大节日动态下发活动入口');label._c('setNumberOfLines_', 0);return label;},getHomeModule4: function () {var button = UIButton._c('buttonWithType_', 0);button._c('setFrame_', new TTReact(10, self._c('view')._c('frame').size.width * 0.75 * 2 + 20, self._c('view')._c('bounds').size.width - 20, 44));button._c('setTitle_forState_', '查看使用详情', 0);button._c('addTarget_action_forControlEvents_', self, 'btnDidAction', 1 << 6);button._c('setBackgroundColor_', UIColor._c('systemGreenColor'));return button;},btnDidAction: function () {var gitHomeVC = GitHomeViewController._c('new');self._c('navigationController')._c('pushViewController_animated_', gitHomeVC, true);}}, {});defineClass('GitHomeViewController:UIViewController', {viewDidLoad: function () {Super()._c('viewDidLoad');self._c('view')._c('addSubview_', self._c('getHomeModule3'));self._c('setTitle_', 'README.md');},getHomeModule3: function () {var webview = WKWebView._c('alloc')._c('initWithFrame_', new TTReact(10, 10, self._c('view')._c('bounds').size.width - 20, self._c('view')._c('bounds').size.height - 10 * 2));webview._c('loadRequest_', NSURLRequest._c('requestWithURL_', NSURL._c('URLWithString_', 'https://github.com/yangyangFeng/TTPatch/blob/master/README.md')));return webview;}}, {});