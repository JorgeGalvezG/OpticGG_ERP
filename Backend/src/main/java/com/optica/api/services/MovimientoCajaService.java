package com.optica.api.services;

import com.optica.api.dto.NuevoMovimientoDTO;
import com.optica.api.models.MovimientoCaja;
import com.optica.api.models.Usuario;
import com.optica.api.models.enums.Tienda;
import com.optica.api.repositories.MovimientoCajaRepository;
import com.optica.api.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MovimientoCajaService {

    @Autowired private MovimientoCajaRepository cajaRepository;
    @Autowired private UsuarioRepository usuarioRepository;

    // 1. Obtener el historial de la caja (los más recientes primero)
    public List<MovimientoCaja> obtenerPorTienda(Tienda tienda) {
        return cajaRepository.findByTiendaOrderByFechaDesc(tienda);
    }


    // 2. Registrar un gasto o ingreso manual
    public MovimientoCaja registrarMovimientoManual(NuevoMovimientoDTO dto) {
        Usuario usuario = usuarioRepository.findById(dto.getUsuarioId())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        MovimientoCaja movimiento = new MovimientoCaja();
        movimiento.setTipo(dto.getTipo());
        movimiento.setMonto(dto.getMonto());
        movimiento.setDescripcion(dto.getDescripcion());
        movimiento.setUsuario(usuario);
        movimiento.setTienda(dto.getTienda());

        return cajaRepository.save(movimiento);
    }

}