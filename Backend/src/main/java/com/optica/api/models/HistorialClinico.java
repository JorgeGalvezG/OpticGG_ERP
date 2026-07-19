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

    @Column(name = "av_od", length = 50)
    private String avOd;

    @Column(name = "graduacion_oi", length = 255)
    private String graduacionOi;

    @Column(name = "av_oi", length = 50)
    private String avOi;

    @Column(name = "adicion", length = 50)
    private String adicion;

    @Column(name = "dip", length = 50)
    private String dip;

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

    @Column(name = "especialista", length = 100)
    private String especialista;

    // --- CAMPOS DE COMPRA EXTRA ---
    @Column(name = "tiene_compra_extra")
    private Boolean tieneCompraExtra = false;

    @Column(name = "graduacion_od_extra", length = 255)
    private String graduacionOdExtra;

    @Column(name = "av_od_extra", length = 50)
    private String avOdExtra;

    @Column(name = "graduacion_oi_extra", length = 255)
    private String graduacionOiExtra;

    @Column(name = "av_oi_extra", length = 50)
    private String avOiExtra;

    @Column(name = "adicion_extra", length = 50)
    private String adicionExtra;

    @Column(name = "dip_extra", length = 50)
    private String dipExtra;

    @Column(name = "tipo_luna_extra", length = 100)
    private String tipoLunaExtra;

    @Column(name = "es_luna_cliente_extra")
    private Boolean esLunaClienteExtra = false;

    @Column(name = "montura_extra", length = 100)
    private String monturaExtra;

    @Column(name = "es_montura_cliente_extra")
    private Boolean esMonturaClienteExtra = false;

    @Column(name = "observaciones_extra", columnDefinition = "TEXT")
    private String observacionesExtra;

    @Column(name = "especialista_extra", length = 100)
    private String especialistaExtra;
}