package com.optica.api.controllers;

import com.optica.api.dto.HistorialPacienteDTO;
import com.optica.api.models.Paciente;
import com.optica.api.models.enums.Tienda;
import com.optica.api.services.PacienteHistorialService;
import com.optica.api.services.PacienteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pacientes")
@CrossOrigin("*")
public class PacienteController {

    @Autowired
    private PacienteService pacienteService;

    @Autowired
    private PacienteHistorialService historialService;

    @GetMapping("/tienda/{tiendaStr}")
    public ResponseEntity<Page<Paciente>> listarPacientes(
            @PathVariable String tiendaStr,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        if (tiendaStr.equalsIgnoreCase("ALL")) {
            return ResponseEntity.ok(pacienteService.listarTodos(page, size));
        }
        return ResponseEntity.ok(pacienteService.listarPacientesPorTienda(Tienda.valueOf(tiendaStr.toUpperCase()), page, size));
    }

    @GetMapping("/buscar")
    public ResponseEntity<Page<Paciente>> buscar(
            @RequestParam String tienda,
            @RequestParam String termino,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        if (tienda.equalsIgnoreCase("ALL")) {
            return ResponseEntity.ok(pacienteService.buscarTodos(termino, page, size));
        }
        return ResponseEntity.ok(pacienteService.buscarPacientesPorTienda(termino, Tienda.valueOf(tienda.toUpperCase()), page, size));
    }

    // POS /api/pacientes
    @PostMapping
    public ResponseEntity<Paciente> crearPaciente(@RequestBody Paciente paciente) {
        return ResponseEntity.ok(pacienteService.guardarPaciente(paciente));
    }
    // PUT /api/pacientes/
    @PutMapping("/{id}")
    public ResponseEntity<Paciente> actualizarPaciente(
            @PathVariable Long id,
            @RequestBody Paciente paciente) {
        return ResponseEntity.ok(pacienteService.actualizarPaciente(id, paciente));
    }
    // GET: /api/pacientes/tienda/C1/vip
    @GetMapping("/tienda/{tiendaStr}/vip")
    public ResponseEntity<List<Paciente>> listarVip(@PathVariable String tiendaStr) {
        if (tiendaStr.equalsIgnoreCase("ALL")) {
            return ResponseEntity.ok(pacienteService.listarTodosVip());
        }
        return ResponseEntity.ok(pacienteService.listarVipPorTienda(Tienda.valueOf(tiendaStr.toUpperCase())));
    }

    @GetMapping("/{id}/historial")
    public ResponseEntity<HistorialPacienteDTO> obtenerHistorial(@PathVariable Long id) {
        return ResponseEntity.ok(historialService.obtenerHistorial(id));
    }
}