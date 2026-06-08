package com.optica.api.controllers;

import com.optica.api.dto.DashboardResumenDTO;
import com.optica.api.models.enums.EstadoTrabajo;
import com.optica.api.models.enums.Tienda;
import com.optica.api.models.enums.TipoMovimiento;
import com.optica.api.repositories.MovimientoCajaRepository;
import com.optica.api.repositories.VentaRepository;
import com.optica.api.repositories.PacienteRepository;
import com.optica.api.repositories.OrdenTrabajoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "*")
public class DashboardController {

    @Autowired private VentaRepository ventaRepository;
    @Autowired private PacienteRepository pacienteRepository;
    @Autowired private OrdenTrabajoRepository ordenTrabajoRepository;
    @Autowired private MovimientoCajaRepository cajaRepository;

    // =========================================================================
    // GET /api/dashboard/resumen/{tienda}
    // tiendaStr puede ser "ALL", "C1", "C2" o "C3"
    // =========================================================================
    @GetMapping("/resumen/{tiendaStr}")
    public DashboardResumenDTO obtenerResumen(@PathVariable String tiendaStr) {

        Map<String, BigDecimal> totalesPorMetodo = new HashMap<>();
        Map<String, BigDecimal> metodosPagoMes = new HashMap<>();
        Map<String, BigDecimal> ventasPorVendedor = new HashMap<>();
        Map<String, BigDecimal> ventasVendedores15Dias = new HashMap<>();
        Map<String, BigDecimal> ventasVendedores30Dias = new HashMap<>();

        long cumpleaneros;
        long pendientes;
        BigDecimal ingresosHoy;
        BigDecimal egresosHoy;
        BigDecimal ingresosAyer;
        BigDecimal egresosAyer;
        BigDecimal ingresosQuincena;
        BigDecimal egresosQuincena;
        BigDecimal ingresosMes;
        BigDecimal egresosMes;

        LocalDateTime hace14Dias = LocalDateTime.now().minusDays(14);
        LocalDateTime hace30Dias = LocalDateTime.now().minusDays(30);
        LocalDate fechaAyer = LocalDate.now().minusDays(1);

        if (tiendaStr.equalsIgnoreCase("ALL")) {

            // Métodos de pago hoy — global
            for (Object[] fila : ventaRepository.sumarIngresosPorMetodoHoyGlobal()) {
                String metodo = fila[0] != null ? (String) fila[0] : "OTROS";
                totalesPorMetodo.put(metodo, (BigDecimal) fila[1]);
            }
            // Métodos de pago mes — global
            for (Object[] fila : ventaRepository.sumarIngresosPorMetodoMesGlobal()) {
                String metodo = fila[0] != null ? (String) fila[0] : "OTROS";
                metodosPagoMes.put(metodo, (BigDecimal) fila[1]);
            }

            // Vendedores hoy — global
            for (Object[] fila : ventaRepository.sumarVentasPorVendedorHoyGlobal()) {
                String nombre = fila[0] != null ? (String) fila[0] : "Desconocido";
                ventasPorVendedor.put(nombre, (BigDecimal) fila[1]);
            }
            // Vendedores 15 días — global
            for (Object[] fila : ventaRepository.sumarVentasPorVendedorRangoGlobal(hace14Dias)) {
                ventasVendedores15Dias.put((String) fila[0], (BigDecimal) fila[1]);
            }
            // Vendedores 30 días — global
            for (Object[] fila : ventaRepository.sumarVentasPorVendedorRangoGlobal(hace30Dias)) {
                ventasVendedores30Dias.put((String) fila[0], (BigDecimal) fila[1]);
            }

            cumpleaneros = pacienteRepository.contarCumpleanerosHoyGlobal();
            pendientes   = ordenTrabajoRepository.countByEstado(EstadoTrabajo.PENDIENTE);

            ingresosHoy      = cajaRepository.sumarPorTipoHoyGlobal(TipoMovimiento.ENTRADA);
            egresosHoy       = cajaRepository.sumarPorTipoHoyGlobal(TipoMovimiento.SALIDA);
            ingresosAyer     = cajaRepository.sumarPorTipoAyerGlobal(TipoMovimiento.ENTRADA, fechaAyer);
            egresosAyer      = cajaRepository.sumarPorTipoAyerGlobal(TipoMovimiento.SALIDA, fechaAyer);
            ingresosQuincena = cajaRepository.sumarPorTipoQuincenaGlobal(TipoMovimiento.ENTRADA, hace14Dias);
            egresosQuincena  = cajaRepository.sumarPorTipoQuincenaGlobal(TipoMovimiento.SALIDA, hace14Dias);
            ingresosMes      = cajaRepository.sumarPorTipoQuincenaGlobal(TipoMovimiento.ENTRADA, hace30Dias);
            egresosMes       = cajaRepository.sumarPorTipoQuincenaGlobal(TipoMovimiento.SALIDA, hace30Dias);

        } else {

            Tienda tiendaEnum = parseTienda(tiendaStr);

            // Métodos de pago hoy — por tienda
            for (Object[] fila : ventaRepository.sumarIngresosPorMetodoHoy(tiendaEnum)) {
                String metodo = fila[0] != null ? (String) fila[0] : "OTROS";
                totalesPorMetodo.put(metodo, (BigDecimal) fila[1]);
            }
            // Métodos de pago mes — por tienda
            for (Object[] fila : ventaRepository.sumarIngresosPorMetodoMes(tiendaEnum)) {
                String metodo = fila[0] != null ? (String) fila[0] : "OTROS";
                metodosPagoMes.put(metodo, (BigDecimal) fila[1]);
            }

            // Vendedores hoy — por tienda
            for (Object[] fila : ventaRepository.sumarVentasPorVendedorHoy(tiendaEnum)) {
                String nombre = fila[0] != null ? (String) fila[0] : "Desconocido";
                ventasPorVendedor.put(nombre, (BigDecimal) fila[1]);
            }
            // Vendedores 15 dias — por tienda
            for (Object[] fila : ventaRepository.sumarVentasPorVendedorRango(tiendaEnum, hace14Dias)) {
                ventasVendedores15Dias.put((String) fila[0], (BigDecimal) fila[1]);
            }
            // Vendedores 30 dias — por tienda
            for (Object[] fila : ventaRepository.sumarVentasPorVendedorRango(tiendaEnum, hace30Dias)) {
                ventasVendedores30Dias.put((String) fila[0], (BigDecimal) fila[1]);
            }

            cumpleaneros = pacienteRepository.contarCumpleanerosHoy(tiendaEnum);
            pendientes   = ordenTrabajoRepository.countByTiendaAndEstado(tiendaEnum, EstadoTrabajo.PENDIENTE);

            ingresosHoy      = cajaRepository.sumarPorTiendaYTipoHoy(tiendaEnum, TipoMovimiento.ENTRADA);
            egresosHoy       = cajaRepository.sumarPorTiendaYTipoHoy(tiendaEnum, TipoMovimiento.SALIDA);
            ingresosAyer     = cajaRepository.sumarPorTiendaYTipoAyer(tiendaEnum, TipoMovimiento.ENTRADA, fechaAyer);
            egresosAyer      = cajaRepository.sumarPorTiendaYTipoAyer(tiendaEnum, TipoMovimiento.SALIDA, fechaAyer);
            ingresosQuincena = cajaRepository.sumarPorTiendaYTipoQuincena(tiendaEnum, TipoMovimiento.ENTRADA, hace14Dias);
            egresosQuincena  = cajaRepository.sumarPorTiendaYTipoQuincena(tiendaEnum, TipoMovimiento.SALIDA, hace14Dias);
            ingresosMes      = cajaRepository.sumarPorTiendaYTipoQuincena(tiendaEnum, TipoMovimiento.ENTRADA, hace30Dias);
            egresosMes       = cajaRepository.sumarPorTiendaYTipoQuincena(tiendaEnum, TipoMovimiento.SALIDA, hace30Dias);
        }

        return DashboardResumenDTO.builder()
                .totalesPorMetodo(totalesPorMetodo)
                .metodosPagoMes(metodosPagoMes)
                .ventasPorVendedor(ventasPorVendedor)
                .ventasVendedores15Dias(ventasVendedores15Dias)
                .ventasVendedores30Dias(ventasVendedores30Dias)
                .cumpleanerosHoy(cumpleaneros)
                .ordenesPendientes(pendientes)
                .ingresosHoy(ingresosHoy)
                .egresosHoy(egresosHoy)
                .pctIngresosHoy(calcularPorcentaje(ingresosHoy, ingresosAyer))
                .pctEgresosHoy(calcularPorcentaje(egresosHoy, egresosAyer))
                .ingresosQuincena(ingresosQuincena)
                .egresosQuincena(egresosQuincena)
                .ingresosMes(ingresosMes)
                .egresosMes(egresosMes)
                .build();
    }

    private Double calcularPorcentaje(BigDecimal hoy, BigDecimal ayer) {
        if (hoy == null) hoy = BigDecimal.ZERO;
        if (ayer == null || ayer.compareTo(BigDecimal.ZERO) == 0) {
            return hoy.compareTo(BigDecimal.ZERO) > 0 ? 100.0 : 0.0;
        }
        return hoy.subtract(ayer)
                .divide(ayer, 4, java.math.RoundingMode.HALF_UP)
                .multiply(new BigDecimal(100))
                .doubleValue();
    }
    // =========================================================================
    // GET /api/dashboard/historico/{tiendaStr}?mes=4&anio=2026
    // Histórico mensual de ventas por vendedor — se resetea visual pero guarda datos
    // =========================================================================
    @GetMapping("/historico/{tiendaStr}")
    public Map<String, Object> obtenerHistoricoMensual(
            @PathVariable String tiendaStr,
            @RequestParam int mes,
            @RequestParam int anio) {

        Map<String, BigDecimal> ventasPorVendedor = new HashMap<>();
        List<Object[]> resultados;

        if (tiendaStr.equalsIgnoreCase("ALL")) {
            resultados = ventaRepository.ventasPorVendedorEnMesGlobal(mes, anio);
        } else {
            resultados = ventaRepository.ventasPorVendedorEnMes(parseTienda(tiendaStr), mes, anio);
        }

        for (Object[] fila : resultados) {
            String nombre = fila[0] != null ? (String) fila[0] : "Desconocido";
            ventasPorVendedor.put(nombre, (BigDecimal) fila[1]);
        }

        Map<String, Object> respuesta = new HashMap<>();
        respuesta.put("mes", mes);
        respuesta.put("anio", anio);
        respuesta.put("tienda", tiendaStr);
        respuesta.put("ventasPorVendedor", ventasPorVendedor);
        return respuesta;
    }

    // ── Helper privado ────────────────────────────────────────────────────────
    private Tienda parseTienda(String tiendaStr) {
        try {
            return Tienda.valueOf(tiendaStr.toUpperCase());
        } catch (IllegalArgumentException e) {
            return Tienda.C1;
        }
    }
}