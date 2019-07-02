_import('UIView,UILabel,UIImage,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,TTTableView,UIScreen,UIImageView');
defineClass('ViewController:UIViewController', {
    data: property(),
    loadJSCode: function () {
        let dataSource = [
            '加载下发模块',
            '点击加载更多'
        ];
        self.call('setData_', dataSource);
        let data = self.call('data');
        let tableview = self.call('getTableview');
        self.call('setTableview_', tableview);
        self.call('view').call('addSubview_', tableview);
        Util.log('js调用 viewDidLoad');
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
    }
}, {});