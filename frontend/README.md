# Óptica Cubas ERP - Sistema de Gestión Integral

Bienvenido al ecosistema digital de **Óptica Cubas**. Este sistema ha sido diseñado para optimizar cada punto de contacto de la clínica, desde la recepción del paciente hasta el control financiero y la entrega de productos ópticos.

## 🌟 Identidad Visual y Experiencia
El sistema utiliza una paleta **Cian Clínico Vibrante** y **Azul Medianoche**, diseñada para transmitir una imagen moderna, tecnológica y profesional. La interfaz es 100% responsiva, adaptándose perfectamente a tablets, smartphones y computadoras de escritorio.

## 🚀 Módulos Principales

### 📊 1. Dashboard Estratégico (Panel de Control)
El corazón del sistema. Proporciona una vista de "Alta Densidad" de la operación diaria:
*   **Balance de Caja en Tiempo Real**: Visualización clara de Entradas (Ingresos) vs Salidas (Egresos) con cálculo de Balance Neto.
*   **Rendimiento Histórico**: Gráficas comparativas que muestran la evolución de ingresos del Día, Quincena y Mes.
*   **Agenda de Cumpleaños**: Bloque automatizado para identificar a los pacientes que cumplen años hoy y fortalecer la fidelización.
*   **Ranking de Ventas**: Identificación inmediata de los vendedores con mayor desempeño diario.
*   **Accesos Rápidos**: Atajos directos a las funciones más críticas del negocio.

### 🛒 2. Gestión de Ventas y Órdenes
Un flujo de trabajo lineal e intuitivo que reemplaza los complejos tableros Kanban por acciones directas:
*   **Buscador Inteligente**: Localiza ventas por nombre de paciente o número de orden en milisegundos.
*   **Control de Estados**: Botones de acción contextuales ("Enviar a Lab", "Listo para Entrega", "Entregar").
*   **Gestión de Saldos**: Sistema de seguridad que bloquea la entrega si hay deuda pendiente y permite realizar cobros parciales.
*   **Resumen Técnico**: Visualización rápida del paquete adquirido (Montura + Cristales) en la misma lista.

### 🏥 3. Directorio y Historial de Pacientes
*   **Buscador Global**: Filtrado por nombre, DNI o celular.
*   **Ficha Clínica Detallada**: Diálogo de historial que separa cronológicamente las **Recetas Médicas (OD/OI)** de los **Detalles de Compra**.
*   **Seguimiento VIP**: Identificación de pacientes destacados con integración directa a WhatsApp para el envío de promociones personalizadas.

### 🎫 4. Documentación y Compartición
*   **Ticketera (80mm)**: Generación de tickets de venta con detalle de receta y observaciones para impresión física.
*   **Orden de Compra Pro (A4 PDF)**: Formato corporativo elegante diseñado para ser **compartido por WhatsApp**. Incluye logo de la sede, datos fiscales y especificaciones técnicas completas.

## 🏗️ Arquitectura Técnica (Feature-First)
El proyecto está organizado por dominios de negocio para máxima escalabilidad:

```text
lib/
├── core/              # Configuración global, temas y servicios de red (ApiService)
└── features/          # Módulos independientes
    ├── auth/          # Sesión y seguridad JWT
    ├── dashboard/     # Métricas y analítica
    ├── pacientes/     # Directorio clínico
    ├── ventas/        # Órdenes, Tickets y servicios PDF
    ├── caja/          # Control de egresos y movimientos
    └── vip/           # Fidelización y Marketing WhatsApp
```

## 🛠️ Tecnologías Utilizadas
*   **Frontend**: Flutter (v3.x).
*   **Estado**: Provider (Manejo reactivo).
*   **Gráficos**: fl_chart.
*   **Documentos**: pdf & printing.
*   **Integración**: share_plus para compartir PDF en móviles.
*   **Networking**: Http con interceptores para Token JWT.

## 🔗 Integración con Backend
Para que el sistema funcione al 100%, el backend debe cumplir con las especificaciones detalladas en:
👉 [**Guía de Requerimientos Backend (BACKEND_REQUIREMENTS.md)**](./BACKEND_REQUIREMENTS.md)

---
**Desarrollado para Óptica Cubas - Excelencia en Salud Visual.**
