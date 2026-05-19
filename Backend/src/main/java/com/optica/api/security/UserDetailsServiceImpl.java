package com.optica.api.security;

import com.optica.api.models.Usuario;
import com.optica.api.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // Buscamos a tu usuario en la base de datos
        Usuario usuario = usuarioRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado: " + username));

        // Verificamos si la cuenta está activa
        if (!usuario.getActivo()) {
            throw new RuntimeException("El usuario está desactivado");
        }

        // Traducimos tu Usuario a un "User" de Spring Security
        return new User(
                usuario.getUsername(),
                usuario.getPassword(),
                Collections.singletonList(
                        new SimpleGrantedAuthority("ROLE_" + usuario.getRol().name()))
        );
    }
}