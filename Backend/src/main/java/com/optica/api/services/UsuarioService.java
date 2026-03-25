package com.optica.api.services;

import com.optica.api.models.Usuario;
import com.optica.api.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    // Método con paginación incorporada (ej: página 0, tamaño 20)
    public Page<Usuario> obtenerTodos(int page, int size) {
        return usuarioRepository.findAll(PageRequest.of(page, size));
    }
}