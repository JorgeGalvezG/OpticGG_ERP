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
        if (dto.getFechaManual() != null && !dto.getFechaManual().isEmpty()) {
            try {
                // Soportar formatos comunes que vienen del frontend
                if (dto.getFechaManual().contains("T")) {
                    ahora = LocalDateTime.parse(dto.getFechaManual());
                } else if (dto.getFechaManual().length() == 10) {
                    ahora = LocalDateTime.parse(dto.getFechaManual() + "T00:00:00");
                }
            } catch (Exception e) {
                System.err.println("Error parseando fecha manual: " + dto.getFechaManual());
            }
        }

        // 1. Validar/Crear paciente y validar vendedor
        Paciente paciente;
        if (dto.getPacienteId() == null || dto.getPacienteId() <= 0) {
            if (dto.getPacienteNombreManual() == null || dto.getPacienteNombreManual().trim().isEmpty()) {
                throw new RuntimeException("Paciente ID no especificado y nombre manual vacío");
            }
            paciente = new Paciente();
            String nombreCompleto = dto.getPacienteNombreManual().trim();
            int primerEspacio = nombreCompleto.indexOf(' ');
            if (primerEspacio > 0) {
                paciente.setNombre(nombreCompleto.substring(0, primerEspacio));
                paciente.setApellidos(nombreCompleto.substring(primerEspacio + 1));
            } else {
                paciente.setNombre(nombreCompleto);
                paciente.setApellidos("-");
            }
            paciente.setTienda(dto.getTienda());
            paciente.setEsDestacado(false);
            paciente = pacienteRepository.save(paciente);
        } else {
            paciente = pacienteRepository.findById(dto.getPacienteId())
                    .orElseThrow(() -> new RuntimeException("Paciente no encontrado: " + dto.getPacienteId()));
        }

        Usuario vendedor = usuarioRepository.findById(dto.getVendedorId())
                .orElseThrow(() -> new RuntimeException("Vendedor no encontrado: " + dto.getVendedorId()));

        // 2. Generar Código de Barras Único para la Venta
        String codigoBarras = "V-" + ahora.format(DateTimeFormatter.ofPattern("yyMMddHHmmss")) + "-" + (int)(Math.random() * 100);

        // 3. Crear la venta (control de dinero)
        BigDecimal total = dto.getMontoTotal() != null ? dto.getMontoTotal() : BigDecimal.ZERO;
        BigDecimal acuenta = dto.getMontoACuenta() != null ? dto.getMontoACuenta() : BigDecimal.ZERO;
        com.optica.api.models.enums.TipoVenta tipoVenta = dto.getTipoVenta() != null ? dto.getTipoVenta() : com.optica.api.models.enums.TipoVenta.ORDEN_TRABAJO;

        if (tipoVenta == com.optica.api.models.enums.TipoVenta.ORDEN_VENTA && acuenta.compareTo(BigDecimal.ZERO) == 0) {
            acuenta = total;
        }

        BigDecimal saldo = total.subtract(acuenta);

        Venta venta = new Venta();
        venta.setCodigoBarras(codigoBarras);
        venta.setCliente(paciente);
        venta.setVendedor(vendedor);
        venta.setTipoVenta(tipoVenta);
        venta.setTienda(dto.getTienda());
        venta.setMontoTotal(total);
        venta.setMontoACuenta(acuenta);
        venta.setMontoSaldo(saldo);
        venta.setMetodoPago(dto.getMetodoPago());
        venta.setFecha(ahora);

        // Estado de pago automático
        if (saldo.compareTo(BigDecimal.ZERO) <= 0) {
            venta.setEstado(EstadoPago.PAGADO);
        } else if (acuenta.compareTo(BigDecimal.ZERO) > 0) {
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
            historial.setAvOd(dto.getAvOd());
            historial.setGraduacionOi(dto.getGraduacionOi());
            historial.setAvOi(dto.getAvOi());
            historial.setAdicion(dto.getAdicion());
            historial.setDip(dto.getDip());
            historial.setTipoLuna(dto.getTipoLuna());
            historial.setEsLunaCliente(dto.getEsLunaCliente());
            historial.setMontura(dto.getMontura());
            historial.setEsMonturaCliente(dto.getEsMonturaCliente());
            historial.setObservaciones(dto.getObservaciones());
            historial.setEspecialista(dto.getEspecialista());
            historialClinicoRepository.save(historial);

            venta.setGraduacionOd(dto.getGraduacionOd());
            venta.setAvOd(dto.getAvOd());
            venta.setGraduacionOi(dto.getGraduacionOi());
            venta.setAvOi(dto.getAvOi());
            venta.setAdicion(dto.getAdicion());
            venta.setDip(dto.getDip());
            venta.setTipoLuna(dto.getTipoLuna());
            venta.setTipoLunaOd(dto.getTipoLunaOd());
            venta.setPrecioLunaOd(dto.getPrecioLunaOd());
            venta.setTipoLunaOi(dto.getTipoLunaOi());
            venta.setPrecioLunaOi(dto.getPrecioLunaOi());
            venta.setEsLunaCliente(dto.getEsLunaCliente());
            venta.setMontura(dto.getMontura());
            venta.setPrecioMontura(dto.getPrecioMontura());
            venta.setEsMonturaCliente(dto.getEsMonturaCliente());
            venta.setObservaciones(dto.getObservaciones());
            venta.setEspecialista(dto.getEspecialista());
        }

        Venta ventaGuardada = ventaRepository.save(venta);

        // Si es ORDEN_VENTA (Productos), registramos detalles y descargamos stock
        if (venta.getTipoVenta() == com.optica.api.models.enums.TipoVenta.ORDEN_VENTA && dto.getProductos() != null) {
            for (NuevaVentaCompletaDTO.DetalleVentaAlmacenDTO itemDto : dto.getProductos()) {
                VentasDetalleAlmacen detalle = new VentasDetalleAlmacen();
                detalle.setVenta(ventaGuardada);

                if (itemDto.getAlmacenId() != null) {
                    Almacen producto = almacenRepository.findById(itemDto.getAlmacenId())
                            .orElseThrow(() -> new RuntimeException("Producto no encontrado en almacén: " + itemDto.getAlmacenId()));

                    if (producto.getStock() < itemDto.getCantidad()) {
                        throw new RuntimeException("Stock insuficiente para: " + producto.getNombre());
                    }

                    // Restar stock
                    producto.setStock(producto.getStock() - itemDto.getCantidad());
                    almacenRepository.save(producto);

                    detalle.setAlmacen(producto);
                } else {
                    detalle.setNombreProductoManual(itemDto.getNombreProductoManual());
                }

                detalle.setCantidad(itemDto.getCantidad());
                detalle.setPrecioUnitario(itemDto.getPrecioUnitario());
                detalle.setSubtotal(itemDto.getPrecioUnitario().multiply(new BigDecimal(itemDto.getCantidad())));
                ventasDetalleAlmacenRepository.save(detalle);
            }
        }

        // Crear orden de trabajo según tipo de venta (para que aparezca en el listado y sea imprimible/auditable)
        if (venta.getTipoVenta() == com.optica.api.models.enums.TipoVenta.ORDEN_TRABAJO) {
            String codigoOrden = "OT-" + ahora.format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss"));
            OrdenTrabajo orden = new OrdenTrabajo();
            orden.setNumeroOrden(codigoOrden);
            orden.setCliente(paciente);
            orden.setVenta(ventaGuardada);
            orden.setTienda(dto.getTienda());
            orden.setMontoTotal(total);
            orden.setMontoACuenta(acuenta);
            orden.setMontoSaldo(saldo);
            orden.setEstado(EstadoTrabajo.PENDIENTE);
            orden.setFecha(ahora);
            orden.setGraduacionOd(dto.getGraduacionOd());
            orden.setAvOd(dto.getAvOd());
            orden.setGraduacionOi(dto.getGraduacionOi());
            orden.setAvOi(dto.getAvOi());
            orden.setAdicion(dto.getAdicion());
            orden.setDip(dto.getDip());
            orden.setTipoLuna(dto.getTipoLuna());
            orden.setTipoLunaOd(dto.getTipoLunaOd());
            orden.setPrecioLunaOd(dto.getPrecioLunaOd());
            orden.setTipoLunaOi(dto.getTipoLunaOi());
            orden.setPrecioLunaOi(dto.getPrecioLunaOi());
            orden.setEsLunaCliente(dto.getEsLunaCliente());
            orden.setMontura(dto.getMontura());
            orden.setPrecioMontura(dto.getPrecioMontura());
            orden.setEsMonturaCliente(dto.getEsMonturaCliente());
            orden.setObservaciones(dto.getObservaciones());
            orden.setEspecialista(dto.getEspecialista());
            orden.setMetodoPago(dto.getMetodoPago());
            ordenTrabajoRepository.save(orden);
        } else if (venta.getTipoVenta() == com.optica.api.models.enums.TipoVenta.ORDEN_VENTA) {
            String codigoOrden = "OV-" + ahora.format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss"));
            
            // Construir la descripción de los productos para guardarlo en tipoLuna
            StringBuilder sb = new StringBuilder();
            if (dto.getProductos() != null) {
                for (NuevaVentaCompletaDTO.DetalleVentaAlmacenDTO itemDto : dto.getProductos()) {
                    String descProd = "";
                    if (itemDto.getAlmacenId() != null) {
                        Almacen producto = almacenRepository.findById(itemDto.getAlmacenId()).orElse(null);
                        descProd = (producto != null) ? producto.getNombre() : "Producto #" + itemDto.getAlmacenId();
                    } else {
                        descProd = itemDto.getNombreProductoManual();
                    }
                    if (sb.length() > 0) sb.append(", ");
                    sb.append(itemDto.getCantidad()).append("x ").append(descProd);
                }
            } else {
                sb.append("VENTA DE PRODUCTOS GENERAL");
            }

            OrdenTrabajo orden = new OrdenTrabajo();
            orden.setNumeroOrden(codigoOrden);
            orden.setCliente(paciente);
            orden.setVenta(ventaGuardada);
            orden.setTienda(dto.getTienda());
            orden.setMontoTotal(total);
            orden.setMontoACuenta(acuenta);
            orden.setMontoSaldo(saldo);
            orden.setEstado(EstadoTrabajo.ENTREGADO); // Ya se entregó porque es venta directa
            orden.setFecha(ahora);
            orden.setTipoLuna(sb.toString()); // Guardamos la lista de productos aquí para el ticket
            orden.setObservaciones(dto.getObservaciones());
            orden.setMetodoPago(dto.getMetodoPago());
            ordenTrabajoRepository.save(orden);
        }

        // 6. Registrar ingreso en caja
        BigDecimal montoCaja = venta.getMontoACuenta();
        if (montoCaja.compareTo(BigDecimal.ZERO) > 0) {
            MovimientoCaja ingreso = new MovimientoCaja();
            ingreso.setTipo(TipoMovimiento.ENTRADA);
            ingreso.setMonto(montoCaja);
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

    public Venta buscarPorCodigo(String codigo) {
        if (codigo.startsWith("OT-")) {
            return ordenTrabajoRepository.findByNumeroOrden(codigo)
                    .map(OrdenTrabajo::getVenta)
                    .orElseThrow(() -> new RuntimeException("Orden no encontrada: " + codigo));
        } else {
            return ventaRepository.findByCodigoBarras(codigo)
                    .orElseThrow(() -> new RuntimeException("Venta no encontrada: " + codigo));
        }
    }
}