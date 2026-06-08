package com.optica.api.models;

import com.optica.api.models.enums.Tienda;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.math.BigDecimal;

@Getter @Setter @NoArgsConstructor
@Entity
@Table(name = "almacen")
public class Almacen {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "codigo_barras", nullable = false, unique = true, length = 50)
    private String codigoBarras;

    @Column(nullable = false, length = 200)
    private String nombre;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "categoria_id", nullable = false)
    private CategoriaProducto categoria;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "proveedor_id")
    private Proveedor proveedor;

    @Column(nullable = false)
    private Integer stock = 0;

    @Column(name = "foto_url")
    private String fotoUrl = "default_product.png";

    @Column(name = "precio_compra", precision = 10, scale = 2)
    private BigDecimal precioCompra = BigDecimal.ZERO;

    @Column(name = "precio_venta", nullable = false, precision = 10, scale = 2)
    private BigDecimal precioVenta = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Tienda tienda;
}