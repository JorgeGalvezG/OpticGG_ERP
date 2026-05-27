package com.optica.api.services;

import com.optica.api.models.ConfigTienda;
import com.optica.api.models.enums.Tienda;
import com.optica.api.repositories.ConfigTiendaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class ConfigTiendaService {

    @Autowired
    private ConfigTiendaRepository configRepository;

    public Optional<ConfigTienda> obtenerPorTienda(Tienda tienda) {
        return configRepository.findById(tienda);
    }

    public ConfigTienda guardarConfig(ConfigTienda config) {
        return configRepository.save(config);
    }
}
