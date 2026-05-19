package com.optica.api.repositories;

import com.optica.api.models.ConfigTienda;
import com.optica.api.models.enums.Tienda;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ConfigTiendaRepository extends JpaRepository<ConfigTienda, Tienda> {
    // findById(Tienda) ya viene gratis de JpaRepository
}