# Instrucciones para ejecutar ADSO4089 Mobile

Esta guía explica cómo instalar las herramientas, descargar el proyecto, ejecutarlo en Android y usar sus módulos desde cero.

## 1. Requisitos

- Windows 10/11 con conexión a Internet.
- Git.
- Flutter SDK compatible con la restricción de Dart indicada en `pubspec.yaml` (`^3.13.7`).
- Android Studio con Android SDK y Platform-Tools, o un teléfono Android con depuración USB activada.
- Un emulador Android creado desde **Android Studio > Device Manager**, o un dispositivo conectado.

Guías oficiales para instalar [Flutter en Windows](https://docs.flutter.dev/get-started/install/windows) y [Android Studio](https://developer.android.com/studio).

## 2. Preparar el entorno

1. Instala Flutter y agrega la carpeta `flutter/bin` al `PATH` de Windows.
2. Instala Android Studio y, desde **SDK Manager**, instala Android SDK y Android SDK Platform-Tools.
3. Abre PowerShell y valida las herramientas:

   ```powershell
   flutter --version
   flutter doctor
   flutter doctor --android-licenses
   ```

   Acepta las licencias cuando se solicite. Resuelve en `flutter doctor` cualquier requisito pendiente de Android.

## 3. Descargar y preparar el proyecto

Clona el repositorio:

```powershell
git clone https://github.com/juangamersyt2005-ui/ADSO-API-4089.git
cd ADSO-API-4089
```

Sitúate en la carpeta que contiene `pubspec.yaml`. Si el proyecto Flutter está dentro de una subcarpeta, entra en ella; por ejemplo:

```powershell
cd adso4089_mobile
```

Descarga las dependencias declaradas por el proyecto:

```powershell
flutter pub get
```

No hace falta configurar credenciales. La URL de la API está en `lib/core/constants/api_constants.dart` y el permiso de Internet está declarado en el manifiesto principal de Android.

## 4. Ejecutar en Android

Inicia el emulador o conecta el teléfono y comprueba que Flutter lo detecte:

```powershell
flutter devices
```

Desde la carpeta del proyecto Flutter ejecuta:

```powershell
flutter run
```

Si hay varios dispositivos, especifica el identificador mostrado por `flutter devices`:

```powershell
flutter run -d <id-del-dispositivo>
```

El dispositivo debe tener acceso a Internet y la API debe estar disponible. La primera consulta puede tardar mientras el servicio remoto responde.

## 5. Usar la aplicación

1. Al abrirse, el dashboard consulta las cantidades de Aprendices, Personas, Cursos, Instructores, Asignaciones, Matrículas, Evaluaciones y Notas.
2. Pulsa una tarjeta para abrir el listado del módulo.
3. Usa el campo de búsqueda para filtrar los registros cargados. La búsqueda se aplica al contenido disponible en la lista.
4. Pulsa un registro para consultar sus detalles cuando estén disponibles.
5. Usa el botón de actualizar o desliza la lista hacia abajo para volver a consultar la API.
6. En los módulos que permiten eliminación, pulsa el icono de papelera y confirma en el diálogo para enviar DELETE.

Si un endpoint falla, la interfaz informa el error y permite reintentar. No muestra cantidades ficticias. Para respuestas que entregan un arreglo directo, el dashboard cuenta los registros recibidos; ese valor no implica que la API haya aplicado paginación.

La aplicación no incluye formularios de creación o edición: no se encontró un contrato confirmado para los cuerpos POST y PUT de cada módulo.

## 6. Pruebas y compilación

Desde la carpeta que contiene `pubspec.yaml`:

```powershell
dart format lib test
flutter analyze
flutter test
```

Para generar un APK de Android:

```powershell
flutter build apk --release
```

El archivo se genera en `build/app/outputs/flutter-apk/app-release.apk`.

## 7. Solución de problemas

- **`flutter` no se reconoce:** agrega `flutter/bin` al `PATH`, cierra y abre PowerShell y vuelve a ejecutar `flutter --version`.
- **No aparece el teléfono o emulador:** inicia el emulador desde Device Manager, habilita depuración USB en el teléfono y vuelve a ejecutar `flutter devices`.
- **Falla una consulta:** confirma que Android tenga Internet y vuelve a intentar desde el módulo. La pantalla muestra el error de conexión o de respuesta HTTP.
- **Faltan paquetes:** ejecuta `flutter pub get` desde la carpeta del proyecto Flutter.
- **La compilación conserva archivos generados antiguos:** ejecuta `flutter clean` y después `flutter pub get` antes de volver a compilar.
