package com.optica.api.repositories;

import com.optica.api.models.CompraProveedor;
import com.optica.api.models.enums.EstadoPago;
import com.optica.api.models.enums.Tienda;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CompraProveedorRepository extends JpaRepository<CompraProveedor, Long> {

    List<CompraProveedor> findByProveedorId(Long proveedorId);

    List<CompraProveedor> findByTiendaOrderByFechaPedidoDesc(Tienda tienda);

    List<CompraProveedor> findByTiendaAndEstadoPago(Tienda tienda, EstadoPago estadoPago);
}
