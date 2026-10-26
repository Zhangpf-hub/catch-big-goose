import { Node, Scene, AudioSource, AudioClip, resources } from 'cc';
import { SaveData } from './SaveData';

export type SfxName = 'pick' | 'drop' | 'match' | 'win' | 'lose' | 'honk' | 'shuffle' | 'prop';

/**
 * 轻量音效播放器：单 AudioSource + playOneShot，预加载全部短音效。
 * 微信小游戏首次播放需要用户交互解锁音频上下文；本游戏所有音效都由
 * 点击触发，天然满足该限制，无需额外处理。
 */
export class AudioMan {
    private source: AudioSource;
    /** BGM 独占一个 source：它要 loop 且音量独立，不能和 playOneShot 混用同一个。 */
    private bgmSource: AudioSource;
    private clips = new Map<SfxName, AudioClip>();
    private lastPlay = new Map<SfxName, number>();
    /** 声音总开关（音效 + BGM），跟随本地存档；关闭时 play 直接返回。 */
    private enabled = SaveData.getSound();
    /** BGM 是否已被请求播放——用于开关切换时决定要不要接着放。 */
    private bgmWanted = false;
    private suspended = false;

    setSuspended(suspended: boolean) {
        this.suspended = suspended;
        if (suspended) this.bgmSource.pause();
        else if (this.enabled && this.bgmWanted && this.bgmSource.clip) this.bgmSource.play();
    }

    constructor(scene: Scene) {
        const n = new Node('AudioMan');
        n.setParent(scene);
        this.source = n.addComponent(AudioSource);
        this.source.playOnAwake = false;
        const names: SfxName[] = ['pick', 'drop', 'match', 'win', 'lose', 'honk', 'shuffle', 'prop'];
        for (const name of names) {
            resources.load(`audio/${name}`, AudioClip, (err, clip) => {
                if (!err && clip) this.clips.set(name, clip);
            });
        }

        const bn = new Node('BgmSource');
        bn.setParent(scene);
        this.bgmSource = bn.addComponent(AudioSource);
        this.bgmSource.playOnAwake = false;
        this.bgmSource.loop = true;
        // BGM 是垫底音，波形已归一化到 -16dBFS，这里再压一档确保不抢音效
        this.bgmSource.volume = 0.5;
        resources.load('audio/bgm', AudioClip, (err, clip) => {
            if (err || !clip) { console.warn('[AudioMan] BGM 加载失败', err); return; }
            this.bgmSource.clip = clip;
            if (this.bgmWanted && this.enabled && !this.suspended) this.bgmSource.play();
        });
    }

    get soundOn(): boolean { return this.enabled; }

    /**
     * 开始播放 BGM（幂等）。必须由用户手势触发的路径调用——
     * 浏览器的自动播放策略会拒绝无手势的音频播放。
     */
    startBgm() {
        this.bgmWanted = true;
        if (!this.enabled || this.suspended || !this.bgmSource.clip || this.bgmSource.playing) return;
        this.bgmSource.play();
    }

    stopBgm() {
        this.bgmWanted = false;
        this.bgmSource.stop();
    }

    /** 切换声音开关并持久化，返回切换后的状态。BGM 随之起停。 */
    toggleSound(): boolean {
        this.enabled = !this.enabled;
        SaveData.setSound(this.enabled);
        if (this.enabled) {
            // 开关本身就是用户手势，此刻起播不会被自动播放策略拦下
            if (this.bgmWanted && this.bgmSource.clip && !this.suspended) this.bgmSource.play();
        } else {
            this.bgmSource.stop();
        }
        return this.enabled;
    }

    play(name: SfxName, volume = 1) {
        if (!this.enabled || this.suspended) return;
        const clip = this.clips.get(name);
        if (!clip) return;
        // 同名音效 60ms 内去重：凑齐道具连续拾取时避免爆音叠加。
        const now = performance.now();
        if (now - (this.lastPlay.get(name) ?? -Infinity) < 60) return;
        this.lastPlay.set(name, now);
        this.source.playOneShot(clip, volume);
    }
}
