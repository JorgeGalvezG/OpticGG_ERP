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

@Service
public class OrdenTrabajoService {

    @Autowired
    private OrdenTrabajoRepository ordenRepository;

    public Page<OrdenTrabajo> listarPorTiendaYEstado(Tienda tienda, EstadoTrabajo estado, int page, int size) {
        return ordenRepository.findByTiendaAndEstado(tienda, estado, PageRequest.of(page, size));
    }

    // @Transactional asegura que si la base de datos se corta a la mitad, no guarde datos corruptos
    @Transactional
    public OrdenTrabajo actualizarEstado(Long id, OrdenActualizarDTO request) {
        OrdenTrabajo orden = ordenRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Orden no encontrada"));

        orden.setEstado(request.getNuevoEstado());
        return ordenRepository.save(orden);
    }
}