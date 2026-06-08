package com.optica.api.services;

import com.optica.api.models.Almacen;
import com.optica.api.models.enums.Tienda;
import com.optica.api.repositories.AlmacenRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
public class AlmacenService {

    @Autowired
    private AlmacenRepository almacenRepository;

    public List<Almacen> listarTodo() {
        return almacenRepository.findAll();
    }

    public List<Almacen> listarPorTienda(Tienda tienda) {
        return almacenRepository.findByTienda(tienda);
    }

    public Optional<Almacen> obtenerPorId(Long id) {
        return almacenRepository.findById(id);
    }

    public Optional<Almacen> obtenerPorCodigoBarras(String codigo) {
        return almacenRepository.findByCodigoBarras(codigo);
    }

    @Transactional
    public Almacen guardar(Almacen producto) {
        return almacenRepository.save(producto);
    }

    @Transactional
    public void actualizarStock(Long id, Integer cantidad) {
        Almacen producto = almacenRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));
        producto.setStock(producto.getStock() + cantidad);
        almacenRepository.save(producto);
    }

    @Transactional
    public void eliminar(Long id) {
        almacenRepository.deleteById(id);
    }
}