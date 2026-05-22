package com.optica.api.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class PagoSaldoDTO {
    private Long ordenId;
    private BigDecimal monto;
    private String metodoPago;
}
