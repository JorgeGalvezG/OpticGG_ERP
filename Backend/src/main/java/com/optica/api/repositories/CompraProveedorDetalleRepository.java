package com.optica.api.repositories;

import com.optica.api.models.CompraProveedorDetalle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CompraProveedorDetalleRepository extends JpaRepository<CompraProveedorDetalle, Long> {
    List<CompraProveedorDetalle> findByCompraId(Long compraId);
}