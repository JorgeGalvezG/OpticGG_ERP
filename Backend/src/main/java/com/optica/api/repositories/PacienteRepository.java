package com.optica.api.repositories;

import com.optica.api.models.Paciente;
import com.optica.api.models.enums.Tienda; // Asegúrate de importar el Enum
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PacienteRepository extends JpaRepository<Paciente, Long> {

    // Traer todos los pacientes, pero SOLO de una tienda específica
    Page<Paciente> findByTienda(Tienda tienda, Pageable pageable);

    // Buscador Supercargado (Nombres, Apellidos o Teléfono) aislado por tienda
    @Query("SELECT p FROM Paciente p WHERE p.tienda = :tienda AND " +
            "(LOWER(p.nombre) LIKE LOWER(CONCAT('%', :termino, '%')) OR " +
            "LOWER(p.apellidos) LIKE LOWER(CONCAT('%', :termino, '%')) OR " +
            "p.telefono LIKE CONCAT('%', :termino, '%'))")
    Page<Paciente> buscarPorTerminoYTienda(
            @Param("termino") String termino,
            @Param("tienda") Tienda tienda,
            Pageable pageable);
    // Traer solo los VIP de una tienda
    List<Paciente> findByTiendaAndEsDestacadoTrue(Tienda tienda);

    @Query("SELECT COUNT(p) FROM Paciente p WHERE p.tienda = :tienda " +
            "AND MONTH(p.fechaNacimiento) = MONTH(CURRENT_DATE)" +
            "AND DAY(p.fechaNacimiento) = DAY(CURRENT_DATE)")
    long contarCumpleanerosHoy(@Param("tienda") Tienda tienda);

    @Query("SELECT COUNT(p) FROM Paciente p " +
            "WHERE MONTH(p.fechaNacimiento) = MONTH(CURRENT_DATE) " +
            "AND DAY(p.fechaNacimiento) = DAY(CURRENT_DATE)")
    long contarCumpleanerosHoyGlobal();
}