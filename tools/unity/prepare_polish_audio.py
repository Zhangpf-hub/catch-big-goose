"""Compose the UI3 loop and soft physical rattles for the active Unity project.

Original deterministic synthesis; does not modify reference projects. Run with
the bundled Python (numpy + imageio_ffmpeg). Writes an audit beside WAV previews.
"""
import hashlib
import json
import subprocess
import wave
from pathlib import Path

import imageio_ffmpeg
import numpy as np

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'projects/catch-big-goose-unity/Assets/Resources/Audio'
WORK = ROOT / 'work/detail-polish-20261025/audio'
SR, BPM = 44100, 124
BEAT = 60 / BPM
RNG = np.random.default_rng(20261025)


def frequency(midi):
    return 440 * 2 ** ((midi - 69) / 12)


def pluck(midi, duration, bass=False):
    t = np.arange(round(SR * duration)) / SR
    f = frequency(midi)
    # Harmonic wooden/plucked tone; no metallic inharmonic bell partials.
    tone = sum(gain * np.sin(2 * np.pi * f * harmonic * t)
               * np.exp(-t * (3.4 if bass else 6) * harmonic ** .65)
               for harmonic, gain in ((1, 1), (2, .23), (3, .08)))
    return tone * np.minimum(t / .008, 1) * np.minimum((duration - t) / .025, 1)


def filtered_noise(duration, low=250, high=1800):
    n = round(SR * duration)
    spectrum = np.fft.rfft(RNG.normal(size=n))
    freq = np.fft.rfftfreq(n, 1 / SR)
    spectrum *= (1 - np.exp(-(freq / low) ** 4)) * np.exp(-(freq / high) ** 6)
    noise = np.fft.irfft(spectrum, n)
    return noise / max(np.max(np.abs(noise)), 1e-9)


def place(buf, note, at, gain=1, pan=0, loop=False):
    indices = np.arange(len(note)) + round(at * SR)
    if loop:
        indices %= len(buf)
    else:
        keep = indices < len(buf)
        indices, note = indices[keep], note[keep]
    if buf.ndim == 1:
        np.add.at(buf, indices, note * gain)
    else:
        for channel, level in enumerate(((1 - pan) ** .5, (1 + pan) ** .5)):
            np.add.at(buf[:, channel], indices, note * gain * level * .7071)


def wav(path, data):
    with wave.open(str(path), 'wb') as file:
        file.setnchannels(1 if data.ndim == 1 else data.shape[1])
        file.setsampwidth(2)
        file.setframerate(SR)
        file.writeframes((np.clip(data, -.999, .999) * 32767).astype('<i2').tobytes())


def stats(data):
    mono = data if data.ndim == 1 else data.mean(axis=1)
    spectrum = np.abs(np.fft.rfft(mono)) ** 2
    freq = np.fft.rfftfreq(len(mono), 1 / SR)
    return dict(seconds=round(len(data) / SR, 4), peak=round(float(np.max(np.abs(data))), 5),
                rms=round(float(np.sqrt(np.mean(data ** 2))), 5),
                energyAbove4k=round(float(spectrum[freq > 4000].sum() / max(spectrum.sum(), 1e-12)), 7))


def music():
    buf = np.zeros((round(16 * 4 * BEAT * SR), 2))
    # C / Am / F / G, with an answering phrase in the second eight bars.
    chords = [(48, (60, 64, 67)), (45, (60, 64, 69)),
              (41, (60, 65, 69)), (43, (59, 62, 67))]
    phrases = [
        [(0, 76), (.75, 79), (1.5, 81), (2.5, 79), (3, 76)],
        [(0, 72), (.5, 76), (1.5, 79), (2.5, 76), (3.5, 72)],
        [(0, 74), (.75, 77), (1.5, 81), (2.5, 79), (3, 77)],
        [(0, 74), (1, 71), (1.5, 74), (2.5, 79), (3.5, 74)],
        [(0, 76), (.5, 79), (1.5, 84), (2.5, 81), (3.25, 79)],
        [(0, 81), (.75, 79), (1.5, 76), (2.5, 72), (3.5, 76)],
        [(0, 77), (.5, 81), (1.5, 79), (2.5, 77), (3, 74)],
        [(0, 74), (.75, 76), (1.5, 74), (2.5, 71), (3.5, 72)],
    ]
    kick_t = np.arange(round(.16 * SR)) / SR
    kick = np.sin(2 * np.pi * (76 * kick_t - 75 * kick_t ** 2)) * np.exp(-28 * kick_t) * np.minimum(kick_t / .006, 1)
    brush_t = np.arange(round(.08 * SR)) / SR
    for bar in range(16):
        root, chord = chords[bar % 4]
        start = bar * 4 * BEAT
        for beat, midi in phrases[bar % 8]:
            # Small changes to the response keep the loop from being mechanical.
            if bar >= 8 and beat == 1.5:
                beat += .125
            place(buf, pluck(midi, .48), start + beat * BEAT, .22, -.16, True)
        for beat in (0, 1.5, 2, 3.5):
            place(buf, pluck(root if beat < 2 else root + 7, .32, True), start + beat * BEAT, .24, .04, True)
        for beat in (.5, 1.5, 2.5, 3.5):
            for j, midi in enumerate(chord):
                place(buf, pluck(midi, .22), start + beat * BEAT + j * .012, .054, .23, True)
        for beat in (0, 2):
            place(buf, kick, start + beat * BEAT, .17, 0, True)
        for step in range(8):
            brush = filtered_noise(.08, 450, 2400) * np.exp(-42 * brush_t) * np.minimum(brush_t / .007, 1)
            place(buf, brush, start + step * .5 * BEAT, .032 if step % 2 else .018, -.3 if step % 2 else .3, True)
    # Circular, short room reflection, including the previous loop's tails.
    dry = buf.copy()
    buf += .12 * np.roll(dry, round(.065 * SR), axis=0)
    buf += .055 * np.roll(dry, round(.13 * SR), axis=0)
    buf *= min(.72 / np.max(np.abs(buf)), .15 / np.sqrt(np.mean(buf ** 2)))
    return buf


def rattle(shuffle=False):
    duration = .5 if shuffle else .36
    buf = np.zeros(round(duration * SR))
    times = (0, .065, .145, .245, .32) if shuffle else (0, .075, .17)
    for i, at in enumerate(times):
        t = np.arange(round(.12 * SR)) / SR
        wood = np.sin(2 * np.pi * (210 + 23 * i) * t) * np.exp(-42 * t)
        brush = filtered_noise(.12, 180, 1550) * np.exp(-24 * t)
        sound = (wood * .60 + brush * .40) * np.minimum(t / .008, 1) * np.minimum((.12 - t) / .018, 1)
        place(buf, sound, at, (.85 ** i))
    buf *= .52 / np.max(np.abs(buf))
    return buf


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    WORK.mkdir(parents=True, exist_ok=True)
    bgm = music()
    wav(WORK / 'bgm-preview.wav', bgm)
    subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-y', '-v', 'error', '-i', str(WORK / 'bgm-preview.wav'),
                    '-c:a', 'libvorbis', '-q:a', '4', str(OUT / 'bgm.ogg')], check=True)
    audit = dict(bpm=BPM, bars=16, sampleRate=SR, provenance='Original deterministic synthesis; no reference audio used',
                 instruments='wooden mallet, offbeat plucked chords, bouncing bass, soft kick/brush', clips={'bgm': stats(bgm)})
    for name in ('shake', 'shuffle'):
        data = rattle(name == 'shuffle')
        wav(OUT / (name + '.wav'), data)
        wav(WORK / (name + '-preview.wav'), data * (.48 if name == 'shake' else .62))
        audit['clips'][name] = stats(data)
        assert audit['clips'][name]['energyAbove4k'] < .005
    audit['loopSeam'] = float(np.max(np.abs(bgm[0] - bgm[-1])))
    audit['hashes'] = {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                       for p in (OUT / 'bgm.ogg', OUT / 'shake.wav', OUT / 'shuffle.wav')}
    (WORK / 'audio-audit.json').write_text(json.dumps(audit, ensure_ascii=False, indent=2), encoding='utf8')
    print(json.dumps(audit, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
