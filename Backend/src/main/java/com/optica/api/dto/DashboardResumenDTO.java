package com.optica.api.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.util.Map;

@Data
@Builder
public class DashboardResumenDTO {

    // ── MÉTODOS DE PAGO (gráfico donut) ─────────────────────────────────────
    private Map<String, BigDecimal> totalesPorMetodo;

    // ── RANKING DE VENDEDORES ────────────────────────────────────────────────
    // Para el dashboard del día (hoy) y para el histórico por mes
    private Map<String, BigDecimal> ventasPorVendedor;

    // ── ALERTAS ──────────────────────────────────────────────────────────────
    private Long cumpleanerosHoy;
    private Long ordenesPendientes;

    // ── CONTROL FINANCIERO: HOY ──────────────────────────────────────────────
    private BigDecimal ingresosHoy;
    private BigDecimal egresosHoy;

    // ── CONTROL FINANCIERO: ÚLTIMOS 15 DÍAS ─────────────────────────────────
    private BigDecimal ingresosQuincena;
    private BigDecimal egresosQuincena;

    // ── CONTROL FINANCIERO: MES ACTUAL ──────────────────────────────────────
    private BigDecimal ingresosMes;
    private BigDecimal egresosMes;
}