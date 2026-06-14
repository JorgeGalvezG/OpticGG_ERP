package com.optica.api.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.util.List;

@Data
@AllArgsConstructor
public class AuditReportDTO {
    private List<String> inconsistencies;
    private long orphanedSales;
    private long stockMismatches;
    private long balanceMismatches;
}
