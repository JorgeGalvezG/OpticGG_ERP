package com.optica.api.dto;
import com.optica.api.models.enums.Tienda;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class VentaRequestDTO {
    private Long clienteId;
    private Long vendedorId;
    private BigDecimal montoTotal;
    private BigDecimal montoACuenta;
    private Tienda tienda;
}