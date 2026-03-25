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
@Table(name = "ventas")
public class Venta {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // FetchType.LAZY e IgnoreProperties es el combo perfecto para velocidad sin errores
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cliente_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Paciente cliente;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vendedor_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Usuario vendedor;

    @Column(name = "monto_total", nullable = false, precision = 10, scale = 2)
    private BigDecimal montoTotal;

    @Column(name = "monto_a_cuenta", precision = 10, scale = 2)
    private BigDecimal montoACuenta = BigDecimal.ZERO;

    @Column(name = "monto_saldo", precision = 10, scale = 2)
    private BigDecimal montoSaldo = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    private EstadoTrabajo estado = EstadoTrabajo.EN_PROCESO;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Tienda tienda;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy HH:mm:ss")
    @Column(updatable = false, insertable = false)
    private LocalDateTime fecha;
}