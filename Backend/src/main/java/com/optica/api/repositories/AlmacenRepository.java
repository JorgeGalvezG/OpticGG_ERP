package com.optica.api.repositories;

import com.optica.api.models.Almacen;
import com.optica.api.models.enums.Tienda;
import org.hibernate.annotations.ListIndexBase;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface AlmacenRepository extends JpaRepository<Almacen, Long> {
    Optional<Almacen> findByCodigoBarras(String codigoBarras);
    List<Almacen> findByTienda(Tienda tienda);

}