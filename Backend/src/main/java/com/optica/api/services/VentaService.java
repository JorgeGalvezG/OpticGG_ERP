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
    @Autowired private AlmacenRepository almacenRepository;
    @Autowired private VentasDetalleAlmacenRepository ventasDetalleAlmacenRepository;

    @Transactional
    public Venta procesarNuevaVenta(NuevaVentaCompletaDTO dto) {
        LocalDateTime ahora = LocalDateTime.now();

        // 1. Validar que existan paciente y vendedor
        Paciente paciente = pacienteRepository.findById(dto.getPacienteId())
                .orElseThrow(() -> new RuntimeException("Paciente no encontrado: " + dto.getPacienteId()));

        Usuario vendedor = usuarioRepository.findById(dto.getVendedorId())
                .orElseThrow(() -> new RuntimeException("Vendedor no encontrado: " + dto.getVendedorId()));

        // 2. Generar Código de Barras Único para la Venta
        String codigoBarras = "V-" + ahora.format(DateTimeFormatter.ofPattern("yyMMddHHmmss")) + "-" + (int)(Math.random() * 100);

        // 3. Crear la venta (control de dinero)
        BigDecimal saldo = dto.getMontoTotal().subtract(dto.getMontoACuenta());

        Venta venta = new Venta();
        venta.setCodigoBarras(codigoBarras);
        venta.setCliente(paciente);
        venta.setVendedor(vendedor);
        venta.setTipoVenta(dto.getTipoVenta() != null ? dto.getTipoVenta() : com.optica.api.models.enums.TipoVenta.ORDEN_TRABAJO);
        venta.setTienda(dto.getTienda());
        venta.setMontoTotal(dto.getMontoTotal());
        venta.setMontoACuenta(dto.getMontoACuenta());
        venta.setMontoSaldo(saldo);
        venta.setMetodoPago(dto.getMetodoPago());
        venta.setFecha(ahora);

        // Estado de pago automático
        if (saldo.compareTo(BigDecimal.ZERO) <= 0) {
            venta.setEstado(EstadoPago.PAGADO);
        } else if (dto.getMontoACuenta().compareTo(BigDecimal.ZERO) > 0) {
            venta.setEstado(EstadoPago.PARCIAL);
        } else {
            venta.setEstado(EstadoPago.PENDIENTE);
        }

        // Lógica según tipo de venta
        if (venta.getTipoVenta() == com.optica.api.models.enums.TipoVenta.ORDEN_TRABAJO) {
            // Lógica de Fabricación (Consulta + Historial + OT)
            Consulta consulta = new Consulta();
            consulta.setPaciente(paciente);
            consulta.setVendedor(vendedor);
            consulta.setMotivo("Venta de Lentes");
            consulta.setReceta(dto.getObservaciones());
            consulta.setFecha(ahora);
            Consulta consultaGuardada = consultaRepository.save(consulta);

            HistorialClinico historial = new HistorialClinico();
            historial.setConsulta(consultaGuardada);
            historial.setGraduacionOd(dto.getGraduacionOd());
            historial.setGraduacionOi(dto.getGraduacionOi());
            historial.setAdicion(dto.getAdicion());
            historial.setDip(dto.getDip());
            historial.setTipoLuna(dto.getTipoLuna());
            historial.setEsLunaCliente(dto.getEsLunaCliente());
            historial.setMontura(dto.getMontura());
            historial.setEsMonturaCliente(dto.getEsMonturaCliente());
            historial.setObservaciones(dto.getObservaciones());
            historialClinicoRepository.save(historial);

            venta.setGraduacionOd(dto.getGraduacionOd());
            venta.setGraduacionOi(dto.getGraduacionOi());
            venta.setAdicion(dto.getAdicion());
            venta.setDip(dto.getDip());
            venta.setTipoLuna(dto.getTipoLuna());
            venta.setEsLunaCliente(dto.getEsLunaCliente());
            venta.setMontura(dto.getMontura());
            venta.setEsMonturaCliente(dto.getEsMonturaCliente());
            venta.setObservaciones(dto.getObservaciones());
        }

        Venta ventaGuardada = ventaRepository.save(venta);

        // Si es ORDEN_VENTA (Productos), registramos detalles y descargamos stock
        if (venta.getTipoVenta() == com.optica.api.models.enums.TipoVenta.ORDEN_VENTA && dto.getProductos() != null) {
            for (NuevaVentaCompletaDTO.DetalleVentaAlmacenDTO itemDto : dto.getProductos()) {
                Almacen producto = almacenRepository.findById(itemDto.getAlmacenId())
                        .orElseThrow(() -> new RuntimeException("Producto no encontrado en almacén: " + itemDto.getAlmacenId()));
                
                if (producto.getStock() < itemDto.getCantidad()) {
                    throw new RuntimeException("Stock insuficiente para: " + producto.getNombre());
                }

                VentasDetalleAlmacen detalle = new VentasDetalleAlmacen();
                detalle.setVenta(ventaGuardada);
                detalle.setAlmacen(producto);
                detalle.setCantidad(itemDto.getCantidad());
                detalle.setPrecioUnitario(itemDto.getPrecioUnitario());
                detalle.setSubtotal(itemDto.getPrecioUnitario().multiply(new BigDecimal(itemDto.getCantidad())));
                ventasDetalleAlmacenRepository.save(detalle);

                // Descargar stock
                producto.setStock(producto.getStock() - itemDto.getCantidad());
                almacenRepository.save(producto);
            }
        }

        // Crear orden de trabajo solo si es fabricación
        if (venta.getTipoVenta() == com.optica.api.models.enums.TipoVenta.ORDEN_TRABAJO) {
            String codigoOrden = "OT-" + ahora.format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss"));
            OrdenTrabajo orden = new OrdenTrabajo();
            orden.setNumeroOrden(codigoOrden);
            orden.setCliente(paciente);
            orden.setVenta(ventaGuardada);
            orden.setTienda(dto.getTienda());
            orden.setMontoTotal(dto.getMontoTotal());
            orden.setMontoACuenta(dto.getMontoACuenta());
            orden.setMontoSaldo(saldo);
            orden.setEstado(EstadoTrabajo.PENDIENTE);
            orden.setFecha(ahora);
            orden.setGraduacionOd(dto.getGraduacionOd());
            orden.setGraduacionOi(dto.getGraduacionOi());
            orden.setAdicion(dto.getAdicion());
            orden.setDip(dto.getDip());
            orden.setTipoLuna(dto.getTipoLuna());
            orden.setEsLunaCliente(dto.getEsLunaCliente());
            orden.setMontura(dto.getMontura());
            orden.setEsMonturaCliente(dto.getEsMonturaCliente());
            orden.setObservaciones(dto.getObservaciones());
            orden.setMetodoPago(dto.getMetodoPago());
            ordenTrabajoRepository.save(orden);
        }

        // 6. Registrar ingreso en caja
        if (dto.getMontoACuenta().compareTo(BigDecimal.ZERO) > 0) {
            MovimientoCaja ingreso = new MovimientoCaja();
            ingreso.setTipo(TipoMovimiento.ENTRADA);
            ingreso.setMonto(dto.getMontoACuenta());
            ingreso.setDescripcion("Venta (" + dto.getMetodoPago() + ") - Cód: " + codigoBarras);
            ingreso.setUsuario(vendedor);
            ingreso.setTienda(dto.getTienda());
            ingreso.setFecha(ahora);
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