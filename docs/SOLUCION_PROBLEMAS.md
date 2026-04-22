# Solución de problemas

## 1. `No encuentro 'gallery-dl' en PATH`

No aplica a esta versión si usas el script incluido, porque descarga `gallery-dl.exe` automáticamente.

## 2. `JSONDecodeError when loading gallery-dl-config.json`

Esta versión escribe el JSON en UTF-8 sin BOM y lo valida antes de ejecutar.

## 3. `NativeCommandError` con mensajes `[twitter][info]`

Esta versión usa `Start-Process` y revisa el `ExitCode` real.
Los mensajes informativos ya no rompen el flujo por sí solos.

## 4. `skip` / no sobrescribir archivos

Está activado con:

- `skip = true`
- `archive.sqlite3`

## 5. Conflictos al subir a GitHub

Si el repo remoto ya tiene README o LICENSE y quieres conservar tus archivos locales:

```powershell
git checkout --ours README.md LICENSE
git add README.md LICENSE
git commit -m "Resolver merge conservando archivos locales"
git push -u origin main
```
