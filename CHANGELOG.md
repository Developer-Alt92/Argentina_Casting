# Changelog

## 1.0.0 - 2026-04-21

- script PowerShell corregido
- descarga automática de `gallery-dl.exe`
- generación de JSON en UTF-8 sin BOM
- logs separados para stdout y stderr
- `skip = true` para no sobrescribir duplicados
- documentación completa para instalación, uso y subida a GitHub


## v1.0.1

- corregida la descarga del binario de `gallery-dl` para Windows
- validación del ejecutable con `--version` antes de usarlo
- prioridad a `gdl-org/builds` como fuente principal del binario
- se mantiene `skip=true` y `archive.sqlite3` para no sobrescribir duplicados
