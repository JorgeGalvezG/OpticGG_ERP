package com.optica.api.controllers;

import com.optica.api.dto.NuevoMovimientoDTO;
import com.optica.api.models.MovimientoCaja;
import com.optica.api.models.enums.Tienda;
import com.optica.api.services.MovimientoCajaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/caja")
@CrossOrigin("*")
public class MovimientoCajaController {

    @Autowired private MovimientoCajaService cajaService;

    // GET: /api/caja/tienda/C1
    @GetMapping("/tienda/{tiendaStr}")
    public ResponseEntity<List<MovimientoCaja>> obtenerMovimientos(@PathVariable String tiendaStr) {
        if (tiendaStr.equalsIgnoreCase("ALL")) {
            return ResponseEntity.ok(cajaService.obtenerTodos());
        }
        Tienda tienda = Tienda.valueOf(tiendaStr.toUpperCase());
        return ResponseEntity.ok(cajaService.obtenerPorTienda(tienda));
    }

    // POST: /api/caja/manual
    @PostMapping("/manual")
    public ResponseEntity<MovimientoCaja> registrarMovimiento(@RequestBody NuevoMovimientoDTO request) {
        return ResponseEntity.ok(cajaService.registrarMovimientoManual(request));
    }
}