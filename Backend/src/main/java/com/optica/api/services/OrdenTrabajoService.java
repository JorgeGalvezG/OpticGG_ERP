package com.optica.api.services;

import com.optica.api.dto.OrdenActualizarDTO;
import com.optica.api.models.OrdenTrabajo;
import com.optica.api.models.enums.EstadoTrabajo;
import com.optica.api.models.enums.Tienda;
import com.optica.api.repositories.OrdenTrabajoRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class OrdenTrabajoService {

    @Autowired
    private OrdenTrabajoRepository ordenRepository;

    // Para la Vista de Lista
    public Page<OrdenTrabajo> listarPorTiendaYEstado(Tienda tienda, EstadoTrabajo estado, int page, int size) {
        return ordenRepository.findByTiendaAndEstado(tienda, estado, PageRequest.of(page, size));
    }

    // Para el Tablero Kanban
    public List<OrdenTrabajo> obtenerTodasPorTienda(Tienda tienda) {
        return ordenRepository.findByTienda(tienda);
    }

    @Transactional
    public OrdenTrabajo actualizarEstado(Long id, OrdenActualizarDTO request) {
        OrdenTrabajo orden = ordenRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Orden no encontrada"));

        orden.setEstado(request.getNuevoEstado());
        return ordenRepository.save(orden);
    }

    public List<OrdenTrabajo> obtenerHistorialPorPaciente(Long pacienteId) {
        return ordenRepository.findByClienteIdOrderByFechaDesc(pacienteId);
    }
}