package com.optica.api.controllers;

import com.optica.api.models.CompraProveedor;
import com.optica.api.models.enums.Tienda;
import com.optica.api.services.CompraProveedorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/compras")
@CrossOrigin("*")
public class CompraProveedorController {

    @Autowired private CompraProveedorService compraService;

    // GET /api/compras/tienda/C1
    @GetMapping("/tienda/{tienda}")
    public ResponseEntity<List<CompraProveedor>> listarPorTienda(@PathVariable Tienda tienda) {
        return ResponseEntity.ok(compraService.listarPorTienda(tienda));
    }

    // GET /api/compras/proveedor/3
    @GetMapping("/proveedor/{proveedorId}")
    public ResponseEntity<List<CompraProveedor>> listarPorProveedor(@PathVariable Long proveedorId) {
        return ResponseEntity.ok(compraService.listarPorProveedor(proveedorId));
    }

    // GET /api/compras/tienda/C1/pendientes
    @GetMapping("/tienda/{tienda}/pendientes")
    public ResponseEntity<List<CompraProveedor>> listarPendientes(@PathVariable Tienda tienda) {
        return ResponseEntity.ok(compraService.listarPendientesPorTienda(tienda));
    }

    // POST /api/compras
    @PostMapping
    public ResponseEntity<CompraProveedor> registrarCompra(@RequestBody CompraProveedor compra) {
        return ResponseEntity.ok(compraService.registrarCompra(compra));
    }

    // PUT /api/compras/5/pagar
    @PutMapping("/{id}/pagar")
    public ResponseEntity<CompraProveedor> marcarComoPagado(@PathVariable Long id) {
        return ResponseEntity.ok(compraService.marcarComoPagado(id));
    }
}
