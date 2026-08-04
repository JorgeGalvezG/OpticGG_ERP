package com.optica.api.services;

import com.optica.api.models.Paciente;
import com.optica.api.models.Consulta;
import com.optica.api.models.HistorialClinico;
import com.optica.api.models.Usuario;
import com.optica.api.models.enums.Tienda;
import com.optica.api.dto.PacienteReactivarDTO;
import com.optica.api.dto.PacienteConMedidaDTO;
import com.optica.api.repositories.PacienteRepository;
import com.optica.api.repositories.ConsultaRepository;
import com.optica.api.repositories.HistorialClinicoRepository;
import com.optica.api.repositories.UsuarioRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

@Service
public class PacienteService {

    @Autowired
    private PacienteRepository pacienteRepository;

    @Autowired
    private ConsultaRepository consultaRepository;

    @Autowired
    private HistorialClinicoRepository historialClinicoRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    // Listar pacientes filtrados por tienda
    public Page<Paciente> listarPacientesPorTienda(Tienda tienda, int page, int size) {
        return pacienteRepository.findByTienda(tienda, PageRequest.of(page, size));
    }

    // Buscar pacientes filtrados por tienda
    public Page<Paciente> buscarPacientesPorTienda(String termino, Tienda tienda, int page, int size) {
        return pacienteRepository.buscarPorTerminoYTienda(termino, tienda, PageRequest.of(page, size));
    }

    @Transactional
    public Paciente guardarPaciente(Paciente paciente) {
        // Asignar fecha de registro actual si es un paciente nuevo
        if (paciente.getId() == null) {
            paciente.setFechaRegistro(LocalDateTime.now());
        }

        // Todo paciente nuevo entra sin ser VIP por defecto
        if (paciente.getEsDestacado() == null) {
            paciente.setEsDestacado(false);
        }

        // Aquí en el futuro puedes agregar la lógica de: si tiene compras > 1000, hacerlo destacado
        return pacienteRepository.save(paciente);
    }
    @Transactional
    public Paciente actualizarPaciente(Long id, Paciente pacienteActualizado) {
        // Buscamos si el paciente existe en la BD
        Paciente pacienteExistente = pacienteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Paciente no encontrado"));

        // Actualizamos los campos
        pacienteExistente.setNombre(pacienteActualizado.getNombre());
        pacienteExistente.setApellidos(pacienteActualizado.getApellidos());
        pacienteExistente.setDni(pacienteActualizado.getDni());
        pacienteExistente.setTelefono(pacienteActualizado.getTelefono());
        pacienteExistente.setEdad(pacienteActualizado.getEdad());
        pacienteExistente.setFechaNacimiento(pacienteActualizado.getFechaNacimiento());
        // PacienteService.java — método actualizarPaciente
        pacienteExistente.setEsDestacado(pacienteActualizado.getEsDestacado()); // ← esto faltaba

        // Guardamos los cambios
        return pacienteRepository.save(pacienteExistente);
    }
    public List<Paciente> listarVipPorTienda(Tienda tienda) {
        return pacienteRepository.findByTiendaAndEsDestacadoTrue(tienda);
    }

    public Page<Paciente> listarTodos(int page, int size) {
        return pacienteRepository.findAll(PageRequest.of(page, size));
    }

    public Page<Paciente> buscarTodos(String termino, int page, int size) {
        return pacienteRepository.buscarPorTerminoGlobal(termino, PageRequest.of(page, size));
    }

    public List<Paciente> listarTodosVip() {
        return pacienteRepository.findByEsDestacadoTrue();
    }

    public List<PacienteReactivarDTO> listarPacientesPorReactivar(String tiendaStr) {
        java.time.LocalDateTime fechaLimite = java.time.LocalDateTime.now().minusMonths(12);
        if (tiendaStr.equalsIgnoreCase("ALL")) {
            return pacienteRepository.findPacientesPorReactivarGlobal(fechaLimite);
        } else {
            return pacienteRepository.findPacientesPorReactivar(Tienda.valueOf(tiendaStr.toUpperCase()), fechaLimite);
        }
    }

    @Transactional
    public Paciente guardarPacienteConMedida(PacienteConMedidaDTO dto) {
        Paciente paciente = new Paciente();
        paciente.setNombre(dto.getNombre());
        paciente.setApellidos(dto.getApellidos());
        paciente.setDni(dto.getDni());
        paciente.setTelefono(dto.getTelefono());
        paciente.setEdad(dto.getEdad());
        paciente.setFechaNacimiento(dto.getFechaNacimiento());
        paciente.setEsDestacado(dto.getEsDestacado() != null ? dto.getEsDestacado() : false);
        paciente.setTienda(dto.getTienda() != null ? dto.getTienda() : Tienda.C1);
        paciente.setFechaRegistro(LocalDateTime.now());

        Paciente savedPaciente = pacienteRepository.save(paciente);

        if (tieneMedidaVisual(dto)) {
            guardarNuevaMedida(savedPaciente, dto);
        }

        return savedPaciente;
    }

    @Transactional
    public Paciente actualizarPacienteConMedida(Long id, PacienteConMedidaDTO dto) {
        Paciente pacienteExistente = pacienteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Paciente no encontrado"));

        pacienteExistente.setNombre(dto.getNombre());
        pacienteExistente.setApellidos(dto.getApellidos());
        pacienteExistente.setDni(dto.getDni());
        pacienteExistente.setTelefono(dto.getTelefono());
        pacienteExistente.setEdad(dto.getEdad());
        pacienteExistente.setFechaNacimiento(dto.getFechaNacimiento());
        if (dto.getEsDestacado() != null) {
            pacienteExistente.setEsDestacado(dto.getEsDestacado());
        }
        if (dto.getTienda() != null) {
            pacienteExistente.setTienda(dto.getTienda());
        }

        Paciente savedPaciente = pacienteRepository.save(pacienteExistente);

        if (tieneMedidaVisual(dto)) {
            List<Consulta> consultas = consultaRepository.findUltimaConsultaPorPaciente(id, PageRequest.of(0, 1));
            boolean requiereNuevaMedida = true;

            if (!consultas.isEmpty()) {
                Consulta ultimaConsulta = consultas.get(0);
                java.util.Optional<HistorialClinico> ultimoHistorialOpt = historialClinicoRepository.findByConsultaId(ultimaConsulta.getId());
                
                if (ultimoHistorialOpt.isPresent()) {
                    HistorialClinico ultimoHistorial = ultimoHistorialOpt.get();
                    boolean cambio = !Objects.equals(dto.getGraduacionOd(), ultimoHistorial.getGraduacionOd())
                            || !Objects.equals(dto.getAvOd(), ultimoHistorial.getAvOd())
                            || !Objects.equals(dto.getGraduacionOi(), ultimoHistorial.getGraduacionOi())
                            || !Objects.equals(dto.getAvOi(), ultimoHistorial.getAvOi())
                            || !Objects.equals(dto.getAdicion(), ultimoHistorial.getAdicion())
                            || !Objects.equals(dto.getDip(), ultimoHistorial.getDip())
                            || !Objects.equals(dto.getTipoLuna(), ultimoHistorial.getTipoLuna())
                            || !Objects.equals(dto.getMontura(), ultimoHistorial.getMontura())
                            || !Objects.equals(dto.getObservaciones(), ultimoHistorial.getObservaciones())
                            || !Objects.equals(dto.getEspecialista(), ultimoHistorial.getEspecialista());
                    
                    if (!cambio) {
                        requiereNuevaMedida = false;
                    }
                }
            }

            if (requiereNuevaMedida) {
                guardarNuevaMedida(savedPaciente, dto);
            }
        }

        return savedPaciente;
    }

    private boolean tieneMedidaVisual(PacienteConMedidaDTO dto) {
        return (dto.getGraduacionOd() != null && !dto.getGraduacionOd().trim().isEmpty())
                || (dto.getGraduacionOi() != null && !dto.getGraduacionOi().trim().isEmpty())
                || (dto.getTipoLuna() != null && !dto.getTipoLuna().trim().isEmpty())
                || (dto.getMontura() != null && !dto.getMontura().trim().isEmpty());
    }

    private void guardarNuevaMedida(Paciente paciente, PacienteConMedidaDTO dto) {
        Usuario vendedor = null;
        if (dto.getVendedorId() != null) {
            vendedor = usuarioRepository.findById(dto.getVendedorId()).orElse(null);
        }
        if (vendedor == null) {
            vendedor = usuarioRepository.findAll().stream().findFirst().orElseThrow(() -> new RuntimeException("No se encontró ningún usuario vendedor en el sistema"));
        }

        Consulta consulta = new Consulta();
        consulta.setPaciente(paciente);
        consulta.setVendedor(vendedor);
        consulta.setMotivo("Registro Clínico de Medida");
        consulta.setFecha(LocalDateTime.now());
        consulta = consultaRepository.save(consulta);

        HistorialClinico hc = new HistorialClinico();
        hc.setConsulta(consulta);
        hc.setGraduacionOd(dto.getGraduacionOd());
        hc.setAvOd(dto.getAvOd());
        hc.setGraduacionOi(dto.getGraduacionOi());
        hc.setAvOi(dto.getAvOi());
        hc.setAdicion(dto.getAdicion());
        hc.setDip(dto.getDip());
        hc.setTipoLuna(dto.getTipoLuna());
        hc.setMontura(dto.getMontura());
        hc.setObservaciones(dto.getObservaciones());
        hc.setEspecialista(dto.getEspecialista());
        historialClinicoRepository.save(hc);
    }
}