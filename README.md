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

## 🛠️ Guía de Implementación para IA
Si eres un agente trabajando en este código, sigue estas reglas:
1.  **Contexto de Tienda:** Nunca olvides filtrar por el campo `tienda` (C1, C2, C3). El Admin puede ver "ALL", pero el Vendedor solo su sede.
2.  **Integridad Financiera:** Los cálculos de `monto_total - monto_a_cuenta = monto_saldo` deben ser consistentes en el Backend y reflejarse correctamente en el Ticket PDF del Frontend.
3.  **Tickets:** La clase `TicketPdfService` en el frontend es la fuente de verdad para la impresión. Utiliza la constante `_sucursales` para mapear los datos legales de `config_tienda`.
4.  **Modelos:** El modelo `OrdenTrabajo` en Flutter debe mantener sincronía con los campos de historial clínico para que los tickets salgan completos.

---
*Este proyecto está optimizado para la eficiencia operativa y la transparencia financiera en el sector óptico.*
