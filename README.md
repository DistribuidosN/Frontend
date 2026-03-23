<p align="center">
  <img src="./assets/banner.svg" alt="Banner de ImageFlow Frontend con un panel visual para operaciones de procesamiento distribuido de imagenes" width="100%">
</p>

<p align="center">
  <img alt="Frontend Flutter" src="https://img.shields.io/badge/Flutter-Frontend%20Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img alt="Dart 3.9+" src="https://img.shields.io/badge/Dart-3.9%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img alt="UI responsive" src="https://img.shields.io/badge/UI-Responsive-1F2937?style=for-the-badge&logo=materialdesign&logoColor=white">
  <img alt="Estado prototipo" src="https://img.shields.io/badge/Estado-Prototipo%20UI-FACC15?style=for-the-badge&labelColor=111827&color=FACC15">
</p>

<h1 align="center">ImageFlow Frontend</h1>

<p align="center">
  Interfaz Flutter para supervisar, configurar y recorrer un flujo distribuido de procesamiento de imagenes.
</p>

<p align="center">
  El repositorio contiene un frontend visualmente pulido para autenticacion, carga de lotes, configuracion de tareas, seguimiento de progreso, revision de resultados y observabilidad operativa.
</p>

<p align="center">
  <a href="#resumen">Resumen</a> |
  <a href="#demo">Demo</a> |
  <a href="#stack">Stack</a> |
  <a href="#arquitectura">Arquitectura</a> |
  <a href="#puesta-en-marcha">Puesta en marcha</a> |
  <a href="#hoja-de-ruta">Hoja de ruta</a>
</p>

<p align="center">
  <img src="./assets/separator.svg" alt="Separador visual" width="100%">
</p>

## Resumen

`ImageFlow Frontend` vive en `flutter_app/` y modela la experiencia de un operador que trabaja con un pipeline distribuido de imagenes. El recorrido principal ya esta representado: iniciar sesion, cargar archivos, definir transformaciones, monitorear la ejecucion, revisar resultados y consultar historial, nodos y logs.

> Estado actual: este repositorio es un prototipo frontend. La UI funciona con estado local, datos mock y progreso simulado. Todavia no hay integracion real con autenticacion, almacenamiento, cargas de archivos ni APIs backend.

## Demo

<p align="center">
  <img src="./assets/demo-placeholder.svg" alt="Vista previa de ImageFlow Frontend" width="100%">
</p>

Vista ilustrativa del panel principal y del estado operativo de la interfaz.

## Indice

- [Por que importa](#por-que-importa)
- [Pantallas principales](#pantallas-principales)
- [Stack](#stack)
- [Arquitectura](#arquitectura)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Puesta en marcha](#puesta-en-marcha)
- [Variables de entorno](#variables-de-entorno)
- [Comandos utiles](#comandos-utiles)
- [Flujo actual](#flujo-actual)
- [Limitaciones actuales](#limitaciones-actuales)
- [Hoja de ruta](#hoja-de-ruta)
- [Contribuir](#contribuir)
- [Preguntas frecuentes](#preguntas-frecuentes)
- [Licencia](#licencia)

## Por que importa

- Valida el recorrido completo de operacion antes de conectar servicios reales.
- Define una direccion visual consistente con layout responsive, tipografia editorial y componentes reutilizables.
- Deja una base clara para migrar de mocks a datos reales sin rehacer toda la presentacion.

## Pantallas principales

- `Auth`: login, registro y recuperacion de contrasena por pasos.
- `Dashboard`: throughput, cola, lotes recientes y salud del cluster.
- `Upload`: carga simulada de imagenes por lote.
- `Task Builder`: configuracion de transformaciones, preview y salida.
- `Progress`: seguimiento de procesamiento distribuido.
- `Results`: metricas, comparacion antes/despues y grilla de resultados.
- `History`: historial de solicitudes con filtros y acceso a detalle.
- `Request Detail`: detalle por solicitud, transformaciones y logs asociados.
- `Worker Nodes`: monitoreo de nodos, carga y heartbeat.
- `Logs`: eventos operativos por nivel y fuente.
- `Settings`: perfil, notificaciones, defaults y acceso API.

## Stack

<p align="center">
  <img src="./assets/stack.svg" alt="Resumen visual del stack de ImageFlow Frontend" width="100%">
</p>

- `Flutter` como shell multiplataforma.
- `Dart` para logica de UI, estado y modulos.
- `Material 3` como base de componentes, personalizado por tema propio.
- `google_fonts` para la combinacion tipografica `Fraunces` + `Manrope`.
- Estructura por features con carpetas `presentation`, `domain` y `data`.
- Datos mock para dashboard, historial, nodos, logs, detalle y resultados.

## Arquitectura

<p align="center">
  <img src="./assets/architecture.svg" alt="Diagrama de arquitectura del frontend ImageFlow" width="100%">
</p>

- `lib/main.dart` inicia Flutter y delega en `ImageFlowApp`.
- `lib/features/shell/presentation/shell.dart` concentra autenticacion, navegacion y layout responsive.
- `lib/core/theme/app_theme.dart` define colores, tipografia y estilo global.
- `lib/shared/widgets/shared_widgets.dart` agrupa primitivas reutilizables como paneles, pills, grids y metric cards.
- Cada feature mantiene cerca su UI, modelos y mocks para que el crecimiento sea mas ordenado.
- La capa de datos actual es local: no hay servicios remotos conectados todavia.

## Estructura del proyecto

```text
Frontend/
|-- assets/                      # SVG usados por este README
`-- flutter_app/
    |-- lib/
    |   |-- app.dart
    |   |-- main.dart
    |   |-- core/
    |   |   `-- theme/
    |   |-- shared/
    |   |   `-- widgets/
    |   `-- features/
    |       |-- auth/
    |       |-- dashboard/
    |       |-- history/
    |       |-- logs/
    |       |-- nodes/
    |       |-- progress/
    |       |-- request_detail/
    |       |-- results/
    |       |-- settings/
    |       |-- shell/
    |       |-- task_builder/
    |       `-- upload/
    |-- android/
    |-- ios/
    |-- linux/
    |-- macos/
    |-- web/
    `-- windows/
```

## Puesta en marcha

### Requisitos

- Flutter SDK instalado correctamente.
- Un dispositivo, emulador o navegador disponible.
- `flutter doctor` en buen estado para la plataforma que vayas a usar.

### Instalacion y ejecucion

```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

Si prefieres escritorio en Windows:

```bash
cd flutter_app
flutter run -d windows
```

## Variables de entorno

No se requieren variables de entorno en la version actual basada en mocks.

## Comandos utiles

- `flutter pub get` instala dependencias.
- `flutter run` levanta la app en el target por defecto.
- `flutter analyze` ejecuta analisis estatico.
- `flutter test` esta disponible, aunque hoy no hay pruebas especificas del proyecto en `test/`.
- `flutter build web` genera una build web.
- `flutter build windows` genera una build de escritorio para Windows.

## Flujo actual

1. El usuario entra por la capa de autenticacion.
2. Accede al shell principal y revisa el estado del sistema.
3. Carga un lote de imagenes y pasa al configurador de tareas.
4. Define transformaciones, formato de salida y parametros de calidad.
5. Inicia el procesamiento y observa el avance del lote.
6. Revisa resultados, historial, nodos y logs operativos.

## Limitaciones actuales

- La carga de archivos es simulada.
- La autenticacion no esta conectada a un backend real.
- El progreso, los resultados, los logs y el historial usan mocks.
- La navegacion se resuelve con estado local dentro del shell.
- El repositorio todavia no incluye pipeline CI ni archivo de licencia.

## Hoja de ruta

- Conectar autenticacion, upload y procesamiento con APIs reales.
- Reemplazar mocks por repositorios o servicios.
- Agregar persistencia, manejo de errores y reintentos.
- Incorporar pruebas widget e integracion para los flujos principales.
- Sustituir placeholders por capturas reales del producto.
- Publicar una demo web o una build de escritorio para revision interna.

## Contribuir

- Mantene la estructura por features ya existente.
- Reutiliza `core/theme` y `shared/widgets` antes de crear estilos aislados.
- Si tocas un flujo mock, actualiza juntos los archivos `data` y `domain` relacionados.
- Corre `flutter analyze` antes de abrir un cambio.

## Preguntas frecuentes

**La app ya esta conectada a backend?**

No. La implementacion actual es un prototipo frontend con estado local y datos mock.

**La pantalla de carga usa archivos reales?**

Todavia no. La experiencia actual simula el flujo para validar interfaz y recorrido.

**Que plataformas soporta?**

El proyecto Flutter incluye scaffolding para Android, iOS, web, Windows, Linux y macOS.

## Licencia

Este repositorio todavia no incluye un archivo de licencia. Conviene agregarlo antes de abrir el proyecto a uso publico o contribuciones externas.
