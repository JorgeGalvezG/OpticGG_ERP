package com.optica.api.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.optica.api.models.enums.EstadoPago; // Cambiado
import com.optica.api.models.enums.Tienda;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter @NoArgsConstructor
@Entity
@Table(name = "ventas")
public class Venta {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "codigo_barras", unique = true, length = 50)
    private String codigoBarras;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cliente_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Paciente cliente; // Mapeado a la tabla pacientes

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vendedor_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Usuario vendedor;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_venta", nullable = false)
    private com.optica.api.models.enums.TipoVenta tipoVenta = com.optica.api.models.enums.TipoVenta.ORDEN_TRABAJO;

    @Column(name = "monto_total", nullable = false, precision = 10, scale = 2)
    private BigDecimal montoTotal;

    @Column(name = "monto_a_cuenta", precision = 10, scale = 2)
    private BigDecimal montoACuenta = BigDecimal.ZERO;

    @Column(name = "monto_saldo", precision = 10, scale = 2)
    private BigDecimal montoSaldo = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    private EstadoPago estado = EstadoPago.PENDIENTE;

    @Column(name = "metodo_pago", length = 50)
    private String metodoPago; // EFECTIVO, YAPE, PLIN, TARJETA, TRANSFERENCIA

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Tienda tienda;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy HH:mm:ss")
    @Column(updatable = false)
    private LocalDateTime fecha;

    // --- CAMPOS DE HISTORIAL PARA LA VENTA ---
    @Column(name = "graduacion_od")
    private String graduacionOd;

    @Column(name = "av_od")
    private String avOd;

    @Column(name = "graduacion_oi")
    private String graduacionOi;

    @Column(name = "av_oi")
    private String avOi;

    @Column(name = "adicion")
    private String adicion;

    @Column(name = "dip")
    private String dip;

    @Column(name = "tipo_luna")
    private String tipoLuna;

    @Column(name = "tipo_luna_od")
    private String tipoLunaOd;

    @Column(name = "precio_luna_od", precision = 10, scale = 2)
    private BigDecimal precioLunaOd = BigDecimal.ZERO;

    @Column(name = "tipo_luna_oi")
    private String tipoLunaOi;

    @Column(name = "precio_luna_oi", precision = 10, scale = 2)
    private BigDecimal precioLunaOi = BigDecimal.ZERO;

    @Column(name = "es_luna_cliente")
    private Boolean esLunaCliente = false;

    @Column(name = "montura")
    private String montura;

    @Column(name = "precio_montura", precision = 10, scale = 2)
    private BigDecimal precioMontura = BigDecimal.ZERO;

    @Column(name = "es_montura_cliente")
    private Boolean esMonturaCliente = false;

    @Column(columnDefinition = "TEXT")
    private String observaciones;

    @Column(name = "especialista", length = 100)
    private String especialista;

    // --- CAMPOS DE COMPRA EXTRA ---
    @Column(name = "tiene_compra_extra")
    private Boolean tieneCompraExtra = false;

    @Column(name = "graduacion_od_extra")
    private String graduacionOdExtra;

    @Column(name = "av_od_extra")
    private String avOdExtra;

    @Column(name = "graduacion_oi_extra")
    private String graduacionOiExtra;

    @Column(name = "av_oi_extra")
    private String avOiExtra;

    @Column(name = "adicion_extra")
    private String adicionExtra;

    @Column(name = "dip_extra")
    private String dipExtra;

    @Column(name = "tipo_luna_extra")
    private String tipoLunaExtra;

    @Column(name = "tipo_luna_od_extra")
    private String tipoLunaOdExtra;

    @Column(name = "precio_luna_od_extra", precision = 10, scale = 2)
    private BigDecimal precioLunaOdExtra = BigDecimal.ZERO;

    @Column(name = "tipo_luna_oi_extra")
    private String tipoLunaOiExtra;

    @Column(name = "precio_luna_oi_extra", precision = 10, scale = 2)
    private BigDecimal precioLunaOiExtra = BigDecimal.ZERO;

    @Column(name = "es_luna_cliente_extra")
    private Boolean esLunaClienteExtra = false;

    @Column(name = "montura_extra")
    private String monturaExtra;

    @Column(name = "precio_montura_extra", precision = 10, scale = 2)
    private BigDecimal precioMonturaExtra = BigDecimal.ZERO;

    @Column(name = "es_montura_cliente_extra")
    private Boolean esMonturaClienteExtra = false;

    @Column(name = "observaciones_extra", columnDefinition = "TEXT")
    private String observacionesExtra;

    @Column(name = "especialista_extra", length = 100)
    private String especialistaExtra;
}