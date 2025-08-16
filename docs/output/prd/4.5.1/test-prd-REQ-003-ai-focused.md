# REQ-003 - 工单管理系统

## 文档信息
- **模块编号**：REQ-003
- **模块名称**：工单管理系统
- **文档版本**：4.5.1-AI-PRD
- **生成日期**：2025-08-16
- **文档类型**：AI开发助手专用精简PRD
- **技术栈**：Java 21 + Spring Boot 3.3.6 + Vue.js 3.5.13 + Element Plus 2.8.8

## 1. 模块概述

### 1.1 业务价值
工单管理系统是IT运维服务的核心业务模块，负责处理从工单创建到关闭的完整生命周期管理。通过智能派单和自动化流程，提升工单处理效率40%以上，确保服务质量一致性。

### 1.2 功能范围
- 工单全生命周期管理（创建、分配、处理、验收、关闭）
- 智能派单和负载均衡
- SLA监控和告警
- 知识库集成和经验沉淀
- 多渠道接入和实时通知

### 1.3 技术定位
在整体架构中作为核心业务模块，与智能派单系统(REQ-004)、知识库管理系统(REQ-005)、工程师管理系统(REQ-006)紧密集成，提供标准化的工单处理流程和数据接口。

## 2. 功能需求规格

### 2.1 核心功能需求表

| 功能模块 | 功能点 | API接口 | 前端组件 | 验收标准 |
|---------|--------|---------|----------|----------|
| 工单创建 | 多渠道工单创建 | POST /api/v1/tickets | TicketCreate.vue | 创建成功率≥99.9% |
| 工单创建 | 自动分类标签 | POST /api/v1/tickets/classify | - | 分类准确率≥90% |
| 智能派单 | 技能匹配算法 | POST /api/v1/tickets/{id}/assign | - | 匹配准确率≥90% |
| 状态管理 | 状态流转控制 | PUT /api/v1/tickets/{id}/status | TicketStatus.vue | 流转成功率≥99% |
| 工单查询 | 高级搜索 | GET /api/v1/tickets/search | TicketSearch.vue | 查询响应时间≤2秒 |
| 批量操作 | 批量状态更新 | PUT /api/v1/tickets/batch | TicketBatch.vue | 处理成功率≥95% |

### 2.2 关键业务流程

#### 工单处理主流程
1. **工单创建** → 自动分类 → 重复检测 → 生成工单号
2. **智能派单** → 技能匹配 → 负载均衡 → 派单通知
3. **工单处理** → 状态更新 → 进度跟踪 → SLA监控
4. **验收关闭** → 客户确认 → 知识沉淀 → 数据归档

#### 状态流转规则
```
待分配 → 已分配 → 处理中 → 待验收 → 已关闭
   ↓        ↓        ↓        ↓
  已取消   已取消   已取消   已取消
```

### 2.3 数据交互设计
- **前端调用**：Vue.js组件通过Axios调用RESTful API
- **状态管理**：使用Pinia管理工单状态和缓存
- **实时更新**：WebSocket推送工单状态变更
- **事件驱动**：工单状态变更触发相关模块事件

## 3. 技术架构设计

### 3.1 数据模型设计

```java
@Entity
@Table(name = "tickets")
public class Ticket {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ticket_no", unique = true, nullable = false, length = 20)
    private String ticketNo;
    
    @Column(name = "title", nullable = false, length = 200)
    private String title;
    
    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private TicketStatus status;
    
    @Column(name = "priority", nullable = false)
    private Integer priority;
    
    @Column(name = "category", length = 50)
    private String category;
    
    @Column(name = "customer_id", nullable = false)
    private Long customerId;
    
    @Column(name = "assigned_to")
    private Long assignedTo;
    
    @Column(name = "created_by", nullable = false)
    private Long createdBy;
    
    @Column(name = "tenant_id", nullable = false)
    private Long tenantId;
    
    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}

@Entity
@Table(name = "ticket_status_history")
public class TicketStatusHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ticket_id", nullable = false)
    private Long ticketId;
    
    @Column(name = "from_status", length = 20)
    private String fromStatus;
    
    @Column(name = "to_status", nullable = false, length = 20)
    private String toStatus;
    
    @Column(name = "changed_by", nullable = false)
    private Long changedBy;
    
    @Column(name = "change_reason", columnDefinition = "TEXT")
    private String changeReason;
    
    @Column(name = "tenant_id", nullable = false)
    private Long tenantId;
    
    @CreationTimestamp
    @Column(name = "created_at")
    private LocalDateTime createdAt;
}
```

### 3.2 API接口设计

```java
@RestController
@RequestMapping("/api/v1/tickets")
@RequiredArgsConstructor
public class TicketController {
    
    private final TicketService ticketService;
    
    @PostMapping
    public Result<TicketDTO> createTicket(@Valid @RequestBody CreateTicketRequest request) {
        TicketDTO ticket = ticketService.createTicket(request);
        return Result.success(ticket);
    }
    
    @GetMapping
    public Result<PageResult<TicketDTO>> getTickets(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long assignedTo) {
        PageResult<TicketDTO> tickets = ticketService.getTickets(page, size, status, assignedTo);
        return Result.success(tickets);
    }
    
    @GetMapping("/{id}")
    public Result<TicketDTO> getTicket(@PathVariable Long id) {
        TicketDTO ticket = ticketService.getTicketById(id);
        return Result.success(ticket);
    }
    
    @PutMapping("/{id}")
    public Result<TicketDTO> updateTicket(@PathVariable Long id, 
                                         @Valid @RequestBody UpdateTicketRequest request) {
        TicketDTO ticket = ticketService.updateTicket(id, request);
        return Result.success(ticket);
    }
    
    @PutMapping("/{id}/status")
    public Result<Void> updateTicketStatus(@PathVariable Long id,
                                          @Valid @RequestBody UpdateStatusRequest request) {
        ticketService.updateTicketStatus(id, request);
        return Result.success();
    }
    
    @PostMapping("/{id}/assign")
    public Result<Void> assignTicket(@PathVariable Long id,
                                    @Valid @RequestBody AssignTicketRequest request) {
        ticketService.assignTicket(id, request);
        return Result.success();
    }
    
    @GetMapping("/search")
    public Result<PageResult<TicketDTO>> searchTickets(@Valid TicketSearchRequest request) {
        PageResult<TicketDTO> tickets = ticketService.searchTickets(request);
        return Result.success(tickets);
    }
}
```

### 3.3 Service层设计

```java
@Service
@RequiredArgsConstructor
@Transactional
public class TicketServiceImpl implements TicketService {
    
    private final TicketRepository ticketRepository;
    private final TicketStatusHistoryRepository statusHistoryRepository;
    private final ApplicationEventPublisher eventPublisher;
    
    @Override
    public TicketDTO createTicket(CreateTicketRequest request) {
        Ticket ticket = new Ticket();
        ticket.setTicketNo(generateTicketNo());
        ticket.setTitle(request.getTitle());
        ticket.setDescription(request.getDescription());
        ticket.setStatus(TicketStatus.PENDING);
        ticket.setPriority(request.getPriority());
        ticket.setCategory(request.getCategory());
        ticket.setCustomerId(request.getCustomerId());
        ticket.setCreatedBy(SecurityUtils.getCurrentUserId());
        ticket.setTenantId(SecurityUtils.getCurrentTenantId());
        
        ticket = ticketRepository.save(ticket);
        
        // 发布工单创建事件
        eventPublisher.publishEvent(new TicketCreatedEvent(ticket.getId()));
        
        return TicketMapper.toDTO(ticket);
    }
    
    @Override
    public void updateTicketStatus(Long ticketId, UpdateStatusRequest request) {
        Ticket ticket = ticketRepository.findById(ticketId)
            .orElseThrow(() -> new BusinessException("工单不存在"));
        
        TicketStatus oldStatus = ticket.getStatus();
        TicketStatus newStatus = request.getStatus();
        
        // 验证状态流转
        validateStatusTransition(oldStatus, newStatus);
        
        ticket.setStatus(newStatus);
        ticketRepository.save(ticket);
        
        // 记录状态历史
        recordStatusHistory(ticketId, oldStatus, newStatus, request.getReason());
        
        // 发布状态变更事件
        eventPublisher.publishEvent(new TicketStatusChangedEvent(ticketId, oldStatus, newStatus));
    }
}
```

### 3.4 前端组件设计

```vue
<!-- TicketList.vue -->
<template>
  <div class="ticket-list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>工单列表</span>
          <el-button type="primary" @click="showCreateDialog">创建工单</el-button>
        </div>
      </template>
      
      <el-table :data="tickets" v-loading="loading">
        <el-table-column prop="ticketNo" label="工单号" width="150" />
        <el-table-column prop="title" label="标题" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="priority" label="优先级" width="100">
          <template #default="{ row }">
            <el-tag :type="getPriorityType(row.priority)">
              {{ getPriorityText(row.priority) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="创建时间" width="180" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button size="small" @click="viewDetail(row.id)">查看</el-button>
            <el-button size="small" type="primary" @click="editTicket(row.id)">编辑</el-button>
            <el-button size="small" type="warning" @click="assignTicket(row.id)">分配</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :total="total"
        @current-change="handlePageChange"
        layout="total, sizes, prev, pager, next, jumper"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useTicketStore } from '@/stores/ticket'

const ticketStore = useTicketStore()
const tickets = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)

const loadTickets = async () => {
  loading.value = true
  try {
    const result = await ticketStore.fetchTickets({
      page: currentPage.value,
      size: pageSize.value
    })
    tickets.value = result.data
    total.value = result.total
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadTickets()
})
</script>
```

### 3.5 集成接口设计

```java
// 工单事件定义
@Data
@AllArgsConstructor
public class TicketCreatedEvent {
    private Long ticketId;
    private String ticketNo;
    private Long customerId;
    private Integer priority;
    private String category;
    private Long tenantId;
}

@Data
@AllArgsConstructor
public class TicketStatusChangedEvent {
    private Long ticketId;
    private TicketStatus fromStatus;
    private TicketStatus toStatus;
    private Long changedBy;
    private Long tenantId;
}

// 事件监听器
@Component
@RequiredArgsConstructor
public class TicketEventListener {
    
    private final IntelligentDispatchService dispatchService;
    private final NotificationService notificationService;
    
    @EventListener
    public void handleTicketCreated(TicketCreatedEvent event) {
        // 触发智能派单
        dispatchService.dispatchTicket(event.getTicketId());
        
        // 发送创建通知
        notificationService.sendTicketCreatedNotification(event);
    }
    
    @EventListener
    public void handleTicketStatusChanged(TicketStatusChangedEvent event) {
        // 发送状态变更通知
        notificationService.sendStatusChangedNotification(event);
        
        // 更新SLA监控
        slaService.updateSlaStatus(event.getTicketId(), event.getToStatus());
    }
}
```

## 4. 实现指导

### 4.1 后端开发步骤

1. **创建实体类**：定义Ticket、TicketStatusHistory等JPA实体
2. **实现Repository层**：使用Spring Data JPA实现数据访问
3. **实现Service层**：业务逻辑处理，包括状态流转、权限检查
4. **实现Controller层**：RESTful API接口实现
5. **配置安全**：JWT认证、权限控制、多租户数据隔离

### 4.2 前端开发步骤

1. **创建Pinia Store**：管理工单状态和API调用
2. **实现Vue组件**：工单列表、详情、创建、编辑组件
3. **集成Element Plus**：使用表格、表单、对话框等组件
4. **实现路由**：配置工单相关的前端路由
5. **集成API**：使用Axios调用后端API接口

### 4.3 数据库设计

```sql
-- 工单主表
CREATE TABLE tickets (
    id BIGSERIAL PRIMARY KEY,
    ticket_no VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(20) NOT NULL,
    priority INTEGER NOT NULL,
    category VARCHAR(50),
    customer_id BIGINT NOT NULL,
    assigned_to BIGINT,
    created_by BIGINT NOT NULL,
    tenant_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 索引设计
CREATE INDEX idx_tickets_tenant_status ON tickets(tenant_id, status);
CREATE INDEX idx_tickets_assigned_to ON tickets(assigned_to);
CREATE INDEX idx_tickets_customer_id ON tickets(customer_id);
CREATE INDEX idx_tickets_created_at ON tickets(created_at);

-- 工单状态历史表
CREATE TABLE ticket_status_history (
    id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    from_status VARCHAR(20),
    to_status VARCHAR(20) NOT NULL,
    changed_by BIGINT NOT NULL,
    change_reason TEXT,
    tenant_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ticket_status_history_ticket_id ON ticket_status_history(ticket_id);
```

### 4.4 配置要求

```yaml
# application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/portal
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
  jpa:
    hibernate:
      ddl-auto: validate
      naming:
        physical-strategy: org.hibernate.boot.model.naming.SnakeCasePhysicalNamingStrategy
    show-sql: false
  redis:
    host: localhost
    port: 6379
    timeout: 2000ms

# 业务配置
ticket:
  auto-assign: true
  sla-warning-hours: 2
  max-batch-size: 1000

# 安全配置
jwt:
  secret: ${JWT_SECRET}
  expiration: 86400000
```

## 5. 技术约束

### 5.1 性能要求
- **API响应时间**：≤2秒，复杂查询≤5秒
- **并发处理**：支持1000并发用户，TPS≥500
- **数据库查询**：单次查询≤1000条记录，使用分页

### 5.2 安全要求
- **身份认证**：JWT token认证，有效期24小时
- **权限控制**：基于RBAC的方法级权限控制
- **数据隔离**：多租户数据严格隔离，所有查询自动添加tenant_id过滤

### 5.3 集成要求
- **事件驱动**：使用Spring Events实现模块间解耦
- **API规范**：统一使用Result<T>响应格式，错误码标准化
- **数据一致性**：关键操作使用@Transactional保证数据一致性
