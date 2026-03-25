package com.optica.api.dto;
import com.optica.api.models.enums.RolUsuario;
import com.optica.api.models.enums.Tienda;
import lombok.Data;

@Data
public class UsuarioResponseDTO {
    private Long id;
    private String username;
    private RolUsuario rol;
    private Tienda tienda;
    private Boolean activo;
}