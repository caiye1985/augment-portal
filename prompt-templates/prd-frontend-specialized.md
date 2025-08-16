## 任务：生成 AI开发助手专用的前端开发PRD文档

### 背景与目标
为前端开发专门优化的PRD模板，专注于Vue.js应用架构、用户界面设计和交互体验。此模板确保前端代码的组件化、可复用性和用户体验优化，为分离式开发提供完整的前端实现指导。

### 前置要求
1. **核心参考文档**：
   - 全局上下文：`$GLOBAL_FILE`
   - 当前模块 PRD：`$MODULE_FILE`
   - API 规范文档：`$API_SPEC_FILE`
   - UI设计规范：`docs/design/ui-design-guidelines.md`
   - 技术栈规范：`docs/prd/split/$VERSION/appendix/03-technology-stack.md`

2. **技术约束**：
   - Vue.js 3.5.13 + Composition API
   - Element Plus 2.8.8 UI组件库
   - Vite 6.0.1 构建工具
   - Pinia 2.2.6 状态管理
   - Vue Router 4.4.5 路由管理
   - TypeScript 5.x 类型支持

### AI处理步骤

#### Step 1：用户界面分析
1. **页面结构设计**：
   - 基于API规范设计页面层次结构
   - 确定主要页面和子页面的导航关系
   - 设计响应式布局和组件复用策略

2. **交互流程设计**：
   - 分析用户操作路径和业务流程
   - 设计表单交互和数据验证逻辑
   - 确定状态管理和数据流转方案

#### Step 2：组件架构设计
1. **组件分层设计**：
   - 设计页面级、业务级、通用级组件
   - 确定组件间的通信和数据传递
   - 建立组件复用和扩展机制

2. **状态管理设计**：
   - 设计Pinia store结构和数据流
   - 确定本地状态和全局状态的边界
   - 建立数据缓存和同步策略

### 输出要求
生成文件：`docs/ai_prd/$VERSION/frontend/$MODULE_ID-frontend-prd.md`

**前端专用结构化文档格式**：

#### 1. 前端架构配置 (FRONTEND_ARCHITECTURE_SPEC)
```yaml
frontend_architecture_spec:
  module_id: $MODULE_ID
  module_name: $MODULE_NAME
  
  technology_stack:
    vue_version: "3.5.13"
    element_plus_version: "2.8.8"
    vite_version: "6.0.1"
    pinia_version: "2.2.6"
    vue_router_version: "4.4.5"
    typescript_version: "5.x"
    axios_version: "1.7.7"
  
  project_structure:
    src:
      - "views/[module]/" # 页面组件
      - "components/[module]/" # 业务组件
      - "components/common/" # 通用组件
      - "stores/[module].ts" # 状态管理
      - "api/[module].ts" # API调用
      - "types/[module].ts" # 类型定义
      - "utils/[module].ts" # 工具函数
      - "composables/[module].ts" # 组合式函数
  
  architecture_patterns:
    - pattern: "Composition API"
      usage: "所有组件使用Composition API编写"
      benefits: "更好的逻辑复用和类型推导"
    
    - pattern: "Single File Component"
      usage: "组件采用SFC格式，包含template、script、style"
      benefits: "组件封装和维护性"
    
    - pattern: "Store Pattern"
      usage: "使用Pinia进行状态管理"
      benefits: "集中式状态管理和数据流控制"
    
    - pattern: "Composables Pattern"
      usage: "业务逻辑抽取为可复用的组合式函数"
      benefits: "逻辑复用和测试友好"

  routing_strategy:
    router_mode: "history"
    base_path: "/[module]"
    lazy_loading: true
    route_guards: ["authentication", "authorization", "tenant"]
    
    route_structure:
      - path: "/[module]"
        component: "[ModuleName]Layout"
        children:
          - path: ""
            name: "[ModuleName]List"
            component: "views/[module]/[EntityName]List.vue"
          - path: "create"
            name: "[ModuleName]Create"
            component: "views/[module]/[EntityName]Create.vue"
          - path: ":id"
            name: "[ModuleName]Detail"
            component: "views/[module]/[EntityName]Detail.vue"
          - path: ":id/edit"
            name: "[ModuleName]Edit"
            component: "views/[module]/[EntityName]Edit.vue"
```

#### 2. 页面组件设计 (FRONTEND_PAGE_SPEC)
```yaml
frontend_page_spec:
  pages:
    - name: "[EntityName]List"
      path: "/[module]/list"
      component: "views/[module]/[EntityName]List.vue"
      description: "[实体]列表页面"
      
      permissions: ["[RESOURCE]:READ"]
      
      features:
        - "数据表格展示"
        - "分页查询"
        - "高级搜索"
        - "批量操作"
        - "数据导出"
        - "实时刷新"
      
      layout_sections:
        - section: "search_bar"
          description: "搜索和筛选区域"
          components: ["SearchForm", "FilterTabs"]
        
        - section: "action_bar"
          description: "操作按钮区域"
          components: ["CreateButton", "BatchActions", "ExportButton"]
        
        - section: "data_table"
          description: "数据表格区域"
          components: ["DataTable", "Pagination"]
      
      state_management:
        local_state:
          - "searchParams: [EntityName]SearchParams"
          - "selectedRows: [EntityName][]"
          - "loading: boolean"
        
        store_state:
          - "[entityName]List: [EntityName][]"
          - "pagination: PaginationInfo"
          - "filters: FilterOptions"
      
      api_integration:
        - action: "fetchList"
          endpoint: "GET /api/v1/[resource]"
          trigger: "onMounted, search, pagination"
        
        - action: "batchDelete"
          endpoint: "DELETE /api/v1/[resource]/batch"
          trigger: "batch action"
        
        - action: "export"
          endpoint: "GET /api/v1/[resource]/export"
          trigger: "export button"
      
      user_interactions:
        - interaction: "search"
          trigger: "search button click, enter key"
          action: "更新搜索参数并重新加载数据"
        
        - interaction: "row_selection"
          trigger: "checkbox selection"
          action: "更新选中行状态"
        
        - interaction: "pagination"
          trigger: "page change, size change"
          action: "更新分页参数并重新加载数据"
    
    - name: "[EntityName]Detail"
      path: "/[module]/:id"
      component: "views/[module]/[EntityName]Detail.vue"
      description: "[实体]详情页面"
      
      permissions: ["[RESOURCE]:READ"]
      
      features:
        - "详情信息展示"
        - "关联数据展示"
        - "操作历史"
        - "状态流转"
        - "编辑跳转"
      
      layout_sections:
        - section: "header"
          description: "页面头部"
          components: ["PageHeader", "ActionButtons"]
        
        - section: "main_info"
          description: "主要信息"
          components: ["InfoCard", "StatusBadge"]
        
        - section: "related_data"
          description: "关联数据"
          components: ["RelatedTabs", "RelatedList"]
        
        - section: "history"
          description: "操作历史"
          components: ["HistoryTimeline"]
      
      state_management:
        local_state:
          - "entityId: string"
          - "activeTab: string"
          - "loading: boolean"
        
        store_state:
          - "[entityName]Detail: [EntityName]Detail"
          - "relatedData: RelatedData[]"
          - "history: HistoryRecord[]"
      
      api_integration:
        - action: "fetchDetail"
          endpoint: "GET /api/v1/[resource]/:id"
          trigger: "onMounted, route change"
        
        - action: "fetchRelated"
          endpoint: "GET /api/v1/[resource]/:id/related"
          trigger: "tab change"
        
        - action: "fetchHistory"
          endpoint: "GET /api/v1/[resource]/:id/history"
          trigger: "history tab active"
    
    - name: "[EntityName]Form"
      path: "/[module]/create | /[module]/:id/edit"
      component: "views/[module]/[EntityName]Form.vue"
      description: "[实体]创建/编辑页面"
      
      permissions: ["[RESOURCE]:CREATE", "[RESOURCE]:UPDATE"]
      
      features:
        - "表单数据录入"
        - "实时数据验证"
        - "文件上传"
        - "关联数据选择"
        - "草稿保存"
      
      layout_sections:
        - section: "form_header"
          description: "表单头部"
          components: ["FormHeader", "SaveButtons"]
        
        - section: "form_body"
          description: "表单主体"
          components: ["FormSections", "FileUpload"]
        
        - section: "form_footer"
          description: "表单底部"
          components: ["SubmitButtons", "CancelButton"]
      
      form_validation:
        client_side:
          - "必填字段验证"
          - "格式验证（邮箱、电话等）"
          - "长度限制验证"
          - "自定义业务规则验证"
        
        server_side:
          - "唯一性验证"
          - "业务规则验证"
          - "权限验证"
      
      state_management:
        local_state:
          - "formData: [EntityName]FormData"
          - "errors: ValidationErrors"
          - "isDirty: boolean"
          - "isSubmitting: boolean"
        
        form_rules:
          - field: "name"
            rules: ["required", "minLength:2", "maxLength:100"]
          - field: "email"
            rules: ["email", "maxLength:255"]
          - field: "phone"
            rules: ["phone", "maxLength:20"]
```

#### 3. 业务组件设计 (FRONTEND_COMPONENT_SPEC)
```yaml
frontend_component_spec:
  business_components:
    - name: "[EntityName]Table"
      type: "业务组件"
      description: "[实体]数据表格组件"
      
      props:
        - name: "data"
          type: "[EntityName][]"
          required: true
          description: "表格数据"
        
        - name: "loading"
          type: "boolean"
          default: false
          description: "加载状态"
        
        - name: "pagination"
          type: "PaginationConfig"
          required: true
          description: "分页配置"
        
        - name: "selectable"
          type: "boolean"
          default: true
          description: "是否支持行选择"
      
      events:
        - name: "row-click"
          payload: "[EntityName]"
          description: "行点击事件"
        
        - name: "selection-change"
          payload: "[EntityName][]"
          description: "选择变更事件"
        
        - name: "page-change"
          payload: "number"
          description: "页码变更事件"
        
        - name: "sort-change"
          payload: "SortConfig"
          description: "排序变更事件"
      
      features:
        - "响应式表格布局"
        - "列排序和筛选"
        - "行选择和批量操作"
        - "自定义列渲染"
        - "操作按钮列"
      
      element_plus_usage:
        - component: "el-table"
          props: ["data", "loading", "stripe", "border"]
        - component: "el-table-column"
          props: ["prop", "label", "sortable", "width"]
        - component: "el-pagination"
          props: ["current-page", "page-size", "total"]
    
    - name: "[EntityName]Form"
      type: "表单组件"
      description: "[实体]表单组件"
      
      props:
        - name: "modelValue"
          type: "[EntityName]FormData"
          required: true
          description: "表单数据"
        
        - name: "mode"
          type: "'create' | 'edit'"
          default: "create"
          description: "表单模式"
        
        - name: "loading"
          type: "boolean"
          default: false
          description: "提交状态"
      
      events:
        - name: "update:modelValue"
          payload: "[EntityName]FormData"
          description: "数据更新事件"
        
        - name: "submit"
          payload: "[EntityName]FormData"
          description: "表单提交事件"
        
        - name: "cancel"
          payload: "void"
          description: "取消操作事件"
      
      validation_rules:
        - field: "name"
          rules: |
            [
              { required: true, message: '名称不能为空', trigger: 'blur' },
              { min: 2, max: 100, message: '长度在 2 到 100 个字符', trigger: 'blur' }
            ]
        
        - field: "email"
          rules: |
            [
              { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
            ]
      
      element_plus_usage:
        - component: "el-form"
          props: ["model", "rules", "label-width"]
        - component: "el-form-item"
          props: ["label", "prop", "required"]
        - component: "el-input"
          props: ["v-model", "placeholder", "clearable"]
    
    - name: "[EntityName]Card"
      type: "展示组件"
      description: "[实体]卡片展示组件"
      
      props:
        - name: "data"
          type: "[EntityName]"
          required: true
          description: "实体数据"
        
        - name: "actions"
          type: "ActionConfig[]"
          default: "[]"
          description: "操作按钮配置"
      
      events:
        - name: "action-click"
          payload: "{ action: string, data: [EntityName] }"
          description: "操作按钮点击事件"
      
      features:
        - "卡片式数据展示"
        - "状态标签显示"
        - "操作按钮集成"
        - "响应式布局"

  common_components:
    - name: "SearchForm"
      type: "通用组件"
      description: "通用搜索表单组件"
      
      props:
        - name: "fields"
          type: "SearchFieldConfig[]"
          required: true
          description: "搜索字段配置"
        
        - name: "modelValue"
          type: "Record<string, any>"
          required: true
          description: "搜索参数"
      
      features:
        - "动态表单字段生成"
        - "多种输入类型支持"
        - "搜索条件组合"
        - "重置和清空功能"
    
    - name: "DataExport"
      type: "通用组件"
      description: "数据导出组件"
      
      props:
        - name: "exportUrl"
          type: "string"
          required: true
          description: "导出接口地址"
        
        - name: "params"
          type: "Record<string, any>"
          default: "{}"
          description: "导出参数"
      
      features:
        - "多种导出格式支持"
        - "导出进度显示"
        - "大数据量分批导出"
        - "导出历史记录"

#### 4. 状态管理设计 (FRONTEND_STATE_SPEC)
```yaml
frontend_state_spec:
  stores:
    - name: "[module]Store"
      file: "stores/[module].ts"
      description: "[模块]状态管理"

      state:
        - name: "[entityName]List"
          type: "[EntityName][]"
          default: "[]"
          description: "[实体]列表数据"

        - name: "[entityName]Detail"
          type: "[EntityName]Detail | null"
          default: "null"
          description: "[实体]详情数据"

        - name: "loading"
          type: "boolean"
          default: "false"
          description: "加载状态"

        - name: "pagination"
          type: "PaginationState"
          default: "{ page: 1, size: 20, total: 0 }"
          description: "分页状态"

        - name: "searchParams"
          type: "[EntityName]SearchParams"
          default: "{}"
          description: "搜索参数"

        - name: "filters"
          type: "FilterState"
          default: "{}"
          description: "筛选状态"

      getters:
        - name: "filtered[EntityName]List"
          return_type: "[EntityName][]"
          description: "过滤后的[实体]列表"
          implementation: |
            (state) => {
              return state.[entityName]List.filter(item => {
                // 应用本地筛选逻辑
                return true;
              });
            }

        - name: "total[EntityName]Count"
          return_type: "number"
          description: "[实体]总数"
          implementation: |
            (state) => state.pagination.total

        - name: "[entityName]ById"
          return_type: "(id: number) => [EntityName] | undefined"
          description: "根据ID获取[实体]"
          implementation: |
            (state) => (id: number) => {
              return state.[entityName]List.find(item => item.id === id);
            }

      actions:
        - name: "fetch[EntityName]List"
          parameters:
            - name: "params"
              type: "[EntityName]SearchParams"
              default: "{}"

          description: "获取[实体]列表"

          implementation: |
            async fetch[EntityName]List(params: [EntityName]SearchParams = {}) {
              this.loading = true;
              try {
                const response = await [module]Api.getList({
                  ...this.searchParams,
                  ...params,
                  page: this.pagination.page - 1,
                  size: this.pagination.size
                });

                this.[entityName]List = response.data.content;
                this.pagination = {
                  page: response.data.page + 1,
                  size: response.data.size,
                  total: response.data.total
                };
              } catch (error) {
                ElMessage.error('获取数据失败');
                throw error;
              } finally {
                this.loading = false;
              }
            }

        - name: "fetch[EntityName]Detail"
          parameters:
            - name: "id"
              type: "number"

          description: "获取[实体]详情"

          implementation: |
            async fetch[EntityName]Detail(id: number) {
              this.loading = true;
              try {
                const response = await [module]Api.getDetail(id);
                this.[entityName]Detail = response.data;
              } catch (error) {
                ElMessage.error('获取详情失败');
                throw error;
              } finally {
                this.loading = false;
              }
            }

        - name: "create[EntityName]"
          parameters:
            - name: "data"
              type: "[EntityName]CreateRequest"

          description: "创建[实体]"

          implementation: |
            async create[EntityName](data: [EntityName]CreateRequest) {
              try {
                const response = await [module]Api.create(data);
                this.[entityName]List.unshift(response.data);
                this.pagination.total += 1;
                ElMessage.success('创建成功');
                return response.data;
              } catch (error) {
                ElMessage.error('创建失败');
                throw error;
              }
            }

        - name: "update[EntityName]"
          parameters:
            - name: "id"
              type: "number"
            - name: "data"
              type: "[EntityName]UpdateRequest"

          description: "更新[实体]"

          implementation: |
            async update[EntityName](id: number, data: [EntityName]UpdateRequest) {
              try {
                const response = await [module]Api.update(id, data);
                const index = this.[entityName]List.findIndex(item => item.id === id);
                if (index !== -1) {
                  this.[entityName]List[index] = response.data;
                }
                if (this.[entityName]Detail?.id === id) {
                  this.[entityName]Detail = { ...this.[entityName]Detail, ...response.data };
                }
                ElMessage.success('更新成功');
                return response.data;
              } catch (error) {
                ElMessage.error('更新失败');
                throw error;
              }
            }

        - name: "delete[EntityName]"
          parameters:
            - name: "id"
              type: "number"

          description: "删除[实体]"

          implementation: |
            async delete[EntityName](id: number) {
              try {
                await [module]Api.delete(id);
                this.[entityName]List = this.[entityName]List.filter(item => item.id !== id);
                this.pagination.total -= 1;
                if (this.[entityName]Detail?.id === id) {
                  this.[entityName]Detail = null;
                }
                ElMessage.success('删除成功');
              } catch (error) {
                ElMessage.error('删除失败');
                throw error;
              }
            }

        - name: "updateSearchParams"
          parameters:
            - name: "params"
              type: "Partial<[EntityName]SearchParams>"

          description: "更新搜索参数"

          implementation: |
            updateSearchParams(params: Partial<[EntityName]SearchParams>) {
              this.searchParams = { ...this.searchParams, ...params };
              this.pagination.page = 1; // 重置到第一页
            }

        - name: "updatePagination"
          parameters:
            - name: "pagination"
              type: "Partial<PaginationState>"

          description: "更新分页状态"

          implementation: |
            updatePagination(pagination: Partial<PaginationState>) {
              this.pagination = { ...this.pagination, ...pagination };
            }

        - name: "reset"
          description: "重置状态"

          implementation: |
            reset() {
              this.[entityName]List = [];
              this.[entityName]Detail = null;
              this.loading = false;
              this.pagination = { page: 1, size: 20, total: 0 };
              this.searchParams = {};
              this.filters = {};
            }

  composables:
    - name: "use[EntityName]List"
      file: "composables/use[EntityName]List.ts"
      description: "[实体]列表逻辑组合函数"

      returns:
        - name: "[entityName]List"
          type: "ComputedRef<[EntityName][]>"
        - name: "loading"
          type: "ComputedRef<boolean>"
        - name: "pagination"
          type: "ComputedRef<PaginationState>"
        - name: "searchParams"
          type: "Ref<[EntityName]SearchParams>"
        - name: "fetchList"
          type: "() => Promise<void>"
        - name: "search"
          type: "(params: [EntityName]SearchParams) => Promise<void>"
        - name: "changePage"
          type: "(page: number) => Promise<void>"
        - name: "changeSize"
          type: "(size: number) => Promise<void>"

      implementation: |
        export function use[EntityName]List() {
          const store = use[Module]Store();

          const [entityName]List = computed(() => store.[entityName]List);
          const loading = computed(() => store.loading);
          const pagination = computed(() => store.pagination);
          const searchParams = ref<[EntityName]SearchParams>({});

          const fetchList = async () => {
            await store.fetch[EntityName]List(searchParams.value);
          };

          const search = async (params: [EntityName]SearchParams) => {
            searchParams.value = params;
            store.updateSearchParams(params);
            await fetchList();
          };

          const changePage = async (page: number) => {
            store.updatePagination({ page });
            await fetchList();
          };

          const changeSize = async (size: number) => {
            store.updatePagination({ page: 1, size });
            await fetchList();
          };

          return {
            [entityName]List,
            loading,
            pagination,
            searchParams,
            fetchList,
            search,
            changePage,
            changeSize
          };
        }

    - name: "use[EntityName]Form"
      file: "composables/use[EntityName]Form.ts"
      description: "[实体]表单逻辑组合函数"

      parameters:
        - name: "mode"
          type: "'create' | 'edit'"
        - name: "id"
          type: "number | undefined"

      returns:
        - name: "formData"
          type: "Ref<[EntityName]FormData>"
        - name: "formRef"
          type: "Ref<FormInstance | undefined>"
        - name: "loading"
          type: "ComputedRef<boolean>"
        - name: "isSubmitting"
          type: "Ref<boolean>"
        - name: "isDirty"
          type: "ComputedRef<boolean>"
        - name: "submit"
          type: "() => Promise<void>"
        - name: "reset"
          type: "() => void"
        - name: "validate"
          type: "() => Promise<boolean>"

      implementation: |
        export function use[EntityName]Form(mode: 'create' | 'edit', id?: number) {
          const store = use[Module]Store();
          const router = useRouter();

          const formData = ref<[EntityName]FormData>({
            // 初始化表单数据
          });

          const formRef = ref<FormInstance>();
          const loading = computed(() => store.loading);
          const isSubmitting = ref(false);
          const originalData = ref<[EntityName]FormData>({});

          const isDirty = computed(() => {
            return JSON.stringify(formData.value) !== JSON.stringify(originalData.value);
          });

          const submit = async () => {
            if (!(await validate())) return;

            isSubmitting.value = true;
            try {
              if (mode === 'create') {
                await store.create[EntityName](formData.value);
                router.push('/[module]');
              } else if (id) {
                await store.update[EntityName](id, formData.value);
                router.push(`/[module]/${id}`);
              }
            } finally {
              isSubmitting.value = false;
            }
          };

          const reset = () => {
            formData.value = { ...originalData.value };
            formRef.value?.clearValidate();
          };

          const validate = async (): Promise<boolean> => {
            if (!formRef.value) return false;
            try {
              await formRef.value.validate();
              return true;
            } catch {
              return false;
            }
          };

          // 编辑模式下加载数据
          if (mode === 'edit' && id) {
            onMounted(async () => {
              await store.fetch[EntityName]Detail(id);
              if (store.[entityName]Detail) {
                formData.value = { ...store.[entityName]Detail };
                originalData.value = { ...store.[entityName]Detail };
              }
            });
          }

          return {
            formData,
            formRef,
            loading,
            isSubmitting,
            isDirty,
            submit,
            reset,
            validate
          };
        }
```

#### 5. 前端验证检查点 (FRONTEND_VALIDATION_CHECKPOINTS)
```yaml
frontend_validation_checkpoints:
  vue_best_practices:
    - check: "Composition API使用规范"
      rule: "所有组件使用Composition API编写"
      error_message: "组件必须使用Composition API"

    - check: "响应式数据使用"
      rule: "正确使用ref和reactive"
      error_message: "响应式数据必须正确声明"

    - check: "组件props定义"
      rule: "所有props包含类型定义和默认值"
      error_message: "Props必须包含完整的类型定义"

  element_plus_compliance:
    - check: "组件使用规范"
      rule: "正确使用Element Plus组件"
      error_message: "Element Plus组件使用必须符合规范"

    - check: "主题一致性"
      rule: "使用统一的主题配置"
      error_message: "必须使用项目统一的主题配置"

  performance_optimization:
    - check: "组件懒加载"
      rule: "路由组件使用懒加载"
      error_message: "路由组件必须使用懒加载"

    - check: "列表虚拟化"
      rule: "大数据量列表使用虚拟滚动"
      error_message: "大列表必须使用虚拟滚动优化"

  accessibility_compliance:
    - check: "键盘导航支持"
      rule: "所有交互元素支持键盘操作"
      error_message: "必须支持键盘导航"

    - check: "ARIA标签使用"
      rule: "复杂组件包含ARIA标签"
      error_message: "复杂组件必须包含无障碍标签"

  code_quality:
    - check: "TypeScript类型安全"
      rule: "所有变量和函数包含类型定义"
      error_message: "必须使用TypeScript类型定义"

    - check: "组件单一职责"
      rule: "组件功能职责单一明确"
      error_message: "组件必须遵循单一职责原则"

  state_management:
    - check: "状态管理规范"
      rule: "全局状态使用Pinia管理"
      error_message: "全局状态必须使用Pinia"

    - check: "状态更新规范"
      rule: "状态更新通过actions进行"
      error_message: "状态更新必须通过actions"
```

### AI处理指令
1. **严格遵循Vue.js 3最佳实践**：确保代码符合Vue 3生态规范
2. **完整性检查**：所有组件必须完整且可运行
3. **一致性验证**：使用FRONTEND_VALIDATION_CHECKPOINTS进行自我验证
4. **用户体验优化**：应用响应式设计、加载状态、错误处理等UX优化
5. **性能优化**：实现懒加载、虚拟滚动、缓存等性能优化策略

### 质量控制要求
1. **组件化规范性**：严格遵循组件设计原则和复用策略
2. **用户体验一致性**：统一的交互模式和视觉风格
3. **性能达标**：页面加载时间≤2s，交互响应时间≤200ms
4. **无障碍合规**：符合WCAG 2.1 AA级无障碍标准
5. **浏览器兼容性**：支持主流浏览器最新两个版本

### 并行开发协调
1. **API契约遵循**：严格按照API规范进行前端集成
2. **Mock数据使用**：开发阶段使用Mock Server进行独立开发
3. **类型定义同步**：与后端保持数据类型定义的一致性
4. **集成测试配合**：提供完整的前端集成测试支持
