# Radio Austral en vivo (YouTube 24/7)

Un contenedor que abre `https://kvothesson.com/radio/?vivo` en un Chromium sobre una pantalla virtual y manda imagen (1280x720, 30 fps) y sonido a YouTube Live con ffmpeg. La música se compone en el servidor, así que no depende de ninguna compu personal.

- Si Chromium se cae, se reinicia solo, y además se reinicia cada 12 h por higiene.
- Si ffmpeg pierde la conexión, reconecta a los 5 s.
- Las estaciones rotan solas cada 12 a 20 minutos.

> Estado: el contenedor todavía no se probó en un servidor. El modo vivo de la página sí está probado en local: arranca sin clic, suena y no clipea.

## 1. YouTube

1. En YouTube Studio, entrá a **Crear → Emitir en vivo**. La primera vez YouTube tarda hasta 24 h en habilitar el streaming del canal.
2. Elegí **Transmisión** (no "Webcam") y creá una transmisión con estas opciones:
   - título: `Radio Austral · música generativa 24/7 del Universo Austral`
   - visibilidad: **no listada** para la primera prueba
   - latencia: normal
3. Copiá la **clave de transmisión**. Es una contraseña: no la pegues en chats, issues ni commits.

## 2. Servidor gratis: Oracle Cloud Always Free

1. Creá la cuenta en cloud.oracle.com. Pide tarjeta para verificar identidad; el plan Always Free no cobra.
2. **Compute → Instances → Create instance**:
   - imagen: Ubuntu 22.04 o 24.04
   - forma: **VM.Standard.A1.Flex** (Ampere ARM), 2 OCPU y 12 GB de RAM, que entran en lo gratuito
   - descargá la clave SSH que te ofrece
   - si dice "Out of capacity", probá otra zona de disponibilidad o reintentá más tarde
3. Conectate por SSH e instalá Docker:

```bash
sudo apt-get update && sudo apt-get install -y docker.io git
```

```bash
sudo usermod -aG docker $USER && newgrp docker
```

## 3. Arrancar la radio

```bash
git clone https://github.com/kvothesson/radio.git && cd radio/stream
```

```bash
docker build -t radio-austral .
```

Prueba de 60 segundos a archivo, sin salir al aire:

```bash
docker run --rm --shm-size=1g -e OUTPUT=/tmp/out/prueba.mp4 -v $PWD:/tmp/out radio-austral
```

Si `prueba.mp4` tiene imagen y sonido, salí al aire. El comando lee la clave sin mostrarla en pantalla:

```bash
read -s -p "Clave de YouTube: " YT && docker run -d --name radio --restart unless-stopped --shm-size=1g -e YOUTUBE_KEY="$YT" radio-austral && unset YT
```

Para ver el estado y los logs:

```bash
docker logs -f radio
```

## Variables

| Variable | Por defecto | Para qué |
|---|---|---|
| `YOUTUBE_KEY` | (obligatoria) | clave de transmisión |
| `RADIO_URL` | `https://kvothesson.com/radio/?vivo` | página que se transmite |
| `WIDTH` / `HEIGHT` / `FPS` | 1280 / 720 / 30 | resolución y cuadros por segundo |
| `VIDEO_BITRATE` | 3000k | bitrate de video (YouTube recomienda entre 2500 y 4000 para 720p) |
| `RESTART_HOURS` | 12 | cada cuántas horas se reinicia Chromium |
| `OUTPUT` / `DURATION` | | graba a archivo en vez de transmitir (para pruebas) |

Si el servidor no llega a 30 fps, usá `-e FPS=24 -e VIDEO_BITRATE=2500k`.
