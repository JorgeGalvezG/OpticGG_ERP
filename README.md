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

## 🛠️ Guía de Implementación para IA
Este repositorio incluye un archivo especializado llamado `IA_client.md`. Si eres una IA, lee ese archivo primero para obtener el contexto completo del stack, esquema de base de datos y reglas de negocio.

---
*Este proyecto está optimizado para la eficiencia operativa y la transparencia financiera en el sector óptico.*
