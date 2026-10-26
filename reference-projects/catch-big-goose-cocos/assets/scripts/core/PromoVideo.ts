export type PromoResult = 'completed' | 'closed' | 'error' | 'timeout';

export const PROMO_FILES = ['Darkchaser-Battletide.mp4', 'Skycore-Reboot.f5800.mp4'];

export class PromoVideo {
    private finish: ((result: PromoResult) => void) | null = null;

    get active(): boolean { return this.finish !== null; }

    close() { this.finish?.('closed'); }

    play(rewardText: string): Promise<PromoResult> {
        if (this.active || typeof document === 'undefined') return Promise.resolve('error');
        return new Promise(resolve => {
            const overlay = document.createElement('div');
            overlay.setAttribute('role', 'dialog');
            overlay.setAttribute('aria-label', '观看宣传片');
            overlay.style.cssText = 'position:fixed;inset:0;z-index:2147483647;background:#100e0b;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#fff2d7;font:16px sans-serif;touch-action:none;padding:24px;box-sizing:border-box;';
            const status = document.createElement('p');
            status.textContent = `完整观看${rewardText}`;
            const video = document.createElement('video');
            video.style.cssText = 'width:100%;max-height:75vh;object-fit:contain;';
            video.playsInline = true;
            video.controls = false;
            video.disablePictureInPicture = true;
            video.preload = 'auto';
            const close = document.createElement('button');
            close.textContent = '关闭宣传片';
            close.style.cssText = 'position:absolute;right:16px;top:max(16px,env(safe-area-inset-top));padding:12px;border:1px solid #c49a55;border-radius:10px;background:#332619;color:#fff2d7;cursor:pointer;';
            const resume = document.createElement('button');
            resume.textContent = '点击播放 / 继续';
            resume.style.cssText = 'padding:12px 28px;background:#ffcf37;color:#402a17;border:0;border-radius:12px;cursor:pointer;';
            resume.hidden = true;
            overlay.append(close, status, video, resume);
            let settled = false;
            let watched = 0;
            let watchdog: ReturnType<typeof setTimeout> | undefined;
            const armTimeout = () => {
                clearTimeout(watchdog);
                watchdog = setTimeout(() => finish('timeout'), 30000);
            };
            const finish = (result: PromoResult) => {
                if (settled) return;
                settled = true;
                clearTimeout(watchdog);
                document.removeEventListener('visibilitychange', onVisibility);
                this.finish = null;
                video.pause();
                video.removeAttribute('src');
                video.load();
                overlay.remove();
                resolve(result);
            };
            const start = () => {
                if (settled) return;
                resume.hidden = true;
                armTimeout();
                void video.play().catch(() => {
                    if (settled) return;
                    clearTimeout(watchdog);
                    resume.hidden = false;
                    status.textContent = `点击播放，完整观看${rewardText}`;
                });
            };
            const onVisibility = () => {
                if (document.hidden) {
                    video.pause();
                    clearTimeout(watchdog);
                } else resume.hidden = false;
            };
            this.finish = finish;
            close.onclick = () => finish('closed');
            resume.onclick = start;
            video.addEventListener('error', () => finish('error'));
            video.addEventListener('pause', () => { if (!settled) resume.hidden = false; });
            video.addEventListener('seeking', () => {
                if (video.currentTime > watched + 0.5) video.currentTime = watched;
            });
            video.addEventListener('timeupdate', () => {
                if (settled || document.hidden || video.seeking) return;
                if (video.currentTime > watched) {
                    watched = video.currentTime;
                    armTimeout();
                }
            });
            video.addEventListener('ended', () => {
                if (document.hidden) return;
                const complete = Number.isFinite(video.duration) && video.duration > 0
                    && watched >= video.duration - 0.5;
                finish(complete ? 'completed' : 'error');
            });
            document.addEventListener('visibilitychange', onVisibility);
            document.body.appendChild(overlay);
            video.src = new URL(`video/${PROMO_FILES[Math.floor(Math.random() * PROMO_FILES.length)]}`, document.baseURI).href;
            start();
        });
    }
}
