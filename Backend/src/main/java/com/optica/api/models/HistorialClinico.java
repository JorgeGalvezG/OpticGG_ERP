package com.optica.api.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter @NoArgsConstructor
@Entity
@Table(name = "historial_clinico")
public class HistorialClinico {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Relación 1 a 1: Cada consulta tiene sus medidas exactas
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "consulta_id", nullable = false, unique = true)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Consulta consulta;

    @Column(name = "graduacion_od", length = 20)
    private String graduacionOd; // Ojo Derecho

    @Column(name = "graduacion_oi", length = 20)
    private String graduacionOi; // Ojo Izquierdo

    // CAMPOS MANUALES (Tu idea de agilidad)
    @Column(name = "tipo_luna_manual", length = 100)
    private String tipoLunaManual; // Ej: "Resina Antireflejo 1.56"

    @Column(name = "montura_manual", length = 100)
    private String monturaManual; // Ej: "Metalica Aviador"

    @Column(name = "tipo_luna", length = 100)
    private String tipoLuna;

    @Column(name = "es_luna_cliente")
    private Boolean esLunaCliente = false;

    @Column(length = 100)
    private String montura;

    @Column(name = "es_montura_cliente")
    private Boolean esMonturaCliente = false;

    @Column(columnDefinition = "TEXT")
    private String observaciones;

    // Relación al catálogo (Dejado como OPCIONAL para el futuro)
    @Column(name = "lente_id")
    private Long lenteId;
}