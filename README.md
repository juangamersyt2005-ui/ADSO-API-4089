# ADSO4089 Mobile

Aplicación móvil Flutter con Material 3 para consultar y gestionar los módulos académicos de ADSO4089 mediante la API REST.

## Módulos

- Aprendices
- Personas
- Cursos
- Instructores
- Asignaciones
- Matrículas
- Evaluaciones
- Notas

Incluye dashboard con cantidades consultadas a la API, búsqueda, detalles, actualización de listas y formularios para crear, editar y eliminar registros. Las relaciones se seleccionan desde los datos disponibles en la API.

## Publicar la aplicación web en Render

El repositorio incluye `render.yaml` y un `Dockerfile` que compila Flutter Web
y sirve los archivos de producción. En Render, crea un **Blueprint** conectado
a este repositorio y a la rama `main`; Render publicará el servicio
`adso4089-mobile-web-juangamers`.

La aplicación consulta por defecto `https://adso3294089.onrender.com`. La API
permite el origen web indicado en su configuración. Si cambias el dominio del
frontend, configura ese origen exacto en `CORS_ORIGINS` dentro del Web Service
de la API. Las credenciales de MySQL se configuran únicamente en el servicio
de la API; el frontend no debe contener secretos.

Para compilar manualmente con otra URL de API, usa:

```powershell
flutter build web --release --dart-define=API_BASE_URL=https://tu-api.onrender.com
```

## Empezar desde cero

Consulta [INSTRUCCIONES.md](INSTRUCCIONES.md) para instalar Flutter y Android Studio, preparar el dispositivo, ejecutar la aplicación, usar los formularios y correr las pruebas.

La URL de la API se configura en `lib/core/constants/api_constants.dart`. Las operaciones de escritura usan los campos documentados en el contrato local; consulta [docs/CONTRATO_API_PENDIENTE.md](docs/CONTRATO_API_PENDIENTE.md) para conocer los campos y los límites de validación en Render.
