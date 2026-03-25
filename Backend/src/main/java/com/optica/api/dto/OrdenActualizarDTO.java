package com.optica.api.dto;
import com.optica.api.models.enums.EstadoTrabajo;
import lombok.Data;

@Data
public class OrdenActualizarDTO {
    private EstadoTrabajo nuevoEstado;
}