# Radio Austral

Música generativa infinita del Universo Austral, sintetizada en el navegador con [Strudel](https://strudel.cc). Nunca suena igual dos veces.

**Escuchala:** https://kvothesson.com/radio/

> El frío computa, el calor recuerda.

## Estaciones

| Dial | Estilo | Carácter |
|---|---|---|
| 01 · FM CALOR 404 | Cumbia glitch | Güira, bombo en el 1 y el 3, bajo en tumbao, acordeón en terceras |
| 02 · NEO-BA 2074 | Milonga cyberpunk | 3-3-2, marcato en cuatro, bandoneón sintético |
| 03 · GLACIAR | Folklore electrónico | 6/8, bombo legüero, quena pentatónica, charango, viento |

## Cómo funciona

- Toda la radio es un único patrón de Strudel. Cada 8 compases, el reloj de Strudel pide la sección siguiente y se arma en ese momento, con una semilla propia: ritmos, melodía, bajo, energía y capas. Por eso sigue mutando aunque la pestaña quede en segundo plano.
- Cada 4 secciones cambian la tonalidad, el modo, el tempo y los timbres.
- La salida pasa por un compresor y una saturación `tanh`, así que la señal nunca llega a 1 y no puede clipear. Un vigía reanuda el audio si detecta silencio.
- El visual es un canvas 2D (cristal hexagonal, espectro radial, osciloscopio y glitches en los golpes fuertes), con un tope de píxeles para que ande en celulares.

Es un solo archivo, `index.html`, sin build. Para probarlo en local:

```bash
python -m http.server 8000
```

y abrí http://localhost:8000/.

## Licencia

AGPL-3.0, igual que Strudel.
