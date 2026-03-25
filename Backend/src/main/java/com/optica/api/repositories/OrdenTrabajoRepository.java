// --- OrdenTrabajoRepository.java ---
package com.optica.api.repositories;
import com.optica.api.models.OrdenTrabajo;
import com.optica.api.models.enums.EstadoTrabajo;
import com.optica.api.models.enums.Tienda;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface OrdenTrabajoRepository extends JpaRepository<OrdenTrabajo, Long> {
    // Para que cada tienda vea solo SUS órdenes pendientes
    Page<OrdenTrabajo> findByTiendaAndEstado(Tienda tienda, EstadoTrabajo estado, Pageable pageable);
}