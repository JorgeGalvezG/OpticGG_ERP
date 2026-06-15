# OpticGG ERP - Frontend (Flutter)

Interfaz de usuario multiplataforma para la gestión operativa de Centro Óptico Cubas 20/20.

## Tecnologías
- **Framework**: Flutter 3.x
- **Gestión de Estado**: Provider
- **Gráficos**: fl_chart
- **Navegación**: Rutas nativas y Layouts dinámicos.
- **Comunicación**: HTTP (ApiService personalizado).

## Flujo de Trabajo Principal

### 1. Proceso de Venta (UI)
- **Buscador de Pacientes**: Localización rápida por nombre/DNI/celular.
- **Formulario Inteligente**: Botón "Cargar Última" que recupera y parsea la receta previa del paciente (OD/OI, ADD, DIP) para ahorrar tiempo.
- **Generación de Ticket**: Creación automática de PDF profesional con datos reales para impresión.

### 2. Tablero Kanban (Órdenes de Trabajo)
- Visualización de estados: Pendiente -> Laboratorio -> Listo -> Entregado.
- Arrastrar/Cambiar estado actualiza inmediatamente la base de datos.

### 3. Dashboard Interactivo
- **Métricas**: Tarjetas con varianza porcentual respecto al día anterior.
- **Gráficos de Caja**: Comparativa de Ingresos vs Egresos en periodos de Hoy, 15 Días y 30 Días.
- **Cumpleaños**: Notificación y botón para enviar mensajes personalizados vía WhatsApp (`url_launcher`).
- **Métodos de Pago**: Gráfico circular con estadísticas mensuales.

### 4. Administración de Personal
- Vista de usuarios con filtros por tienda.
- Interruptores de estado (Activo/Inactivo) sincronizados con el backend.

## Requisitos e Instalación
1. Instalar Flutter SDK.
2. Ejecutar `flutter pub get`.
3. Configurar la URL del backend en `lib/core/constants/api_constants.dart`.
4. Ejecutar `flutter run`.
