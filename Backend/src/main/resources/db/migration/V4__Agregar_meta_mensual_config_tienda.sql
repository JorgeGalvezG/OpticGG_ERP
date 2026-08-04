-- Migration V4: Agregar meta mensual a config_tienda
ALTER TABLE config_tienda ADD COLUMN meta_mensual DECIMAL(10,2) NOT NULL DEFAULT 15000.00;

-- Establecer metas específicas de prueba por tienda
UPDATE config_tienda SET meta_mensual = 30000.00 WHERE tienda = 'C1';
UPDATE config_tienda SET meta_mensual = 20000.00 WHERE tienda = 'C2';
UPDATE config_tienda SET meta_mensual = 20000.00 WHERE tienda = 'C3';
