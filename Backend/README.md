# OpticGG ERP - Backend (Spring Boot)

Este es el motor central del sistema OpticGG ERP, encargado de la persistencia de datos, lógica de negocio y seguridad.

## Tecnologías
- **Framework**: Spring Boot 3.x
- **Lenguaje**: Java 17
- **Base de Datos**: MySQL 8.0
- **Seguridad**: Spring Security (JWT)
- **Lombok**: Para reducir el código boilerplate.

## Flujo de Trabajo Principal

### 1. Gestión de Ventas y Recetas
- El backend recibe un `NuevaVentaCompletaDTO` que consolida la información financiera y clínica.
- **Acción**: Crea una `Venta`, una `OrdenTrabajo` (Kanban), un `HistorialClinico` y registra un `MovimientoCaja`.
- **Sincronización**: Se asegura de que la fecha se asigne en Java antes de guardar para evitar valores nulos en la respuesta al frontend.

### 2. Historial del Paciente
- El `PacienteHistorialService` cruza datos de múltiples tablas para ofrecer una vista unificada.
- Se incluye la última medida detectada (incluyendo Esfera, Cilindro, Eje, Adición y DIP) junto con los materiales utilizados.

### 3. Dashboard y Analítica
- Provee estadísticas en tiempo real filtradas por tienda o globales.
- Cálculos de varianza porcentual diaria para Ingresos/Egresos.
- Agregaciones de ventas por vendedor en rangos de 15 y 30 días.

### 4. Gestión de Usuarios
- Permite la activación/desactivación lógica de personal mediante el campo `activo`.
- Los vendedores están vinculados a tiendas específicas (C1, C2, C3).

## Requisitos e Instalación
1. Clonar el repositorio.
2. Configurar `src/main/resources/application.properties` con las credenciales de MySQL.
3. Ejecutar `./mvnw spring-boot:run`.

## Base de Datos (Comandos Necesarios)
Si actualizas el sistema, aplica estos cambios:
```sql
ALTER TABLE ventas ADD COLUMN adicion VARCHAR(50) AFTER graduacion_oi;
ALTER TABLE ventas ADD COLUMN dip VARCHAR(50) AFTER adicion;
ALTER TABLE ordenes_trabajo ADD COLUMN adicion VARCHAR(50) AFTER graduacion_oi;
ALTER TABLE ordenes_trabajo ADD COLUMN dip VARCHAR(50) AFTER adicion;
ALTER TABLE historial_clinico ADD COLUMN adicion VARCHAR(50) AFTER graduacion_oi;
ALTER TABLE historial_clinico ADD COLUMN dip VARCHAR(50) AFTER adicion;
```
