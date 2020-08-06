/**
 * 引入UI组件,不引入无法直接使用
 */
_import('TTPatchURLSession,NSURLRequest,NSURL,NSString,TTPatchHotRefrshTool,UIDevice,UIView,UILabel,UIColor,UIFont,UIScreen,UIImageView,UIImage,UITapGestureRecognizer,UIButton,TTPlaygroundModel')

/**
 *  @params:1.要替换的Class名,`:`标识继承关系
 *  @params:2.声明实例方法
 *  @params:3.声明静态方法
 *  声明Class,如无需在Oc中动态创建,可不设置父类,直接在js中创建类
 *  声明Class,如Native不存在,则动态创建Class
 */
defineClass('TTPatchUnitTests:XCTestCase', {
    /**
     * 添加属性,自动生成`setter`/`getter`方法,取值和赋值必须使用`setter`/`getter`方法.
     */
    name: property(),

    blockAddSignatureCase: function () {
        self.testInt_string_obj_(1,"TTPatch");
        var list = [1,2,3,];
        var dic = {"key":"val"};
        // self.testArray_dic_(list,dic);

        // self.testBlockInt_(block("void,int",function(){

        // }))
        // testInt_string_obj_: function(p1, p2, p3) {},
        // testArray_dic_: function(p1, p2) {},
        // testBlockInt_: function(p1) {},
        // testBlockString_: function(p1) {},
        // testBlockObj_: function(p1) {},
            self.testCall0_(block("", function () {
                Utils.log_info('[unit-test] --------JS传入OC方法,接受到回调--------- 无参数,无返回值');
            }));
            self.testCall1_(block('void,id,int', function (arg1, arg2) {
                var dic = JSON.parse(arg1);
                Utils.log_info('[unit-test] --------JS传入OC方法,接受到回调--------- 有参数,无返回值  ' + dic.name + '-' + arg2);
            }));


            self.testCall2_(block("id,id", function (arg) {
                Utils.log_info('[unit-test] --------JS传入OC方法,接受到回调--------- 有参数,有返回值:string  ' + arg);
                // arg.view().setBackgroundColor_(UIColor.blackColor());
                return arg;
            }));


            self.testCall3_(block("id,void", function () {
                Utils.log_info('[unit-test] --------JS传入OC方法,接受到回调--------- 无参数,有返回值:string  ');
                return '这是有返回值的哦';
            }));
        },
        funcWithBlockParams_param2_: dynamic('void,id,?', function (arg1, callback) {
            Utils.log_info('[unit-test] [1]funcWithBlockParams:' + arg1);
            if (callback) {
                callback("1");
            }
        }),
    funcWithBlockParams_paramInt2_: dynamic('void,id,?', function (arg1, callback) {
        Utils.log_info('[unit-test] [2]funcWithBlockParams:paramInt2:' + arg1);
        if (callback) {
            callback(2);
        }
    }),
    funcWithParams_param2_: dynamic('void,id,id', function (param1, param2) {
        var arg1 = param1[0];
        var arg2 = param2['key'];
        Utils.log_info('[unit-test] [3]funcWithParams_param2_:' + param1 + ',' + arg2);
    }),
    testBlockInt_: dynamic('void,int',function(p1) {
        p1(1);
        Utils.log_info('[unit-test] [3]testBlockInt_:' + p1);
    }),
    testBlockString_: dynamic('void,@',function(p1) {
        p1("ttpatch");
        Utils.log_info('[unit-test] [3]testBlockString_:' + p1);
    }),
    testBlockObj_: dynamic('void,@',function(p1) {
        var dic = {"key":"val"};
        p1(dic);
        Utils.log_info('[unit-test] [3]testBlockObj_:' + p1);
    })
}, {
    //静态方法
    testAction_: function (str) {Utils.log_info('[unit-test] 静态方法调用成功-> ' + str);}
})

defineClass('UserModel:NSObject', {
    getUserName: function () {
            Utils.log_info(self.getUserPW());
            return "Alibaba";
        },
        getUserPW: function () {
            return "self -> UserModel";
        },
}, {});