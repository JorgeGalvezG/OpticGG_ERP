package com.optica.api.services;

import com.optica.api.models.Proveedor;
import com.optica.api.models.enums.Tienda;
import com.optica.api.repositories.ProveedorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProveedorService {

    @Autowired
    private ProveedorRepository proveedorRepository;

    public List<Proveedor> listarPorTienda(Tienda tienda) {
        return proveedorRepository.findByTienda(tienda);
    }

    public Proveedor guardarProveedor(Proveedor proveedor) {
        return proveedorRepository.save(proveedor);
    }

    public Proveedor actualizarProveedor(Long id, Proveedor proveedorActualizado) {
        Proveedor existente = proveedorRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Proveedor no encontrado: " + id));
        existente.setNombreEmpresa(proveedorActualizado.getNombreEmpresa());
        existente.setNombreContacto(proveedorActualizado.getNombreContacto());
        existente.setTelefono(proveedorActualizado.getTelefono());
        existente.setRuc(proveedorActualizado.getRuc());
        return proveedorRepository.save(existente);
    }
}
