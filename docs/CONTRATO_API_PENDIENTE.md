# Contrato local confirmado; validación en Render pendiente

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

Los cuerpos POST/PUT se basan en `swagger.json` y en los controladores locales
del backend. Los nombres de propiedades de escritura son minúsculos, aunque GET
devuelve claves en mayúsculas. POST usa la ruta de colección; PUT y DELETE usan
la ruta de registro con el UUID devuelto por GET. El formulario usa selectores
para las claves relacionadas y fechas en formato `AAAA-MM-DD`.

Los campos enviados son:

- **Aprendiz:** `fecha_nac` (fecha), `per_id` (entero requerido).
- **Persona:** `pri_nombre`, `pri_apellido`, `documento` (requeridos); `seg_nombre` y `seg_apellido` (opcionales).
- **Curso:** `nombre`, `codigo`, `duracion` (entero desde 1), `costo` (número desde 0); `descripcion` (opcional).
- **Instructor:** `especialidad`, `per_id` (entero requerido).
- **Asignación (`imparte`):** `rol`, `fecha`, `fecha_asignacion`, `cur_id`, `ins_id` (todos requeridos).
- **Matrícula:** `fecha`, `estado`, `per_id`, `cur_id` (todos requeridos).
- **Evaluación:** `nombre`, `codigo`, `porcentaje` (número de 0 a 100), `fecha` (todos requeridos).
- **Nota (`materia-evalua`):** `nota` (número de 0 a 5), `eva_id`, `mat_id` (enteros requeridos).

Las rutas de escritura y los UUID también se verificaron mediante OPTIONS en
Render. La aplicación confirma antes de eliminar. No se ejecutó ninguna
mutación contra Render durante el desarrollo; POST, PUT y DELETE tienen pruebas
de cliente HTTP simulado. Por ello, los cuerpos deben considerarse basados en
el contrato del backend local hasta completar una prueba de escritura controlada
en el entorno remoto.
