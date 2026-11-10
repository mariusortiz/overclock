"""Generates the placeholder sound effects in assets/audio/.

Run from the repo root: python3 tools/make_sounds.py
"""
import math
import random
import struct
import wave

RATE = 44100
OUT = "assets/audio/"


def write(name, samples):
    with wave.open(OUT + name, "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767)) for s in samples))


def shot():
    """Laser zap: falling pitch sweep with a noise burst at the start."""
    rnd = random.Random(1)
    n = int(RATE * 0.14)
    phase = 0.0
    out = []
    for i in range(n):
        t = i / n
        freq = 1500 * (1 - t) ** 2 + 220
        phase += 2 * math.pi * freq / RATE
        tone = math.sin(phase) + 0.4 * math.sin(2 * phase)
        noise = rnd.uniform(-1, 1) * max(0.0, 1 - t * 6)
        out.append(0.45 * (tone * 0.7 + noise * 0.6) * (1 - t) ** 1.5)
    return out


def hit():
    """Short high tick confirming a hit."""
    n = int(RATE * 0.05)
    return [0.4 * math.sin(2 * math.pi * 2400 * i / RATE) * (1 - i / n) ** 2 for i in range(n)]


def pickup():
    """Rising two-note chime."""
    out = []
    for freq in (880, 1320):
        n = int(RATE * 0.09)
        out += [0.35 * math.sin(2 * math.pi * freq * i / RATE) * (1 - i / n) ** 0.7 for i in range(n)]
    return out


write("shot.wav", shot())
write("pickup.wav", pickup())
write("hit.wav", hit())
