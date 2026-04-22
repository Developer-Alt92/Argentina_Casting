# Instalación

## Opción rápida

1. descarga o clona este repositorio
2. abre PowerShell en la carpeta del proyecto
3. ejecuta el script con tu método de autenticación

## Ejemplo

```powershell
.\bajar_x_videos.ps1 -CookiesFile "D:\ArgentCast\cookies.txt"
```

## Notas

- el script descargará `gallery-dl.exe` automáticamente dentro de `tools/`
- la carpeta de salida se crea sola
- el archivo de configuración JSON se genera de forma automática
