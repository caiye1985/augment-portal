package com.fxtech.portal.ticket.controller;

import com.fxtech.portal.common.dto.ApiResponse;
import com.fxtech.portal.common.dto.PagedResponse;
import com.fxtech.portal.ticket.dto.*;
import com.fxtech.portal.ticket.service.TicketService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 工单管理控制器
 * 基于AI增强PRD模板生成
 */
@RestController
@RequestMapping("/api/v1/tickets")
@Validated
@Slf4j
@RequiredArgsConstructor
@Tag(name = "Ticket Management", description = "工单管理 CRUD operations")
public class TicketController {

    private final TicketService ticketService;

    @GetMapping
    @Operation(summary = "查询工单列表", description = "分页查询工单列表，支持多条件筛选和排序")
    @PreAuthorize("hasPermission('TICKET', 'READ')")
    public ApiResponse<PagedResponse<TicketDTO>> list(
            @PageableDefault(size = 20) Pageable pageable,
            @Parameter(description = "工单状态筛选") @RequestParam(required = false) String status,
            @Parameter(description = "优先级筛选") @RequestParam(required = false) Integer priority,
            @Parameter(description = "分配工程师筛选") @RequestParam(required = false) Long assignedTo,
            @Parameter(description = "搜索关键词") @RequestParam(required = false) String keyword) {
        
        TicketSearchCriteria searchCriteria = TicketSearchCriteria.builder()
                .status(status)
                .priority(priority)
                .assignedTo(assignedTo)
                .keyword(keyword)
                .build();
        
        PagedResponse<TicketDTO> result = ticketService.findAll(pageable, searchCriteria);
        return ApiResponse.success(result);
    }

    @GetMapping("/{id}")
    @Operation(summary = "查询工单详情", description = "根据ID查询工单详细信息")
    @PreAuthorize("hasPermission('TICKET', 'READ')")
    public ApiResponse<TicketDetailDTO> getById(
            @Parameter(description = "工单ID") @PathVariable Long id) {
        
        TicketDetailDTO result = ticketService.findById(id);
        return ApiResponse.success(result);
    }

    @PostMapping
    @Operation(summary = "创建工单", description = "创建新的工单")
    @PreAuthorize("hasPermission('TICKET', 'CREATE')")
    public ApiResponse<TicketDTO> create(@Valid @RequestBody TicketCreateRequest request) {
        TicketDTO result = ticketService.create(request);
        return ApiResponse.success(result);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新工单", description = "更新工单信息")
    @PreAuthorize("hasPermission('TICKET', 'UPDATE')")
    public ApiResponse<TicketDTO> update(
            @Parameter(description = "工单ID") @PathVariable Long id,
            @Valid @RequestBody TicketUpdateRequest request) {
        
        TicketDTO result = ticketService.update(id, request);
        return ApiResponse.success(result);
    }

    @PutMapping("/{id}/status")
    @Operation(summary = "更新工单状态", description = "更新工单状态并记录变更历史")
    @PreAuthorize("hasPermission('TICKET', 'UPDATE')")
    public ApiResponse<TicketDTO> updateStatus(
            @Parameter(description = "工单ID") @PathVariable Long id,
            @Valid @RequestBody TicketStatusUpdateRequest request) {
        
        TicketDTO result = ticketService.updateStatus(id, request);
        return ApiResponse.success(result);
    }

    @PostMapping("/{id}/assign")
    @Operation(summary = "分配工单", description = "将工单分配给指定工程师")
    @PreAuthorize("hasPermission('TICKET', 'ASSIGN')")
    public ApiResponse<TicketDTO> assign(
            @Parameter(description = "工单ID") @PathVariable Long id,
            @Valid @RequestBody TicketAssignRequest request) {
        
        TicketDTO result = ticketService.assign(id, request);
        return ApiResponse.success(result);
    }

    @PutMapping("/batch")
    @Operation(summary = "批量更新工单", description = "批量更新多个工单")
    @PreAuthorize("hasPermission('TICKET', 'UPDATE')")
    public ApiResponse<BatchOperationResult> batchUpdate(
            @Valid @RequestBody TicketBatchUpdateRequest request) {
        
        BatchOperationResult result = ticketService.batchUpdate(request);
        return ApiResponse.success(result);
    }

    @GetMapping("/search")
    @Operation(summary = "高级搜索工单", description = "使用高级搜索功能查询工单")
    @PreAuthorize("hasPermission('TICKET', 'READ')")
    public ApiResponse<PagedResponse<TicketDTO>> search(
            @Parameter(description = "搜索查询字符串") @RequestParam String q,
            @PageableDefault(size = 20) Pageable pageable) {
        
        PagedResponse<TicketDTO> result = ticketService.search(q, pageable);
        return ApiResponse.success(result);
    }
}
