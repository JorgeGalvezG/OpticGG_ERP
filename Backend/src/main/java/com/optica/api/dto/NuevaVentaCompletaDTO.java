package com.optica.api.dto;

import com.optica.api.models.enums.Tienda;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class NuevaVentaCompletaDTO {
    // 1. Identificadores
    private Long pacienteId;
    private Long vendedorId;
    private Tienda tienda;

    // 2. Dinero
    private BigDecimal montoTotal;
    private BigDecimal montoACuenta;
    private String metodoPago;

    // 3. Receta Visual (Historial Clínico)
    private String graduacionOd; // Ej: "Esf: -1.00, Cil: -0.50..."
    private String graduacionOi;

    // 4. Productos
    private Boolean esLunaCliente;
    private String tipoLuna;
    private Boolean esMonturaCliente;
    private String montura;

    // 5. Detalles
    private String observaciones;
}