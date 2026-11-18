# Contrato pendiente para operaciones de escritura

## Consultas verificadas

El 18 de noviembre de 2026 se consultaron mediante GET los ocho endpoints
configurados. En esa revisión respondieron con arreglos JSON directos. Los
campos observados se usan en los modelos Dart. El lector también admite la
envoltura `value` y `Count` compartida previamente para aprendices.

Cuando la respuesta incluye `Count`, la aplicación conserva ese valor. Si la
respuesta solo contiene un arreglo, el indicador muestra cuántos elementos
recibió la aplicación; no lo presenta como un total paginado del servidor.

También se verificaron las referencias actuales comparando identificadores
entre GET: instructor con persona (2/2), asignación con curso e instructor
(1/1 en cada relación), matrícula con curso y persona (2/2 en cada relación)
y nota con evaluación y matrícula (2/2 en cada relación). Las listas resuelven
esos nombres cuando los endpoints relacionados están disponibles.

## Operaciones POST, PUT y DELETE

No se encontró `swagger.json`, `openapi.json` ni una especificación en las
rutas documentales probadas del host. El 18 de noviembre de 2026, OPTIONS
confirmó POST en las rutas de colección y PUT/DELETE en las rutas de registro
con IDs y UUIDs reales. La aplicación usa el UUID devuelto por GET para la
ruta de eliminación y siempre solicita confirmación antes de enviarla.

Las respuestas GET no confirman los cuerpos que esperan POST/PUT. Por esa
razón, esta versión implementa DELETE con diálogo de confirmación, pero no
envía POST/PUT ni muestra formularios que construyan payloads supuestos. No se
ejecutó ninguna mutación contra Render durante la revisión; la llamada DELETE
se cubre con un cliente HTTP simulado en las pruebas.

Para habilitar creación y edición se necesita confirmar el contrato de cuerpo
de cada endpoint.
