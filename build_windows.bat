@echo off
REM ===== ViralClip AI Studio - Windows portable build =====
REM Run this ONCE on a Windows 10/11 PC with Python 3.10, 3.11 or 3.12 (64-bit; NOT 3.13+) - the script installs 3.12 automatically if missing installed and internet access.
REM Result: dist\ViralClipAIStudio\ViralClipAIStudio.exe  (copy the whole folder anywhere / to a USB drive)
setlocal
cd /d "%~dp0"

echo [1/5] Looking for Python 3.12 / 3.11 / 3.10 (newer versions like 3.13+ lack some packages)...
set PYV=
for %%V in (3.12 3.11 3.10) do (
  if not defined PYV (
    py -%%V -c "import sys" >nul 2>&1 && set PYV=%%V
  )
)
if not defined PYV (
  echo Python 3.12 not found. Installing it with the Python install manager...
  py install 3.12 || goto :err
  set PYV=3.12
)
echo Using Python %PYV%
py -%PYV% -m venv .venv || goto :err
call .venv\Scripts\activate.bat
python -m pip install --upgrade pip || goto :err

echo [2/5] Installing dependencies...
pip install -r requirements.txt || goto :err

echo [3/5] Getting FFmpeg (GPL build by BtbN, redistributable under GPL)...
if not exist bin\ffmpeg.exe (
  powershell -NoProfile -Command "Invoke-WebRequest https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip -OutFile ffmpeg.zip" || goto :err
  powershell -NoProfile -Command "Expand-Archive ffmpeg.zip -DestinationPath ffmpeg_tmp -Force" || goto :err
  for /d %%D in (ffmpeg_tmp\*) do (
    copy "%%D\bin\ffmpeg.exe" bin\ >nul
    copy "%%D\bin\ffprobe.exe" bin\ >nul
  )
  rmdir /s /q ffmpeg_tmp & del ffmpeg.zip
)

echo [4/5] Building with PyInstaller (folder mode - most reliable with Qt + Whisper)...
pyinstaller --noconfirm --clean --windowed --name ViralClipAIStudio ^
  --collect-all faster_whisper --collect-all ctranslate2 --collect-all av ^
  --collect-all onnxruntime --collect-all yt_dlp --collect-submodules PySide6.QtMultimedia ^
  app.py || goto :err
mkdir dist\ViralClipAIStudio\bin 2>nul
copy bin\ffmpeg.exe dist\ViralClipAIStudio\bin\ >nul
copy bin\ffprobe.exe dist\ViralClipAIStudio\bin\ >nul
copy README.md dist\ViralClipAIStudio\ >nul

echo [5/5] OPTIONAL: pre-download the Whisper 'base' model (~140 MB) so the first run works offline.
set /p DL="Download now? (y/n): "
if /i "%DL%"=="y" (
  mkdir dist\ViralClipAIStudio\data\models 2>nul
  python -c "from faster_whisper import WhisperModel; WhisperModel('base', download_root=r'dist\ViralClipAIStudio\data\models')"
)
echo.
echo DONE.  Run: dist\ViralClipAIStudio\ViralClipAIStudio.exe
exit /b 0
:err
echo BUILD FAILED. Scroll up for the error and see README.md - Troubleshooting.
pause
exit /b 1
