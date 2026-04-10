# Numix - Professional Math Suite

## Descripción
Numix es una suite matemática profesional y aplicación móvil desarrollada en Flutter. Proporciona un conjunto de herramientas esenciales para la gestión comercial, incluyendo calculadoras de precios, gestión de descuentos y sistema de inventario, operando bajo reglas estrictas de precisión matemática y una arquitectura escalable.

## Estado del Proyecto
- **Versión**: 1.0.0+1
- **Arquitectura**: Domain-Driven Feature-First (DDD)
- **Gestión de Estado**: `provider`
- **Motor Matemático**: `math_expressions`

## 🏗️ Arquitectura y Estructura (Feature-First)

Este proyecto se adhiere estrictamente a un diseño Domain-Driven adaptado para Flutter. El directorio `lib/` está estructurado así:

*   **`core/`**: Contiene utilidades de toda la aplicación, temas, constantes y formateadores (especialmente para precisión matemática y evitar errores de punto flotante).
*   **`features/`**: Contiene los dominios reales de la aplicación. Cada feature está completamente aislado y contiene su propia UI (`screens`/`widgets`), State Management (`providers`) y Lógica (`services`/`use_cases`).
    *   `calculator/`
    *   `discount_calculator/`
    *   `sales_price_calculator/`
    *   `product_inventory/`
    *   `sales_history/`
    *   `settings/`
    *   `home/`
    *   `welcome/`

### UI Design System

La consistencia visual se gobierna desde tema global y reglas de diseño reutilizable:

*   Tema centralizado en `lib/core/themes/` (Material 3 light/dark).
*   Tokens visuales vía `Theme.of(context).colorScheme` y `textTheme`.
*   Sin colores hardcodeados para componentes de uso general.

## 🧠 Lógica y Reglas de Estado

*   **Widgets "Tontos"**: La interfaz gráfica solo muestra datos y dispara eventos. Toda la lógica matemática, parseo de strings y reglas de negocio residen dentro de los Providers o Servicios.
*   **Seguridad Matemática**: Los cálculos están impulsados por `math_expressions`. Evitamos explícitamente la evaluación directa de strings con `dart:math` para prevenir crashes. Todos los parseos están envueltos en `try/catch` para manejar `FormatExceptions`.
*   **Rendimiento**: Se exige el uso correcto de `context.read()` para eventos y `context.watch()` o `Consumer` exclusivamente para las partes de la UI que necesitan reconstruirse, garantizando 60/120 fps fluidos.

## 🤖 Ecosistema de IA

Este repositorio se mantiene en colaboración con un ecosistema de Agentes de IA. Consulta `AGENTS.md` para ver las directrices operativas estrictas, los subagentes (`ui-ux-agent`, `qa-integration-agent`, `devops-agent`, `tech-writer-agent`, `play-store-architect-agent`) y las skills activas (`clean-architecture-skill`, `provider-state-skill`, `design-system-skill`, `math-precision-skill`, `devsecops-workflow-skill`, `git-ops-skill`) que imponen calidad de código, coherencia visual, integridad arquitectónica y flujo de versionado.

## Instalación y Desarrollo
1. Asegúrate de tener Flutter instalado (`sdk: ^3.6.0`).
2. Clona el repositorio y ejecuta `flutter pub get` para instalar dependencias.
3. Ejecuta `flutter run` para iniciar la aplicación.
4. Ejecuta `flutter test` para ejecutar el ciclo de pruebas.

---
Desarrollado con ❤️ utilizando Flutter bajo el ecosistema de Agentes Numix.
