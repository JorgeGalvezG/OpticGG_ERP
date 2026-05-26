package com.optica.api.controllers;

import com.optica.api.models.Usuario;
import com.optica.api.models.enums.Tienda;
import com.optica.api.services.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin("*") // Permite que Flutter Web se conecte sin errores de CORS
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    // GET: /api/usuarios?page=0&size=20 (Lista global para la Dueña)
    @GetMapping
    public ResponseEntity<Page<Usuario>> listarUsuarios(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(usuarioService.obtenerTodos(page, size));
    }

    // GET: /api/usuarios/tienda/C1?page=0&size=20 (Paginado por sucursal)
    @GetMapping("/tienda/{tienda}")
    public ResponseEntity<Page<Usuario>> listarPorTienda(
            @PathVariable Tienda tienda,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(usuarioService.obtenerPorTienda(tienda, page, size));
    }

    // GET: /api/usuarios/tienda/C1/activos (Para llenar el Desplegable de Flutter)
    @GetMapping("/tienda/{tienda}/activos")
    public ResponseEntity<List<Usuario>> listarActivosPorTienda(@PathVariable Tienda tienda) {
        return ResponseEntity.ok(usuarioService.obtenerActivosPorTienda(tienda));
    }

    // POST: /api/usuarios (Guarda el vendedor creado en Flutter)
    @PostMapping
    public ResponseEntity<Usuario> crearUsuario(@RequestBody Usuario nuevoUsuario) {
        // Retornará código 200 OK con el usuario creado (sin la contraseña gracias al @JsonIgnore)
        return ResponseEntity.ok(usuarioService.crearUsuario(nuevoUsuario));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Usuario> actualizarUsuario(@PathVariable Long id, @RequestBody Usuario datos) {
        return ResponseEntity.ok(usuarioService.actualizarUsuario(id, datos));
    }

    @PatchMapping("/{id}/estado")
    public ResponseEntity<Usuario> cambiarEstado(@PathVariable Long id) {
        return ResponseEntity.ok(usuarioService.cambiarEstado(id));
    }

    // GET: /api/usuarios/buscar?termino=maria
    @GetMapping("/buscar")
    public ResponseEntity<Page<Usuario>> buscarUsuarios(
            @RequestParam String termino,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "100") int size) {
        return ResponseEntity.ok(usuarioService.buscarUsuarios(termino, page, size));
    }
}