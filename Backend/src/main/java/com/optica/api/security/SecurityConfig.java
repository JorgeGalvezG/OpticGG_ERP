package com.optica.api.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtRequestFilter jwtRequestFilter;

    // Encriptador militar para las contraseñas
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    // Configuración de CORS
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("*")); // Permitir todos los orígenes
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
        configuration.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type", "X-Requested-With", "accept", "Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"));
        configuration.setExposedHeaders(Arrays.asList("Authorization"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    // Las Reglas del Club
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .cors(cors -> cors.configurationSource(corsConfigurationSource())) // Configuración explícita de CORS
                .csrf(csrf -> csrf.disable()) // Desactivar protección web tradicional (usamos tokens)
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/auth", "/api/auth/**").permitAll()
                        .requestMatchers("/api/usuarios", "/api/usuarios/**").permitAll()
                        .requestMatchers("/api/pacientes", "/api/pacientes/**").permitAll()
                        .requestMatchers("/api/ordenes", "/api/ordenes/**").permitAll()
                        .requestMatchers("/api/caja", "/api/caja/**").permitAll()
                        .requestMatchers("/api/proveedores", "/api/proveedores/**").permitAll()
                        .requestMatchers("/api/compras", "/api/compras/**").permitAll()
                        .requestMatchers("/api/dashboard", "/api/dashboard/**").permitAll()
                        .requestMatchers("/api/ventas", "/api/ventas/**").permitAll()
                        .requestMatchers("/api/config-tienda", "/api/config-tienda/**").permitAll()
                        .requestMatchers("/api/almacen", "/api/almacen/**").permitAll()
                        .requestMatchers("/api/categorias", "/api/categorias/**").permitAll()
                        .requestMatchers("/api/reportes", "/api/reportes/**").permitAll()
                        .requestMatchers("/api/imagenes", "/api/imagenes/**").permitAll()
                        .requestMatchers("/api/audit", "/api/audit/**").permitAll()
                        .requestMatchers("/uploads/**").permitAll() // Permitir acceso a las imágenes subidas
                        .anyRequest().authenticated()
                );

        // Ponemos a nuestro Guardián (Filtro JWT) en la puerta principal
        http.addFilterBefore(jwtRequestFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}