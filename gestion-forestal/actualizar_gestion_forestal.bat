@echo off
setlocal
chcp 65001 >nul
rem ============================================================
rem  Actualiza public\gestion_forestal.html (incluye la consulta de personal)
rem  guardada en GitHub y publica el sitio cuadrante-secona.
rem  Coloca este archivo en la carpeta hosting-gpex.
rem ============================================================
cd /d "%~dp0"

if not exist "public" (
  echo No encuentro la carpeta "public". Coloca este archivo dentro de hosting-gpex.
  pause
  exit /b 1
)

set "BASE=https://raw.githubusercontent.com/paloceropalo/APP.PY/claude/bold-meitner-82dkkx/gestion-forestal"

for %%F in (gestion_forestal.html) do (
  call :descargar %%F
  if errorlevel 1 exit /b 1
)
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
exit /b 0

rem ---- Descarga un archivo de GitHub, comprueba que no esta vacio y lo copia en public ----
:descargar
set "TMPFILE=%TEMP%\%~1"
echo Descargando %~1...
curl -sS -f -L -o "%TMPFILE%" "%BASE%/%~1?t=%RANDOM%%RANDOM%"
if errorlevel 1 (
  echo.
  echo *** ERROR: no se pudo descargar %~1 de GitHub. Revisa la conexion. ***
  pause
  exit /b 1
)
for %%A in ("%TMPFILE%") do set SIZE=%%~zA
if %SIZE% LSS 10000 (
  echo.
  echo *** ERROR: %~1 ha llegado demasiado pequeno ^(%SIZE% bytes^). No se copia. ***
  pause
  exit /b 1
)
copy /Y "%TMPFILE%" "public\%~1" >nul
del "%TMPFILE%" >nul 2>&1
echo   Copiado en public\%~1 (%SIZE% bytes).
exit /b 0
