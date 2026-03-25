-- 1. Tabla de Usuarios (Autenticación)
CREATE TABLE usuarios (
                          id BIGINT AUTO_INCREMENT PRIMARY KEY,
                          username VARCHAR(50) UNIQUE NOT NULL,
                          password VARCHAR(255) NOT NULL,
                          rol ENUM('ADMIN', 'VENDEDOR') NOT NULL,
                          tienda ENUM('C1', 'C2' , 'C3'),
                          activo BOOLEAN DEFAULT TRUE
);

-- 2. Tabla de Pacientes (Con campos VIP)
CREATE TABLE pacientes (
                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                           nombre VARCHAR(100) NOT NULL,
                           apellidos VARCHAR(100) NOT NULL,
                           telefono VARCHAR(20),
                           edad INT,
                           fecha_nacimiento DATE,
                           es_destacado BOOLEAN DEFAULT FALSE,
                           tipo_destacado ENUM('AUTO', 'MANUAL'),
                           fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabla de Lentes (Catálogo Opcional)
CREATE TABLE lentes (
                        id BIGINT AUTO_INCREMENT PRIMARY KEY,
                        tipo VARCHAR(50) NOT NULL,
                        material VARCHAR(50) NOT NULL,
                        tratamiento VARCHAR(100),
                        precio DECIMAL(10,2) NOT NULL
);

-- 4. Tabla de Consultas (Motor Clínico)
CREATE TABLE consultas (
                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                           paciente_id BIGINT NOT NULL,
                           vendedor_id BIGINT NOT NULL,
                           fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                           motivo TEXT,
                           receta TEXT,
                           recomendaciones TEXT,
                           FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
                           FOREIGN KEY (vendedor_id) REFERENCES usuarios(id)
);

-- 5. Tabla de Historial Clínico (Medidas y Detalles Flexibles)
CREATE TABLE historial_clinico (
                                   id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                   consulta_id BIGINT NOT NULL UNIQUE,
                                   graduacion_od VARCHAR(20),
                                   graduacion_oi VARCHAR(20),
                                   tipo_luna VARCHAR(100),
                                   es_luna_cliente BOOLEAN DEFAULT FALSE,
                                   montura VARCHAR(100),
                                   es_montura_cliente BOOLEAN DEFAULT FALSE,
                                   observaciones TEXT,
                                   lente_id BIGINT,
                                   FOREIGN KEY (consulta_id) REFERENCES consultas(id) ON DELETE CASCADE,
                                   FOREIGN KEY (lente_id) REFERENCES lentes(id)
);

-- 6. Tabla de Proveedores (Perfil del Contacto)
CREATE TABLE proveedores (
                             id BIGINT AUTO_INCREMENT PRIMARY KEY,
                             nombre_empresa VARCHAR(100) NOT NULL,
                             nombre_contacto VARCHAR(100),
                             telefono VARCHAR(20),
                             ruc VARCHAR(20),
                             fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Tabla de Compras a Proveedores (Historial de Pedidos)
CREATE TABLE compras_proveedor (
                                   id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                   proveedor_id BIGINT NOT NULL,
                                   monto DECIMAL(10,2) NOT NULL,
                                   estado_pago ENUM('PENDIENTE', 'PAGADO') DEFAULT 'PENDIENTE',
                                   fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                   descripcion TEXT,
                                   tienda ENUM('C1','C2','C3') NOT NULL,
                                   FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
);

-- 8. Tabla de Movimientos de Caja
CREATE TABLE movimientos_caja (
                                  id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                  tipo ENUM('ENTRADA','SALIDA') NOT NULL,
                                  monto DECIMAL(10,2) NOT NULL,
                                  descripcion TEXT,
                                  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                  usuario_id BIGINT,
                                  tienda ENUM('C1','C2','C3') NOT NULL,
                                  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- 9. Tabla de Ventas
CREATE TABLE ventas (
                        id BIGINT AUTO_INCREMENT PRIMARY KEY,
                        cliente_id BIGINT NOT NULL,
                        vendedor_id BIGINT NOT NULL,
                        monto_total DECIMAL(10,2) NOT NULL,
                        monto_a_cuenta DECIMAL(10,2) DEFAULT 0,
                        monto_saldo DECIMAL(10,2) DEFAULT 0,
                        estado ENUM('EN_PROCESO','LISTO','ENTREGADO') DEFAULT 'EN_PROCESO',
                        fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        tienda ENUM('C1','C2','C3') NOT NULL,
                        FOREIGN KEY (cliente_id) REFERENCES pacientes(id),
                        FOREIGN KEY (vendedor_id) REFERENCES usuarios(id)
);

-- 10. Tabla de Órdenes de Trabajo
CREATE TABLE ordenes_trabajo (
                                 id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                 cliente_id BIGINT NOT NULL,
                                 venta_id BIGINT,
                                 numero_orden VARCHAR(50) UNIQUE NOT NULL,
                                 estado ENUM('EN_PROCESO','LISTO','ENTREGADO') DEFAULT 'EN_PROCESO',
                                 monto_total DECIMAL(10,2) NOT NULL,
                                 monto_a_cuenta DECIMAL(10,2) DEFAULT 0,
                                 monto_saldo DECIMAL(10,2) DEFAULT 0,
                                 fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                 lente_id BIGINT,
                                 tienda ENUM('C1','C2','C3') NOT NULL,
                                 FOREIGN KEY (cliente_id) REFERENCES pacientes(id),
                                 FOREIGN KEY (venta_id) REFERENCES ventas(id),
                                 FOREIGN KEY (lente_id) REFERENCES lentes(id)
);

-- INDICES PARA OPTIMIZACION DE BUSQUEDAS (Ultra Rápidas)
CREATE INDEX idx_pacientes_apellidos ON pacientes(apellidos);
CREATE INDEX idx_pacientes_nombre ON pacientes(nombre);
CREATE INDEX idx_pacientes_telefono ON pacientes(telefono);
CREATE INDEX idx_consultas_fecha ON consultas(fecha DESC);
CREATE INDEX idx_ventas_fecha ON ventas(fecha DESC);
CREATE INDEX idx_movimientos_fecha ON movimientos_caja(fecha DESC);