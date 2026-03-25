package com.optica.api.controllers;

import com.optica.api.dto.OrdenActualizarDTO;
import com.optica.api.models.OrdenTrabajo;
import com.optica.api.models.enums.EstadoTrabajo;
import com.optica.api.models.enums.Tienda;
import com.optica.api.services.OrdenTrabajoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ordenes")
@CrossOrigin("*")
public class OrdenTrabajoController {

    @Autowired
    private OrdenTrabajoService ordenService;

    // URL de ejemplo: /api/ordenes/tienda/C1?estado=EN_PROCESO&page=0&size=10
    @GetMapping("/tienda/{tienda}")
    public ResponseEntity<Page<OrdenTrabajo>> listarOrdenes(
            @PathVariable Tienda tienda,
            @RequestParam EstadoTrabajo estado,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(ordenService.listarPorTiendaYEstado(tienda, estado, page, size));
    }

    @PutMapping("/{id}/estado")
    public ResponseEntity<OrdenTrabajo> actualizarEstado(
            @PathVariable Long id,
            @RequestBody OrdenActualizarDTO request) {
        return ResponseEntity.ok(ordenService.actualizarEstado(id, request));
    }
}