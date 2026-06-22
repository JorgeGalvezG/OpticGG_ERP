package com.optica.api.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.optica.api.models.enums.EstadoPago;
import com.optica.api.models.enums.Tienda;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter @NoArgsConstructor
@Entity
@Table(name = "compras_proveedor")
public class CompraProveedor {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Relación: Muchas compras pertenecen a 1 proveedor
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "proveedor_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Proveedor proveedor;

    @Column(length = 200)
    private String titulo;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal monto;

    @Column(name = "monto_pagado", precision = 10, scale = 2)
    private BigDecimal montoPagado = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado_pago")
    private EstadoPago estadoPago = EstadoPago.PENDIENTE;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado_entrega")
    private com.optica.api.models.enums.EstadoEntrega estadoEntrega = com.optica.api.models.enums.EstadoEntrega.SOLICITADO;

    @Column(columnDefinition = "TEXT")
    private String descripcion;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Tienda tienda;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy HH:mm:ss")
    @Column(name = "fecha_pedido", updatable = false, insertable = false)
    private LocalDateTime fechaPedido;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy HH:mm:ss")
    @Column(name = "fecha_entrega")
    private LocalDateTime fechaEntrega;

    @OneToMany(mappedBy = "compra", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties("compra")
    private java.util.List<CompraProveedorDetalle> detalles = new java.util.ArrayList<>();
}