_import('UIView,UILabel,UIImage,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,TTTableView,UIScreen,UIImageView');
defineClass('ViewController:UIViewController', {
    data: property(),
    loadJSCode: function () {
        let dataSource = [
            '加载下发模块',
            'JS-OC间block',
            '点击加载更多'
        ];
        self.call('setData_', dataSource);
        let data = self.call('data');
        let tableview = self.call('getTableview');
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
        } else {
            let dataSource = self.call('data');
            dataSource.call('push', '新增Cell');
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
            title.call('setText_', '------关于我们------');
            title.call('setTextAlignment_', 1);
            title.call('setFrame_', new TTReact(50, 150, 200, 100));
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
        logo.call('setCenter_', new TTPoint(screenWidth / 2, 150));
        let title = UILabel.call('new');
        title.call('setText_', 'Apple');
        title.call('setFont_', UIFont.call('fontWithName_size_', 'GillSans-UltraBold', 25));
        title.call('setTextAlignment_', 1);
        title.call('setFrame_', new TTReact(50, 150, 100, 100));
        title.call('setCenter_', new TTPoint(screenWidth / 2, 270));
        self.call('view').call('addSubview_', logo);
        self.call('view').call('addSubview_', title);
    },
    btnAction_: function (index) {
        switch (index) {
        case 0: {
                self.call('testCall0_', function () {
                    Util.log('--------JS传入OC方法,接受到回调--------- 无参数,无返回值');
                });
            }
            break;
        case 1: {
                self.call('testCall1_', function (arg) {
                    Util.log('--------JS传入OC方法,接受到回调--------- 有参数,无返回值  ' + arg);
                });
            }
            break;
        case 2: {
                self.call('testCall2_', function (arg) {
                    Util.log('--------JS传入OC方法,接受到回调--------- 有参数,有返回值:string  ' + arg);
                    return '这是有返回值的哦';
                });
            }
            break;
        case 3: {
                self.call('testCall3_', function () {
                    Util.log('--------JS传入OC方法,接受到回调--------- 有参数,有返回值:string  ');
                    return '这是有返回值的哦';
                });
            }
            break;
        case 4: {
                self.call('runBlock');
            }
            break;
        default: {
                self.call('testCallVID_', function (arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) {
                    Util.log('--------JS传入OC方法,接受到回调---------' + arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7 + arg8, arg9);
                });
                self.call('OCcallBlock_', function (arg1) {
                    Util.log('js与js block回调' + arg1);
                });
            }
            break;
        }
    },
    callBlock_: function (callback) {
        if (callback) {
            callback('js object');
        }
    }
}, {});