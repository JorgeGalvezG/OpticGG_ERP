package com.optica.api.controllers;

import com.optica.api.models.Almacen;
import com.optica.api.models.enums.Tienda;
import com.optica.api.services.AlmacenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/almacen")
public class AlmacenController {

    @Autowired
    private AlmacenService almacenService;

    @GetMapping
    public List<Almacen> listarTodo() {
        return almacenService.listarTodo();
    }

    @GetMapping("/tienda/{tienda}")
    public List<Almacen> listarPorTienda(@PathVariable Tienda tienda) {
        return almacenService.listarPorTienda(tienda);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Almacen> obtenerPorId(@PathVariable Long id) {
        return almacenService.obtenerPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/codigo/{codigo}")
    public ResponseEntity<Almacen> obtenerPorCodigo(@PathVariable String codigo) {
        return almacenService.obtenerPorCodigoBarras(codigo)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Almacen guardar(@RequestBody Almacen producto) {
        return almacenService.guardar(producto);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Almacen> actualizar(@PathVariable Long id, @RequestBody Almacen producto) {
        try {
            return ResponseEntity.ok(almacenService.actualizar(id, producto));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        almacenService.eliminar(id);
        return ResponseEntity.ok().build();
    }
}