package com.fxtech.portal.ticket.entity;

import com.fxtech.portal.common.entity.BaseEntity;
import com.fxtech.portal.ticket.enums.TicketStatus;
import com.fxtech.portal.ticket.enums.TicketSource;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 工单实体类
 * 基于AI增强PRD模板生成
 */
@Entity
@Table(name = "tickets", indexes = {
    @Index(name = "idx_tickets_tenant_created", columnList = "tenant_id, created_at"),
    @Index(name = "idx_tickets_tenant_status", columnList = "tenant_id, status"),
    @Index(name = "idx_tickets_tenant_assigned", columnList = "tenant_id, assigned_to"),
    @Index(name = "idx_tickets_tenant_customer", columnList = "tenant_id, customer_id"),
    @Index(name = "idx_tickets_ticket_no", columnList = "ticket_no")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class TicketEntity extends BaseEntity {

    @Column(name = "tenant_id", nullable = false)
    @NotNull
    private Long tenantId;

    @Column(name = "ticket_no", unique = true, length = 20)
    @NotBlank
    @Size(max = 20)
    private String ticketNo;

    @Column(name = "title", nullable = false, length = 200)
    @NotBlank
    @Size(max = 200)
    private String title;

    @Column(name = "description", nullable = false, columnDefinition = "TEXT")
    @NotBlank
    private String description;

    @Column(name = "category", length = 50)
    @Size(max = 50)
    private String category;

    @Column(name = "priority", nullable = false)
    @NotNull
    @Min(1)
    @Max(4)
    private Integer priority;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    @NotNull
    private TicketStatus status;

    @Enumerated(EnumType.STRING)
    @Column(name = "source", nullable = false)
    @NotNull
    private TicketSource source;

    @Column(name = "customer_id", nullable = false)
    @NotNull
    private Long customerId;

    @Column(name = "customer_name", nullable = false, length = 100)
    @NotBlank
    @Size(max = 100)
    private String customerName;

    @Column(name = "customer_phone", length = 20)
    @Size(max = 20)
    private String customerPhone;

    @Column(name = "customer_email", length = 100)
    @Email
    @Size(max = 100)
    private String customerEmail;

    @Column(name = "assigned_to")
    private Long assignedTo;

    @Column(name = "assigned_at")
    private LocalDateTime assignedAt;

    @Column(name = "sla_response_time")
    private LocalDateTime slaResponseTime;

    @Column(name = "sla_resolve_time")
    private LocalDateTime slaResolveTime;

    @Column(name = "actual_response_time")
    private LocalDateTime actualResponseTime;

    @Column(name = "actual_resolve_time")
    private LocalDateTime actualResolveTime;

    @Column(name = "tags", length = 500)
    @Size(max = 500)
    private String tags;

    // 关联关系
    @OneToMany(mappedBy = "ticket", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<TicketCommentEntity> comments;

    @OneToMany(mappedBy = "ticket", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<TicketAttachmentEntity> attachments;

    @OneToMany(mappedBy = "ticket", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<TicketStatusHistoryEntity> statusHistory;
}
