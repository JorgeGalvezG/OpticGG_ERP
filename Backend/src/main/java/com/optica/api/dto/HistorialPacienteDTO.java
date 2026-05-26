// package com.optica.api.dto;
package com.optica.api.dto;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;

@Data
@Builder
public class HistorialPacienteDTO {

    // Datos básicos del paciente
    private Long pacienteId;
    private String nombreCompleto;

    // Última venta
    private Long ventaId;
    private String fechaVenta;
    private BigDecimal montoTotal;
    private BigDecimal montoSaldo;
    private String estadoPago;
    private String metodoPago;

    // Última medida (historial clínico)
    private String graduacionOd;
    private String graduacionOi;
    private String adicion;
    private String dip;
    private String tipoLuna;
    private Boolean esLunaCliente;
    private String montura;
    private Boolean esMonturaCliente;
    private String observaciones;
    private String fechaConsulta;
}