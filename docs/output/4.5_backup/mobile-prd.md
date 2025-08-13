# IT运维门户系统 - Flutter移动端精简 PRD v4.5

## 1. 项目概述

### 1.1 系统定位
基于Flutter框架的跨平台移动端应用，为IT运维门户系统提供移动办公解决方案，支持iOS和Android双平台，实现随时随地的运维管理。

### 1.2 核心价值
- **跨平台支持**：一套代码同时支持iOS和Android
- **原生性能**：接近原生应用的性能和用户体验
- **离线功能**：支持离线数据缓存和同步
- **实时通信**：推送通知、实时消息、状态同步

### 1.3 技术目标
- 应用启动时间：冷启动≤3秒，热启动≤1秒
- 页面切换流畅度：60FPS流畅动画
- 平台兼容性：iOS 13+，Android 8+ (API 26+)
- 包体积控制：APK≤50MB，IPA≤60MB

## 2. 技术架构

### 2.1 核心技术栈
| 技术组件 | 版本 | 说明 |
|----------|------|------|
| Flutter | 3.16+ | 跨平台框架 |
| Dart | 3.2+ | 开发语言 |
| Material Design | 3.0 | UI设计规范 |
| Cupertino | Latest | iOS风格组件 |
| Riverpod | 2.4+ | 状态管理 |
| GoRouter | 12.0+ | 路由管理 |
| Drift | 2.14+ | 本地数据库 |
| Dio | 5.3+ | HTTP客户端 |

### 2.2 架构设计
- **MVVM架构**：Model-View-ViewModel分层架构
- **响应式编程**：基于Stream和Future的异步编程
- **状态管理**：Riverpod集中状态管理
- **本地存储**：Drift SQLite数据库 + SharedPreferences

### 2.3 项目结构
```
lib/
├── main.dart           # 应用入口
├── app/               # 应用配置
├── core/              # 核心功能
│   ├── network/       # 网络层
│   ├── database/      # 数据库层
│   ├── utils/         # 工具类
│   └── constants/     # 常量定义
├── features/          # 功能模块
│   ├── auth/          # 认证模块
│   ├── dashboard/     # 仪表板
│   ├── tickets/       # 工单管理
│   ├── knowledge/     # 知识库
│   └── profile/       # 个人中心
├── shared/            # 共享组件
│   ├── widgets/       # 通用组件
│   ├── models/        # 数据模型
│   └── providers/     # 状态提供者
└── assets/            # 静态资源
```

## 3. 核心功能模块

### 3.1 用户认证模块
**功能概述**：用户登录、注册、密码管理等认证功能

**核心功能**：
- 用户名密码登录
- 手机验证码登录
- 生物识别登录（指纹/面容）
- 自动登录和记住密码
- 密码修改和重置

**技术要求**：
- 支持多种认证方式
- 生物识别集成
- 安全存储认证信息
- 登录状态持久化

**Flutter实现**：
```dart
// 认证服务
class AuthService {
  Future<AuthResult> login(String username, String password);
  Future<bool> biometricLogin();
  Future<void> logout();
  Stream<AuthState> get authStateStream;
}

// 生物识别
class BiometricAuth {
  Future<bool> isAvailable();
  Future<bool> authenticate();
}
```

### 3.2 工作台仪表板
**功能概述**：移动端个性化工作台和关键数据展示

**核心功能**：
- 待办工单列表
- 关键指标卡片
- 快捷操作入口
- 消息通知中心
- 个人绩效统计

**技术要求**：
- 下拉刷新和上拉加载
- 卡片式布局设计
- 实时数据更新
- 手势操作支持

**Flutter实现**：
```dart
// 仪表板页面
class DashboardPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(dashboardProvider),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(/* ... */),
          SliverGrid(/* 指标卡片 */),
          SliverList(/* 待办列表 */),
        ],
      ),
    );
  }
}
```

### 3.3 工单管理模块
**功能概述**：移动端工单查看、处理、创建等功能

**核心功能**：
- 工单列表查看（支持筛选）
- 工单详情查看
- 工单状态更新
- 工单创建和编辑
- 工单图片上传

**技术要求**：
- 列表虚拟滚动
- 图片选择和压缩
- 离线数据缓存
- 实时状态同步

**Flutter实现**：
```dart
// 工单列表
class TicketListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) => TicketCard(
          ticket: tickets[index],
          onTap: () => context.push('/tickets/${tickets[index].id}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tickets/create'),
        child: Icon(Icons.add),
      ),
    );
  }
}

// 工单卡片组件
class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(ticket.title),
        subtitle: Text(ticket.description),
        trailing: StatusChip(status: ticket.status),
        onTap: onTap,
      ),
    );
  }
}
```

### 3.4 知识库模块
**功能概述**：移动端知识查看、搜索、收藏功能

**核心功能**：
- 知识文档浏览
- 全文搜索功能
- 知识分类导航
- 知识收藏管理
- 离线知识缓存

**技术要求**：
- Markdown渲染
- 搜索结果高亮
- 本地搜索索引
- 收藏同步

**Flutter实现**：
```dart
// 知识库页面
class KnowledgePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('知识库'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: KnowledgeSearchDelegate(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          CategoryTabs(),
          Expanded(child: KnowledgeList()),
        ],
      ),
    );
  }
}

// Markdown渲染
class MarkdownViewer extends StatelessWidget {
  final String content;
  
  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: content,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
    );
  }
}
```

### 3.5 消息通知模块
**功能概述**：推送通知、消息中心、实时通信

**核心功能**：
- 推送通知接收
- 消息列表查看
- 消息已读状态
- 消息分类管理
- 通知设置配置

**技术要求**：
- Firebase推送集成
- 本地通知管理
- 消息持久化存储
- 实时消息同步

**Flutter实现**：
```dart
// 推送通知服务
class PushNotificationService {
  Future<void> initialize();
  Future<String?> getToken();
  Stream<RemoteMessage> get onMessage;
  Stream<RemoteMessage> get onMessageOpenedApp;
}

// 消息页面
class MessagesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('消息'),
        actions: [
          IconButton(
            icon: Icon(Icons.mark_email_read),
            onPressed: () => ref.read(messagesProvider.notifier).markAllRead(),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: messages.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) => MessageTile(message: messages[index]),
      ),
    );
  }
}
```

### 3.6 个人中心模块
**功能概述**：用户信息、设置、偏好配置

**核心功能**：
- 个人信息查看
- 密码修改
- 应用设置配置
- 主题切换
- 关于应用

**技术要求**：
- 用户头像上传
- 设置项持久化
- 主题动态切换
- 版本更新检查

**Flutter实现**：
```dart
// 个人中心页面
class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: UserHeader(user: user),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SettingsSection(
                title: '账户设置',
                children: [
                  SettingsTile(
                    title: '修改密码',
                    onTap: () => context.push('/profile/change-password'),
                  ),
                  SettingsTile(
                    title: '生物识别',
                    trailing: Switch(
                      value: ref.watch(biometricEnabledProvider),
                      onChanged: (value) => ref.read(biometricEnabledProvider.notifier).state = value,
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
```

## 4. UI/UX设计规范

### 4.1 设计系统
- **Material Design 3**：遵循Google最新设计规范
- **iOS Human Interface**：iOS平台遵循苹果设计规范
- **主色调**：#409EFF（与Web端保持一致）
- **自适应主题**：支持浅色/深色主题切换

### 4.2 组件规范
- **导航栏**：统一的AppBar设计，支持返回和操作按钮
- **列表项**：统一的ListTile设计，支持头像、标题、副标题
- **按钮**：ElevatedButton、TextButton、IconButton统一样式
- **输入框**：TextFormField统一样式，支持验证和错误提示

### 4.3 交互规范
- **手势操作**：支持滑动、长按、双击等手势
- **动画效果**：页面切换、状态变化使用流畅动画
- **反馈机制**：操作反馈、加载状态、错误提示
- **无障碍支持**：语义化标签、屏幕阅读器支持

## 5. 数据管理

### 5.1 状态管理
**Riverpod状态管理架构**：
```dart
// 全局状态提供者
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

// 页面状态提供者
final ticketsProvider = FutureProvider.family<List<Ticket>, TicketFilter>((ref, filter) {
  return ref.read(ticketServiceProvider).getTickets(filter);
});

// 本地状态提供者
final themeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});
```

### 5.2 本地数据库
**Drift数据库设计**：
```dart
// 数据表定义
@DataClassName('Ticket')
class Tickets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

// 数据库访问对象
@DriftDatabase(tables: [Tickets, Users, Messages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
}
```

### 5.3 网络请求
**Dio HTTP客户端配置**：
```dart
class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.ops-portal.com',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ));
    
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }
  
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters});
  Future<Response<T>> post<T>(String path, {dynamic data});
}
```

## 6. 离线功能

### 6.1 数据缓存策略
- **关键数据缓存**：用户信息、工单列表、知识库文档
- **图片缓存**：工单图片、用户头像本地缓存
- **搜索索引**：知识库全文搜索本地索引
- **配置缓存**：应用设置、用户偏好本地存储

### 6.2 离线同步机制
```dart
class OfflineSyncService {
  // 离线数据队列
  Future<void> queueOfflineAction(OfflineAction action);
  
  // 网络恢复时同步
  Future<void> syncWhenOnline();
  
  // 冲突解决
  Future<void> resolveConflicts(List<ConflictData> conflicts);
}

// 离线操作模型
class OfflineAction {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String id;
}
```

### 6.3 网络状态管理
```dart
class ConnectivityService {
  Stream<ConnectivityResult> get connectivityStream;
  Future<bool> get isConnected;
  
  // 网络状态变化监听
  void onConnectivityChanged(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      // 触发离线数据同步
      _syncOfflineData();
    }
  }
}
```

## 7. 推送通知

### 7.1 Firebase集成
```dart
class FirebaseMessagingService {
  Future<void> initialize() async {
    // 请求通知权限
    await FirebaseMessaging.instance.requestPermission();
    
    // 获取FCM Token
    String? token = await FirebaseMessaging.instance.getToken();
    
    // 监听消息
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    // 前台消息处理
    _showLocalNotification(message);
  }
  
  void _handleBackgroundMessage(RemoteMessage message) {
    // 后台消息处理
    _navigateToMessage(message);
  }
}
```

### 7.2 本地通知
```dart
class LocalNotificationService {
  Future<void> initialize();
  
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  });
  
  Future<void> scheduleNotification({
    required DateTime scheduledDate,
    required String title,
    required String body,
  });
}
```

## 8. 性能优化

### 8.1 启动优化
- **启动画面**：自定义启动画面，减少白屏时间
- **预加载**：关键数据预加载，减少首屏等待时间
- **懒加载**：非关键功能延迟加载
- **代码分割**：按功能模块分割代码

### 8.2 渲染优化
```dart
// 列表优化
class OptimizedListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // 使用builder减少内存占用
      itemBuilder: (context, index) => _buildItem(index),
      // 设置缓存范围
      cacheExtent: 1000,
      // 添加分隔符减少重绘
      separatorBuilder: (context, index) => Divider(),
    );
  }
}

// 图片优化
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => ShimmerPlaceholder(),
      errorWidget: (context, url, error) => ErrorPlaceholder(),
      memCacheWidth: 300, // 限制内存缓存大小
    );
  }
}
```

### 8.3 内存管理
- **图片缓存**：合理设置图片缓存大小和策略
- **状态清理**：页面销毁时清理状态和监听器
- **定时器管理**：及时取消定时器和订阅
- **大数据处理**：分页加载，避免一次性加载大量数据

## 9. 安全与隐私

### 9.1 数据安全
```dart
class SecureStorage {
  // 敏感数据加密存储
  Future<void> storeSecurely(String key, String value);
  Future<String?> getSecurely(String key);
  
  // 生物识别保护
  Future<void> storeBiometric(String key, String value);
  Future<String?> getBiometric(String key);
}

// 网络安全
class SecurityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加安全头
    options.headers['X-Requested-With'] = 'XMLHttpRequest';
    options.headers['X-App-Version'] = AppConfig.version;
    
    super.onRequest(options, handler);
  }
}
```

### 9.2 权限管理
```dart
class PermissionService {
  Future<bool> requestCameraPermission();
  Future<bool> requestStoragePermission();
  Future<bool> requestLocationPermission();
  Future<bool> requestNotificationPermission();
  
  // 权限状态检查
  Future<PermissionStatus> checkPermission(Permission permission);
}
```

## 10. 测试策略

### 10.1 单元测试
```dart
// 服务测试
void main() {
  group('AuthService', () {
    late AuthService authService;
    
    setUp(() {
      authService = AuthService();
    });
    
    test('should login successfully with valid credentials', () async {
      final result = await authService.login('username', 'password');
      expect(result.isSuccess, true);
    });
  });
}
```

### 10.2 Widget测试
```dart
void main() {
  testWidgets('TicketCard should display ticket information', (tester) async {
    final ticket = Ticket(id: 1, title: 'Test Ticket', status: 'Open');
    
    await tester.pumpWidget(
      MaterialApp(
        home: TicketCard(ticket: ticket),
      ),
    );
    
    expect(find.text('Test Ticket'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
  });
}
```

### 10.3 集成测试
```dart
void main() {
  group('App Integration Tests', () {
    testWidgets('complete login flow', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // 输入用户名密码
      await tester.enterText(find.byKey(Key('username')), 'testuser');
      await tester.enterText(find.byKey(Key('password')), 'password');
      
      // 点击登录按钮
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();
      
      // 验证跳转到主页
      expect(find.byType(DashboardPage), findsOneWidget);
    });
  });
}
```

## 11. 部署与发布

### 11.1 构建配置
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
  
  # 应用图标
  flutter_icons:
    android: true
    ios: true
    image_path: "assets/icons/app_icon.png"

# Android配置
android:
  minSdkVersion: 26
  targetSdkVersion: 34
  compileSdkVersion: 34

# iOS配置
ios:
  deployment_target: 13.0
```

### 11.2 发布流程
- **代码签名**：Android签名配置，iOS证书配置
- **版本管理**：语义化版本号，构建号自动递增
- **应用商店**：Google Play Store，Apple App Store发布
- **内测分发**：Firebase App Distribution，TestFlight

### 11.3 CI/CD集成
```yaml
# GitHub Actions示例
name: Flutter CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - run: flutter build ios --release --no-codesign
```

---

**文档版本**：v4.5  
**最后更新**：2025年8月13日  
**技术负责人**：移动端开发团队