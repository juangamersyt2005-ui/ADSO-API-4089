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

## Empezar desde cero

Consulta [INSTRUCCIONES.md](INSTRUCCIONES.md) para instalar Flutter y Android Studio, preparar el dispositivo, ejecutar la aplicación, usar los formularios y correr las pruebas.

La URL de la API se configura en `lib/core/constants/api_constants.dart`. Las operaciones de escritura usan los campos documentados en el contrato local; consulta [docs/CONTRATO_API_PENDIENTE.md](docs/CONTRATO_API_PENDIENTE.md) para conocer los campos y los límites de validación en Render.
