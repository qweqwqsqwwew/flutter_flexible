import 'package:ana_page_loop/ana_page_loop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jh_debug/jh_debug.dart';
import 'package:provider/provider.dart';
import '../../components/UpdateAppVersion/UpdateAppVersion.dart'
    show getNewAppVer;
import '../../config/app_config.dart';
import '../../components/DoubleBackExitApp/DoubleBackExitApp.dart';
import 'provider/appHomePageStore.p.dart';
import 'MyPersonal/MyPersonal.dart';
import 'Search/Search.dart';
import 'Hot/Hot.dart';
import 'Home/Home.dart';

/// [params] 别名路由传递的参数
/// [params.pageId] 跳转到指定tab页面（0第一页），如果不是别名路由跳转的话，又想实现跳转到指定tab页面，推荐别名路由跳转方式。
///```dart
/// // 手动传入参数跳转路由方式如下：
/// Navigator.of(context).push(
///   MaterialPageRoute(
///     builder: (context) => BarTabs(
///       params: {'pageId': 2}, // 跳转到tabs的第三个页面
///     ),
///   )
/// );
///
/// // 别名路由跳转方式如下：
/// Navigator.pushNamed(context, '/testDemo', arguments: {
///   'pageId': 2,
/// });
/// ```
class AppHomePage extends StatefulWidget {
  final params;

  AppHomePage({
    Key key,
    this.params,
  }) : super(key: key);

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage>
    with PageViewListenerMixin, AutomaticKeepAliveClientMixin {
  int currentIndex = 0; // 接收bar当前点击索引
  bool physicsFlag = true; // 是否禁止左右滑动跳转tab
  AppHomePageStore appPageStore;
  PageController pageController;
  @override
  bool get wantKeepAlive => true;

  // app主页底部bar
  final List<Map<String, dynamic>> appBottomBar = [
    {
      'title': '首页',
      'icon': Icons.home,
      'body': Home(),
    },
    {
      'title': '热门',
      'icon': Icons.whatshot,
      'body': Hot(),
    },
    {
      'title': '搜索',
      'icon': Icons.search,
      'body': Search(),
    },
    {
      'title': '我的',
      'icon': Icons.person,
      'body': MyPersonal(),
    },
  ];

  @override
  void initState() {
    handleCurrentIndex();
    initTools();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appPageStore.saveController(pageController);

      if (AppConfig.showJhDebugBtn) {
        jhDebug.showDebugBtn(); // jhDebug 调试按钮
      }

      getNewAppVer(); // 更新APP版本检查
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// 处理tab默认显示索引
  handleCurrentIndex() {
    if (widget.params != null) {
      // 默认加载页面
      currentIndex = widget.params['pageId'] ?? 0 >= (appBottomBar.length)
          ? (appBottomBar.length - 1)
          : widget.params['pageId'];
    }

    // 初始化tab控制器
    pageController = PageController(initialPage: currentIndex, keepPage: true);
  }

  /// 初始化第三方插件插件
  initTools() {
    // jhDebug插件初始化
    jhDebug.init(
      context: context,
      // 调试窗口按钮1事件
      btnTap1: () {},
    );
  }

  /// 实现PageViewListenerMixin类上的方法，供页面埋点使用
  @override
  PageViewMixinData initPageViewListener() {
    return PageViewMixinData(
      controller: pageController,
      tabsData: appBottomBar.map((data) => data['title'] as String).toList(),
    );
  }

  @override
  void didPopNext() {
    super.didPopNext();
  }

  @override
  void didPop() {
    super.didPop();
  }

  @override
  void didPush() {
    super.didPush();
  }

  @override
  void didPushNext() {
    super.didPushNext();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    WidgetsFlutterBinding.ensureInitialized();
    // 初始化设计稿尺寸
    ScreenUtil.init(context,
        designSize: Size(750, 1334), allowFontScaling: true);
    appPageStore = Provider.of<AppHomePageStore>(context);

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        appPageStore.getGrayTheme ? Color(0xff757575) : Colors.transparent,
        BlendMode.color,
      ),
      child: _scaffoldBody(),
    );
  }

  /// 页面Scaffold层组件
  Widget _scaffoldBody() {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            controller: pageController,
            physics: physicsFlag ? NeverScrollableScrollPhysics() : null,
            children: bodyWidget(), // tab页面主体
            // 监听滑动
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
          Positioned(
            bottom: 30,
            child: DoubleBackExitApp(),
          ),
        ],
      ),

      // 底部栏
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex, // 当前页
        elevation: 5.0,
        selectedFontSize: 26.sp, // 选中的字体大小
        unselectedFontSize: 26.sp, // 未选中的字体大小
        onTap: (int idx) async {
          setState(() {
            currentIndex = idx;
          });
          pageController.jumpToPage(idx); // 跳转
        },
        items: _generateBottomBars(), // 底部菜单导航
      ),
    );
  }

  /// tab视图内容区域
  List<Widget> bodyWidget() {
    try {
      return appBottomBar
          .map((itemData) => itemData['body'] as Widget)
          .toList();
    } catch (e) {
      throw Exception('appBottomBar变量缺少body参数，errorMsg:$e');
    }
  }

  /// 生成底部菜单导航
  List<BottomNavigationBarItem> _generateBottomBars() {
    try {
      return appBottomBar.map<BottomNavigationBarItem>((itemData) {
        return BottomNavigationBarItem(
          icon: Icon(
            itemData['icon'], // 图标
            size: 44.sp,
          ),
          label: itemData['title'],
        );
      }).toList();
    } catch (e) {
      throw Exception('appBottomBar数据缺少参数、或字段类型不匹配, errorMsg:$e');
    }
  }
}
