# Subir este proyecto a GitHub

Repositorio objetivo:

```text
https://github.com/Developer-Alt92/Argentina_Casting.git
```

## Desde cero

```powershell
cd D:\ArgentCast\Argentina_Casting
git config --global --add safe.directory D:/ArgentCast/Argentina_Casting
git config --global user.name "Developer Alt92"
git config --global user.email "TU_CORREO_DE_GITHUB"
git init
git branch -M main
git add .
git commit -m "Primer commit del proyecto Argentina_Casting"
git remote remove origin 2>$null
git remote add origin https://github.com/Developer-Alt92/Argentina_Casting.git
git push -u origin main
```

## Si el remoto ya existe y tiene archivos

```powershell
cd D:\ArgentCast\Argentina_Casting
git fetch origin
git pull origin main --allow-unrelated-histories --no-rebase
```

Si aparecen conflictos y quieres conservar tu versión local de `README.md` y `LICENSE`:

```powershell
git checkout --ours README.md LICENSE
git add README.md LICENSE
git commit -m "Resolver merge conservando archivos locales"
git push -u origin main
```

## Si ya existe `origin`

```powershell
git remote set-url origin https://github.com/Developer-Alt92/Argentina_Casting.git
git push -u origin main
```
