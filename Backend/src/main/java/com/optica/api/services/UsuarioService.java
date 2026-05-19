package com.optica.api.services;

import com.optica.api.models.Usuario;
import com.optica.api.models.enums.Tienda;
import com.optica.api.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // 1. Obtener TODOS (Solo para la dueña / ADMIN)
    public Page<Usuario> obtenerTodos(int page, int size) {
        return usuarioRepository.findAll(PageRequest.of(page, size));
    }

    // 2. Obtener solo los de una tienda con Paginación
    public Page<Usuario> obtenerPorTienda(Tienda tienda, int page, int size) {
        return usuarioRepository.findByTienda(tienda, PageRequest.of(page, size));
    }

    // 3. Obtener la lista cruda de activos (Para el Select de Ventas en Flutter)
    public List<Usuario> obtenerActivosPorTienda(Tienda tienda) {
        return usuarioRepository.findByTiendaAndActivoTrue(tienda);
    }

    // 4. Crear un usuario desde Flutter SIN pedirle contraseña
    public Usuario crearUsuario(Usuario nuevoUsuario) {
        // Asignamos una contraseña genérica por defecto
        String clavePorDefecto = "123456";

        // La encriptamos para que la Base de Datos esté segura
        nuevoUsuario.setPassword(passwordEncoder.encode(clavePorDefecto));

        // Por defecto, un usuario nuevo nace "Activo"
        nuevoUsuario.setActivo(true);

        return usuarioRepository.save(nuevoUsuario);
    }
    // Buscar usuarios por término
    public Page<Usuario> buscarUsuarios(String termino, int page, int size) {
        return usuarioRepository.buscarPorTermino(termino, PageRequest.of(page, size));
    }
}