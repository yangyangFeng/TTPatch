_import('UIView,UILabel,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont');
defineClass('ViewController:UIViewController', {
    refresh: function () {
        var color = UIColor.call('call', 'colorWithWhite_alpha_', 1, 1);
        self.call('call', 'tableview').call('call', 'setBackgroundColor_', color);
        log('JS--------');
        var text = self.call('call', 'cell').call('call', 'textLabel');
        text.call('call', 'setText_', '我是**的大**\uFF0C你是一个大\uD83C\uDF4E\uD83C\uDF4E\uD83C\uDF4E');
        var tempCell = self.call('call', 'cell');
        var tempCellText = tempCell.call('call', 'textLabel');
        tempCellText.call('call', 'setFont_', UIFont.call('call', 'systemFontOfSize_', 20));
        tempCellText.call('call', 'setTextColor_', UIColor.call('call', 'redColor'));
        tempCell.call('call', 'setBackgroundColor_', color);
        tempCellText.call('call', 'setText_', '我是DJ喜洋洋\uFF0C青青草原我最狂~~~~~~');
    },
    viewDidLoad: function () {
        self.call('call', 'ttviewDidLoad');
        var tableview = self.call('call', 'getTableview');
        self.call('call', 'setTableview_', tableview);
        self.call('call', 'view').call('call', 'addSubview_', tableview);
        Util.log('js调用 viewDidLoad');
        log('JS--------viewDidLoad');
    },
    tableView_numberOfRowsInSection_: function (tableview, section) {
        return 10;
    },
    countA: function () {
    },
    tableView_cellForRowAtIndexPath_: function (tableview, indexPath) {
        let cell = UITableViewCell.call('call', 'alloc').call('call', 'initWithStyle_reuseIdentifier_', 0, 'cell');
        cell.call('call', 'textLabel').call('call', 'setText_', '我是第----------' + indexPath.call('call', 'row') + '    cell');
        if (indexPath.call('call', 'row') === 1) {
            self.call('call', 'setCell_', cell);
        }
        return cell;
    }
}, {});