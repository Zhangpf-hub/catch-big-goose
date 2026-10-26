#!/usr/bin/env python3
"""合成循环 BGM（八音盒音色 + 五声音阶）。

为什么是合成而不是找素材：本作 8 条音效已全部是合成产物，风格统一；
且免费音乐库的授权条款需要逐个核对留档，自己合成没有版权尾巴。

音乐设计上的两个约束来自玩法本身：
1. 游戏自带倒计时压力，音乐不能再催——96 BPM 中速偏慢，不用密集节奏型。
2. 是长时间循环播放的垫底音乐，旋律不能太"抓耳"，否则十分钟后开始烦。
   用五声音阶（无半音、无三全音）是因为它天然不产生尖锐倾向性，耐听。

体积：40s 的 22050Hz 16bit WAV 是 1.7MB，入库会把整轮资源瘦身的成果吃回去。
所以生成后用 macOS 自带的 afconvert 转 AAC（约 200KB），WAV 只当中间产物不入库。

用法：
    python3 tools/art/gen_bgm.py [输出.m4a]
默认写到 reference-projects/catch-big-goose-cocos/assets/resources/audio/bgm.m4a
"""

import math
import os
import struct
import subprocess
import sys
import tempfile
import wave

SR = 22050  # 与现有 8 条音效一致
BPM = 96
BEAT = 60.0 / BPM  # 0.625s
BAR = BEAT * 4

# 五声音阶（C 大调宫调式）音名 → 频率
NOTE = {
    "C4": 261.63,
    "D4": 293.66,
    "E4": 329.63,
    "G4": 392.00,
    "A4": 440.00,
    "C5": 523.25,
    "D5": 587.33,
    "E5": 659.25,
    "C3": 130.81,
    "D3": 146.83,
    "E3": 164.81,
    "F3": 174.61,
    "G3": 196.00,
    "A3": 220.00,
}

# 主旋律：(音名, 时值拍数)。A 段落在主音上收束，B 段抬高八度制造起伏，
# 末段回到 C4 让循环点听起来是"落定"而不是"断掉"。
MELODY = [
    # A 段
    ("E4", 1),
    ("G4", 1),
    ("A4", 1),
    ("G4", 1),
    ("E4", 1),
    ("D4", 1),
    ("C4", 2),
    ("D4", 1),
    ("E4", 1),
    ("G4", 1),
    ("E4", 1),
    ("D4", 4),
    # B 段：整体上移，情绪打开
    ("G4", 1),
    ("A4", 1),
    ("C5", 1),
    ("A4", 1),
    ("G4", 1),
    ("E4", 1),
    ("D4", 2),
    ("E4", 1),
    ("G4", 1),
    ("E4", 1),
    ("D4", 1),
    ("C4", 4),
    # A' 段：重复 A 但尾句改走高音，避免整曲过于对称
    ("E4", 1),
    ("G4", 1),
    ("A4", 1),
    ("C5", 1),
    ("D5", 1),
    ("C5", 1),
    ("A4", 2),
    ("G4", 1),
    ("E4", 1),
    ("G4", 1),
    ("A4", 1),
    ("G4", 4),
    # 收束段：级进下行回主音
    ("E4", 1),
    ("D4", 1),
    ("C4", 1),
    ("D4", 1),
    ("E4", 1),
    ("G4", 1),
    ("E4", 2),
    ("D4", 1),
    ("C4", 1),
    ("D4", 1),
    ("E4", 1),
    ("C4", 4),
]

# 每小节的低音根音（16 小节），走 C-Am-F-G 这类温和进行
BASS = [
    "C3",
    "A3",
    "F3",
    "G3",
    "C3",
    "A3",
    "F3",
    "C3",
    "C3",
    "A3",
    "D3",
    "G3",
    "C3",
    "G3",
    "F3",
    "C3",
]


def bell(freq, dur, amp):
    """八音盒/木琴音色：基频 + 少量非整数倍泛音，指数衰减。

    泛音取 2.76 与 5.4 倍而非整数倍——整数倍泛音听起来像管风琴，
    金属条振动的非谐泛音才是"叮"的那种质感。
    """
    n = int(SR * dur)
    out = [0.0] * n
    partials = ((1.0, 1.0, 3.2), (2.76, 0.34, 5.5), (5.40, 0.14, 8.0))
    for mult, level, decay in partials:
        w = 2 * math.pi * freq * mult / SR
        for i in range(n):
            env = math.exp(-decay * i / SR)
            if env < 1e-4:
                break
            # 3ms 起音斜坡，避免爆音
            atk = min(1.0, i / (SR * 0.003))
            out[i] += math.sin(w * i) * env * level * atk
    return [v * amp for v in out]


def pad(freq, dur, amp):
    """低音垫：慢起慢落的柔和正弦，只做和声底色，不能盖过旋律。"""
    n = int(SR * dur)
    w = 2 * math.pi * freq / SR
    w2 = 2 * math.pi * freq * 2 / SR
    out = []
    for i in range(n):
        t = i / n
        env = math.sin(math.pi * t) ** 0.7  # 两端自然淡入淡出
        out.append((math.sin(w * i) + 0.25 * math.sin(w2 * i)) * env * amp)
    return out


def mix(buf, src, at):
    """把 src 叠加到 buf 的 at 采样处，超出末尾的部分直接丢弃。

    这里**不做**绕回叠加。绕回本是无缝循环的常规手法（让尾音出现在开头），
    但 AAC 编码会在头部插入 priming samples——实测 40.00s 的源编码后是 40.12s，
    多出的 120ms 静音正好落在循环接缝上，会把绕回的尾音拦腰截断，
    反而比不绕回更难听。改为让末句自然收尽：最后一个音符是 4 拍长音，
    bell 的衰减系数 3.2/s 在 2.5s 后已衰减到 e^-8，接缝处本就接近静音，
    多 120ms 听感上只是乐句间的呼吸。
    """
    n = len(buf)
    for i, v in enumerate(src):
        if at + i >= n:
            break
        buf[at + i] += v


def main(out_path):
    total_beats = sum(d for _, d in MELODY)
    n = int(SR * BEAT * total_beats)
    buf = [0.0] * n

    # 主旋律
    t = 0.0
    for name, beats in MELODY:
        dur = BEAT * beats
        # 尾音留一点空隙，音符之间才有颗粒感而不是糊成一片
        mix(buf, bell(NOTE[name], dur * 1.6, 0.30), int(t * SR))
        t += dur

    # 低音垫，每小节一个
    for bar_i, name in enumerate(BASS):
        at = int(bar_i * BAR * SR)
        if at >= n:
            break
        mix(buf, pad(NOTE[name], BAR, 0.10), at)

    # 简易混响：两个衰减抽头，给空间感又不糊。
    # 同样不绕回（i-d < 0 时取 0），否则开头会混进上一轮的混响尾巴，理由见 mix()
    for delay_ms, gain in ((110, 0.20), (230, 0.11)):
        d = int(SR * delay_ms / 1000)
        tap = [buf[i - d] * gain if i >= d else 0.0 for i in range(n)]
        for i in range(n):
            buf[i] += tap[i]

    # 归一化到 -16dBFS：BGM 是垫底的，必须明显低于音效，否则抢戏
    peak = max(abs(v) for v in buf) or 1.0
    target = 10 ** (-16 / 20)
    buf = [v / peak * target for v in buf]

    tmp_wav = os.path.join(tempfile.mkdtemp(), "bgm.wav")
    with wave.open(tmp_wav, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(
            b"".join(
                struct.pack("<h", max(-32768, min(32767, int(v * 32767)))) for v in buf
            )
        )

    print(f"  {n / SR:.1f}s / {BPM} BPM / {len(BASS)} 小节 / {SR}Hz 16bit 单声道")
    wav_kb = os.path.getsize(tmp_wav) / 1024

    if out_path.endswith(".wav"):
        os.replace(tmp_wav, out_path)
        print(f"已生成 {out_path}（{wav_kb:.0f}KB）")
        return

    # afconvert 是 macOS 自带的；换平台时改用 ffmpeg -c:a aac 即可
    subprocess.run(
        ["afconvert", "-f", "m4af", "-d", "aac", "-b", "56000", tmp_wav, out_path],
        check=True,
    )
    os.remove(tmp_wav)
    print(
        f"已生成 {out_path}"
        f"（WAV {wav_kb:.0f}KB → AAC {os.path.getsize(out_path) / 1024:.0f}KB）"
    )


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "reference-projects/catch-big-goose-cocos/assets/resources/audio/bgm.m4a")
