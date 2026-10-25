#!/usr/bin/env bash
# Transmite Radio Austral. Variables:
#   YOUTUBE_KEY   clave de transmisión de YouTube Live (obligatoria salvo que se use OUTPUT)
#   OUTPUT        en vez de YouTube, graba a este archivo (para pruebas); DURATION segundos (60)
#   RADIO_URL     página a transmitir (https://kvothesson.com/radio/?vivo)
#   WIDTH HEIGHT FPS VIDEO_BITRATE   1280 720 30 3000k
#   RESTART_HOURS cada cuántas horas se reinicia Chromium por higiene (12)
set -euo pipefail

# Chromium y PulseAudio no quieren correr como root
if [ "$(id -u)" = "0" ]; then exec runuser -u radio -- "$0" "$@"; fi

W=${WIDTH:-1280}; H=${HEIGHT:-720}; FPS=${FPS:-30}; VB=${VIDEO_BITRATE:-3000k}
URL=${RADIO_URL:-https://kvothesson.com/radio/?vivo}

if [ -n "${OUTPUT:-}" ]; then
  DEST=(-t "${DURATION:-60}" -f mp4 "$OUTPUT")
elif [ -n "${YOUTUBE_KEY:-}" ]; then
  DEST=(-f flv "rtmp://a.rtmp.youtube.com/live2/${YOUTUBE_KEY}")
else
  echo "Falta YOUTUBE_KEY (o OUTPUT para grabar una prueba)" >&2; exit 1
fi

export HOME=/home/radio DISPLAY=:99 XDG_RUNTIME_DIR=/tmp/radio-run
mkdir -p "$XDG_RUNTIME_DIR"

Xvfb :99 -screen 0 "${W}x${H}x24" -nolisten tcp >/dev/null 2>&1 &
pulseaudio -D --exit-idle-time=-1 --disallow-exit --log-target=stderr 2>/dev/null
until pactl info >/dev/null 2>&1; do sleep 0.5; done
pactl load-module module-null-sink sink_name=radio sink_properties=device.description=radio >/dev/null
pactl set-default-sink radio

navegador() {
  while true; do
    rm -rf /tmp/radio-chrome
    timeout "${RESTART_HOURS:-12}h" chromium \
      --no-sandbox --no-first-run --no-default-browser-check --noerrdialogs --disable-infobars \
      --kiosk --window-position=0,0 --window-size="${W},${H}" --user-data-dir=/tmp/radio-chrome \
      --autoplay-policy=no-user-gesture-required \
      --disable-background-timer-throttling --disable-renderer-backgrounding \
      --disable-backgrounding-occluded-windows --disable-features=Translate,MediaRouter \
      "$URL" >/dev/null 2>&1 || true
    echo "[radio] chromium terminó, reinicio en 3 s"
    sleep 3
  done
}
navegador &

# margen para que cargue la página y suene el primer compás
sleep "${WARMUP:-12}"

while true; do
  ffmpeg -hide_banner -loglevel warning \
    -thread_queue_size 1024 -f x11grab -draw_mouse 0 -video_size "${W}x${H}" -framerate "$FPS" -i :99 \
    -thread_queue_size 1024 -f pulse -i radio.monitor \
    -c:v libx264 -preset veryfast -pix_fmt yuv420p -b:v "$VB" -maxrate "$VB" -bufsize 6000k -g $((FPS * 2)) \
    -c:a aac -b:a 160k -ar 44100 \
    "${DEST[@]}" || true
  if [ -n "${OUTPUT:-}" ]; then
    kill $(jobs -p) 2>/dev/null; pkill -u radio chromium 2>/dev/null; pkill -u radio Xvfb 2>/dev/null; pulseaudio -k 2>/dev/null
    break
  fi
  echo "[radio] ffmpeg cayó, reconecto en 5 s"
  sleep 5
done
