package com.optica.api.dto;

import com.optica.api.models.enums.Tienda;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.util.List;

@Getter @Setter
public class NuevaCompraProveedorDTO {
    private Long proveedorId;
    private String titulo;
    private BigDecimal montoTotal;
    private BigDecimal montoPagado;
    private String descripcion;
    private Tienda tienda;
    private List<DetalleCompraDTO> items;

    @Getter @Setter
    public static class DetalleCompraDTO {
        private Long almacenId;
        private Integer cantidad;
        private BigDecimal precioUnitario;
    }
}