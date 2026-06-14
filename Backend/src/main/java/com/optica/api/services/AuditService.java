package com.optica.api.services;

import com.optica.api.dto.AuditReportDTO;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class AuditService {

    @PersistenceContext
    private EntityManager entityManager;

    public AuditReportDTO generateReport() {
        List<String> details = new ArrayList<>();

        // 1. Orphaned Sales (Sales without Caja entry)
        String orphanedQuery = "SELECT COUNT(v.id) FROM ventas v " +
                "LEFT JOIN movimientos_caja m ON m.descripcion LIKE CONCAT('%Cód: ', v.codigo_barras, '%') " +
                "WHERE v.monto_a_cuenta > 0 AND m.id IS NULL";
        long orphanedCount = ((Number) entityManager.createNativeQuery(orphanedQuery).getSingleResult()).longValue();
        if (orphanedCount > 0) details.add("Se detectaron " + orphanedCount + " ventas con abonos que no figuran en caja.");

        // 2. Stock Mismatches (Total sold vs stock)
        // (Just a simple check if any stock is negative or suspicious)
        String stockQuery = "SELECT COUNT(id) FROM almacen WHERE stock < 0";
        long stockMismatches = ((Number) entityManager.createNativeQuery(stockQuery).getSingleResult()).longValue();
        if (stockMismatches > 0) details.add("Hay " + stockMismatches + " productos con stock negativo.");

        // 3. Balance Mismatches (OT vs Venta)
        String balanceQuery = "SELECT COUNT(ot.id) FROM ordenes_trabajo ot " +
                "JOIN ventas v ON ot.venta_id = v.id " +
                "WHERE ot.monto_saldo <> v.monto_saldo";
        long balanceMismatches = ((Number) entityManager.createNativeQuery(balanceQuery).getSingleResult()).longValue();
        if (balanceMismatches > 0) details.add("Existen " + balanceMismatches + " órdenes cuyos saldos no coinciden con su venta original.");

        return new AuditReportDTO(details, orphanedCount, stockMismatches, balanceMismatches);
    }
}
