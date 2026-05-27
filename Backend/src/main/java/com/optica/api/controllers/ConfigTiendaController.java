package com.optica.api.controllers;

import com.optica.api.models.ConfigTienda;
import com.optica.api.models.enums.Tienda;
import com.optica.api.services.ConfigTiendaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/config-tienda")
public class ConfigTiendaController {

    @Autowired
    private ConfigTiendaService configService;

    @GetMapping("/{tienda}")
    public ResponseEntity<ConfigTienda> obtenerPorTienda(@PathVariable Tienda tienda) {
        return configService.obtenerPorTienda(tienda)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ConfigTienda> guardarConfig(@RequestBody ConfigTienda config) {
        return ResponseEntity.ok(configService.guardarConfig(config));
    }
}
