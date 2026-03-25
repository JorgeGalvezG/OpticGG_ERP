package com.optica.api.dto;
import com.optica.api.models.enums.RolUsuario;
import com.optica.api.models.enums.Tienda;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginResponseDTO {
    private String token;
    private String username;
    private RolUsuario rol;
    private Tienda tienda;
}