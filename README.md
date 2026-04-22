# Argentina Casting X Video Downloader

Script en PowerShell para descargar videos públicos de una cuenta de X/Twitter usando `gallery-dl`, con soporte para cookies, archivo de historial y modo seguro para no sobrescribir duplicados.

## Qué hace

- descarga automáticamente `gallery-dl.exe` si no existe
- genera la configuración JSON en UTF-8 sin BOM
- soporta cookies desde `cookies.txt` o perfil del navegador
- guarda un archivo de historial (`archive.sqlite3`)
- hace **skip** si el archivo ya existe o si ya fue registrado en el archive
- separa `stdout`, `stderr` y un log combinado
- evita que PowerShell falle por mensajes informativos enviados a `stderr`

## Estructura del repositorio

```text
.
├── bajar_x_videos.ps1
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── .gitignore
├── .gitattributes
├── .github/
│   └── ISSUE_TEMPLATE/
│       └── bug_report.md
└── docs/
    ├── INSTALACION.md
    ├── USO.md
    ├── PUSH_GITHUB.md
    └── SOLUCION_PROBLEMAS.md
```

## Requisitos

- Windows PowerShell o PowerShell 7
- conexión a internet
- una sesión válida de X/Twitter si el sitio exige autenticación
- opcional: archivo `cookies.txt`

## Uso rápido

### Con archivo de cookies

```powershell
.\bajar_x_videos.ps1 -CookiesFile "D:\ArgentCast\cookies.txt"
```

### Con navegador

```powershell
.\bajar_x_videos.ps1 -Browser firefox
```

## Parámetros

- `-AccountUrl`  
  URL del perfil de X.  
  Valor por defecto: `https://x.com/ArgentCasting`

- `-OutDir`  
  Carpeta donde se guardan videos y logs.

- `-Browser`  
  Navegador a usar si no se pasa `-CookiesFile`.  
  Valores válidos: `firefox`, `chrome`, `edge`, `brave`, `chromium`

- `-CookiesFile`  
  Ruta a un archivo `cookies.txt`.

## Comportamiento con archivos repetidos

Este repositorio está configurado para **no sobrescribir** archivos ya descargados.

Lo logra de dos formas:

1. `skip = true`
2. `archive.sqlite3`

Eso significa que si vuelves a correr el script y el video ya fue descargado, se hará **skip**.

## Logs

Dentro de la carpeta de salida se generan:

- `gallery-dl-config.json`
- `archive.sqlite3`
- `gallery-dl.stdout.log`
- `gallery-dl.stderr.log`
- `descarga.log`

## Subir a GitHub

Consulta:

- `docs/PUSH_GITHUB.md`

## Aviso

Úsalo solo con contenido que tengas derecho a descargar y conservar.
