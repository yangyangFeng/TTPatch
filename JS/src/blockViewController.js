_import(
  "NSMutableDictionary,NSMutableArray,UIView,UILabel,UIImage,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,UIScreen,UIImageView,TaoBaoHome"
);

defineClass(
  "BlockViewController:UITableViewController",
  {
    dealloc: function () {
      Utils.log("BlockViewController->已释放");
    },
    viewDidLoad: function () {
      Super().viewDidLoad();
      self.addSomeTestView();
    },
    refresh: function () {
      // Super().testSuper();
      // self.testSuper();
      self.cleanSubviews();
      self.addSomeTestView();
    },
    cleanSubviews: function () {
      self
        .view()
        .subviews()
        .forEach((subview) => {
          if (subview != "UITableView") {
            subview.removeFromSuperview();
          } else {
            self.tableView().reloadData();
          }
        });
    },
    sendMessage_: function (msg) {
      Utils.log_info(msg);
    },
    sendMessageVC_: function (vc) {
      vc.view().setBackgroundColor_(UIColor.blackColor());
    },
    addSomeTestView: function () {
      self.setTitle_("BlockViewController");
      self.view().setBackgroundColor_(UIColor.whiteColor());
      let screenWidth = UIScreen.mainScreen().bounds().size.width;
      let screenHeight = UIScreen.mainScreen().bounds().size.height;

      let logo = UIImageView.new();
      logo.setImage_(UIImage.imageNamed_("applelogo"));
      logo.setFrame_(new TTReact(50, 50, 100, 100));
      logo.setCenter_(new TTPoint(screenWidth / 2, screenHeight - 250));
      let title = UILabel.new();
      title.setText_("Apple");
      title.setFont_(UIFont.fontWithName_size_("GillSans-UltraBold", 25));
      title.setTextAlignment_(1);
      title.setFrame_(new TTReact(50, 150, 150, 100));
      title.setCenter_(new TTPoint(screenWidth / 2, screenHeight - 150));
      self.view().addSubview_(logo);
      self.view().addSubview_(title);
    },
    btnAction_: function (index) {
      switch (index) {
        case 0:
          {
            self.noReturnParamsVoid_(
              block("void,void", function () {
                Utils.log_info(
                  "--------JS传入OC方法,接受到回调--------- 无参数,无返回值"
                );
              })
            );
          }
          break;
        case 1:
          {
            self.noReturnParamsStringInt_(
              block("void,id,int", function (arg1, arg2) {
                var dic = JSON.parse(arg1);
                Utils.log_info(
                  "--------JS传入OC方法,接受到回调--------- 有参数,无返回值  " +
                    dic.name +
                    "-" +
                    arg2
                );
              })
            );
          }
          break;
        case 2:
          {
            Utils.log_info("runBlock, js调用");
            self.returnParamsId_(
              block("id,id", function (arg) {
                var dic = JSON.parse(
                  '{"id":1,"name":"jb51","email":"admin@jb51.net","interest":["wordpress","php"]}'
                );
                Utils.log_info(
                  "--------JS传入OC方法,接受到回调--------- 有参数,有返回值:string  " +
                    arg
                );
                arg.view().setBackgroundColor_(UIColor.blackColor());
                return dic;
              })
            );
          }
          break;
        case 3:
          {
            Utils.log_info("runBlock, js调用");
            self.runBlock();
          }
          break;

        default:
          {
            //方法签名第一位 是返回值,如果返回为void可以不填,但是要以","分割
            self.testMoreParams_(
              block("id, id, id, int, bool, float, id", function (
                arg1,
                arg2,
                arg3,
                arg4,
                arg5,
                arg6
              ) {
                Utils.log_info(
                  "--------JS传入OC方法,接受到回调---------" +
                    arg1 +
                    "\n" +
                    arg2 +
                    "\n" +
                    arg3 +
                    "\n" +
                    arg4 +
                    "\n" +
                    arg5 +
                    "\n" +
                    arg6
                );
              })
            );
            // self.OCcallBlock_(
            //   block(",id", function (arg1) {
            //     Utils.log_info("js与js block回调" + arg1);
            //   })
            // );
          }
          break;
      }
    },
    OCNoReturnParams_: function (callback) {
      Utils.log_info("OC block 传入JS, js调用");
      if (callback) {
        callback("OCNoReturnParams: arg: 10");
      }
    },
  },
  {}
);
