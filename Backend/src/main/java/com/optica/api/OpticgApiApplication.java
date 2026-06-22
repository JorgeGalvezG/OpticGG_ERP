package com.optica.api;

import com.optica.api.models.Usuario;
import com.optica.api.models.enums.RolUsuario;
import com.optica.api.models.enums.Tienda;
import com.optica.api.repositories.UsuarioRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootApplication
public class OpticgApiApplication {

	@jakarta.annotation.PostConstruct
	public void init() {
		java.util.TimeZone.setDefault(java.util.TimeZone.getTimeZone("America/Lima"));
	}

	public static void main(String[] args) {
		SpringApplication.run(OpticgApiApplication.class, args);
	}

	// Este bloque crea al primer ADMIN si no existe
	@Bean
	CommandLineRunner initDatabase(UsuarioRepository repo, PasswordEncoder encoder) {
		return args -> {
			if (repo.findByUsername("admin").isEmpty()) {
				Usuario admin = new Usuario();
				admin.setUsername("admin");
				// Encriptamos la contraseña "123456"
				admin.setPassword(encoder.encode("123456"));
				admin.setRol(RolUsuario.ADMIN);
				admin.setTienda(Tienda.C1);
				admin.setActivo(true);
				repo.save(admin);
				System.out.println("ADMIN CREADO EXITOSAMENTE");
			}
		};
	}
}