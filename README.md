# Frontend

## Prompt para generar un README premium

````text
Quiero que actues como un Senior Technical Writer, maintainer open source y disenador visual experto en GitHub READMEs.

Tu tarea es crear un README espectacular, claro, profesional y visualmente memorable para mi proyecto, junto con los archivos SVG necesarios para que el repositorio se vea premium en GitHub.

Objetivo:
- Redactar un `README.md` que convierta visitas en uso, contribuciones o stars.
- Hacer que el README sea limpio, moderno, escaneable y confiable.
- Disenar assets SVG coherentes con la identidad del proyecto.
- Mantener compatibilidad real con GitHub.

Entrega exactamente esto:
1. `README.md`
2. `assets/banner.svg`
3. `assets/separator.svg`
4. `assets/stack.svg`
5. `assets/architecture.svg` (solo si aplica)
6. `assets/demo-placeholder.svg` (si no tengo screenshots reales)

Reglas criticas:
- Usa Markdown + HTML simple compatible con GitHub.
- No uses JavaScript.
- No dependas de CSS externo.
- No insertes SVG inline dentro del README si puede afectar compatibilidad; usa archivos `.svg` locales y refierete a ellos con `<img src="./assets/...">`.
- Usa una estetica consistente, moderna y no generica.
- Prioriza legibilidad, jerarquia visual, buen espaciado y contraste.
- El tono debe ser profesional, preciso y persuasivo, sin frases vacias.
- Si falta informacion, no inventes datos criticos: usa placeholders claros como `[AGREGA TU URL]`, `[AGREGA SCREENSHOT]`, `[AGREGA TOKEN]`.
- Adapta el README al tipo de proyecto: app web, API, libreria, CLI, bot, SaaS, plantilla, etc.
- Si algo no aplica, omitelo con criterio.
- Si una seccion no tiene informacion suficiente, entrega una version minima util con placeholders claros en vez de eliminar valor innecesariamente.
- Manten todo listo para copiar y pegar en un repositorio real.

Quiero que el `README.md` incluya, si corresponde:
- Hero section centrada con banner SVG.
- Nombre del proyecto y tagline potente de una linea.
- Badges utiles y elegantes.
- Descripcion breve del problema que resuelve.
- Seccion "Demo" con screenshot, GIF o placeholder.
- Tabla de contenidos.
- Seccion "Features" con beneficios claros.
- Seccion "Tech Stack".
- Seccion "Arquitectura" o diagrama si aporta valor.
- Instalacion paso a paso.
- Variables de entorno en bloque claro.
- Uso rapido con ejemplos reales.
- Scripts disponibles.
- Estructura del proyecto.
- Flujo de desarrollo o despliegue si aplica.
- Roadmap.
- Contribucion.
- Licencia.
- Autor, contacto y links relevantes.
- FAQ breve si aporta claridad.

Criterios de diseno:
- Disena un README que se sienta como un mini landing page dentro de GitHub.
- Usa `p align="center"` e imagenes con tamanos razonables cuando mejore el layout.
- Evita tablas pesadas si perjudican mobile.
- Usa separadores SVG con buen gusto, no adornos innecesarios.
- El banner SVG debe verse limpio, tecnologico y con personalidad.
- El SVG de stack debe mostrar tecnologias de forma visual y ordenada.
- El SVG de arquitectura debe ser minimalista, entendible y profesional.
- Si no hay branding definido, propon una direccion visual sobria y moderna.
- Incluye `alt` text util en imagenes.
- Manten el resultado listo para copiar y pegar.
- Evita una estetica generica de plantilla; busca un look mas editorial, tecnico y premium.
- Asegurate de que el README sea escaneable tanto en desktop como en mobile.

Logica de adaptacion:
- Si el proyecto es una API o backend, prioriza endpoints, auth, ejemplos de requests/responses y arquitectura.
- Si el proyecto es una libreria o SDK, prioriza instalacion, ejemplos de uso, API surface y casos de uso.
- Si el proyecto es una app web o SaaS, prioriza valor del producto, screenshots/demo, features y flujo de uso.
- Si el proyecto es CLI, prioriza instalacion, comandos, flags, ejemplos y output esperado.
- Si el proyecto es un template o boilerplate, prioriza stack, estructura, setup y casos de uso.
- Si la arquitectura no aporta valor real, omite `assets/architecture.svg`.

Formato de salida obligatorio:
- Primero escribe una sola linea muy corta con la identidad visual propuesta.
- Luego entrega cada archivo por separado.
- Cada archivo debe venir con este formato exacto:

### README.md
```md
...contenido completo...
```

### assets/banner.svg
```svg
...contenido completo...
```

### assets/separator.svg
```svg
...contenido completo...
```

### assets/stack.svg
```svg
...contenido completo...
```

### assets/architecture.svg
```svg
...contenido completo...
```

### assets/demo-placeholder.svg
```svg
...contenido completo...
```

Reglas de salida:
- No expliques lo que vas a hacer.
- No des consejos aparte.
- No entregues borradores parciales.
- No dejes texto fuera del formato pedido, excepto la linea inicial de identidad visual.
- Entrega directamente los archivos finales listos para usar.
- Si `assets/architecture.svg` no aplica, escribe exactamente: `No aplica para este proyecto.` en lugar de inventar un diagrama.
- Si ya hay screenshots reales, no generes `assets/demo-placeholder.svg`; escribe exactamente: `No aplica porque hay screenshots reales.`

Usa estos datos del proyecto:

- Nombre del proyecto: [NOMBRE]
- Tipo de proyecto: [WEB / API / LIBRERIA / CLI / BOT / SAAS / OTRO]
- Descripcion corta: [QUE HACE]
- Problema que resuelve: [PROBLEMA]
- Publico objetivo: [USUARIOS]
- Propuesta de valor: [POR QUE ES DIFERENTE]
- Features principales: [LISTA]
- Tech stack: [TECNOLOGIAS]
- Comando de instalacion: [COMANDO]
- Comando de desarrollo: [COMANDO]
- Comando de build: [COMANDO]
- Comando de test: [COMANDO]
- Variables de entorno: [LISTA]
- Estructura de carpetas: [ARBOL O RESUMEN]
- Demo URL: [URL]
- Repo URL: [URL]
- Documentacion URL: [URL]
- Licencia: [LICENCIA]
- Autor / organizacion: [NOMBRE]
- Email o contacto: [CONTACTO]
- Screenshots disponibles: [SI/NO]
- Idioma del README: [ES / EN / BILINGUE]

Si detectas que mi proyecto encaja mejor con otra estructura de README, ajustala sin perder calidad visual ni claridad.
````
