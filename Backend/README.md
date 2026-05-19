# OpticGG ERP - Sistema de Gestión para Ópticas

Este proyecto es un **ERP Multiplataforma** diseñado específicamente para la gestión integral de ópticas. Su arquitectura permite que el sistema sea adaptable a cualquier dispositivo (Móvil, Tablet, Desktop), garantizando una experiencia de usuario fluida y reactiva.

## 🚀 Propósito del Proyecto
Optimizar la operación de una cadena de ópticas mediante la digitalización de historiales clínicos, control de ventas, seguimiento de órdenes de trabajo y gestión financiera multi-sede.

## 🛠️ Stack Tecnológico
- **Backend:** Java 17 con **Spring Boot 4.0.3**.
- **Seguridad:** Spring Security con **JWT (JSON Web Tokens)** para sesiones sin estado.
- **Base de Datos:** MySQL (Compatible con AWS TiDB / MariaDB).
- **Persistencia:** Spring Data JPA + Hibernate.
- **Migraciones:** Flyway para control de versiones de la base de datos.
- **Frontend (Referencia):** Diseñado para ser consumido por clientes multiplataforma (ej. Flutter, React, o aplicaciones nativas).

## 📊 Modelo de Dominio (Módulos Principales)

El sistema se basa en los siguientes pilares definidos en `BD_optica.sql`:

1.  **Gestión Multi-Sede:** Soporte nativo para múltiples tiendas (C1, C2, C3) con configuraciones personalizadas (RUC, dirección, logo).
2.  **CRM de Pacientes:** Registro detallado de clientes, incluyendo sistema de fidelización (Pacientes destacados) y alertas de cumpleaños.
3.  **Módulo Clínico:**
    *   **Consultas:** Registro del motivo y recomendaciones.
    *   **Historial Clínico:** Almacenamiento técnico de graduaciones (OD/OI), tipos de luna y monturas (propias o de cliente).
4.  **Ciclo de Ventas:**
    *   **Ventas:** Control de montos totales, pagos a cuenta y saldos pendientes.
    *   **Métodos de Pago:** Registro flexible (Efectivo, Yape, Plin, Tarjeta, etc.).
    *   **Órdenes de Trabajo (OT):** Seguimiento del estado de fabricación (Pendiente, Laboratorio, Listo, Entregado).
5.  **Finanzas y Caja:**
    *   **Movimientos de Caja:** Registro de entradas y salidas de dinero por tienda.
    *   **Gestión de Proveedores:** Control de compras y estados de pago a laboratorios/suministros.
6.  **Dashboard de Inteligencia:** Reportes en tiempo real de ventas por vendedor, ingresos por sede y métricas financieras quincenales/mensuales.

## 🔑 Seguridad y Roles
- **ADMIN:** Acceso total, visualización de métricas globales (todas las sedes).
- **VENDEDOR:** Acceso restringido a las operaciones diarias de su sede asignada.

## 🤖 Instrucciones para IA (Contexto)
Cuando trabajes en este proyecto, ten en cuenta:
1.  **Contexto Multi-tienda:** Casi todas las entidades (`Venta`, `Paciente`, `MovimientoCaja`, `OrdenTrabajo`) pertenecen a una `tienda` específica (Enum: C1, C2, C3). Siempre verifica el filtrado por sede.
2.  **Saldos:** El sistema maneja `monto_total`, `monto_a_cuenta` y `monto_saldo`. Asegura la integridad lógica de estos cálculos en las actualizaciones.
3.  **Extensibilidad:** El diseño debe mantenerse desacoplado del frontend para permitir que la interfaz se adapte a cualquier tamaño de pantalla sin modificar la lógica de negocio.
4.  **Base de Datos:** El esquema de referencia principal es `BD_optica.sql`.

---
*Este README sirve como fuente de verdad para el entendimiento del negocio y la estructura técnica del proyecto OpticGG.*
