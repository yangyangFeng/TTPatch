_import('UIView,UILabel,UIColor,TTView,ViewController,UITableViewCell,UITableView');
defineClass('ViewController:UIViewController', {
    addView: function () {
        console.call('call', 'log', 'viewDidLoad');
        var a = TTView.call('call', 'alloc').call('call', 'initWithFrame_', new TTReact(120, 100, 100, 100));
        var color = UIColor.call('call', 'blackColor');
        a.call('call', 'setBackgroundColor_', color);
    },
    refresh: function () {
        var color = UIColor.call('call', 'redColor');
        self.call('call', 'tableview').call('call', 'setBackgroundColor_', color);
        console.call('call', 'log', '刷新');
    },
    viewDidLoad: function () {
        self.call('call', 'call', 'ttviewDidLoad');
    },
    addTableView: function () {
    },
    execJSCode_: function (obj) {
    }
}, {});