package com.optica.api.controllers;

import com.optica.api.models.Proveedor;
import com.optica.api.models.enums.Tienda;
import com.optica.api.services.ProveedorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/proveedores")
@CrossOrigin("*")
public class ProveedorController {

    @Autowired
    private ProveedorService proveedorService;

    // GET: /api/proveedores/tienda/C1
    @GetMapping("/tienda/{tienda}")
    public ResponseEntity<List<Proveedor>> listarProveedores(@PathVariable Tienda tienda) {
        return ResponseEntity.ok(proveedorService.listarPorTienda(tienda));
    }

    // POST: /api/proveedores
    @PostMapping
    public ResponseEntity<Proveedor> crearProveedor(@RequestBody Proveedor proveedor) {
        return ResponseEntity.ok(proveedorService.guardarProveedor(proveedor));
    }
    //falto añadir el put
    // PUT : /api/proveedores
    @PutMapping("/{id}")
    public ResponseEntity<Proveedor> actualizarProveedor(
            @PathVariable Long id,
            @RequestBody Proveedor proveedor ) {
        return ResponseEntity.ok(proveedorService. actualizarProveedor(id, proveedor));
    }
}