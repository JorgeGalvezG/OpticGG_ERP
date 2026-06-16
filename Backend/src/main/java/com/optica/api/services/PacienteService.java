package com.optica.api.services;

import com.optica.api.models.Paciente;
import com.optica.api.models.enums.Tienda;
import com.optica.api.repositories.PacienteRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class PacienteService {

    @Autowired
    private PacienteRepository pacienteRepository;

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
}