package com.optica.api.controllers;

import com.optica.api.models.CategoriaProducto;
import com.optica.api.repositories.CategoriaProductoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/categorias")
@org.springframework.web.bind.annotation.CrossOrigin("*")
public class CategoriaProductoController {

    @Autowired
    private CategoriaProductoRepository categoriaRepository;

    @GetMapping
    public List<CategoriaProducto> listarTodas() {
        return categoriaRepository.findAll();
    }

    @org.springframework.web.bind.annotation.PostMapping
    public CategoriaProducto guardar(@org.springframework.web.bind.annotation.RequestBody CategoriaProducto categoria) {
        return categoriaRepository.save(categoria);
    }

    @org.springframework.web.bind.annotation.PutMapping("/{id}")
    public CategoriaProducto actualizar(@org.springframework.web.bind.annotation.PathVariable Long id, @org.springframework.web.bind.annotation.RequestBody CategoriaProducto data) {
        CategoriaProducto existente = categoriaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Categoría no encontrada"));
        existente.setNombre(data.getNombre());
        existente.setClasificacion(data.getClasificacion());
        return categoriaRepository.save(existente);
    }

    @org.springframework.web.bind.annotation.DeleteMapping("/{id}")
    public void eliminar(@org.springframework.web.bind.annotation.PathVariable Long id) {
        categoriaRepository.deleteById(id);
    }
}