package com.optica.api.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.optica.api.models.enums.Tienda;
import com.optica.api.models.enums.TipoDestacado;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter @Setter @NoArgsConstructor
@Entity
@Table(name = "pacientes")
public class Paciente {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String nombre;

    @Column(nullable = false, length = 100)
    private String apellidos;

    @Column(length = 15)
    private String dni;

    @Column(length = 20)
    private String telefono;

    private Integer edad;

    @Column(name = "fecha_nacimiento")
    private LocalDate fechaNacimiento;

    @Column(name = "es_destacado")
    private Boolean esDestacado = false;

    @Enumerated(EnumType.STRING)
    private Tienda tienda;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_destacado")
    private TipoDestacado tipoDestacado;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy HH:mm:ss")
    @Column(name = "fecha_registro", updatable = false, insertable = false)
    private LocalDateTime fechaRegistro;
}