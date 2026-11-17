@echo off
setlocal
chcp 65001 >nul
rem ============================================================
rem  Actualiza public\gestion_forestal.html con la ultima version
rem  guardada en GitHub y publica el sitio cuadrante-secona.
rem  Coloca este archivo en la carpeta hosting-gpex.
rem ============================================================
cd /d "%~dp0"

if not exist "public" (
  echo No encuentro la carpeta "public". Coloca este archivo dentro de hosting-gpex.
  pause
  exit /b 1
)

set "URL=https://raw.githubusercontent.com/paloceropalo/APP.PY/claude/bold-meitner-82dkkx/gestion-forestal/gestion_forestal.html"
set "TMPFILE=%TEMP%\gestion_forestal_nuevo.html"

echo Descargando la ultima version de gestion_forestal.html...
curl -sS -f -L -o "%TMPFILE%" "%URL%?t=%RANDOM%%RANDOM%"
if errorlevel 1 (
  echo.
  echo *** ERROR: no se pudo descargar el archivo de GitHub. Revisa la conexion. ***
  pause
  exit /b 1
)

for %%A in ("%TMPFILE%") do set SIZE=%%~zA
if %SIZE% LSS 10000 (
  echo.
  echo *** ERROR: el archivo descargado es demasiado pequeno ^(%SIZE% bytes^). No se copia. ***
  pause
  exit /b 1
)

copy /Y "%TMPFILE%" "public\gestion_forestal.html" >nul
del "%TMPFILE%" >nul 2>&1
echo Copiado en public\gestion_forestal.html (%SIZE% bytes).
echo.

echo Publicando en Firebase (sitio cuadrante-secona)...
set NODE_OPTIONS=--no-network-family-autoselection
call firebase deploy --only hosting:cuadrante-secona
if errorlevel 1 (
  echo.
  echo *** ERROR: el deploy no se ha completado. Revisa los mensajes de arriba. ***
  pause
  exit /b 1
)

echo.
echo Listo: https://cuadrante-secona.web.app/gestion_forestal.html
pause
