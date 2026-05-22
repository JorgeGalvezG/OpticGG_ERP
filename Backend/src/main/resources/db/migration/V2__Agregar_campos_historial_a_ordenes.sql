-- Agregar campos de historial clínico a la tabla de ventas
ALTER TABLE ventas 
ADD COLUMN graduacion_od VARCHAR(255),
ADD COLUMN graduacion_oi VARCHAR(255),
ADD COLUMN tipo_luna VARCHAR(100),
ADD COLUMN es_luna_cliente TINYINT(1) DEFAULT 0,
ADD COLUMN montura VARCHAR(100),
ADD COLUMN es_montura_cliente TINYINT(1) DEFAULT 0,
ADD COLUMN observaciones TEXT;

-- Agregar campos de historial clínico a la tabla de órdenes de trabajo
ALTER TABLE ordenes_trabajo 
ADD COLUMN graduacion_od VARCHAR(255),
ADD COLUMN graduacion_oi VARCHAR(255),
ADD COLUMN tipo_luna VARCHAR(100),
ADD COLUMN es_luna_cliente TINYINT(1) DEFAULT 0,
ADD COLUMN montura VARCHAR(100),
ADD COLUMN es_montura_cliente TINYINT(1) DEFAULT 0,
ADD COLUMN observaciones TEXT,
ADD COLUMN metodo_pago VARCHAR(50);
