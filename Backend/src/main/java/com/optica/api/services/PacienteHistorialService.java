package com.optica.api.services;

import com.optica.api.dto.HistorialPacienteDTO;
import com.optica.api.models.Consulta;
import com.optica.api.models.HistorialClinico;
import com.optica.api.models.Paciente;
import com.optica.api.models.Venta;
import com.optica.api.repositories.ConsultaRepository;
import com.optica.api.repositories.HistorialClinicoRepository;
import com.optica.api.repositories.PacienteRepository;
import com.optica.api.repositories.VentaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class PacienteHistorialService {

    @Autowired private PacienteRepository pacienteRepository;
    @Autowired private VentaRepository ventaRepository;
    @Autowired private ConsultaRepository consultaRepository;
    @Autowired private HistorialClinicoRepository historialRepository;

    public HistorialPacienteDTO obtenerHistorial(Long pacienteId) {

        // 1. Validar que exista el paciente
        Paciente paciente = pacienteRepository.findById(pacienteId)
                .orElseThrow(() -> new RuntimeException("Paciente no encontrado: " + pacienteId));

        // 2. Última venta — usamos List + Pageable (correcto en Spring Data 4.x)
        List<Venta> ventas = ventaRepository
                .findUltimaVentaPorPaciente(pacienteId, PageRequest.of(0, 1));
        Optional<Venta> ultimaVenta = ventas.isEmpty()
                ? Optional.empty()
                : Optional.of(ventas.get(0));

        // 3. Última consulta — misma estrategia
        List<Consulta> consultas = consultaRepository
                .findUltimaConsultaPorPaciente(pacienteId, PageRequest.of(0, 1));
        Optional<Consulta> ultimaConsulta = consultas.isEmpty()
                ? Optional.empty()
                : Optional.of(consultas.get(0));

        // 4. Historial clínico de esa consulta — aquí sí usamos Optional normal
        Optional<HistorialClinico> historial = ultimaConsulta
                .flatMap(c -> historialRepository.findByConsultaId(c.getId()));

        // 5. Construir el DTO
        HistorialPacienteDTO.HistorialPacienteDTOBuilder builder = HistorialPacienteDTO.builder()
                .pacienteId(paciente.getId())
                .nombreCompleto(paciente.getNombre() + " " + paciente.getApellidos());

        // Datos de la última venta
        ultimaVenta.ifPresent(v -> builder
                .ventaId(v.getId())
                .fechaVenta(v.getFecha() != null ? v.getFecha().toString() : "Sin fecha")
                .montoTotal(v.getMontoTotal())
                .montoSaldo(v.getMontoSaldo())
                .estadoPago(v.getEstado() != null ? v.getEstado().name() : "PENDIENTE")
                .metodoPago(v.getMetodoPago() != null ? v.getMetodoPago() : "No registrado")
        );

        // Datos de la última medida
        historial.ifPresent(h -> builder
                .graduacionOd(h.getGraduacionOd())
                .graduacionOi(h.getGraduacionOi())
                .tipoLuna(h.getTipoLuna())
                .esLunaCliente(h.getEsLunaCliente())
                .montura(h.getMontura())
                .esMonturaCliente(h.getEsMonturaCliente())
                .observaciones(h.getObservaciones())
        );

        ultimaConsulta.ifPresent(c -> builder
                .fechaConsulta(c.getFecha() != null ? c.getFecha().toString() : "Sin fecha")
        );

        return builder.build();
    }
}