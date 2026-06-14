package com.optica.api.controllers;

import com.optica.api.dto.NuevaVentaCompletaDTO;
import com.optica.api.models.Venta;
import com.optica.api.services.VentaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ventas")
@CrossOrigin("*")
public class VentaController {

    @Autowired private VentaService ventaService;

    @PostMapping("/nueva")
    public ResponseEntity<Venta> crearVentaGigante(@RequestBody NuevaVentaCompletaDTO request) {
        return ResponseEntity.ok(ventaService.procesarNuevaVenta(request));
    }

    @PostMapping("/pago-saldo")
    public ResponseEntity<Venta> registrarPagoSaldo(@RequestBody com.optica.api.dto.PagoSaldoDTO request) {
        return ResponseEntity.ok(ventaService.registrarPagoSaldo(request));
    }

    @GetMapping("/buscar/{codigo}")
    public ResponseEntity<Venta> buscarPorCodigo(@PathVariable String codigo) {
        try {
            return ResponseEntity.ok(ventaService.buscarPorCodigo(codigo));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}