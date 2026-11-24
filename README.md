# 🎓 ADSO 4089 - Sistema de Gestión Académica & API REST

[![Node.js](https://img.shields.io/badge/Backend-Node.js%20%26%20Express-339933?logo=node.js)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-4169E1?logo=postgresql)](https://www.postgresql.org/)
[![Flutter](https://img.shields.io/badge/Frontend-Flutter%20Material%203-02569B?logo=flutter)](https://flutter.dev/)
[![Render](https://img.shields.io/badge/Deploy-Render-46E3B7?logo=render)](https://render.com/)

Aplicación móvil Flutter con Material 3 para consultar y gestionar los módulos académicos de ADSO4089 mediante una API REST.

El sistema está pensado para el control de aprendices, asistencias en tiempo real, seguimiento curricular y reportes académicos de la ficha **ADSO 2824089** (SENA).

---

## 📱 Interfaz Móvil y Prototipos UI (Material 3)

La solución cuenta con una interfaz moderna basada en los principios de **Google Material 3**:

1. **Dashboard Principal:** Resumen de métricas de rendimiento y accesos rápidos.
2. **Módulos & Competencias:** Seguimiento curricular de asignaturas.
3. **Gestión de Aprendices:** Directorio con filtrado rápido y estados de matrícula.
4. **Evaluaciones & Calificaciones:** Rúbrica valorativa y notas por resultado de aprendizaje.
5. **Formulario de Registro:** Alta de registros y selección de relaciones disponibles desde la API.
6. **Perfil Completo del Aprendiz:** Historial académico, juicios evaluativos y datos de contacto.
7. **Detalle de Curso / Ficha:** Información administrativa de la ficha académica.
8. **Planilla de Asistencia Diaria:** Control de estados con `P`, `F`, `E` y `R`.
9. **Reporte Trimestral de Inasistencias:** Analítica mensual y alertas académicas.
10. **Centro de Notificaciones:** Novedades prioritarias, excusas y eventos del sistema.

Las pantallas implementadas deben conservar el sistema visual definido en `lib/config/theme.dart`.

---

## 🧩 Módulos implementados

- Aprendices
- Personas
- Cursos
- Instructores
- Asignaciones
- Matrículas
- Evaluaciones
- Notas

Incluye dashboard con cantidades consultadas a la API, búsqueda, detalles, actualización de listas y formularios para crear, editar y eliminar registros. Las relaciones se seleccionan desde los datos disponibles en la API.

---

## 🗂️ Estructura del proyecto

```text
ADSO-API-4089/
├── android/                  # Configuración de Android
├── docs/                     # Documentación y capturas
│   └── CONTRATO_API_PENDIENTE.md
├── lib/
│   ├── config/theme.dart     # Tema y paleta Material 3
│   ├── core/                 # Constantes y servicios compartidos
│   ├── data/models/          # Modelos de datos
│   ├── presentation/         # Pantallas y widgets
│   └── routes/               # Rutas de navegación
├── test/                     # Pruebas unitarias y de widgets
├── pubspec.yaml
├── INSTRUCCIONES.md
└── README.md
```

Si se incluye el backend en el mismo repositorio, se recomienda mantenerlo en una carpeta `backend/` independiente del frontend Flutter.

---

## 🎨 Sistema de Diseño (Design Tokens Material 3)

### Paleta de colores

| Uso | Color |
|---|---|
| Primario Esmeralda SENA / Teal | `#0F766E` |
| Fondo / Surface | `#F8F9FF` |
| Contenedores de tarjetas | `#FFFFFF` y `#EFF4FF` |
| Aprobado / Presente | `#10B981` |
| Alerta / Falla / Riesgo | `#EF4444` |
| Excusas / Proceso | `#6366F1` |
| Retardos / Pendientes | `#F59E0B` |

### Estilos visuales

- Tipografía: Inter o Roboto.
- Radio de bordes: 16 px para tarjetas y 24 px para botones píldora.
- Elevación de tarjetas: mínima o nula.
- Tema: Material 3 con fondo claro y superficies blancas.

El tema está implementado en `lib/config/theme.dart`.

---

## 🔌 Conexión con la API REST

La URL base se configura en `lib/core/constants/api_constants.dart`.

Los módulos disponibles realizan consultas reales al backend. Las operaciones de escritura usan los campos documentados en el contrato local y las validaciones conocidas del servidor.

| Funcionalidad | Endpoint | Método | Descripción |
|---|---|---|---|
| Dashboard | Endpoint de métricas disponible | `GET` | Consulta las cantidades de los módulos |
| Aprendices | `/api/v1/aprendices` | `GET / POST` | Lista o registra aprendices |
| Aprendiz por ID | `/api/v1/aprendices/:id` | `GET / PUT / DELETE` | Consulta, actualiza o elimina un aprendiz |
| Asistencias | `/api/v1/asistencias/batch` | `POST` | Envía estados masivos `[P, F, E, R]` |
| Reporte de inasistencias | `/api/v1/reportes/inasistencias` | `GET` | Consulta estadísticas y alertas |

> Los endpoints definitivos pueden variar según la implementación vigente del backend. Antes de integrar nuevas pantallas, valida las rutas y campos en Swagger o en `docs/CONTRATO_API_PENDIENTE.md`.

---

## 🚀 Puesta en marcha

### Requisitos

- Windows 10/11.
- Git.
- Flutter SDK compatible con `pubspec.yaml`.
- Android Studio con Android SDK o un teléfono Android.
- Conexión a Internet para consultar la API.

### Preparación

```powershell
git clone https://github.com/juangamersyt2005-ui/ADSO-API-4089.git
cd ADSO-API-4089
flutter pub get
```

### Ejecutar en Android

```powershell
flutter devices
flutter run
```

Para seleccionar un dispositivo:

```powershell
flutter run -d <id-del-dispositivo>
```

Consulta `INSTRUCCIONES.md` para una guía completa de instalación, uso de formularios y solución de problemas.

### Ejecutar pruebas y análisis

```powershell
dart format lib test
flutter analyze
flutter test
```

### Generar APK

```powershell
flutter build apk --release
```

El archivo se genera en `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🧪 Estado actual

- El dashboard consulta datos reales desde la API.
- Las listas admiten búsqueda y actualización.
- Los formularios permiten crear, editar y eliminar registros disponibles.
- Las relaciones se cargan desde los módulos correspondientes.
- Las respuestas que contienen arreglos directos se cuentan tal como llegan; este conteo no supone paginación si el backend no la implementa.
- Los errores de conexión y HTTP se muestran en la interfaz y permiten reintentar.