package com.optica.api.dto;

import com.optica.api.models.enums.Tienda;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PacienteReactivarDTO {
    private Long id;
    private String nombre;
    private String apellidos;
    private String telefono;
    private Tienda tienda;
    private LocalDateTime fechaUltimaConsulta;
}
