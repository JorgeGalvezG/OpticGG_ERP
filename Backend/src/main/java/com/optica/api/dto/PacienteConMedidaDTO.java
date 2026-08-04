package com.optica.api.dto;

import com.optica.api.models.enums.Tienda;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PacienteConMedidaDTO {
    // Campos del Paciente
    private Long id;
    private String nombre;
    private String apellidos;
    private String dni;
    private String telefono;
    private Integer edad;
    private LocalDate fechaNacimiento;
    private Boolean esDestacado;
    private Tienda tienda;

    // Campos de la Medida Visual (Historial Clínico / Consulta)
    private String graduacionOd;
    private String avOd;
    private String graduacionOi;
    private String avOi;
    private String adicion;
    private String dip;
    private String tipoLuna;
    private String montura;
    private String observaciones;
    private String especialista;
    
    // Identificador del Vendedor que realiza la operación
    private Long vendedorId;
}
