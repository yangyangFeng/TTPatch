_import(
  "NSMutableDictionary,NSMutableArray,UIView,UILabel,UIImage,UIColor,TTView,ViewController,UITableViewCell,UITableView,NSIndexPath,UIFont,UIScreen,UIImageView,TaoBaoHome"
);

defineClass(
  "ViewController:UIViewController<UITableViewDelegate,UITableViewDataSource>",
  {
    data: property(),
    viewDidLoad: function () {
      /**
       * super 使用
       */
      Super().viewDidLoad();
      /**
       * self 使用
       */
      self.refresh();
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
          subview.removeFromSuperview();
        });
    },
    addSomeTestView: function () {
      let dataSource = [
        "加载纯JS模块",
        "JS动态替换Native方法, 热修复场景",
        "淘宝大事故修复方案",
        "动态添加数据",
      ];
      self.setData_(dataSource);
      let data = self.data();
      let tableview = self.getTableview();
      tableview.setTableHeaderView_(self.createPageHeader());
      self.setTableview_(tableview);
      self.view().addSubview_(tableview);
      self.setTitle_("Demo.js");
    },
    tableView_numberOfRowsInSection_: dynamic(
      "long long,@,long long",
      function (tableview, section) {
        let data = self.data();

        return data.length;
      }
    ),
    tableView_cellForRowAtIndexPath_: dynamic("@,@,@", function (
      tableview,
      indexPath
    ) {
      let cell = UITableViewCell.alloc().initWithStyle_reuseIdentifier_(
        1,
        "cell"
      );
      let data;

      data = self.data()[indexPath.row()];

      cell.textLabel().setText_("<" + data + ">");
      return cell;
    }),
    tableView_didSelectRowAtIndexPath_: dynamic("@,@,@", function (
      tableview,
      indexPath
    ) {
      if (indexPath.row() === 0) {
        let vc = JSRootViewController.new();
        self.navigationController().pushViewController_animated_(vc, true);
        vc = null;
      } else if (indexPath.row() === 1) {
        let vc = BlockViewController.new();
        self.navigationController().pushViewController_animated_(vc, true);
        vc = null;
      } else if (indexPath.row() === 2) {
        let vc = TaoBaoHome.new();
        self.navigationController().pushViewController_animated_(vc, true);
        vc = null;
      } else {
        let dataSource = self.data();

        dataSource.push("点击加载更多Cell");

        self.setData_(dataSource);
        self.tableview().reloadData();
      }
    }),
    getTableview: function () {
      _tableview = UITableView.alloc().initWithFrame_style_(
        self.view().bounds(),
        0
      );
      _tableview.setDelegate_(self);
      _tableview.setDataSource_(self);
      return _tableview;
    },
    params1_params2_params3_params4_params5_params6_params7_: function (
      params1,
      params2,
      params3,
      params4,
      params5,
      params6,
      params7
    ) {
      Util.nLog(0, "--------多参数测试---------");
      Util.log(params1, params2, params3, params4, params5, params6, params7);
    },
    createPageHeader: function () {
      var label = UILabel.new();
      label.setFont_(UIFont.systemFontOfSize_(18));
      label.setTextColor_(UIColor.whiteColor());
      label.setBackgroundColor_(UIColor.systemGreenColor());
      label.setFrame_(
        new TTReact(
          10,
          self.view().frame().size.width * 0.75,
          self.view().bounds().size.width - 20,
          self.view().frame().size.height * 0.15
        )
      );
      label.setText_(
        "具体功能实例 \n\n    动态加载纯JS页面, JS与OC之间的Block传递,调用"
      );
      label.setNumberOfLines_(0);
      return label;
    },
  },
  {}
);

//动态生成模块
defineClass(
  "JSRootViewController:RootViewController",
  {
    dealloc: function () {
      Utils.log("TestViewController->已释放");
    },
    viewDidLoad: function () {
      Super().viewDidLoad();
      self.addSomeTestView();
    },
    refresh: function () {
      self.cleanSubviews();
      self.addSomeTestView();
      Utils.log_error("refresh");
    },
    cleanSubviews: function () {
      self
        .view()
        .subviews()
        .forEach((subview) => {
          subview.removeFromSuperview();
        });
    },
    addSomeTestView: function () {
      self.setTitle_("动态创建控制器 JSRootViewController");
      self.view().setBackgroundColor_(UIColor.whiteColor());
      let screenWidth = UIScreen.mainScreen().bounds().size.width;
      let screenHeight = UIScreen.mainScreen().bounds().size.height;

      let logo = UIImageView.new();
      logo.setImage_(UIImage.imageNamed_("applelogo"));
      logo.setFrame_(new TTReact(50, 50, 100, 100));
      logo.setCenter_(new TTPoint(screenWidth / 2, 150));
      let title = UILabel.new();
      title.setText_("Apple");
      title.setFont_(UIFont.fontWithName_size_("GillSans-UltraBold", 25));
      title.setTextAlignment_(1);
      title.setFrame_(new TTReact(50, 150, 100, 100));
      title.setCenter_(new TTPoint(screenWidth / 2, 270));
      self.view().addSubview_(logo);
      self.view().addSubview_(title);

      {
        let title = UILabel.new();
        title.setText_(
          "------------------------\n本页面由纯JS编写,具体使用场景可结合自身业务使用\n------------------------\n\n 请在src/目录下搜索`JSRootViewController`修改js文件查看效果"
        );
        title.setNumberOfLines_(0);
        title.setTextAlignment_(1);
        title.setFrame_(new TTReact(50, 150, 200, 300));
        title.setCenter_(new TTPoint(screenWidth / 2, 370));
        // self.view().addSubview_(logo);
        self.view().addSubview_(title);
      }
    },
  },
  {}
);
