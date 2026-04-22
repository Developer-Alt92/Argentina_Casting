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


## Error: PyInstaller's embedded PKG archive

Si ves un error parecido a este:

```text
[PYI-3848:ERROR] Could not load PyInstaller's embedded PKG archive
```

la causa suele ser un ejecutable inválido o incompleto de `gallery-dl.exe`.

Qué hace esta versión del proyecto:

1. intenta descargar primero `gallery-dl_windows.exe` desde `gdl-org/builds`;
2. valida el binario ejecutando `--version`;
3. solo lo usa si pasa esa validación;
4. si falla, prueba el release clásico de `mikf/gallery-dl`.

Arreglo manual rápido:

1. borra `tools\gallery-dl.exe`
2. vuelve a ejecutar el script
3. confirma que en pantalla aparezca una línea `Version  : ...` antes de iniciar la descarga
