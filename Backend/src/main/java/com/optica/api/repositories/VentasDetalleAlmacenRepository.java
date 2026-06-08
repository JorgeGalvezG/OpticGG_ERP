package com.optica.api.repositories;

import com.optica.api.models.VentasDetalleAlmacen;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface VentasDetalleAlmacenRepository extends JpaRepository<VentasDetalleAlmacen, Long> {
    List<VentasDetalleAlmacen> findByVentaId(Long ventaId);
}