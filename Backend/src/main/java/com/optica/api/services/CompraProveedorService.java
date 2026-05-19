package com.optica.api.services;

import com.optica.api.models.CompraProveedor;
import com.optica.api.models.Proveedor;
import com.optica.api.models.enums.EstadoPago;
import com.optica.api.models.enums.Tienda;
import com.optica.api.repositories.CompraProveedorRepository;
import com.optica.api.repositories.ProveedorRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CompraProveedorService {

    @Autowired private CompraProveedorRepository compraRepository;
    @Autowired private ProveedorRepository proveedorRepository;

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
    public CompraProveedor registrarCompra(CompraProveedor compra) {
        Proveedor proveedor = proveedorRepository.findById(compra.getProveedor().getId())
                .orElseThrow(() -> new RuntimeException("Proveedor no encontrado: " + compra.getProveedor().getId()));
        compra.setProveedor(proveedor);
        compra.setEstadoPago(EstadoPago.PENDIENTE);
        return compraRepository.save(compra);
    }

    @Transactional
    public CompraProveedor marcarComoPagado(Long compraId) {
        CompraProveedor compra = compraRepository.findById(compraId)
                .orElseThrow(() -> new RuntimeException("Compra no encontrada: " + compraId));
        compra.setEstadoPago(EstadoPago.PAGADO);
        return compraRepository.save(compra);
    }
}
