# Git Commit Message Convention

> Esta convención asegura que todos los commits sean claros, consistentes y generen un changelog limpio. Basado en el estilo de Angular.

## Estructura del mensaje

```txt
<type>(<scope>): <subject>
```

### Ejemplos válidos

```txt
feat(auth): add Google Sign-In
fix(home): prevent crash on scroll
refactor(theme): simplify color logic
chore: update Flutter SDK version
revert: feat(onboarding): remove welcome screen
```

## Tipos permitidos

| Tipo     | Descripción                                 |
| -------- | ------------------------------------------- |
| feat     | Nueva funcionalidad                         |
| fix      | Corrección de bugs                          |
| style    | Cambios de formato/código (sin lógica)      |
| refactor | Cambios internos sin afectar comportamiento |
| perf     | Mejoras de rendimiento                      |
| test     | Cambios en pruebas                          |
| chore    | Mantenimiento general                       |
| ci       | Configuración de CI/CD                      |
| workflow | Cambios en GitHub Actions u otros flujos    |
| types    | Cambios en modelos/tipos                    |
| wip      | Trabajo en progreso                         |
| revert   | Reversión de un commit anterior             |

## Reglas al escribir el commit

* Usa **presente, imperativo**: `add`, `fix`, `refactor`, no `added` o `fixes`.
* No usar punto al final.
* Máximo **72 caracteres** en `<subject>`.

## Instalación de Hooks

Después de clonar el proyecto y correr `flutter pub get`, instala el hook con:

```bash
dart tool/install_hooks.dart
```

Esto activará un hook que impide commits con formato incorrecto.
