# Guía de Integración Backend (Java / Spring Boot)

Para que las nuevas funcionalidades de **Óptica Cubas** (Historial, Tickets Detallados y Pagos) funcionen correctamente, el backend debe alinearse con los siguientes requerimientos técnicos.

## 1. Actualización de la Entidad `OrdenTrabajo` / `Venta`
Asegúrate de que tu tabla en la base de datos y tu entidad Java tengan los siguientes campos:

| Campo Flutter | Tipo JSON | Descripción |
| :--- | :--- | :--- |
| `montura` | `String` | Marca/Modelo de la montura. |
| `tipoLuna` | `String` | Descripción de los cristales/lentes. |
| `observaciones` | `String` | Notas del especialista o médico. |
| `graduacionOd` | `String` | Medida del Ojo Derecho (Ej: "E:-1.00 C:-0.50 A:180"). |
| `graduacionOi` | `String` | Medida del Ojo Izquierdo. |
| `metodoPago` | `String` | "EFECTIVO", "TARJETA", "YAPE / PLIN", "TRANSF.". |
| `esMonturaCliente` | `boolean` | Indica si el paciente trajo su propia montura. |
| `esLunaCliente` | `boolean` | Indica si el paciente trajo sus propias lunas. |

## 2. Endpoints Requeridos

### A. Historial de Paciente
El frontend llama a este endpoint al abrir la ficha de historial.
*   **Ruta**: `GET /api/ordenes/paciente/{id}`
*   **Retorno**: Una lista (`List<OrdenTrabajo>`) de todas las órdenes vinculadas a ese ID de cliente.

### B. Registro de Nueva Venta
El DTO que recibe tu controlador debe ser capaz de mapear estos campos exactos.
*   **Ruta**: `POST /api/ventas/nueva`
*   **Payload esperado (JSON)**:
    ```json
    {
      "pacienteId": 12,
      "vendedorId": 1,
      "tienda": "C1",
      "montoTotal": 250.00,
      "montoACuenta": 100.00,
      "graduacionOd": "E:-1.00 C:-0.50 A:180",
      "graduacionOi": "Plano",
      "esLunaCliente": false,
      "tipoLuna": "Resina AR",
      "esMonturaCliente": false,
      "montura": "Ray-Ban Aviator",
      "observaciones": "Paciente requiere protección azul",
      "metodoPago": "EFECTIVO"
    }
    ```

### C. Pago de Saldo Pendiente (Deuda)
Para registrar cobros de ventas que se hicieron con abono parcial.
*   **Ruta**: `POST /api/ventas/pago-saldo`
*   **Payload esperado**:
    ```json
    {
      "ordenId": 45,
      "monto": 150.00,
      "metodoPago": "TARJETA"
    }
    ```

### D. Actualización de Estado (Flujo Simple)
Para el nuevo sistema de botones (Enviar a Lab, Listo, Entregar).
*   **Ruta**: `PUT /api/ordenes/{id}/estado`
*   **Payload esperado**: `{ "nuevoEstado": "LABORATORIO" }` (o "LISTO", "ENTREGADO").

## 3. Consideraciones de Seguridad
*   Todos los endpoints deben estar protegidos por el **filtro JWT** que ya tenemos configurado.
*   El backend debe verificar que el usuario tenga permisos de `ADMIN` o `VENDEDOR` para realizar estas acciones.

---
**Nota para el desarrollador:** Si estos campos o rutas no coinciden exactamente, el frontend mostrará errores de "null" o el historial aparecerá vacío.
