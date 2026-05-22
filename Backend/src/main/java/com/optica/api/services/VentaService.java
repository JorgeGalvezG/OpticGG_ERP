package com.optica.api.services;

import com.optica.api.dto.NuevaVentaCompletaDTO;
import com.optica.api.models.*;
import com.optica.api.models.OrdenTrabajo;
import com.optica.api.models.Paciente;
import com.optica.api.models.Usuario;
import com.optica.api.models.Venta;

import com.optica.api.models.enums.EstadoTrabajo;
import com.optica.api.models.enums.EstadoPago;

import com.optica.api.models.enums.TipoMovimiento;
import com.optica.api.repositories.*;
import com.optica.api.repositories.OrdenTrabajoRepository;
import com.optica.api.repositories.PacienteRepository;
import com.optica.api.repositories.UsuarioRepository;
import com.optica.api.repositories.VentaRepository;

import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
public class VentaService {
    @Autowired private VentaRepository ventaRepository;
    @Autowired private OrdenTrabajoRepository ordenTrabajoRepository;
    @Autowired private PacienteRepository pacienteRepository;
    @Autowired private UsuarioRepository usuarioRepository;
    @Autowired private ConsultaRepository consultaRepository;
    @Autowired private HistorialClinicoRepository historialClinicoRepository;
    @Autowired private MovimientoCajaRepository movimientoCajaRepository;

    @Transactional
    public Venta procesarNuevaVenta(NuevaVentaCompletaDTO dto) {

        // 1. Validar que existan paciente y vendedor
        Paciente paciente = pacienteRepository.findById(dto.getPacienteId())
                .orElseThrow(() -> new RuntimeException("Paciente no encontrado: " + dto.getPacienteId()));

        Usuario vendedor = usuarioRepository.findById(dto.getVendedorId())
                .orElseThrow(() -> new RuntimeException("Vendedor no encontrado: " + dto.getVendedorId()));

        // 2. Crear consulta básica
        Consulta consulta = new Consulta();
        consulta.setPaciente(paciente);
        consulta.setVendedor(vendedor);
        consulta.setMotivo("Venta de Lentes");
        Consulta consultaGuardada = consultaRepository.save(consulta);

        // 3. Crear historial clínico (receta)
        HistorialClinico historial = new HistorialClinico();
        historial.setConsulta(consultaGuardada);
        historial.setGraduacionOd(dto.getGraduacionOd());
        historial.setGraduacionOi(dto.getGraduacionOi());
        historial.setTipoLuna(dto.getTipoLuna());
        historial.setEsLunaCliente(dto.getEsLunaCliente());
        historial.setMontura(dto.getMontura());
        historial.setEsMonturaCliente(dto.getEsMonturaCliente());
        historial.setObservaciones(dto.getObservaciones());
        historialClinicoRepository.save(historial);

        // 4. Crear la venta (control de dinero)
        BigDecimal saldo = dto.getMontoTotal().subtract(dto.getMontoACuenta());

        Venta venta = new Venta();
        venta.setCliente(paciente);
        venta.setVendedor(vendedor);
        venta.setTienda(dto.getTienda());
        venta.setMontoTotal(dto.getMontoTotal());
        venta.setMontoACuenta(dto.getMontoACuenta());
        venta.setMontoSaldo(saldo);
        venta.setMetodoPago(dto.getMetodoPago());
        
        // Copiar campos de historial a la venta
        venta.setGraduacionOd(dto.getGraduacionOd());
        venta.setGraduacionOi(dto.getGraduacionOi());
        venta.setTipoLuna(dto.getTipoLuna());
        venta.setEsLunaCliente(dto.getEsLunaCliente());
        venta.setMontura(dto.getMontura());
        venta.setEsMonturaCliente(dto.getEsMonturaCliente());
        venta.setObservaciones(dto.getObservaciones());

        // Estado de pago automático
        if (saldo.compareTo(BigDecimal.ZERO) <= 0) {
            venta.setEstado(EstadoPago.PAGADO);
        } else if (dto.getMontoACuenta().compareTo(BigDecimal.ZERO) > 0) {
            venta.setEstado(EstadoPago.PARCIAL);
        } else {
            venta.setEstado(EstadoPago.PENDIENTE);
        }

        Venta ventaGuardada = ventaRepository.save(venta);

        // 5. Crear orden de trabajo (Kanban)
        String codigoOrden = "OT-" + LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss"));

        OrdenTrabajo orden = new OrdenTrabajo();
        orden.setNumeroOrden(codigoOrden);
        orden.setCliente(paciente);
        orden.setVenta(ventaGuardada);
        orden.setTienda(dto.getTienda());
        orden.setMontoTotal(dto.getMontoTotal());
        orden.setMontoACuenta(dto.getMontoACuenta());
        orden.setMontoSaldo(saldo);
        orden.setEstado(EstadoTrabajo.PENDIENTE);
        
        // Copiar campos de historial a la orden
        orden.setGraduacionOd(dto.getGraduacionOd());
        orden.setGraduacionOi(dto.getGraduacionOi());
        orden.setTipoLuna(dto.getTipoLuna());
        orden.setEsLunaCliente(dto.getEsLunaCliente());
        orden.setMontura(dto.getMontura());
        orden.setEsMonturaCliente(dto.getEsMonturaCliente());
        orden.setObservaciones(dto.getObservaciones());
        orden.setMetodoPago(dto.getMetodoPago());

        ordenTrabajoRepository.save(orden);

        // 6. Registrar ingreso en caja automáticamente si hay pago a cuenta
        if (dto.getMontoACuenta().compareTo(BigDecimal.ZERO) > 0) {
            MovimientoCaja ingreso = new MovimientoCaja();
            ingreso.setTipo(TipoMovimiento.ENTRADA);
            ingreso.setMonto(dto.getMontoACuenta());
            ingreso.setDescripcion("Venta (" + dto.getMetodoPago() + ") - Orden: " + codigoOrden);
            ingreso.setUsuario(vendedor);
            ingreso.setTienda(dto.getTienda());
            movimientoCajaRepository.save(ingreso);
        }

        return ventaGuardada;
    }

    @Transactional
    public Venta registrarPagoSaldo(com.optica.api.dto.PagoSaldoDTO dto) {
        OrdenTrabajo orden = ordenTrabajoRepository.findById(dto.getOrdenId())
                .orElseThrow(() -> new RuntimeException("Orden no encontrada: " + dto.getOrdenId()));

        Venta venta = orden.getVenta();
        if (venta == null) {
            throw new RuntimeException("Esta orden no tiene una venta asociada");
        }

        // 1. Actualizar saldos en la venta
        BigDecimal nuevoAcuenta = venta.getMontoACuenta().add(dto.getMonto());
        BigDecimal nuevoSaldo = venta.getMontoTotal().subtract(nuevoAcuenta);

        venta.setMontoACuenta(nuevoAcuenta);
        venta.setMontoSaldo(nuevoSaldo);

        if (nuevoSaldo.compareTo(BigDecimal.ZERO) <= 0) {
            venta.setEstado(EstadoPago.PAGADO);
        } else {
            venta.setEstado(EstadoPago.PARCIAL);
        }
        ventaRepository.save(venta);

        // 2. Actualizar saldos en la orden
        orden.setMontoACuenta(nuevoAcuenta);
        orden.setMontoSaldo(nuevoSaldo);
        ordenTrabajoRepository.save(orden);

        // 3. Registrar movimiento en caja
        MovimientoCaja ingreso = new MovimientoCaja();
        ingreso.setTipo(TipoMovimiento.ENTRADA);
        ingreso.setMonto(dto.getMonto());
        ingreso.setDescripcion("Pago de Saldo (" + dto.getMetodoPago() + ") - Orden: " + orden.getNumeroOrden());
        ingreso.setUsuario(venta.getVendedor());
        ingreso.setTienda(venta.getTienda());
        movimientoCajaRepository.save(ingreso);

        return venta;
    }
}