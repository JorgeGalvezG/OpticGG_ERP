package com.optica.api.services;

import com.optica.api.dto.VentaRequestDTO;
import com.optica.api.models.OrdenTrabajo;
import com.optica.api.models.Paciente;
import com.optica.api.models.Usuario;
import com.optica.api.models.Venta;
import com.optica.api.models.enums.EstadoTrabajo;
import com.optica.api.repositories.OrdenTrabajoRepository;
import com.optica.api.repositories.PacienteRepository;
import com.optica.api.repositories.UsuarioRepository;
import com.optica.api.repositories.VentaRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
public class VentaService {

    @Autowired private VentaRepository ventaRepository;
    @Autowired private OrdenTrabajoRepository ordenTrabajoRepository;
    @Autowired private PacienteRepository pacienteRepository;
    @Autowired private UsuarioRepository usuarioRepository;

    // @Transactional garantiza que si falla la Orden, no se guarde la Venta. ¡Todo o nada!
    @Transactional
    public Venta procesarNuevaVenta(VentaRequestDTO request) {

        // 1. Buscamos al Cliente y al Vendedor en la BD
        Paciente cliente = pacienteRepository.findById(request.getClienteId())
                .orElseThrow(() -> new RuntimeException("Cliente no encontrado"));

        Usuario vendedor = usuarioRepository.findById(request.getVendedorId())
                .orElseThrow(() -> new RuntimeException("Vendedor no encontrado"));

        // 2. Calculamos el saldo matemáticamente
        BigDecimal saldo = request.getMontoTotal().subtract(request.getMontoACuenta());

        // 3. Creamos y guardamos la VENTA
        Venta nuevaVenta = new Venta();
        nuevaVenta.setCliente(cliente);
        nuevaVenta.setVendedor(vendedor);
        nuevaVenta.setMontoTotal(request.getMontoTotal());
        nuevaVenta.setMontoACuenta(request.getMontoACuenta());
        nuevaVenta.setMontoSaldo(saldo);
        nuevaVenta.setTienda(request.getTienda());
        nuevaVenta.setEstado(EstadoTrabajo.EN_PROCESO);

        Venta ventaGuardada = ventaRepository.save(nuevaVenta);

        // 4. CREAMOS LA ORDEN DE TRABAJO AUTOMÁTICAMENTE
        OrdenTrabajo orden = new OrdenTrabajo();
        // Generamos un código único para la orden (Ej: OT-20260317-1245)
        String codigoOrden = "OT-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmm"));

        orden.setNumeroOrden(codigoOrden);
        orden.setCliente(cliente);
        orden.setVenta(ventaGuardada); // Enlazamos la orden a la venta
        orden.setMontoTotal(ventaGuardada.getMontoTotal());
        orden.setMontoACuenta(ventaGuardada.getMontoACuenta());
        orden.setMontoSaldo(ventaGuardada.getMontoSaldo());
        orden.setTienda(ventaGuardada.getTienda());
        orden.setEstado(EstadoTrabajo.EN_PROCESO);

        ordenTrabajoRepository.save(orden);

        return ventaGuardada;
    }
}