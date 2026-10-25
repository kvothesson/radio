# Radio Austral en vivo: un Chromium en pantalla virtual toca la página en modo vivo
# y ffmpeg manda imagen y sonido a YouTube por RTMP. Anda en x86 y en ARM (Oracle Free).
FROM debian:bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      chromium xvfb pulseaudio pulseaudio-utils ffmpeg \
      fonts-dejavu-core ca-certificates procps \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m radio

COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

ENTRYPOINT ["/usr/local/bin/start.sh"]
