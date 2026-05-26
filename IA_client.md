# Guía Maestro para IA - OpticGG ERP

Este documento contiene toda la información técnica y lógica necesaria para que un agente de IA comprenda, mantenga y extienda el sistema OpticGG ERP.

## 1. Descripción General
**Nombre del Sistema**: OpticGG ERP
**Objetivo**: Gestión administrativa y clínica para una red de ópticas (Óptica Cubas).
**Arquitectura**: Cliente-Servidor (Backend REST API + Frontend Móvil/Desktop).
**Estructura de Tiendas**: El sistema soporta múltiples sucursales identificadas como `C1`, `C2`, `C3` y una vista global `ALL`.

## 2. Stack Tecnológico
### Backend
- **Lenguaje**: Java 17
- **Framework**: Spring Boot 3.x
- **Persistencia**: Spring Data JPA + Hibernate
- **Seguridad**: Spring Security + JWT
- **Herramientas**: Maven, Lombok, Jackson (JSON Mapping).

### Frontend
- **Lenguaje**: Dart
- **Framework**: Flutter 3.x
- **Estado**: Provider
- **Paquetes Clave**: `fl_chart` (Gráficos), `http` (API), `pdf` / `printing` (Tickets), `url_launcher` (WhatsApp).

### Base de Datos
- **Motor**: MySQL 8.0
- **Esquema**: Relacional con Enums nativos.

## 3. Modelo de Datos y Esquema
### Tablas Principales
- `pacientes`: Datos demográficos, fecha de nacimiento y estado VIP.
- `usuarios`: Credenciales, roles (`ADMIN`, `VENDEDOR`), tienda asignada y estado `activo`.
- `ventas`: Registro financiero de transacciones. Incluye copia de la receta para tickets rápidos.
- `ordenes_trabajo`: Seguimiento de fabricación de lentes (Estados: `PENDIENTE`, `LABORATORIO`, `LISTO`, `ENTREGADO`).
- `historial_clinico`: Ficha médica detallada vinculada a `consultas`.
- `consultas`: Registro de la visita del paciente.
- `movimientos_caja`: Entradas y salidas de dinero.
- `lentes`: Catálogo de tipos de lunas y materiales.
- `proveedores` / `compras_proveedor`: Gestión de inventario y pagos externos.

### Enums Clave
- `Tienda`: C1, C2, C3.
- `EstadoPago`: PENDIENTE, PARCIAL, PAGADO.
- `EstadoTrabajo`: PENDIENTE, LABORATORIO, LISTO, ENTREGADO.
- `RolUsuario`: ADMIN, VENDEDOR.
- `TipoMovimiento`: ENTRADA, SALIDA.

## 4. Flujos Críticos de Negocio

### A. Registro de Venta Completa
1. El frontend envía un `NuevaVentaCompletaDTO`.
2. El backend (en una sola transacción):
   - Crea un registro en `consultas`.
   - Crea un registro en `historial_clinico` (Medida visual).
   - Crea un registro en `ventas` (Control de pago).
   - Crea un registro en `ordenes_trabajo` (Para el Kanban).
   - Registra un ingreso en `movimientos_caja` (Si hubo adelanto).
3. El frontend recibe la respuesta con la `fecha` generada y actualiza el estado local.

### B. Historial Clínico (Inteligente)
- El sistema permite "Cargar Última Receta".
- El backend provee un resumen del historial clínico que el frontend parsea (Esfera, Cilindro, Eje, ADD, DIP).
- Esto evita errores manuales y agiliza la atención.

### C. Dashboard y Analítica
- El `DashboardController` procesa agregaciones complejas en MySQL para devolver:
  - Ingresos/Egresos (Hoy vs Ayer con %).
  - Gráficos de barras comparativos (15 vs 30 días).
  - Ranking de mejores vendedores por periodos.
  - Distribución mensual de métodos de pago (Efectivo, Tarjeta, Yape/Plin).

## 5. Estructura de Directorios

### Backend (`OpticGG_ERP/Backend`)
- `src/main/java/com/optica/api/`
  - `controllers/`: Endpoints REST.
  - `dto/`: Objetos de transferencia de datos (Entrada/Salida).
  - `models/`: Entidades JPA (Base de Datos).
  - `repositories/`: Interfaces para consultas SQL (Spring Data).
  - `services/`: Lógica de negocio (Donde ocurre la magia).
  - `security/`: Configuración de acceso y tokens.

### Frontend (`OpticGG_ERP/frontend`)
- `lib/core/`: Constantes, configuración de red, temas visuales.
- `lib/features/`: Módulos por funcionalidad.
  - `auth/`: Login y sesión.
  - `dashboard/`: Pantalla principal y estadísticas.
  - `pacientes/`: Directorio, historial y ficha técnica.
  - `ventas/`: Punto de venta, Kanban y PDF.
  - `usuarios/`: Gestión de personal.
- `lib/main.dart`: Punto de entrada y configuración de Providers.

## 6. Requerimientos de Mantenimiento
- **Soles**: Todos los montos deben mostrarse con el símbolo `S/`.
- **Fechas**: Usar formato `dd-MM-yyyy HH:mm:ss` en JSON. En backend siempre asignar `LocalDateTime.now()` antes de guardar para evitar nulos.
- **WhatsApp**: Los números deben anteponer el código de país (51 para Perú) al usar `url_launcher`.
- **Filtros**: Las consultas de Dashboards deben considerar siempre el parámetro de tienda para mantener la privacidad de datos entre locales.
