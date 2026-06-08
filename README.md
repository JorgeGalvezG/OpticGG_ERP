# OpticGG ERP - Ecosistema de Gestión Integral para Ópticas

Este repositorio contiene la solución completa (Fullstack) para la gestión de una cadena de ópticas con múltiples sedes. El sistema está diseñado para ser multiplataforma, permitiendo su uso en dispositivos móviles (Android/iOS) y de escritorio (Windows/macOS/Web).

## 📌 Visión General del Negocio
OpticGG centraliza la operación de 3 sucursales (C1, C2, C3), permitiendo un control unificado de:
- **Pacientes:** CRM con historial clínico y sistema VIP.
- **Clínico:** Registro de recetas visuales y medidas de laboratorio.
- **Ventas:** Control de ingresos, pagos parciales y saldos pendientes.
- **Logística:** Órdenes de trabajo con seguimiento de estado (Kanban) y compras a proveedores.
- **Finanzas:** Flujo de caja diario, quincenal y mensual por sede.

---

## 🏗️ Estructura del Proyecto

### 1. Backend (Java/Spring Boot)
Ubicado en `C:\Users\User\Desktop\OpticGG_ERP\Backend`
- **Tecnologías:** Java 17, Spring Boot 4.0.3, Spring Security, JWT, MySQL, Flyway.
- **Características Clave:**
  - Seguridad basada en tokens JWT para sesiones sin estado.
  - Transacciones atómicas: Una venta genera automáticamente su Orden de Trabajo y su Movimiento de Caja.
  - API RESTful segmentada por tiendas mediante Enums.

### 2. Frontend (Flutter)
Ubicado en `C:\Users\User\Desktop\OpticGG_ERP\frontend`
- **Tecnologías:** Flutter 3.x, Provider (Estado), PDF & Printing.
- **Características Clave:**
  - **Generación de Tickets:** Sistema dinámico que utiliza la tabla `config_tienda` para imprimir tickets térmicos profesionales (80mm) con los datos legales de la sede correspondiente.
  - **Multiplataforma:** Interfaz adaptativa que funciona en móviles para vendedores y en tablets/PCs para administración.
  - **Tickets Profesionales:** Incluye detalles técnicos del pedido (Lunas, Montura, Graduación), resumen de saldos y código de barras.

### 3. Base de Datos (MySQL/TiDB)
Esquema definido en `BD_optica.sql`
- **Modelo Relacional:**
  - `usuarios`: Gestión de personal con roles ADMIN/VENDEDOR.
  - `pacientes`: Ficha de cliente con detección de cumpleaños para fidelización.
  - `ordenes_trabajo`: Seguimiento desde la venta hasta la entrega.
  - `config_tienda`: Datos dinámicos para la cabecera de los comprobantes.

---

## 🚀 Flujo de Trabajo Actualizado

### 1. Ventas y Automatización
- **Registro Único**: Al realizar una nueva venta desde Flutter, el sistema dispara una transacción atómica en Java que registra la consulta, el historial clínico, la venta financiera, la orden de trabajo para laboratorio y el ingreso inicial a caja.
- **Historial Inteligente**: El vendedor puede usar el botón "Cargar Última" para recuperar instantáneamente la receta anterior del paciente, agilizando la atención.

### 2. Dashboard y Analítica en Tiempo Real
- **Control Financiero**: Comparativas visuales de ingresos y egresos diarios, quincenales y mensuales.
- **KPIs**: Indicadores de rendimiento con porcentajes de varianza respecto al día anterior.
- **Fidelización**: Notificaciones de cumpleaños integradas con WhatsApp para enviar saludos personalizados directamente desde la app.

### 3. Seguimiento Logístico (Kanban)
- Las órdenes de trabajo fluyen por estados configurables. El cambio de estado se refleja en tiempo real para todos los dispositivos de la tienda.

---

## 🔄 Bitácora de Cambios Recientes

### 1. Backend (Java/Spring Boot)
- **Refactorización de Persistencia**: Se corrigieron errores de carga del `ApplicationContext` mediante la eliminación de aritmética de fechas en JPQL (`MovimientoCajaRepository`), migrando la lógica a Java con `LocalDateTime`.
- **Gestión de Configuración de Tiendas**: Implementación de `ConfigTiendaController` y servicios asociados para centralizar datos legales (RUC, Dirección, Teléfono) por cada sede.
- **Seguridad y Permisos**: Reforzamiento de los controles de acceso para la actualización de pacientes y corrección de rutas duplicadas.
- **Tickets Dinámicos**: Adaptación de la lógica de impresión para consumir datos directamente de la tabla `config_tienda`.

### 2. Frontend (Flutter)
- **Carga de Historial Inteligente**: Implementación del botón **"Cargar Última Receta"** en el módulo de ventas, permitiendo recuperar automáticamente medidas previas (Esfera, Cilindro, Eje, Adición, DIP).
- **Mejoras en Tickets PDF**: Se incluyeron los campos de **Adición** y **DIP** en el formato de impresión de tickets para mayor precisión técnica.
- **Gestión de Usuarios**: Adición de un switch para activar/desactivar cuentas de usuario directamente desde la interfaz administrativa.
- **Optimización de Interfaz**: Resolución de errores de navegación y ajuste de permisos de visibilidad según el rol del usuario.

### 3. Base de Datos (MySQL)
- **Nueva Tabla `config_tienda`**: Creación de la estructura para almacenar metadatos de las sucursales (C1, C2, C3), facilitando la personalización de comprobantes.
- **Limpieza de Esquema**: Optimización de tipos de datos y sincronización de Enums para estados de trabajo y tiendas.

---

## 🛠️ Guía de Implementación para IA
Este repositorio incluye un archivo especializado llamado `IA_client.md`. Si eres una IA, lee ese archivo primero para obtener el contexto completo del stack, esquema de base de datos y reglas de negocio.

---
*Este proyecto está optimizado para la eficiencia operativa y la transparencia financiera en el sector óptico.*
