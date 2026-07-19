package com.optica.api.services;

import com.optica.api.models.Almacen;
import com.optica.api.models.enums.Tienda;
import com.optica.api.repositories.AlmacenRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
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

    private void validarProducto(Almacen producto) {
        if (producto.getStock() == null || producto.getStock() < 0) {
            throw new RuntimeException("El stock no puede ser negativo");
        }
        if (producto.getPrecioCompra() != null && producto.getPrecioCompra().compareTo(BigDecimal.ZERO) < 0) {
            throw new RuntimeException("El precio de compra no puede ser negativo");
        }
        if (producto.getPrecioVenta() == null || producto.getPrecioVenta().compareTo(BigDecimal.ZERO) < 0) {
            throw new RuntimeException("El precio de venta no puede ser negativo");
        }
    }

    @Transactional
    public Almacen guardar(Almacen producto) {
        validarProducto(producto);
        return almacenRepository.save(producto);
    }

    @Transactional
    public Almacen actualizar(Long id, Almacen data) {
        validarProducto(data);
        Almacen producto = almacenRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));
        
        producto.setNombre(data.getNombre());
        producto.setCodigoBarras(data.getCodigoBarras());
        producto.setPrecioCompra(data.getPrecioCompra());
        producto.setPrecioVenta(data.getPrecioVenta());
        producto.setStock(data.getStock());
        producto.setFotoUrl(data.getFotoUrl());
        producto.setCategoria(data.getCategoria());
        producto.setProveedor(data.getProveedor());
        
        return almacenRepository.save(producto);
    }

    @Transactional
    public void actualizarStock(Long id, Integer cantidad) {
        Almacen producto = almacenRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado"));
        if (producto.getStock() + cantidad < 0) {
            throw new RuntimeException("Stock insuficiente: la operación resultaría en un stock negativo (" + (producto.getStock() + cantidad) + ") para el producto " + producto.getNombre());
        }
        producto.setStock(producto.getStock() + cantidad);
        almacenRepository.save(producto);
    }

    @Transactional
    public void eliminar(Long id) {
        almacenRepository.deleteById(id);
    }
}