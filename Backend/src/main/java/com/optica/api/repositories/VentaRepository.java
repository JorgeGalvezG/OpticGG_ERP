package com.optica.api.repositories;

import com.optica.api.models.Venta;
import com.optica.api.models.enums.Tienda;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

import java.util.List;

@Repository
public interface VentaRepository extends JpaRepository<Venta, Long> {

    Page<Venta> findByTienda(Tienda tienda, Pageable pageable);

    // ── MÉTODOS DE PAGO HOY (por tienda) ─────────────────────────────────────
    @Query("SELECT v.metodoPago, SUM(v.montoACuenta) FROM Venta v " +
            "WHERE v.tienda = :tienda AND DATE(v.fecha) = CURRENT_DATE " +
            "GROUP BY v.metodoPago")
    List<Object[]> sumarIngresosPorMetodoHoy(@Param("tienda") Tienda tienda);

    // ── MÉTODOS DE PAGO HOY (global) ──────────────────────────────────────────
    @Query("SELECT v.metodoPago, SUM(v.montoACuenta) FROM Venta v " +
            "WHERE DATE(v.fecha) = CURRENT_DATE " +
            "GROUP BY v.metodoPago")
    List<Object[]> sumarIngresosPorMetodoHoyGlobal();

    // ── VENDEDORES HOY (por tienda) ───────────────────────────────────────────
    @Query("SELECT v.vendedor.username, SUM(v.montoTotal) FROM Venta v " +
            "WHERE v.tienda = :tienda AND DATE(v.fecha) = CURRENT_DATE " +
            "GROUP BY v.vendedor.username")
    List<Object[]> sumarVentasPorVendedorHoy(@Param("tienda") Tienda tienda);

    // ── VENDEDORES HOY (global) ───────────────────────────────────────────────
    @Query("SELECT v.vendedor.username, SUM(v.montoTotal) FROM Venta v " +
            "WHERE DATE(v.fecha) = CURRENT_DATE " +
            "GROUP BY v.vendedor.username")
    List<Object[]> sumarVentasPorVendedorHoyGlobal();

    // ── VENDEDORES RANGO (global) ──────────────────────────────────────────────
    @Query("SELECT v.vendedor.username, SUM(v.montoTotal) FROM Venta v " +
            "WHERE v.fecha >= :fechaInicio " +
            "GROUP BY v.vendedor.username")
    List<Object[]> sumarVentasPorVendedorRangoGlobal(@Param("fechaInicio") LocalDateTime fechaInicio);

    // ── VENDEDORES RANGO (por tienda) ──────────────────────────────────────────
    @Query("SELECT v.vendedor.username, SUM(v.montoTotal) FROM Venta v " +
            "WHERE v.tienda = :tienda AND v.fecha >= :fechaInicio " +
            "GROUP BY v.vendedor.username")
    List<Object[]> sumarVentasPorVendedorRango(@Param("tienda") Tienda tienda, @Param("fechaInicio") LocalDateTime fechaInicio);

    // ── MÉTODOS DE PAGO MES ACTUAL (global) ───────────────────────────────────
    @Query("SELECT v.metodoPago, SUM(v.montoACuenta) FROM Venta v " +
            "WHERE MONTH(v.fecha) = MONTH(CURRENT_DATE) AND YEAR(v.fecha) = YEAR(CURRENT_DATE) " +
            "GROUP BY v.metodoPago")
    List<Object[]> sumarIngresosPorMetodoMesGlobal();

    // ── MÉTODOS DE PAGO MES ACTUAL (por tienda) ────────────────────────────────
    @Query("SELECT v.metodoPago, SUM(v.montoACuenta) FROM Venta v " +
            "WHERE v.tienda = :tienda AND MONTH(v.fecha) = MONTH(CURRENT_DATE) AND YEAR(v.fecha) = YEAR(CURRENT_DATE) " +
            "GROUP BY v.metodoPago")
    List<Object[]> sumarIngresosPorMetodoMes(@Param("tienda") Tienda tienda);

    // ── HISTÓRICO MENSUAL POR VENDEDOR (por tienda) ───────────────────────────
    @Query("SELECT v.vendedor.username, SUM(v.montoTotal) FROM Venta v " +
            "WHERE v.tienda = :tienda " +
            "AND MONTH(v.fecha) = :mes AND YEAR(v.fecha) = :anio " +
            "GROUP BY v.vendedor.username " +
            "ORDER BY SUM(v.montoTotal) DESC")
    List<Object[]> ventasPorVendedorEnMes(
            @Param("tienda") Tienda tienda,
            @Param("mes") int mes,
            @Param("anio") int anio);

    // ── HISTÓRICO MENSUAL POR VENDEDOR (global) ───────────────────────────────
    @Query("SELECT v.vendedor.username, SUM(v.montoTotal) FROM Venta v " +
            "WHERE MONTH(v.fecha) = :mes AND YEAR(v.fecha) = :anio " +
            "GROUP BY v.vendedor.username " +
            "ORDER BY SUM(v.montoTotal) DESC")
    List<Object[]> ventasPorVendedorEnMesGlobal(
            @Param("mes") int mes,
            @Param("anio") int anio);

    // ── ÚLTIMA VENTA DE UN PACIENTE ───────────────────────────────────────────
    @Query("SELECT v FROM Venta v WHERE v.cliente.id = :pacienteId ORDER BY v.fecha DESC")
    List<Venta> findUltimaVentaPorPaciente(
            @Param("pacienteId") Long pacienteId,
            Pageable pageable);

}