@echo off
REM Run from source (no build needed). Needs Python + 'pip install -r requirements.txt' + bin\ffmpeg.exe
cd /d "%~dp0"
python app.py
