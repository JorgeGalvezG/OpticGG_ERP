package com.optica.api.repositories;
import com.optica.api.models.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {
    // Esencial para el futuro Login
    Optional<Usuario> findByUsername(String username);
}