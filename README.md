# ViralClip AI Studio

Desktop tool (Python + PySide6 + FFmpeg + faster-whisper) that finds engaging moments in a video, adds captions
and exports 9:16 / 16:9 / 1:1 / 4:5 MP4 clips. Everything runs locally unless you opt in to the external-AI re-rank.

## Quick start
**A. Build the portable app (Windows 10/11, Python 3.10–3.12, 64-bit; NOT 3.13+):** double-click `build_windows.bat`.
Output: `dist\ViralClipAIStudio\` → copy this *whole folder* to any PC/USB and run `ViralClipAIStudio.exe`.

**B. Run from source:** `pip install -r requirements.txt`, put `ffmpeg.exe` + `ffprobe.exe` in `bin\`, then `python app.py`.

## Where files go (portable, next to the exe)
`data\settings.json` · `data\viralclip.db` (projects) · `data\app.log` · `data\models\` (Whisper) ·
`data\downloads\` (YouTube downloads) · `output\` (exported clips, changeable).

## First-run requirements
* Whisper model downloads on first Analyze (base ≈ 140 MB) unless pre-downloaded by the build script.
* YouTube: needs internet; yt-dlp downloads only what is publicly accessible. Private / login / DRM / blocked videos
  fail with a clear message → use **Import Local Video**. Only process videos you own or have permission to use.
* Optional AI re-rank needs your own Anthropic API key (Settings) + explicit consent checkbox. Transcript text is
  sent to the provider only when that box and the Analyze checkbox are both ticked. The key is saved in plain text in
  `data\settings.json` (portable, not encrypted) — don't share that folder.
* NVIDIA GPU: Device = `auto` uses CUDA only if CUDA libraries are present; otherwise CPU (int8).

## Workflow
1. **Source**: paste URL → Fetch Info → Download (or Import Local Video). Choose clip count, duration, language → Analyze.
2. **Clips**: review score/reason, preview, trim, split, delete, untick to skip.
3. **Captions**: fix transcript text (affects burned-in and .srt output).
4. **Export**: aspect, layout (blur background / fill-crop), resolution, quality, fps, caption style → Export.
   Results show the *measured* resolution, duration and file size of each file.

## Tests
`python -m pytest tests` (needs ffmpeg). Verified: probe, exact output sizes for all 4 aspect ratios, subtitle
burn-in, cancel cleanup, highlight rules, consent gate, URL validation, project DB.

## Known limits (honest list)
* Auto speaker tracking/face reframing, background music, logo/intro/outro, text overlays, word-highlight animation
  and merge-clips are **not implemented** yet (blur/fill layouts and 3-word caption groups are).
* Urdu/Hindi transcription runs but accuracy is lower than English (experimental).
* Highlight ranking is a transparent heuristic (hook words, questions, numbers, emotion, pace, sentence completeness);
  it does not predict virality.
* Windows build, audio preview and the Whisper download were NOT tested in the development sandbox — test on a
  clean Windows PC before treating it as portable.

## Troubleshooting
* *"ffmpeg not found"* → place `ffmpeg.exe`, `ffprobe.exe` in `bin\`.
* *App crashes at start with no audio device* → set environment variable `VIRALCLIP_NO_AUDIO=1`.
* *Antivirus flags the exe* → common with PyInstaller; add an exclusion for the folder.
* *Slow transcription* → use Whisper `tiny`/`base` in Settings.
* Logs: `data\app.log`.
