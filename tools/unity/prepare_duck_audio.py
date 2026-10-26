"""Original duck quacks in the MUSIC2 rubbery 140 BPM palette; BGM stays intact."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

import imageio_ffmpeg
import numpy as np

from prepare_rhythm_audio import BEAT, SR, ROOT, save

WORK = ROOT / 'work/duck-audio-20261025/audio'
ASSETS = ROOT / 'projects/catch-big-goose-unity/Assets/Resources/Audio'


def quack(duration, midi, seed):
    rng = np.random.default_rng(seed)
    t = np.arange(round(duration * SR)) / SR
    x = t / duration
    fundamental = 440 * 2 ** ((midi - 69) / 12)
    # A descending, irregular reed excites broad nasal vowel resonances. This
    # creates the "ga" body; a sine/plucked note alone sounds like a UI beep.
    f0 = fundamental * (1 + .43 * np.exp(-t / .026))
    f0 *= 1 + .014 * np.sin(2 * np.pi * 41 * t) + .006 * rng.normal(size=len(t))
    phase = 2 * np.pi * np.cumsum(f0) / SR
    voice = np.zeros_like(t)
    for harmonic in range(1, 21):
        hz = harmonic * fundamental
        resonance = .18 + 1.6 * np.exp(-.5 * ((hz - 750) / 210) ** 2)
        resonance += .9 * np.exp(-.5 * ((hz - 1450) / 260) ** 2)
        resonance += .35 * np.exp(-.5 * ((hz - 2400) / 380) ** 2)
        voice += resonance / harmonic ** .78 * np.sin(harmonic * phase + .13 * harmonic)
    air = rng.normal(size=len(t))
    frequencies = np.fft.rfftfreq(len(t), 1 / SR)
    air_filter = np.exp(-.5 * ((frequencies - 1050) / 620) ** 2)
    air = np.fft.irfft(np.fft.rfft(air) * air_filter, len(t))
    air /= max(np.sqrt(np.mean(air ** 2)), 1e-9)
    # The rough opening, rounded body and dry ending fit the existing short
    # rubber notes. No sharp hiss, long reverb or ambient animal recording.
    envelope = np.minimum(t / .007, 1) * np.minimum((duration - t) / .024, 1)
    envelope *= np.sin(np.pi * np.clip(x, 0, 1)) ** .35 * np.exp(-1.7 * x)
    signal = np.tanh((voice + .16 * air) * 1.45) * envelope
    lowpass = np.exp(-(frequencies / 3300) ** 6)
    signal = np.fft.irfft(np.fft.rfft(signal) * lowpass, len(t))
    signal *= np.minimum(t / .004, 1) * np.minimum((duration - t) / .012, 1)
    return signal


def pair(index):
    # C/G, D/A and E/C all belong to the music's C-major note palette.
    notes = [(60, 55), (62, 57), (64, 60)][index]
    gap = BEAT * [.5, .475, .525][index]
    result = np.zeros(round((gap + .18) * SR))
    for n, (duration, midi) in enumerate(zip((.145, .18), notes)):
        voice = quack(duration, midi, 2026102500 + index * 2 + n)
        start = 0 if n == 0 else round(gap * SR)
        result[start:start + len(voice)] += voice * (1 if n == 0 else .83)
    result *= .58 / np.max(np.abs(result))
    return result


def stats(data):
    f = np.fft.rfftfreq(len(data), 1 / SR)
    power = np.abs(np.fft.rfft(data)) ** 2
    return dict(seconds=len(data) / SR, peak=float(np.max(np.abs(data))),
                rms=float(np.sqrt(np.mean(data ** 2))),
                above4k=float(power[f > 4000].sum() / max(power.sum(), 1e-9)),
                firstSample=float(data[0]), lastSample=float(data[-1]))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--install', action='store_true')
    args = parser.parse_args()
    WORK.mkdir(parents=True, exist_ok=True)
    before = {f.name: hashlib.sha256(f.read_bytes()).hexdigest() for f in ASSETS.iterdir() if f.suffix in ('.ogg', '.wav') and not f.name.startswith('duck-quack-')}
    voices = [pair(i) for i in range(3)]
    rows = []
    for i, data in enumerate(voices):
        name = f'duck-quack-{i + 1}.wav'
        save(WORK / name, data)
        if args.install:
            (ASSETS / name).write_bytes((WORK / name).read_bytes())
        rows.append(dict(file=name, **stats(data)))
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    raw = subprocess.run([ffmpeg, '-v', 'error', '-i', str(ASSETS / 'bgm.ogg'), '-f', 'f32le', '-ac', '2', '-ar', str(SR), '-'], check=True, capture_output=True).stdout
    music = np.frombuffer(raw, dtype='<f4').reshape(-1, 2).astype(np.float64)
    preview = music[:round(9 * SR)].copy() * .28
    # Normal home taps, then the denser cadence of three duck selections.
    for at, i in [(1, 0), (2.5, 1), (4, 2), (6, 0), (6.26, 1), (6.52, 2)]:
        start = round(at * SR)
        preview[start:start + len(voices[i])] += voices[i][:, None] * .5
    save(WORK / 'duck-with-new-music.wav', preview)
    solo = np.zeros(round(3.2 * SR))
    for i, data in enumerate(voices):
        start = round(i * 1.05 * SR); solo[start:start + len(data)] += data
    save(WORK / 'duck-quack-preview.wav', solo)
    unchanged = all(hashlib.sha256((ASSETS / name).read_bytes()).hexdigest() == digest for name, digest in before.items())
    audit = dict(version='QUACK1',bpm=140,voices=rows,existingAudioUnchanged=unchanged,
                 previewPeak=float(np.max(np.abs(preview))),installed=args.install,
                 provenance='Original deterministic reed/formant synthesis, no external animal recording')
    assert unchanged and audit['previewPeak'] < .98
    assert all(r['above4k'] < .01 and r['peak'] < .6 and abs(r['firstSample']) < .0001 and abs(r['lastSample']) < .0001 for r in rows)
    (WORK / 'audio-audit.json').write_text(json.dumps(audit, ensure_ascii=False, indent=2), encoding='utf8')
    print(json.dumps(audit, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
