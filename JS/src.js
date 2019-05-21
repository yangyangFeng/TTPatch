_import('UIView,UILabel,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont')
defineClass('ViewController:UIViewController',{

    refresh:function(){

        var color = UIColor.call("colorWithWhite_alpha_",0.01,10);
        self.call("tableview").call("setBackgroundColor_",color);
        log('JS--------');
        var text = self.call('cell').call('textLabel');
        text.call('setText_','我是你爷爷');

        var index = NSIndexPath.call('indexPathForRow_inSection_',5,0);
        var tempCell = self.call('tableview').call('cellForRowAtIndexPath_',index);
        var tempCellText = tempCell.call('textLabel');
        tempCellText.call('setFont_',UIFont.call('systemFontOfSize_',5))
        tempCellText.call('setTextColor_',color)
        tempCell.call('setBackgroundColor_',color);
        tempCellText.call('setText_','我是你爷爷的asdasdasd爷爷');
        // self.call('tableview').call('removeFromSuperview');
        self.call('view').call('addSubview:',self.call('tableview'));
    },
    viewDidLoad:function(){
        self.call('ttviewDidLoad');
        
        self.call('view').call('addSubview_',self.call('tableview'));
        // self.call('tableview')
        console.log('js调用 viewDidLoad');
        log('JS--------');
    },
    customtableView_numberOfRowsInSection_:function(tableview,section){
        return 666666666;
    },
    countA:function(){

    }
    // tableView_cellForRowAtIndexPath_:function(tableview,indexPath){
    //     var cell = UITableViewCell.call('alloc').call('initWithStyle_reuseIdentifier_',0,'cell');
    //     cell.call('textLabel').call('setText_',"我是第----------")
    //     // cell.textLabel.text = "我是第----------",indexPath.call('row')+'名';
    //     // if (indexPath.call('row') == 1) {
    //     //     self.call('cell') = cell;
    //     // }
    //     return cell;
    // }
    
},{
    
});
