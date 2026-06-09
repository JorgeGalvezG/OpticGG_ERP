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
public class CategoriaProductoController {

    @Autowired
    private CategoriaProductoRepository categoriaRepository;

    @GetMapping
    public List<CategoriaProducto> listarTodas() {
        return categoriaRepository.findAll();
    }
}