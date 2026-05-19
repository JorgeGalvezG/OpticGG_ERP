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

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "consulta_id", nullable = false, unique = true)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Consulta consulta;

    @Column(name = "graduacion_od", length = 255)
    private String graduacionOd;

    @Column(name = "graduacion_oi", length = 255)
    private String graduacionOi;

    @Column(name = "tipo_luna", length = 100)
    private String tipoLuna;

    @Column(name = "es_luna_cliente")
    private Boolean esLunaCliente = false;

    @Column(name = "montura", length = 100)
    private String montura;

    @Column(name = "es_montura_cliente")
    private Boolean esMonturaCliente = false;

    @Column(columnDefinition = "TEXT")
    private String observaciones;

    @Column(name = "lente_id")
    private Long lenteId;
}