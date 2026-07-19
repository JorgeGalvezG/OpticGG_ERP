package com.optica.api.dto;

import com.optica.api.models.enums.Tienda;
import com.optica.api.models.enums.TipoVenta;
import lombok.Getter;
import lombok.Setter;
import java.math.BigDecimal;
import java.util.List;

@Getter @Setter
public class NuevaVentaCompletaDTO {
    // Datos comunes
    private Long pacienteId;
    private Long vendedorId;
    private Tienda tienda;
    private BigDecimal montoTotal;
    private BigDecimal montoACuenta;
    private String metodoPago;
    private TipoVenta tipoVenta;
    private String fechaManual;
    private String pacienteNombreManual;

    // Datos para ORDEN_TRABAJO (Fabricación)
    private String graduacionOd;
    private String avOd;
    private String graduacionOi;
    private String avOi;
    private String adicion;
    private String dip;
    private String tipoLuna;
    private String tipoLunaOd;
    private BigDecimal precioLunaOd;
    private String tipoLunaOi;
    private BigDecimal precioLunaOi;
    private Boolean esLunaCliente;
    private String montura;
    private BigDecimal precioMontura;
    private Boolean esMonturaCliente;
    private String observaciones;
    private String especialista;

    // Datos para Compra Extra (Segunda montura/cristales)
    private Boolean tieneCompraExtra;
    private String graduacionOdExtra;
    private String avOdExtra;
    private String graduacionOiExtra;
    private String avOiExtra;
    private String adicionExtra;
    private String dipExtra;
    private String tipoLunaExtra;
    private String tipoLunaOdExtra;
    private BigDecimal precioLunaOdExtra;
    private String tipoLunaOiExtra;
    private BigDecimal precioLunaOiExtra;
    private Boolean esLunaClienteExtra;
    private String monturaExtra;
    private BigDecimal precioMonturaExtra;
    private Boolean esMonturaClienteExtra;
    private String observacionesExtra;
    private String especialistaExtra;

    // Datos para ORDEN_VENTA (Productos de Almacén)
    private List<DetalleVentaAlmacenDTO> productos;

    @Getter @Setter
    public static class DetalleVentaAlmacenDTO {
        private Long almacenId;
        private String nombreProductoManual;
        private Integer cantidad;
        private BigDecimal precioUnitario;
    }
}