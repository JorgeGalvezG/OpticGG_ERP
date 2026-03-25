package com.optica.api.repositories;
import com.optica.api.models.Venta;
import com.optica.api.models.enums.Tienda;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface VentaRepository extends JpaRepository<Venta, Long> {
    // Para el dashboard del Admin: filtrar ventas por tienda
    Page<Venta> findByTienda(Tienda tienda, Pageable pageable);
}