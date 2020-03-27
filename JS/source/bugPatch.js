_import('UIView,UILabel,UIImage,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,TTTableView,UIScreen,UIImageView,TaoBaoHome');
defineClass('TaoBaoHome:UIViewController', {
    viewDidLoad: function () {
        Super().call('viewDidLoad');
        var home = UIImageView.call('alloc').call('initWithImage_', UIImage.call('imageNamed_', 'tianmao.jpg'));
        home.call('setFrame_', self.call('view').call('bounds'));
        self.call('view').call('addSubview_', home);
    }
}, {});