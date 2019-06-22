_import('UIView,UILabel,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont')
defineClass('ViewController:UIViewController',{

    refresh:function(){

        var color = UIColor.call("colorWithWhite_alpha_",1,1);
        self.call("tableview").call("setBackgroundColor_",color);
        log('JS--------');
        var text = self.call('cell').call('textLabel');
        text.call('setText_','我是**的大**，你是一个大🍎🍎🍎');

        // var index = NSIndexPath.call('indexPathForRow_inSection_',5,0);
        // var tempCell = self.call('tableview').call('cellForRowAtIndexPath_',index);
		var tempCell = self.call('cell');
        var tempCellText = tempCell.call('textLabel');
        tempCellText.call('setFont_',UIFont.call('systemFontOfSize_',20))
        // log(tempCell);
        tempCellText.call('setTextColor_',UIColor.call('redColor'))
        tempCell.call('setBackgroundColor_',color);
        tempCellText.call('setText_','我是DJ喜洋洋，青青草原我最狂~~~~~~');
        // // self.call('tableview').call('removeFromSuperview');
        // self.call('view').call('addSubview:',self.call('tableview'));
        
        // self.call('tableview').call('reloadData');
    },
    viewDidLoad:function(){
        self.call('ttviewDidLoad');
        var tableview = self.call('getTableview')
        self.call('setTableview_',tableview);
        self.call('view').call('addSubview_',tableview);
        // self.call('tableview')
		Util.log('js调用 viewDidLoad');
        log('JS--------viewDidLoad');
    },
    tableView_numberOfRowsInSection_:function(tableview,section){
        return 10;
    },
    countA:function(){

    }
    ,
    tableView_cellForRowAtIndexPath_:function(tableview,indexPath){
        let cell = UITableViewCell.call('alloc').call('initWithStyle_reuseIdentifier_',0,'cell');
        cell.call('textLabel').call('setText_',"我是第----------"+indexPath.call('row')+'    cell');
		// cell.call('textLabel').call('setText_',"我是第----------"+'名');
        if (indexPath.call('row') === 1) {
            self.call('setCell_',cell);
        }
        return cell;
    }
    
},{
    
});
