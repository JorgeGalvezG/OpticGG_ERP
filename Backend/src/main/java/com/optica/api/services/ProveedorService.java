package com.optica.api.services;

import com.optica.api.models.Proveedor;
import com.optica.api.models.ProveedorContacto;
import com.optica.api.models.enums.Tienda;
import com.optica.api.repositories.ProveedorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ProveedorService {

    @Autowired
    private ProveedorRepository proveedorRepository;

    public List<Proveedor> listarPorTienda(Tienda tienda) {
        return proveedorRepository.findByTienda(tienda);
    }

    public Proveedor guardarProveedor(Proveedor proveedor) {
        if (proveedor.getContactos() != null) {
            for (ProveedorContacto c : proveedor.getContactos()) {
                c.setProveedor(proveedor);
            }
        }
        return proveedorRepository.save(proveedor);
    }

    @Transactional
    public Proveedor actualizarProveedor(Long id, Proveedor data) {
        Proveedor existente = proveedorRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Proveedor no encontrado: " + id));
        
        existente.setNombreEmpresa(data.getNombreEmpresa());
        existente.setRuc(data.getRuc());
        
        // Sincronizar contactos
        existente.getContactos().clear();
        if (data.getContactos() != null) {
            for (ProveedorContacto c : data.getContactos()) {
                c.setProveedor(existente);
                existente.getContactos().add(c);
            }
        }
        
        return proveedorRepository.save(existente);
    }
}
