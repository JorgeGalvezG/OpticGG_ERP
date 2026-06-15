-- 1. Soporte para Títulos en Compras
ALTER TABLE compras_proveedor ADD COLUMN titulo VARCHAR(200) AFTER proveedor_id;

-- 2. Tabla para múltiples contactos de proveedores
CREATE TABLE proveedor_contactos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    proveedor_id BIGINT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    cargo VARCHAR(50),
    CONSTRAINT fk_contacto_proveedor FOREIGN KEY (proveedor_id) REFERENCES proveedores (id) ON DELETE CASCADE
);

-- 3. (Opcional) Migrar contacto actual a la nueva tabla si existe
INSERT INTO proveedor_contactos (proveedor_id, nombre, telefono, cargo)
SELECT id, nombre_contacto, telefono, 'Principal' FROM proveedores WHERE nombre_contacto IS NOT NULL AND nombre_contacto <> '';
