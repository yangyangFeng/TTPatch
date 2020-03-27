_import('UIView,UILabel,UIImage,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,TTTableView,UIScreen,UIImageView,TaoBaoHome');
defineClass('ViewController:UIViewController', {
    data: property(),
    loadJSCode: function () {
        let dataSource = [
            '加载纯JS模块',
            'JS-OC block调用示例',
            '淘宝大事故修复方案',
            '动态添加数据'
        ];
        self.call('setData_', dataSource);
        let data = self.call('data');
        let tableview = self.call('getTableview');
        tableview.call('setTableHeaderView_', self.call('createPageHeader'));
        self.call('setTableview_', tableview);
        self.call('view').call('addSubview_', tableview);
        Util.log('js调用 viewDidLoad');
        self.call('setTitle_', 'Demo.js');
    },
    tableView_numberOfRowsInSection_: function (tableview, section) {
        let data = self.call('data');
        return data.length;
    },
    tableView_cellForRowAtIndexPath_: function (tableview, indexPath) {
        let cell = UITableViewCell.call('alloc').call('initWithStyle_reuseIdentifier_', 1, 'cell');
        let data = self.call('data')[indexPath.call('row')];
        cell.call('textLabel').call('setText_', '<' + data + '>');
        return cell;
    },
    tableView_didSelectRowAtIndexPath_: function (tableview, indexPath) {
        if (indexPath.call('row') === 0) {
            let vc = JSRootViewController.call('new');
            self.call('navigationController').call('pushViewController_animated_', vc, true);
            vc = null;
        } else if (indexPath.call('row') === 1) {
            let vc = BlockViewController.call('new');
            self.call('navigationController').call('pushViewController_animated_', vc, true);
            vc = null;
        } else if (indexPath.call('row') === 2) {
            let vc = TaoBaoHome.call('new');
            self.call('navigationController').call('pushViewController_animated_', vc, true);
            vc = null;
        } else {
            let dataSource = self.call('data');
            dataSource.call('push', '点击加载更多Cell');
            self.call('setData_', dataSource);
            self.call('tableview').call('reloadData');
        }
    },
    getTableview: function () {
        _tableview = TTTableView.call('alloc').call('initWithFrame_style_', self.call('view').call('bounds'), 0);
        _tableview.call('setDelegate_', self);
        _tableview.call('setDataSource_', self);
        return _tableview;
    },
    params1_params2_params3_params4_params5_params6_params7_: function (params1, params2, params3, params4, params5, params6, params7) {
        Util.log('--------多参数测试---------');
        Util.log(params1, params2, params3, params4, params5, params6, params7);
    },
    createPageHeader: function () {
        var label = UILabel.call('new');
        label.call('setFont_', UIFont.call('systemFontOfSize_', 18));
        label.call('setTextColor_', UIColor.call('whiteColor'));
        label.call('setBackgroundColor_', UIColor.call('systemGreenColor'));
        label.call('setFrame_', new TTReact(10, self.call('view').call('frame').size.width * 0.75, self.call('view').call('bounds').size.width - 20, self.call('view').call('frame').size.height * 0.15));
        label.call('setText_', '具体功能实例 \n\n    动态加载纯JS页面, JS与OC之间的Block传递,调用');
        label.call('setNumberOfLines_', 0);
        return label;
    }
}, {});
defineClass('JSRootViewController:UIViewController', {
    dealloc: function () {
        Util.log('TestViewController->已释放');
    },
    viewDidLoad: function () {
        Super().call('viewDidLoad');
        self.call('setTitle_', '动态下发模块');
        self.call('view').call('setBackgroundColor_', UIColor.call('whiteColor'));
        let screenWidth = UIScreen.call('mainScreen').call('bounds').size.width;
        let screenHeight = UIScreen.call('mainScreen').call('bounds').size.height;
        let logo = UIImageView.call('new');
        logo.call('setImage_', UIImage.call('imageNamed_', 'applelogo'));
        logo.call('setFrame_', new TTReact(50, 50, 100, 100));
        logo.call('setCenter_', new TTPoint(screenWidth / 2, 150));
        let title = UILabel.call('new');
        title.call('setText_', 'Apple');
        title.call('setFont_', UIFont.call('fontWithName_size_', 'GillSans-UltraBold', 25));
        title.call('setTextAlignment_', 1);
        title.call('setFrame_', new TTReact(50, 150, 100, 100));
        title.call('setCenter_', new TTPoint(screenWidth / 2, 270));
        self.call('view').call('addSubview_', logo);
        self.call('view').call('addSubview_', title);
        {
            let title = UILabel.call('new');
            title.call('setText_', '------------------------\n本页面由纯JS编写,具体使用场景可结合自身业务使用\n------------------------');
            title.call('setNumberOfLines_', 0);
            title.call('setTextAlignment_', 1);
            title.call('setFrame_', new TTReact(50, 150, 200, 300));
            title.call('setCenter_', new TTPoint(screenWidth / 2, 370));
            self.call('view').call('addSubview_', title);
        }
    }
}, {});
defineClass('BlockViewController:UITableViewController', {
    dealloc: function () {
        Util.log('BlockViewController->已释放');
    },
    viewDidLoad: function () {
        Super().call('viewDidLoad');
        self.call('setTitle_', '动态下发模块');
        self.call('view').call('setBackgroundColor_', UIColor.call('whiteColor'));
        let screenWidth = UIScreen.call('mainScreen').call('bounds').size.width;
        let screenHeight = UIScreen.call('mainScreen').call('bounds').size.height;
        let logo = UIImageView.call('new');
        logo.call('setImage_', UIImage.call('imageNamed_', 'applelogo'));
        logo.call('setFrame_', new TTReact(50, 50, 100, 100));
        logo.call('setCenter_', new TTPoint(screenWidth / 2, screenHeight - 250));
        let title = UILabel.call('new');
        title.call('setText_', 'Apple');
        title.call('setFont_', UIFont.call('fontWithName_size_', 'GillSans-UltraBold', 25));
        title.call('setTextAlignment_', 1);
        title.call('setFrame_', new TTReact(50, 150, 150, 100));
        title.call('setCenter_', new TTPoint(screenWidth / 2, screenHeight - 150));
        self.call('view').call('addSubview_', logo);
        self.call('view').call('addSubview_', title);
    },
    btnAction_: function (index) {
        switch (index) {
        case 0: {
                self.call('testCall0_', block(''), function () {
                    Util.log('--------JS传入OC方法,接受到回调--------- 无参数,无返回值');
                });
            }
            break;
        case 1: {
                self.call('testCall1_', block('void,NSString*,int'), function (arg1, arg2) {
                    Util.log('--------JS传入OC方法,接受到回调--------- 有参数,无返回值  ' + arg1 + arg2);
                });
            }
            break;
        case 2: {
                self.call('testCall2_', block('NSString*,NSString*'), function (arg) {
                    Util.log('--------JS传入OC方法,接受到回调--------- 有参数,有返回值:string  ' + arg);
                    return '这是有返回值的哦';
                });
            }
            break;
        case 3: {
                self.call('testCall3_', block('NSString*,void'), function () {
                    Util.log('--------JS传入OC方法,接受到回调--------- 无参数,有返回值:string  ');
                    return '这是有返回值的哦';
                });
            }
            break;
        case 4: {
                self.call('runBlock');
            }
            break;
        default: {
                self.call('testCallVID_', block(',NSString *, NSString *, int, bool, float , NSNumber* '), function (arg1, arg2, arg3, arg4, arg5, arg6) {
                    Util.log('--------JS传入OC方法,接受到回调---------' + arg1 + '\n' + arg2 + '\n' + arg3 + '\n' + arg4 + '\n' + arg5 + '\n' + arg6);
                });
                self.call('OCcallBlock_', block(''), function (arg1) {
                    Util.log('js与js block回调' + arg1);
                });
            }
            break;
        }
    },
    callBlock_: function (callback) {
        if (callback) {
            callback(10);
        }
    }
}, {});