## 任务：生成 AI开发助手专用的移动端开发PRD文档

### 背景与目标
为移动端开发专门优化的PRD模板，专注于Flutter应用架构、移动端特性和跨平台适配。此模板确保移动应用的原生体验、性能优化和平台一致性，为分离式开发提供完整的移动端实现指导。

### 前置要求
1. **核心参考文档**：
   - 全局上下文：`$GLOBAL_FILE`
   - 当前模块 PRD：`$MODULE_FILE`
   - API 规范文档：`$API_SPEC_FILE`
   - 移动端设计规范：`docs/design/mobile-design-guidelines.md`
   - 技术栈规范：`docs/prd/split/$VERSION/appendix/03-technology-stack.md`

2. **技术约束**：
   - Flutter 3.24.x + Dart 3.5.x
   - 支持iOS 12+ 和 Android 8.0+ (API 26+)
   - Material Design 3 + Cupertino设计语言
   - 离线优先架构，支持数据同步
   - 原生性能，启动时间≤3秒，流畅度≥60fps

### AI处理步骤

#### Step 1：移动端特性分析
1. **平台适配设计**：
   - 分析iOS和Android平台差异
   - 设计统一的用户体验和交互模式
   - 确定平台特定功能的实现策略

2. **移动端功能设计**：
   - 基于API规范设计移动端功能
   - 确定离线功能和数据同步策略
   - 设计推送通知和设备集成方案

#### Step 2：应用架构设计
1. **Flutter架构设计**：
   - 设计BLoC状态管理架构
   - 确定页面导航和路由策略
   - 建立数据层和业务逻辑分离

2. **性能优化设计**：
   - 设计图片缓存和懒加载策略
   - 确定内存管理和资源优化方案
   - 建立性能监控和分析机制

### 输出要求
生成文件：`docs/ai_prd/$VERSION/mobile/$MODULE_ID-mobile-prd.md`

**移动端专用结构化文档格式**：

#### 1. 移动端架构配置 (MOBILE_ARCHITECTURE_SPEC)
```yaml
mobile_architecture_spec:
  module_id: $MODULE_ID
  module_name: $MODULE_NAME
  
  technology_stack:
    flutter_version: "3.24.x"
    dart_version: "3.5.x"
    minimum_ios_version: "12.0"
    minimum_android_version: "26" # Android 8.0
    target_platforms: ["iOS", "Android"]
  
  architecture_pattern: "BLoC (Business Logic Component)"
  
  project_structure:
    lib:
      - "main.dart" # 应用入口
      - "app/" # 应用配置
      - "core/" # 核心功能
      - "features/[module]/" # 功能模块
      - "shared/" # 共享组件
      - "data/" # 数据层
      - "domain/" # 业务逻辑层
      - "presentation/" # 表现层
  
  feature_structure:
    "[module]":
      - "data/"
        - "datasources/" # 数据源
        - "models/" # 数据模型
        - "repositories/" # 仓储实现
      - "domain/"
        - "entities/" # 业务实体
        - "repositories/" # 仓储接口
        - "usecases/" # 用例
      - "presentation/"
        - "bloc/" # 状态管理
        - "pages/" # 页面
        - "widgets/" # 组件
  
  design_principles:
    - principle: "Clean Architecture"
      description: "分层架构，依赖倒置"
      implementation: "Domain层不依赖外部框架"
    
    - principle: "SOLID Principles"
      description: "面向对象设计原则"
      implementation: "单一职责、开闭原则等"
    
    - principle: "Reactive Programming"
      description: "响应式编程"
      implementation: "使用Stream和BLoC模式"
    
    - principle: "Offline First"
      description: "离线优先"
      implementation: "本地数据库+网络同步"

  platform_adaptation:
    ios:
      design_language: "Cupertino"
      navigation_style: "iOS Navigation"
      platform_features:
        - "Face ID / Touch ID"
        - "iOS Shortcuts"
        - "Apple Push Notifications"
        - "iOS Share Extension"
    
    android:
      design_language: "Material Design 3"
      navigation_style: "Material Navigation"
      platform_features:
        - "Biometric Authentication"
        - "Android Shortcuts"
        - "Firebase Cloud Messaging"
        - "Android Share Intent"
```

#### 2. 移动端功能设计 (MOBILE_FEATURES_SPEC)
```yaml
mobile_features_spec:
  core_features:
    - feature: "离线数据访问"
      description: "支持离线查看和操作数据"
      implementation:
        - "本地SQLite数据库存储"
        - "数据同步队列管理"
        - "冲突解决策略"
        - "增量同步机制"
      
      technical_details:
        database: "SQLite with Floor ORM"
        sync_strategy: "Last-Write-Wins with Timestamp"
        conflict_resolution: "Server-side resolution"
        storage_limit: "100MB本地数据"
    
    - feature: "推送通知"
      description: "实时消息推送和提醒"
      implementation:
        - "Firebase Cloud Messaging (Android)"
        - "Apple Push Notification Service (iOS)"
        - "本地通知调度"
        - "通知权限管理"
      
      notification_types:
        - type: "工单状态更新"
          priority: "high"
          sound: true
          vibration: true
        - type: "系统公告"
          priority: "normal"
          sound: false
          vibration: false
        - type: "任务提醒"
          priority: "high"
          sound: true
          vibration: true
    
    - feature: "生物识别认证"
      description: "指纹、面部识别登录"
      implementation:
        - "local_auth插件集成"
        - "生物识别可用性检测"
        - "降级到PIN/密码认证"
        - "认证状态缓存"
      
      security_measures:
        - "本地生物识别验证"
        - "Token安全存储"
        - "认证失败限制"
        - "自动锁定机制"
    
    - feature: "文件管理"
      description: "文件上传、下载、预览"
      implementation:
        - "多文件选择和上传"
        - "断点续传支持"
        - "文件类型检测"
        - "本地文件缓存"
      
      supported_formats:
        images: ["jpg", "png", "gif", "webp"]
        documents: ["pdf", "doc", "docx", "xls", "xlsx"]
        videos: ["mp4", "mov", "avi"]
        max_file_size: "50MB"
    
    - feature: "设备集成"
      description: "相机、GPS、传感器集成"
      implementation:
        - "相机拍照和录像"
        - "GPS位置获取"
        - "设备信息收集"
        - "网络状态监听"
      
      permissions:
        - "CAMERA - 拍照上传"
        - "LOCATION - 位置服务"
        - "STORAGE - 文件访问"
        - "MICROPHONE - 录音功能"

  performance_features:
    - feature: "图片优化"
      description: "图片加载和缓存优化"
      implementation:
        - "cached_network_image缓存"
        - "图片压缩和格式转换"
        - "懒加载和预加载"
        - "内存管理优化"
      
      cache_strategy:
        memory_cache: "100MB"
        disk_cache: "500MB"
        cache_duration: "7天"
        compression_quality: "85%"
    
    - feature: "数据预加载"
      description: "智能数据预加载"
      implementation:
        - "关键数据预加载"
        - "用户行为预测"
        - "后台数据同步"
        - "网络状态适配"
      
      preload_strategy:
        - "首页数据预加载"
        - "常用功能数据缓存"
        - "用户偏好数据本地化"
        - "离线模式数据准备"
    
    - feature: "启动优化"
      description: "应用启动时间优化"
      implementation:
        - "启动页面优化"
        - "关键路径优化"
        - "资源延迟加载"
        - "启动时间监控"
      
      performance_targets:
        cold_start: "≤3秒"
        warm_start: "≤1秒"
        hot_start: "≤0.5秒"
        memory_usage: "≤200MB"
```

#### 3. 页面和导航设计 (MOBILE_UI_SPEC)
```yaml
mobile_ui_spec:
  navigation_structure:
    type: "Bottom Navigation + Stack Navigation"
    
    bottom_tabs:
      - tab: "首页"
        icon: "home"
        route: "/home"
        badge_support: true
      
      - tab: "[模块]"
        icon: "[module_icon]"
        route: "/[module]"
        badge_support: true
      
      - tab: "消息"
        icon: "notifications"
        route: "/notifications"
        badge_support: true
      
      - tab: "我的"
        icon: "person"
        route: "/profile"
        badge_support: false
    
    stack_navigation:
      - route: "/[module]"
        page: "[ModuleName]ListPage"
        transition: "slide"
      
      - route: "/[module]/detail/:id"
        page: "[ModuleName]DetailPage"
        transition: "slide"
      
      - route: "/[module]/create"
        page: "[ModuleName]CreatePage"
        transition: "slide_up"
      
      - route: "/[module]/edit/:id"
        page: "[ModuleName]EditPage"
        transition: "slide"

  page_designs:
    - page: "[ModuleName]ListPage"
      description: "[模块]列表页面"
      
      layout_components:
        - component: "AppBar"
          features: ["搜索", "筛选", "刷新"]
        
        - component: "SearchBar"
          features: ["关键词搜索", "语音搜索", "扫码搜索"]
        
        - component: "FilterChips"
          features: ["状态筛选", "时间筛选", "分类筛选"]
        
        - component: "ListView"
          features: ["下拉刷新", "上拉加载", "滑动操作"]
        
        - component: "FloatingActionButton"
          features: ["快速创建", "批量操作"]
      
      interactions:
        - gesture: "下拉刷新"
          action: "重新加载数据"
          feedback: "刷新动画"
        
        - gesture: "上拉加载"
          action: "加载更多数据"
          feedback: "加载指示器"
        
        - gesture: "左滑"
          action: "显示快捷操作"
          feedback: "滑动菜单"
        
        - gesture: "长按"
          action: "进入选择模式"
          feedback: "震动反馈"
      
      responsive_design:
        phone_portrait: "单列列表"
        phone_landscape: "双列网格"
        tablet_portrait: "双列网格"
        tablet_landscape: "三列网格"
    
    - page: "[ModuleName]DetailPage"
      description: "[模块]详情页面"
      
      layout_components:
        - component: "SliverAppBar"
          features: ["折叠头部", "浮动操作", "分享按钮"]
        
        - component: "InfoCard"
          features: ["基本信息", "状态标签", "时间信息"]
        
        - component: "TabBar"
          features: ["详情", "附件", "历史", "相关"]
        
        - component: "ActionButtons"
          features: ["编辑", "删除", "分享", "收藏"]
      
      scroll_behavior:
        - "SliverAppBar折叠效果"
        - "Tab内容懒加载"
        - "图片缩放查看"
        - "附件预览下载"
    
    - page: "[ModuleName]FormPage"
      description: "[模块]表单页面"
      
      layout_components:
        - component: "AppBar"
          features: ["保存", "取消", "草稿"]
        
        - component: "FormSections"
          features: ["分组表单", "动态字段", "验证提示"]
        
        - component: "FileUpload"
          features: ["拍照", "相册", "文件", "录音"]
        
        - component: "BottomActions"
          features: ["保存草稿", "提交", "重置"]
      
      form_validation:
        real_time: true
        submit_validation: true
        error_display: "inline"
        success_feedback: "toast"

  responsive_design:
    breakpoints:
      phone: "< 600dp"
      tablet: "≥ 600dp"
      desktop: "≥ 1200dp"
    
    adaptation_rules:
      - screen: "phone_portrait"
        layout: "单列布局，底部导航"
        font_scale: "1.0x"
      
      - screen: "phone_landscape"
        layout: "双列布局，侧边导航"
        font_scale: "0.9x"
      
      - screen: "tablet"
        layout: "多列布局，侧边导航"
        font_scale: "1.1x"
    
    accessibility:
      - "支持系统字体大小调整"
      - "高对比度模式支持"
      - "屏幕阅读器兼容"
      - "语音控制支持"
```

#### 4. 状态管理和数据层 (MOBILE_STATE_SPEC)
```yaml
mobile_state_spec:
  bloc_architecture:
    - bloc: "[ModuleName]Bloc"
      description: "[模块]业务逻辑组件"
      
      events:
        - event: "[ModuleName]LoadRequested"
          description: "请求加载[模块]数据"
          parameters:
            - "page: int"
            - "filters: Map<String, dynamic>"
        
        - event: "[ModuleName]RefreshRequested"
          description: "请求刷新[模块]数据"
          parameters: []
        
        - event: "[ModuleName]CreateRequested"
          description: "请求创建[模块]"
          parameters:
            - "data: [ModuleName]CreateRequest"
        
        - event: "[ModuleName]UpdateRequested"
          description: "请求更新[模块]"
          parameters:
            - "id: String"
            - "data: [ModuleName]UpdateRequest"
        
        - event: "[ModuleName]DeleteRequested"
          description: "请求删除[模块]"
          parameters:
            - "id: String"
      
      states:
        - state: "[ModuleName]Initial"
          description: "初始状态"
        
        - state: "[ModuleName]Loading"
          description: "加载中状态"
        
        - state: "[ModuleName]Loaded"
          description: "加载完成状态"
          properties:
            - "items: List<[ModuleName]>"
            - "hasReachedMax: bool"
            - "page: int"
        
        - state: "[ModuleName]Error"
          description: "错误状态"
          properties:
            - "message: String"
            - "errorType: ErrorType"
        
        - state: "[ModuleName]OperationSuccess"
          description: "操作成功状态"
          properties:
            - "message: String"
            - "operationType: OperationType"
      
      business_logic:
        - operation: "loadData"
          description: "加载数据逻辑"
          steps:
            - "检查网络连接状态"
            - "优先从本地缓存加载"
            - "网络可用时从服务器获取"
            - "更新本地缓存"
            - "发出状态更新"
        
        - operation: "createItem"
          description: "创建项目逻辑"
          steps:
            - "验证输入数据"
            - "保存到本地队列"
            - "尝试同步到服务器"
            - "更新本地状态"
            - "显示操作结果"

  data_layer:
    repositories:
      - repository: "[ModuleName]Repository"
        description: "[模块]数据仓储"
        
        interface_methods:
          - method: "getList"
            parameters: ["page: int", "filters: Map<String, dynamic>"]
            return_type: "Future<List<[ModuleName]>>"
          
          - method: "getById"
            parameters: ["id: String"]
            return_type: "Future<[ModuleName]?>"
          
          - method: "create"
            parameters: ["data: [ModuleName]CreateRequest"]
            return_type: "Future<[ModuleName]>"
          
          - method: "update"
            parameters: ["id: String", "data: [ModuleName]UpdateRequest"]
            return_type: "Future<[ModuleName]>"
          
          - method: "delete"
            parameters: ["id: String"]
            return_type: "Future<void>"
        
        implementation_strategy:
          - "优先返回本地缓存数据"
          - "后台同步网络数据"
          - "冲突时以服务器数据为准"
          - "离线操作队列管理"
    
    data_sources:
      - source: "[ModuleName]RemoteDataSource"
        description: "远程数据源"
        implementation: "HTTP API调用"
        
        methods:
          - "getList() -> Future<List<[ModuleName]Model>>"
          - "getById(String id) -> Future<[ModuleName]Model>"
          - "create([ModuleName]CreateRequest) -> Future<[ModuleName]Model>"
          - "update(String id, [ModuleName]UpdateRequest) -> Future<[ModuleName]Model>"
          - "delete(String id) -> Future<void>"
      
      - source: "[ModuleName]LocalDataSource"
        description: "本地数据源"
        implementation: "SQLite数据库"
        
        methods:
          - "getList() -> Future<List<[ModuleName]Entity>>"
          - "getById(String id) -> Future<[ModuleName]Entity?>"
          - "insert([ModuleName]Entity) -> Future<void>"
          - "update([ModuleName]Entity) -> Future<void>"
          - "delete(String id) -> Future<void>"
          - "clear() -> Future<void>"

  offline_sync:
    sync_strategy:
      - "应用启动时全量同步关键数据"
      - "用户操作时增量同步"
      - "后台定期同步更新"
      - "网络恢复时自动同步"
    
    conflict_resolution:
      - strategy: "Last-Write-Wins"
        description: "以最后修改时间为准"
        implementation: "比较timestamp字段"
      
      - strategy: "Server-Wins"
        description: "服务器数据优先"
        implementation: "冲突时保留服务器版本"
      
      - strategy: "Manual-Resolution"
        description: "手动解决冲突"
        implementation: "提示用户选择版本"
    
    queue_management:
      - "离线操作队列持久化"
      - "操作失败重试机制"
      - "队列优先级管理"
      - "批量操作优化"

#### 5. 性能优化和监控 (MOBILE_PERFORMANCE_SPEC)
```yaml
mobile_performance_spec:
  performance_targets:
    startup_performance:
      cold_start: "≤3秒"
      warm_start: "≤1秒"
      hot_start: "≤0.5秒"

    runtime_performance:
      frame_rate: "≥60fps"
      memory_usage: "≤200MB"
      cpu_usage: "≤30%"
      battery_drain: "≤5%/hour"

    network_performance:
      api_response: "≤2秒"
      image_loading: "≤1秒"
      file_upload: "≥1MB/s"
      offline_sync: "≤10秒"

  optimization_strategies:
    - strategy: "Widget优化"
      techniques:
        - "使用const构造函数"
        - "避免不必要的rebuild"
        - "使用RepaintBoundary"
        - "ListView.builder懒加载"

      implementation:
        - "StatelessWidget优先"
        - "Provider/BLoC状态管理"
        - "Key的正确使用"
        - "AnimationController复用"

    - strategy: "内存优化"
      techniques:
        - "图片缓存管理"
        - "大对象及时释放"
        - "Stream订阅管理"
        - "定时器清理"

      implementation:
        - "cached_network_image"
        - "dispose方法实现"
        - "StreamSubscription管理"
        - "Timer.cancel调用"

    - strategy: "网络优化"
      techniques:
        - "请求合并和缓存"
        - "图片压缩和格式优化"
        - "分页加载"
        - "预加载策略"

      implementation:
        - "Dio拦截器缓存"
        - "WebP格式支持"
        - "无限滚动列表"
        - "智能预加载算法"

    - strategy: "存储优化"
      techniques:
        - "数据库索引优化"
        - "缓存过期策略"
        - "压缩存储"
        - "清理机制"

      implementation:
        - "Floor数据库索引"
        - "LRU缓存算法"
        - "Gzip压缩"
        - "定期清理任务"

  monitoring_and_analytics:
    performance_monitoring:
      - tool: "Firebase Performance"
        metrics: ["启动时间", "网络请求", "屏幕渲染"]

      - tool: "Flutter Inspector"
        metrics: ["Widget树", "内存使用", "重建次数"]

      - tool: "Custom Metrics"
        metrics: ["业务指标", "用户行为", "错误统计"]

    crash_reporting:
      - tool: "Firebase Crashlytics"
        features: ["崩溃报告", "非致命错误", "用户影响分析"]

      - tool: "Sentry"
        features: ["错误追踪", "性能监控", "发布健康度"]

    user_analytics:
      - tool: "Firebase Analytics"
        events: ["页面访问", "功能使用", "用户留存"]

      - tool: "Custom Events"
        events: ["业务转化", "操作完成", "错误发生"]

#### 6. 移动端验证检查点 (MOBILE_VALIDATION_CHECKPOINTS)
```yaml
mobile_validation_checkpoints:
  flutter_best_practices:
    - check: "Widget构建优化"
      rule: "使用const构造函数和StatelessWidget"
      error_message: "Widget必须优化构建性能"

    - check: "状态管理规范"
      rule: "使用BLoC模式管理状态"
      error_message: "状态管理必须使用BLoC模式"

    - check: "资源管理"
      rule: "正确释放资源和取消订阅"
      error_message: "必须正确管理资源生命周期"

  platform_compliance:
    - check: "iOS设计规范"
      rule: "iOS平台使用Cupertino设计语言"
      error_message: "iOS平台必须符合Apple设计规范"

    - check: "Android设计规范"
      rule: "Android平台使用Material Design"
      error_message: "Android平台必须符合Material Design规范"

    - check: "权限申请规范"
      rule: "运行时权限申请和处理"
      error_message: "权限申请必须符合平台规范"

  performance_validation:
    - check: "启动性能"
      rule: "冷启动时间≤3秒"
      measurement: "使用Flutter Performance工具测量"

    - check: "内存使用"
      rule: "运行时内存使用≤200MB"
      measurement: "使用Flutter Inspector监控"

    - check: "帧率性能"
      rule: "滚动和动画≥60fps"
      measurement: "使用Performance Overlay检测"

  offline_functionality:
    - check: "离线数据访问"
      rule: "核心功能支持离线访问"
      error_message: "核心功能必须支持离线模式"

    - check: "数据同步机制"
      rule: "离线数据能够正确同步"
      error_message: "数据同步机制必须可靠"

    - check: "冲突解决"
      rule: "数据冲突有明确解决策略"
      error_message: "数据冲突必须有处理机制"

  security_validation:
    - check: "数据加密"
      rule: "敏感数据本地加密存储"
      error_message: "敏感数据必须加密存储"

    - check: "网络安全"
      rule: "使用HTTPS和证书验证"
      error_message: "网络通信必须安全"

    - check: "生物识别"
      rule: "生物识别功能正确实现"
      error_message: "生物识别必须安全可靠"

  accessibility_validation:
    - check: "屏幕阅读器支持"
      rule: "所有UI元素支持屏幕阅读器"
      error_message: "必须支持无障碍访问"

    - check: "字体缩放支持"
      rule: "支持系统字体大小调整"
      error_message: "必须支持字体缩放"

    - check: "颜色对比度"
      rule: "颜色对比度符合WCAG标准"
      error_message: "颜色对比度必须符合无障碍标准"

  testing_validation:
    - check: "单元测试覆盖率"
      rule: "业务逻辑单元测试覆盖率≥80%"
      error_message: "单元测试覆盖率不足"

    - check: "Widget测试"
      rule: "关键UI组件包含Widget测试"
      error_message: "关键组件必须包含Widget测试"

    - check: "集成测试"
      rule: "核心用户流程包含集成测试"
      error_message: "核心流程必须包含集成测试"
```

### AI处理指令
1. **严格遵循Flutter最佳实践**：确保代码符合Flutter生态规范
2. **平台适配完整性**：iOS和Android平台特性正确实现
3. **性能优化强制性**：必须满足性能指标要求
4. **离线功能可靠性**：离线模式和数据同步机制完整
5. **一致性验证**：使用MOBILE_VALIDATION_CHECKPOINTS进行自我验证

### 质量控制要求
1. **原生体验**：符合各平台设计规范和用户习惯
2. **性能达标**：启动时间、内存使用、帧率等指标达标
3. **离线可用**：核心功能支持离线使用和数据同步
4. **安全合规**：数据加密、权限管理、网络安全完整
5. **无障碍友好**：支持屏幕阅读器、字体缩放等无障碍功能

### 并行开发协调
1. **API契约遵循**：严格按照API规范进行移动端集成
2. **数据模型同步**：与后端保持数据模型的一致性
3. **推送通知协调**：与后端协调推送消息的格式和时机
4. **文件上传协调**：与后端协调文件上传的格式和限制
5. **测试环境共享**：提供移动端测试环境和测试数据
```
