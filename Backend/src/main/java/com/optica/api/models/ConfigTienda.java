package com.optica.api.models;

import com.optica.api.models.enums.Tienda;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter @Setter @NoArgsConstructor
@Entity
@Table(name = "config_tienda")
public class ConfigTienda {

    @Id
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Tienda tienda;

    @Column(name = "nombre_optica", length = 100)
    private String nombreOptica;

    @Column(length = 20)
    private String ruc;

    @Column(length = 200)
    private String direccion;

    @Column(length = 20)
    private String telefono;

    @Column(name = "logo_url", length = 255)
    private String logoUrl;
}