package com.optica.api.repositories;

import com.optica.api.models.HistorialClinico;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface HistorialClinicoRepository extends JpaRepository<HistorialClinico, Long> {
    // Vacío. JpaRepository ya incluye toda la magia por defecto.

    // El historial clínico ligado a una consulta específica
    Optional<HistorialClinico> findByConsultaId(Long consultaId);
}