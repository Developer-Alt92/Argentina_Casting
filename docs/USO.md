# Uso

## 1. Descargar con cookies.txt

```powershell
.\bajar_x_videos.ps1 -CookiesFile "D:\ArgentCast\cookies.txt"
```

## 2. Descargar con navegador

```powershell
.\bajar_x_videos.ps1 -Browser firefox
```

## 3. Cambiar URL objetivo

```powershell
.\bajar_x_videos.ps1 -AccountUrl "https://x.com/OTRA_CUENTA" -CookiesFile "D:\ArgentCast\cookies.txt"
```

## 4. Cambiar carpeta de salida

```powershell
.\bajar_x_videos.ps1 -OutDir "D:\Videos\Salida" -CookiesFile "D:\ArgentCast\cookies.txt"
```

## Salida esperada

El script mostrará:

- cuenta objetivo
- carpeta de salida
- ruta del config
- ruta del archive
- confirmación de skip activado
- exit code del proceso
- número de videos encontrados
