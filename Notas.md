# Notas de Actualización - OpticGG ERP (Refactorización Masiva)

Este documento resume todos los cambios realizados en el sistema para implementar la gestión de Almacén (Kardex), seguimiento de Proveedores y la nueva lógica de Ventas.

## 🗄️ 1. Base de Datos (MySQL/TiDB)
Se realizaron modificaciones estructurales para soportar el control de inventario:

*   **Nuevas Tablas:**
    *   `categorias_productos`: Clasificación fija (LENTES, OTROS) para evitar redundancia.
    *   `almacen`: Inventario centralizado con `codigo_barras`, `stock`, `precios` y vinculación a tienda.
    *   `compras_proveedor_detalle`: Registro detallado de productos ingresados por compra.
    *   `ventas_detalle_almacen`: Registro de salida de productos (Kardex de salida).
*   **Modificaciones en Tablas Existentes:**
    *   `compras_proveedor`: Agregados campos `monto_pagado`, `estado_entrega` (SOLICITADO/LLEGO) y `fecha_entrega`.
    *   `ventas`: Agregado `tipo_venta` (ORDEN_TRABAJO/ORDEN_VENTA) y `codigo_barras` único por venta.

## ⚙️ 2. Backend (Java Spring Boot)
Se rediseñó la lógica de negocio para automatizar el movimiento de stock:

*   **Entidades y Repositorios:** Creadas todas las clases JPA correspondientes a las nuevas tablas.
*   **VentaService:** 
    *   Generación automática de códigos de barras.
    *   Diferenciación de flujos: Si es `ORDEN_VENTA`, se descuenta stock automáticamente. Si es `ORDEN_TRABAJO`, se mantiene el flujo de laboratorio/receta.
*   **CompraProveedorService:**
    *   Gestión de pagos parciales y saldos deudores a proveedores.
    *   Sistema de recepción: Al marcar una compra como `LLEGO`, el stock del almacén se incrementa automáticamente según el detalle de la compra.
*   **DashboardController:** Corrección en el cálculo de varianzas y visibilidad de egresos manuales de caja.

## 📱 3. Frontend (Flutter)
Actualización de la interfaz de usuario y servicios:

*   **TicketPdfService:** Eliminación de la "Receta Médica" en comprobantes (Ticket 80mm y Boleta A4) para enfocarse en el detalle comercial y financiero.
*   **Almacen/Kardex:**
    *   Nueva pantalla `AlmacenScreen` con búsqueda por código de barras y visualización de stock crítico.
    *   **Sistema de Fotos:** Los productos ahora permiten guardar una imagen (vía URL o subida al servidor) para identificación visual rápida.
    *   **Vinculación con Proveedores:** Cada producto del almacén puede estar enlazado a un proveedor preferencial.
    *   Modelos y Providers para la gestión de inventario.

*   **Proveedores (Compras Detalladas):**
    *   Nuevo flujo de compra que permite seleccionar productos existentes del Almacén.
    *   Al registrar una compra, se genera una deuda con el proveedor y se vinculan los ítems.
    *   Soporte para "Llegada de Pedido" que actualiza el stock automáticamente.
*   **Caja:** Mejora en el listado de movimientos incluyendo fechas legibles y orden descendente.
*   **Menú:** Integración del acceso al Almacén desde la pestaña "Más".

---
*Nota: Estos cambios preparan el sistema para una futura integración con escáneres de códigos de barras físicos.*
