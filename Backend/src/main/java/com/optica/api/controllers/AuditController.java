package com.optica.api.controllers;

import com.optica.api.dto.AuditReportDTO;
import com.optica.api.services.AuditService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin;

@RestController
@RequestMapping("/api/audit")
@CrossOrigin("*")
public class AuditController {

    @Autowired
    private AuditService auditService;

    @GetMapping("/report")
    public ResponseEntity<AuditReportDTO> getReport() {
        return ResponseEntity.ok(auditService.generateReport());
    }
}
