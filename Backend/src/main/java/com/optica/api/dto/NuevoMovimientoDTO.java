package com.optica.api.dto;

import com.optica.api.models.enums.Tienda;
import com.optica.api.models.enums.TipoMovimiento;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class NuevoMovimientoDTO {
    private TipoMovimiento tipo; // ENTRADA o SALIDA
    private BigDecimal monto;
    private String descripcion;
    private Long usuarioId; // Quién hace el registro
    private Tienda tienda;
}