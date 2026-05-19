package com.optica.api.repositories;

import com.optica.api.models.Usuario;
import com.optica.api.models.enums.Tienda; // Asegura la ruta de tu Enum
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;import org.springframework.data.repository.query.Param;import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    // Esencial para el futuro Login
    Optional<Usuario> findByUsername(String username);

    // Paginación por Tienda (Usando el Enum Tienda)
    Page<Usuario> findByTienda(Tienda tienda, Pageable pageable);

    // Útil para la lista desplegable en ventas (Trae a los que no están despedidos)
    List<Usuario> findByTiendaAndActivoTrue(Tienda tienda);

    // Buscador de Personal
    @Query("SELECT u FROM Usuario u WHERE LOWER(u.username) LIKE LOWER(CONCAT('%', :termino, '%')) OR LOWER(u.rol) LIKE LOWER(CONCAT('%', :termino, '%'))")
    Page<Usuario> buscarPorTermino(@Param("termino") String termino, Pageable pageable);
}