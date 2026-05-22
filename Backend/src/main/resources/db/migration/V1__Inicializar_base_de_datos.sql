-- 1. Tabla de Usuarios
CREATE TABLE usuarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol ENUM('ADMIN', 'VENDEDOR') NOT NULL,
    tienda ENUM('C1', 'C2', 'C3'),
    activo TINYINT(1) DEFAULT 1
);

-- 2. Tabla de Pacientes
CREATE TABLE pacientes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    edad INT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    es_destacado TINYINT(1) DEFAULT 0,
    fecha_nacimiento DATE,
    tipo_destacado ENUM('AUTO', 'MANUAL'),
    tienda ENUM('C1', 'C2', 'C3'),
    INDEX idx_pacientes_apellidos (apellidos),
    INDEX idx_pacientes_nombre (nombre),
    INDEX idx_pacientes_telefono (telefono)
);

-- 3. Tabla de Proveedores
CREATE TABLE proveedores (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa VARCHAR(100) NOT NULL,
    nombre_contacto VARCHAR(100),
    telefono VARCHAR(20),
    ruc VARCHAR(20),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tienda ENUM('C1', 'C2', 'C3')
);

-- 4. Tabla de Lentes (Requerida por historial y ordenes)
CREATE TABLE lentes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    material VARCHAR(50) NOT NULL,
    tratamiento VARCHAR(100),
    precio DECIMAL(10,2) NOT NULL
);

-- 5. Tabla de Consultas
CREATE TABLE consultas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    paciente_id BIGINT NOT NULL,
    vendedor_id BIGINT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT,
    receta TEXT,
    recomendaciones TEXT,
    CONSTRAINT fk_cons_pac FOREIGN KEY (paciente_id) REFERENCES pacientes (id) ON DELETE CASCADE,
    CONSTRAINT fk_cons_vend FOREIGN KEY (vendedor_id) REFERENCES usuarios (id),
    INDEX idx_consultas_fecha (fecha)
);

-- 6. Tabla de Historial Clínico
CREATE TABLE historial_clinico (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    consulta_id BIGINT NOT NULL UNIQUE,
    graduacion_od VARCHAR(255),
    graduacion_oi VARCHAR(255),
    lente_id BIGINT,
    observaciones TEXT,
    tipo_luna VARCHAR(100),
    es_luna_cliente TINYINT(1) DEFAULT 0,
    montura VARCHAR(100),
    es_montura_cliente TINYINT(1) DEFAULT 0,
    CONSTRAINT fk_hist_cons FOREIGN KEY (consulta_id) REFERENCES consultas (id) ON DELETE CASCADE,
    CONSTRAINT fk_hist_lente FOREIGN KEY (lente_id) REFERENCES lentes (id)
);

-- 7. Tabla de Compras a Proveedores
CREATE TABLE compras_proveedor (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    proveedor_id BIGINT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    estado_pago ENUM('PENDIENTE', 'PAGADO') DEFAULT 'PENDIENTE',
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT,
    tienda ENUM('C1', 'C2', 'C3') NOT NULL,
    CONSTRAINT fk_compras_prov FOREIGN KEY (proveedor_id) REFERENCES proveedores (id)
);

-- 8. Tabla de Movimientos de Caja
CREATE TABLE movimientos_caja (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('ENTRADA', 'SALIDA') NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    descripcion TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_id BIGINT,
    tienda ENUM('C1', 'C2', 'C3') NOT NULL,
    CONSTRAINT fk_mov_user FOREIGN KEY (usuario_id) REFERENCES usuarios (id),
    INDEX idx_movimientos_fecha (fecha)
);

-- 9. Tabla de Ventas
CREATE TABLE ventas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    vendedor_id BIGINT NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    monto_a_cuenta DECIMAL(10,2) DEFAULT 0,
    monto_saldo DECIMAL(10,2) DEFAULT 0,
    estado ENUM('PENDIENTE', 'PARCIAL', 'PAGADO') DEFAULT 'PENDIENTE',
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tienda ENUM('C1', 'C2', 'C3') NOT NULL,
    metodo_pago VARCHAR(50) DEFAULT 'efectivo',
    CONSTRAINT fk_ventas_cli FOREIGN KEY (cliente_id) REFERENCES pacientes (id),
    CONSTRAINT fk_ventas_vend FOREIGN KEY (vendedor_id) REFERENCES usuarios (id),
    INDEX idx_ventas_fecha (fecha)
);

-- 10. Tabla de Órdenes de Trabajo
CREATE TABLE ordenes_trabajo (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    numero_orden VARCHAR(50) NOT NULL UNIQUE,
    estado ENUM('PENDIENTE', 'LABORATORIO', 'LISTO', 'ENTREGADO') DEFAULT 'PENDIENTE',
    monto_total DECIMAL(10,2) NOT NULL,
    monto_a_cuenta DECIMAL(10,2) DEFAULT 0,
    monto_saldo DECIMAL(10,2) DEFAULT 0,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lente_id BIGINT,
    tienda ENUM('C1', 'C2', 'C3') NOT NULL,
    venta_id BIGINT,
    CONSTRAINT fk_ord_cli FOREIGN KEY (cliente_id) REFERENCES pacientes (id),
    CONSTRAINT fk_ord_len FOREIGN KEY (lente_id) REFERENCES lentes (id),
    CONSTRAINT fk_orden_venta FOREIGN KEY (venta_id) REFERENCES ventas (id)
);

-- 11. Tabla de Configuración de Tienda
CREATE TABLE config_tienda (
    tienda ENUM('C1', 'C2', 'C3') PRIMARY KEY,
    nombre_optica VARCHAR(100) DEFAULT 'OPTICA CUBAS',
    ruc VARCHAR(20),
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    logo_url VARCHAR(255)
);
