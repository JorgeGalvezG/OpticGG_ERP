# Guía de Estilos y Diseño Visual 🎨✨

Esta guía contiene la documentación detallada del **sistema de diseño, colores, tipografía y elementos visuales** utilizados en el aplicativo **OpticGG ERP**, facilitándote su personalización y modificación.

---

## 1. Tipografía (Fuentes) ✍️

La fuente tipográfica configurada por defecto en el aplicativo es **Segoe UI** (limpia, profesional y altamente legible en pantallas de escritorio y móviles).

### ¿Dónde se configura?
En el archivo principal de la aplicación:
📍 **`frontend/lib/main.dart`** (Línea 54)
```dart
theme: ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Segoe UI', // <--- Fuente global del aplicativo
),
```

### ¿Cómo cambiarla?
Si deseas cambiar la fuente por una personalizada (por ejemplo, **Montserrat** o **Inter**), puedes:
1. **Opción A (Google Fonts - Recomendado):**
   * Añade el paquete `google_fonts` en tu `pubspec.yaml`.
   * En `main.dart`, define el tema usando:
     ```dart
     theme: ThemeData(
       textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
     )
     ```
2. **Opción B (Fuente Local en Assets):**
   * Descarga la fuente en formato `.ttf` o `.otf`.
   * Regístrala en tu `pubspec.yaml` bajo la sección `fonts`.
   * Cambia el valor del parámetro `fontFamily: 'NombreDeTuFuente'` en `main.dart`.

---

## 2. Paleta de Colores Corporativa 🎨

Los colores base representan un equilibrio entre el sector médico-clínico (Cianes/Azules) y la sobriedad profesional (Azul Medianoche y Grises Neutros).

📍 **`frontend/lib/core/theme/app_colors.dart`**

| Color / Variable | Código Hexadecimal | Propósito / Uso Visual |
| :--- | :---: | :--- |
| **`primary`** | `0xFF0077B6` | **Azul Océano Vibrante** - Botones de acción principal, encabezados activos, barras superiores y realces. |
| **`primaryLight`** | `0xFFADE8F4` | **Cian Suave** - Fondos de inputs seleccionados, bordes de elementos destacados y cajas activas. |
| **`secondary`** | `0xFF00B4D8` | **Turquesa Médico** - Botones secundarios e iconos de estado secundario. |
| **`background`** | `0xFFF1F5F9` | **Gris Slate 100** - Color de fondo de la pantalla completa (Scaffold) para evitar la fatiga visual. |

### Colores de Estado (Alertas y Validaciones)
| Estado | Código Hexadecimal | Propósito / Uso |
| :--- | :---: | :--- |
| **`success`** | `0xFF06D6A0` | **Verde Menta Vivo** - Caja abierta, abonos completos, guardado exitoso y saldos en S/ 0.00. |
| **`warning`** | `0xFFFFD166` | **Amarillo Sol** - Advertencias de stock bajo o confirmaciones pendientes. |
| **`danger`** | `0xFFEF476F` | **Rosa/Rojo Vibrante** - Alertas de error, stock insuficiente, montos en saldo pendiente y deudas. |

---

## 3. Paleta Astronómica (Tema Especial / Desarrollador) 🚀🌌

Para vistas especiales, pantallas de carga o interfaces alternativas (como el modo desarrollador/espacial), se utiliza una paleta cósmica:

*   **`cosmicDeep`** (`0xFF0B0D17`): Negro espacial profundo.
*   **`nebulaPurple`** (`0xFF6B4EE6`): Púrpura de nebulosa estelar.
*   **`nebulaPink`** (`0xFFE94560`): Rosa cósmico brillante.
*   **`starlight`** (`0xFFE0E1DD`): Blanco estrella apagado.

---

## 4. Gradientes Visuales 🌊

Para crear una apariencia premium e inmersiva (como en la pantalla de Login y los paneles de control), se aplican los siguientes gradientes:

```dart
// Gradiente de Login (Azul Medianoche a Azul Océano)
static const LinearGradient loginGradient = LinearGradient(
  colors: [Color(0xFF03045E), Color(0xFF0077B6)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// Gradiente Principal (Azul Océano a Turquesa)
static const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Gradiente Espacial (Para la interfaz cósmica)
static const LinearGradient nebulaGradient = LinearGradient(
  colors: [Color(0xFF0F3460), Color(0xFF533483), Color(0xFFE94560)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

---

## 5. Bordes, Sombras y Formas (Borders & Elevation) 📐

Para dar una estética limpia y moderna al estilo **Card / Glassmorphism**, el aplicativo sigue estas pautas de diseño:

*   **Bordes Redondeados (BorderRadius):**
    *   Tarjetas normales, inputs y diálogos pequeños: `BorderRadius.circular(12)`
    *   Contenedores principales, tarjetas de información clínica y diálogos flotantes grandes: `BorderRadius.circular(16)`
    *   Botones de acción, tarjetas de facturación e interfaces completas de ventas: `BorderRadius.circular(24)`
*   **Sombras (BoxShadow):**
    *   Sombra ligera y moderna para tarjetas flotantes:
        ```dart
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
        ```

---

## 6. ¿Cómo modificar el diseño del aplicativo rápidamente? 🛠️

1.  **Cambiar Colores Principales:**
    *   Abre [app_colors.dart](file:///D:/Proyectos_Personales/OpticGG/OpticGG_ERP/frontend/lib/core/theme/app_colors.dart) y reemplaza los códigos hexadecimales (`0xFF......`) de `primary`, `secondary` y `background`. Toda la aplicación se actualizará instantáneamente.
2.  **Modificar el Estilo de los TextFields:**
    *   Los formularios usan la decoración global del tema o métodos de ayuda como `_field(...)`.
    *   Si quieres que todos los campos de texto del sistema tengan bordes más redondeados o cambien de color al seleccionarse, puedes modificar la propiedad `inputDecorationTheme` dentro de `ThemeData` en [main.dart](file:///D:/Proyectos_Personales/OpticGG/OpticGG_ERP/frontend/lib/main.dart).
3.  **Ajustar los Diálogos de Alerta:**
    *   Los cuadros de diálogo (como el de Historial o Venta) tienen un diseño suavizado con bordes redondeados a `24`. Si prefieres bordes rectos o más curvos, modifica el parámetro `shape` de los widgets `Dialog` o `AlertDialog` en los archivos de interfaz.
