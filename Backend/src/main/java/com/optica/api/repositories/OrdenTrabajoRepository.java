package com.optica.api.repositories;

import com.optica.api.models.OrdenTrabajo;
import com.optica.api.models.enums.EstadoTrabajo;
import com.optica.api.models.enums.Tienda;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List; // Importante

@Repository
public interface OrdenTrabajoRepository extends JpaRepository<OrdenTrabajo, Long> {

    // 1. Para la Vista de Lista
    Page<OrdenTrabajo> findByTiendaAndEstado(Tienda tienda, EstadoTrabajo estado, Pageable pageable);

    // 2.Para la Vista de Tablero Kanban (Trae todo de un golpe)
    List<OrdenTrabajo> findByTienda(Tienda tienda);

    long countByTiendaAndEstado(Tienda tienda, EstadoTrabajo estado);

    // Para TODAS las sedes (Admin)
    long countByEstado(EstadoTrabajo estado);
}