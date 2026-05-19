package com.optica.api.repositories;

import com.optica.api.models.Consulta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

@Repository
public interface ConsultaRepository extends JpaRepository<Consulta, Long> {
    // Vacío. JpaRepository ya incluye save(), findById(), findAll(), etc.
    @Query("SELECT c FROM Consulta c WHERE c.paciente.id = :pacienteId ORDER BY c.fecha DESC")
    List<Consulta> findUltimaConsultaPorPaciente(
            @Param("pacienteId") Long pacienteId, Pageable pageable);
    @Query("SELECT c FROM Consulta c WHERE c.paciente.id = : pacienteId ORDER BY c.fecha DESC")
    List<Consulta> findAllByPacienteId(@Param("pacienteId") Long pacienteId);
}