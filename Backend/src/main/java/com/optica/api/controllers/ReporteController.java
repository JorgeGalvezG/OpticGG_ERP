package com.optica.api.controllers;

import com.optica.api.repositories.MovimientoCajaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reportes")
@CrossOrigin("*")
public class ReporteController {

    @Autowired
    private MovimientoCajaRepository movimientoCajaRepository;

    @GetMapping("/mensual")
    public List<Map<String, Object>> getReporteMensual() {
        List<Object[]> resultados = movimientoCajaRepository.getReporteGlobalMensual();
        List<Map<String, Object>> response = new ArrayList<>();
        
        for (Object[] fila : resultados) {
            Map<String, Object> map = new HashMap<>();
            map.put("anio", fila[0]);
            map.put("mes", fila[1]);
            map.put("tienda", fila[2] != null ? fila[2].toString() : "N/A");
            map.put("ingresos", fila[3] != null ? fila[3] : BigDecimal.ZERO);
            map.put("egresos", fila[4] != null ? fila[4] : BigDecimal.ZERO);
            response.add(map);
        }
        return response;
    }

    @GetMapping("/diario")
    public List<Map<String, Object>> getReporteDiario() {
        List<Object[]> resultados = movimientoCajaRepository.getReporteGlobalDiario();
        List<Map<String, Object>> response = new ArrayList<>();
        
        for (Object[] fila : resultados) {
            Map<String, Object> map = new HashMap<>();
            map.put("dia", fila[0] != null ? fila[0].toString() : "");
            map.put("tienda", fila[1] != null ? fila[1].toString() : "N/A");
            map.put("ingresos", fila[2] != null ? fila[2] : BigDecimal.ZERO);
            map.put("egresos", fila[3] != null ? fila[3] : BigDecimal.ZERO);
            response.add(map);
        }
        return response;
    }
}
