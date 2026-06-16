package com.optica.api.repositories;

import com.optica.api.models.MovimientoCaja;
import com.optica.api.models.enums.Tienda;
import com.optica.api.models.enums.TipoMovimiento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface MovimientoCajaRepository extends JpaRepository<MovimientoCaja, Long> {

    // ── LISTADO GENERAL ──────────────────────────────────────────────────────
    List<MovimientoCaja> findByTiendaOrderByFechaDesc(Tienda tienda);

    // ── HOY (por tienda) ─────────────────────────────────────────────────────
    @Query("SELECT COALESCE(SUM(m.monto), 0) FROM MovimientoCaja m " +
            "WHERE m.tienda = :tienda AND m.tipo = :tipo " +
            "AND DATE(m.fecha) = CURRENT_DATE")
    BigDecimal sumarPorTiendaYTipoHoy(
            @Param("tienda") Tienda tienda,
            @Param("tipo") TipoMovimiento tipo);

    // ── HOY (global ALL) ─────────────────────────────────────────────────────
    @Query("SELECT COALESCE(SUM(m.monto), 0) FROM MovimientoCaja m " +
            "WHERE m.tipo = :tipo " +
            "AND DATE(m.fecha) = CURRENT_DATE")
    BigDecimal sumarPorTipoHoyGlobal(@Param("tipo") TipoMovimiento tipo);

    // ── AYER (por tienda) ─────────────────────────────────────────────────────
    @Query("SELECT COALESCE(SUM(m.monto), 0) FROM MovimientoCaja m " +
            "WHERE m.tienda = :tienda AND m.tipo = :tipo " +
            "AND DATE(m.fecha) = :ayer ")
    BigDecimal sumarPorTiendaYTipoAyer(
            @Param("tienda") Tienda tienda,
            @Param("tipo") TipoMovimiento tipo,
            @Param("ayer") LocalDate ayer
            );

    // ── AYER (global ALL) ─────────────────────────────────────────────────────
    @Query("SELECT COALESCE(SUM(m.monto), 0) FROM MovimientoCaja m " +
            "WHERE m.tipo = :tipo " +
            "AND DATE(m.fecha) = :ayer ")
    BigDecimal sumarPorTipoAyerGlobal(
            @Param("tipo") TipoMovimiento tipo,
            @Param("ayer") LocalDate ayer
    );

    // ── ÚLTIMOS 15 DÍAS (por tienda) ─────────────────────────────────────────
    @Query("SELECT COALESCE(SUM(m.monto), 0) FROM MovimientoCaja m " +
            "WHERE m.tienda = :tienda AND m.tipo = :tipo " +
            "AND m.fecha >= :fechaInicio")
    BigDecimal sumarPorTiendaYTipoQuincena(
            @Param("tienda") Tienda tienda,
            @Param("tipo") TipoMovimiento tipo,
            @Param("fechaInicio") java.time.LocalDateTime fechaInicio);

    // ── ÚLTIMOS 15 DÍAS (global ALL) ─────────────────────────────────────────
    @Query("SELECT COALESCE(SUM(m.monto), 0) FROM MovimientoCaja m " +
            "WHERE m.tipo = :tipo " +
            "AND m.fecha >= :fechaInicio")
    BigDecimal sumarPorTipoQuincenaGlobal(
            @Param("tipo") TipoMovimiento tipo,
            @Param("fechaInicio") java.time.LocalDateTime fechaInicio);

    // ── MES ACTUAL (por tienda) ──────────────────────────────────────────────
    @Query("SELECT COALESCE(SUM(m.monto), 0) FROM MovimientoCaja m " +
            "WHERE m.tienda = :tienda AND m.tipo = :tipo " +
            "AND MONTH(m.fecha) = MONTH(CURRENT_DATE) " +
            "AND YEAR(m.fecha) = YEAR(CURRENT_DATE)")
    BigDecimal sumarPorTiendaYTipoMesActual(
            @Param("tienda") Tienda tienda,
            @Param("tipo") TipoMovimiento tipo);

    // ── MES ACTUAL (global ALL) ──────────────────────────────────────────────
    @Query("SELECT COALESCE(SUM(m.monto), 0) FROM MovimientoCaja m " +
            "WHERE m.tipo = :tipo " +
            "AND MONTH(m.fecha) = MONTH(CURRENT_DATE) " +
            "AND YEAR(m.fecha) = YEAR(CURRENT_DATE)")
    BigDecimal sumarPorTipoMesActualGlobal(@Param("tipo") TipoMovimiento tipo);

    // ── HISTÓRICO: ventas por vendedor en un mes/año específico (por tienda) ─
    // Usado para el histórico mensual del admin
    // ── HISTÓRICO GENERAL DE LA EMPRESA (ADMIN) ──────────────────────────────────
    @Query("SELECT YEAR(m.fecha) as anio, MONTH(m.fecha) as mes, m.tienda as tienda, " +
           "SUM(CASE WHEN m.tipo = 'ENTRADA' THEN m.monto ELSE 0 END) as ingresos, " +
           "SUM(CASE WHEN m.tipo = 'SALIDA' THEN m.monto ELSE 0 END) as egresos " +
           "FROM MovimientoCaja m GROUP BY YEAR(m.fecha), MONTH(m.fecha), m.tienda ORDER BY anio DESC, mes DESC")
    List<Object[]> getReporteGlobalMensual();

    @Query("SELECT DATE(m.fecha) as dia, m.tienda as tienda, " +
           "SUM(CASE WHEN m.tipo = 'ENTRADA' THEN m.monto ELSE 0 END) as ingresos, " +
           "SUM(CASE WHEN m.tipo = 'SALIDA' THEN m.monto ELSE 0 END) as egresos " +
           "FROM MovimientoCaja m GROUP BY DATE(m.fecha), m.tienda ORDER BY dia DESC")
    List<Object[]> getReporteGlobalDiario();
}