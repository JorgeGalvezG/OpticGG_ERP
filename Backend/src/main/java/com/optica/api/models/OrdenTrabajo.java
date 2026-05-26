package com.optica.api.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.optica.api.models.enums.EstadoTrabajo;
import com.optica.api.models.enums.Tienda;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter @NoArgsConstructor
@Entity
@Table(name = "ordenes_trabajo")
public class OrdenTrabajo {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "numero_orden", nullable = false, unique = true, length = 50)
    private String numeroOrden;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cliente_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Paciente cliente;

    // Enlazamos la Orden con su Ticket de Venta
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venta_id")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Venta venta;

    @Enumerated(EnumType.STRING)
    private EstadoTrabajo estado = EstadoTrabajo.PENDIENTE;

    @Column(name = "monto_total", nullable = false, precision = 10, scale = 2)
    private BigDecimal montoTotal;

    @Column(name = "monto_a_cuenta", precision = 10, scale = 2)
    private BigDecimal montoACuenta = BigDecimal.ZERO;

    @Column(name = "monto_saldo", precision = 10, scale = 2)
    private BigDecimal montoSaldo = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Tienda tienda;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy HH:mm:ss")
    @Column(updatable = false)
    private LocalDateTime fecha;

    // --- NUEVOS CAMPOS PARA HISTORIAL Y TICKET ---
    @Column(name = "graduacion_od")
    private String graduacionOd;

    @Column(name = "graduacion_oi")
    private String graduacionOi;

    @Column(name = "adicion")
    private String adicion;

    @Column(name = "dip")
    private String dip;

    @Column(name = "tipo_luna")
    private String tipoLuna;

    @Column(name = "es_luna_cliente")
    private Boolean esLunaCliente = false;

    @Column(name = "montura")
    private String montura;

    @Column(name = "es_montura_cliente")
    private Boolean esMonturaCliente = false;

    @Column(columnDefinition = "TEXT")
    private String observaciones;

    @Column(name = "metodo_pago", length = 50)
    private String metodoPago;
}