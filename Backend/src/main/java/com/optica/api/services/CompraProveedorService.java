package com.optica.api.services;

import com.optica.api.models.Almacen;
import com.optica.api.models.CompraProveedor;
import com.optica.api.models.CompraProveedorDetalle;
import com.optica.api.models.Proveedor;
import com.optica.api.models.MovimientoCaja;
import com.optica.api.models.Usuario;
import com.optica.api.models.enums.EstadoPago;
import com.optica.api.models.enums.Tienda;
import com.optica.api.repositories.AlmacenRepository;
import com.optica.api.repositories.CompraProveedorDetalleRepository;
import com.optica.api.repositories.CompraProveedorRepository;
import com.optica.api.repositories.ProveedorRepository;
import com.optica.api.repositories.MovimientoCajaRepository;
import com.optica.api.repositories.UsuarioRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class CompraProveedorService {

    @Autowired private CompraProveedorRepository compraRepository;
    @Autowired private ProveedorRepository proveedorRepository;
    @Autowired private AlmacenRepository almacenRepository;
    @Autowired private CompraProveedorDetalleRepository detalleRepository;
    @Autowired private UsuarioRepository usuarioRepository;
    @Autowired private MovimientoCajaRepository movimientoCajaRepository;

    public List<CompraProveedor> listarPorTienda(Tienda tienda) {
        return compraRepository.findByTiendaOrderByFechaPedidoDesc(tienda);
    }

    public List<CompraProveedor> listarPorProveedor(Long proveedorId) {
        return compraRepository.findByProveedorId(proveedorId);
    }

    public List<CompraProveedor> listarPendientesPorTienda(Tienda tienda) {
        return compraRepository.findByTiendaAndEstadoPago(tienda, EstadoPago.PENDIENTE);
    }

    @Transactional
    public CompraProveedor registrarNuevaCompra(com.optica.api.dto.NuevaCompraProveedorDTO dto) {
        Proveedor proveedor = proveedorRepository.findById(dto.getProveedorId())
                .orElseThrow(() -> new RuntimeException("Proveedor no encontrado: " + dto.getProveedorId()));

        CompraProveedor compra = new CompraProveedor();
        compra.setProveedor(proveedor);
        compra.setTitulo(dto.getTitulo());
        compra.setMonto(dto.getMontoTotal());
        compra.setMontoPagado(dto.getMontoPagado());
        compra.setDescripcion(dto.getDescripcion());
        compra.setTienda(dto.getTienda());
        compra.setEstadoEntrega(com.optica.api.models.enums.EstadoEntrega.SOLICITADO);

        // Lógica de estado de pago
        BigDecimal saldo = dto.getMontoTotal().subtract(dto.getMontoPagado());
        if (saldo.compareTo(BigDecimal.ZERO) <= 0) {
            compra.setEstadoPago(EstadoPago.PAGADO);
        } else if (dto.getMontoPagado().compareTo(BigDecimal.ZERO) > 0) {
            compra.setEstadoPago(EstadoPago.PARCIAL);
        } else {
            compra.setEstadoPago(EstadoPago.PENDIENTE);
        }

        CompraProveedor compraGuardada = compraRepository.save(compra);

        // Guardar detalles
        if (dto.getItems() != null) {
            for (com.optica.api.dto.NuevaCompraProveedorDTO.DetalleCompraDTO itemDto : dto.getItems()) {
                CompraProveedorDetalle detalle = new CompraProveedorDetalle();
                detalle.setCompra(compraGuardada);
                
                if (itemDto.getAlmacenId() != null) {
                    Almacen producto = almacenRepository.findById(itemDto.getAlmacenId())
                            .orElseThrow(() -> new RuntimeException("Producto no encontrado en almacén: " + itemDto.getAlmacenId()));
                    detalle.setAlmacen(producto);
                    detalle.setProductoNombre(itemDto.getProductoNombre() != null ? itemDto.getProductoNombre() : producto.getNombre());
                } else {
                    detalle.setAlmacen(null);
                    detalle.setProductoNombre(itemDto.getProductoNombre() != null ? itemDto.getProductoNombre() : "Gasto Directo");
                }
                
                detalle.setCantidad(itemDto.getCantidad());
                detalle.setPrecioUnitario(itemDto.getPrecioUnitario());
                detalleRepository.save(detalle);
            }
        }

        // Registrar egreso en caja si hubo pago a cuenta/inicial
        if (compraGuardada.getMontoPagado().compareTo(BigDecimal.ZERO) > 0) {
            registrarEgresoCaja(compraGuardada, compraGuardada.getMontoPagado(), "Pago Inicial Compra #" + compraGuardada.getId() + " - " + compraGuardada.getTitulo());
        }

        return compraGuardada;
    }

    @Transactional
    public CompraProveedor registrarEntrega(Long compraId) {
        CompraProveedor compra = compraRepository.findById(compraId)
                .orElseThrow(() -> new RuntimeException("Compra no encontrada: " + compraId));
        
        if (compra.getEstadoEntrega() == com.optica.api.models.enums.EstadoEntrega.LLEGO) {
            throw new RuntimeException("Esta compra ya fue marcada como entregada");
        }

        compra.setEstadoEntrega(com.optica.api.models.enums.EstadoEntrega.LLEGO);
        compra.setFechaEntrega(java.time.LocalDateTime.now());

        // Actualizar STOCK en Almacén
        List<CompraProveedorDetalle> detalles = detalleRepository.findByCompraId(compraId);
        for (CompraProveedorDetalle detalle : detalles) {
            if (detalle.getAlmacen() != null) {
                Almacen producto = detalle.getAlmacen();
                producto.setStock(producto.getStock() + detalle.getCantidad());
                almacenRepository.save(producto);
            }
        }

        return compraRepository.save(compra);
    }

    @Transactional
    public CompraProveedor registrarAbono(Long compraId, java.math.BigDecimal monto) {
        CompraProveedor compra = compraRepository.findById(compraId)
                .orElseThrow(() -> new RuntimeException("Compra no encontrada: " + compraId));

        compra.setMontoPagado(compra.getMontoPagado().add(monto));
        
        BigDecimal saldo = compra.getMonto().subtract(compra.getMontoPagado());
        if (saldo.compareTo(BigDecimal.ZERO) <= 0) {
            compra.setEstadoPago(EstadoPago.PAGADO);
        } else {
            compra.setEstadoPago(EstadoPago.PARCIAL);
        }

        CompraProveedor compraGuardada = compraRepository.save(compra);

        // Registrar egreso en caja por el abono realizado
        if (monto.compareTo(BigDecimal.ZERO) > 0) {
            registrarEgresoCaja(compraGuardada, monto, "Abono Compra #" + compraGuardada.getId() + " - Proveedor: " + compraGuardada.getProveedor().getNombreEmpresa());
        }

        return compraGuardada;
    }

    private void registrarEgresoCaja(CompraProveedor compra, BigDecimal monto, String descripcion) {
        String username = "admin";
        try {
            org.springframework.security.core.Authentication auth = 
                org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
            if (auth != null && auth.isAuthenticated() && 
                !(auth instanceof org.springframework.security.authentication.AnonymousAuthenticationToken)) {
                username = auth.getName();
            }
        } catch (Exception e) {
            // Ignorar y usar "admin"
        }

        Usuario usuario = usuarioRepository.findByUsername(username).orElse(null);

        MovimientoCaja egreso = new MovimientoCaja();
        egreso.setTipo(com.optica.api.models.enums.TipoMovimiento.SALIDA);
        egreso.setMonto(monto);
        egreso.setDescripcion(descripcion);
        egreso.setUsuario(usuario);
        egreso.setTienda(compra.getTienda());
        egreso.setFecha(java.time.LocalDateTime.now());
        movimientoCajaRepository.save(egreso);
    }
}
