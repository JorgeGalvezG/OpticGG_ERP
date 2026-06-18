package com.optica.api.controllers;

import com.optica.api.dto.LoginRequestDTO;
import com.optica.api.dto.LoginResponseDTO;
import com.optica.api.models.Usuario;
import com.optica.api.repositories.UsuarioRepository;
import com.optica.api.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin("*")
public class AuthController {

    @Autowired private AuthenticationManager authenticationManager;
    @Autowired private JwtUtil jwtUtil;
    @Autowired private UsuarioRepository usuarioRepository;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequestDTO request) {
        try {
            // 1. Intentamos autenticar con Spring Security
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );

            // 2. Si pasa, buscamos sus datos exactos en la BD
            Usuario usuario = usuarioRepository.findByUsername(request.getUsername()).orElseThrow();

            // 3. Fabricamos su Pase VIP (Token)
            String token = jwtUtil.generarToken(usuario.getUsername(), usuario.getRol().name(), request.isRememberMe());

            // 4. Se lo entregamos al frontend
            return ResponseEntity.ok(new LoginResponseDTO(
                    token,
                    usuario.getUsername(),
                    usuario.getRol(),
                    usuario.getTienda()
            ));

        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Usuario o contraseña incorrectos");
        }
    }
}