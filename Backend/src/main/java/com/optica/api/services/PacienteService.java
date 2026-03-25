package com.optica.api.services;

import com.optica.api.models.Paciente;
import com.optica.api.repositories.PacienteRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

@Service
public class PacienteService {

    @Autowired
    private PacienteRepository pacienteRepository;

    public Page<Paciente> listarPacientes(int page, int size) {
        return pacienteRepository.findAll(PageRequest.of(page, size));
    }

    public Page<Paciente> buscarPacientes(String termino, int page, int size) {
        return pacienteRepository.findByNombreContainingIgnoreCaseOrApellidosContainingIgnoreCase(
                termino, termino, PageRequest.of(page, size));
    }

    @Transactional
    public Paciente guardarPaciente(Paciente paciente) {
        // Aquí en el futuro puedes agregar lógica como: si tiene compras > 1000, hacerlo destacado
        return pacienteRepository.save(paciente);
    }
}