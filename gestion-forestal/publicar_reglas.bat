@echo off
setlocal
chcp 65001 >nul
rem ============================================================
rem  Publica las reglas de Firestore del proyecto cuadrante-secona
rem  (firestore.rules guardado en GitHub). Se puede ejecutar desde
rem  cualquier carpeta: no toca tu firebase.json ni la carpeta public.
rem ============================================================
set "BASE=https://raw.githubusercontent.com/paloceropalo/APP.PY/claude/bold-meitner-82dkkx/gestion-forestal"
set "DIR=%TEMP%\reglas-cuadrante-secona"
if not exist "%DIR%" mkdir "%DIR%"
cd /d "%DIR%"

echo Descargando firestore.rules...
curl -sS -f -L -o firestore.rules "%BASE%/firestore.rules?t=%RANDOM%%RANDOM%"
if errorlevel 1 (
  echo.
  echo *** ERROR: no se pudo descargar firestore.rules de GitHub. Revisa la conexion. ***
  pause
  exit /b 1
)
for %%A in (firestore.rules) do set SIZE=%%~zA
if %SIZE% LSS 3000 (
  echo.
  echo *** ERROR: firestore.rules ha llegado demasiado pequeno ^(%SIZE% bytes^). No se publica. ***
  pause
  exit /b 1
)
findstr /C:"match /gf_adscripciones" firestore.rules >nul || (
  echo *** ERROR: el archivo descargado no parece el de reglas completo. No se publica. ***
  pause
  exit /b 1
)
echo   Descargado (%SIZE% bytes).

> firebase.json echo {"firestore":{"rules":"firestore.rules"}}

echo.
echo Publicando las reglas en el proyecto cuadrante-secona...
set NODE_OPTIONS=--no-network-family-autoselection
call firebase deploy --only firestore:rules --project cuadrante-secona
if errorlevel 1 (
  echo.
  echo *** ERROR: las reglas no se han publicado. Revisa los mensajes de arriba. ***
  echo Si dice que no has iniciado sesion, ejecuta:  firebase login
  pause
  exit /b 1
)
echo.
echo Listo: reglas publicadas.
pause
exit /b 0
