package com.optica.api.repositories;

import com.optica.api.models.Proveedor;
import com.optica.api.models.enums.Tienda;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProveedorRepository extends JpaRepository<Proveedor, Long> {
    // Busca la lista de proveedores por la tienda logueada
    List<Proveedor> findByTienda(Tienda tienda);
}