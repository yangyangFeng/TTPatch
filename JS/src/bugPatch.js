_import('UIView,UILabel,UIImage,UIColor,TTView,UITableViewCell,UITableView,NSIndexPath,UIFont,TTTableView,UIScreen,UIImageView,TaoBaoHome')

defineClass('TaoBaoHome:UIViewController',{
    viewDidLoad:function () {
		Super().viewDidLoad();
		var home = UIImageView.alloc().initWithImage_(UIImage.imageNamed_("tianmao.jpg"));
        home.setFrame_(self.view().bounds());
        self.view().addSubview_(home);
	},
},{});
