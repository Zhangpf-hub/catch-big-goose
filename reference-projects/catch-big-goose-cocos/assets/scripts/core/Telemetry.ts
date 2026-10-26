import { sys } from 'cc';

type EventProps = Record<string, string | number | boolean | null | undefined>;

interface TelemetryEvent {
    /** 仅用于本地队列确认，不发送到收集端。 */
    queueId: string;
    name: string;
    at: string;
    sessionId: string;
    props: EventProps;
}

interface RuntimeConfig {
    telemetryEndpoint?: string;
    buildVersion?: string;
}

/**
 * 轻量一方观测层。
 *
 * 默认不向外发送：事件最多保留 200 条在本地，部署时显式配置 telemetryEndpoint 才批量 POST。
 * 事件只允许基础类型，不采集 userId、设备标识、输入内容或完整 URL，避免为了调关卡引入
 * 不必要的隐私面。网络失败保留队列，下次事件触发时重试。
 */
export class Telemetry {
    private static readonly STORE = 'goose_telemetry_v1';
    private static readonly MAX_QUEUE = 200;
    private static initialized = false;
    private static flushing = false;
    private static sessionId = '';
    private static nextEventId = 0;

    static init(): void {
        if (Telemetry.initialized) return;
        Telemetry.initialized = true;
        Telemetry.sessionId = Telemetry.makeSessionId();
        if (typeof window !== 'undefined') {
            window.addEventListener('error', event => Telemetry.track('runtime_error', {
                message: Telemetry.trim(event.message),
                source: Telemetry.fileName(event.filename),
                line: event.lineno,
            }));
            window.addEventListener('unhandledrejection', event => Telemetry.track('runtime_error', {
                message: Telemetry.trim(String(event.reason ?? 'unhandled rejection')),
                source: 'promise',
            }));
            // QA 可只读检查事件名与字段，不需要翻 localStorage 内部格式。
            (globalThis as any).__gooseTelemetrySnapshot = () => Telemetry.readQueue();
        }
    }

    static track(name: string, props: EventProps = {}): void {
        if (!Telemetry.initialized) Telemetry.init();
        const event: TelemetryEvent = {
            queueId: Telemetry.makeEventId(),
            name,
            at: new Date().toISOString(),
            sessionId: Telemetry.sessionId,
            props: { buildVersion: Telemetry.config().buildVersion ?? 'dev', ...props },
        };
        const queue = [...Telemetry.readQueue(), event].slice(-Telemetry.MAX_QUEUE);
        Telemetry.writeQueue(queue);
        if (queue.length >= 10 || name === 'round_end' || name === 'runtime_error') {
            void Telemetry.flush();
        }
    }

    static error(stage: string, error: unknown, props: EventProps = {}): void {
        Telemetry.track('runtime_error', {
            stage,
            message: Telemetry.trim(error instanceof Error ? error.message : String(error)),
            ...props,
        });
    }

    static async flush(): Promise<void> {
        if (!Telemetry.initialized) Telemetry.init();
        const endpoint = Telemetry.config().telemetryEndpoint?.trim();
        if (!endpoint || Telemetry.flushing) return;
        const queue = Telemetry.readQueue();
        if (queue.length === 0) return;
        // 旧版事件没有本地 ID，先落盘，以便响应回来时仍能准确识别同一批。
        Telemetry.writeQueue(queue);
        Telemetry.flushing = true;
        try {
            const response = await fetch(endpoint, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ events: queue.map(({ queueId, ...event }) => event) }),
                keepalive: true,
            });
            if (response.ok) {
                // 请求期间 track 可能追加事件，甚至触发 200 条裁剪；不能清空队列或按长度截断。
                const sent = new Set(queue.map(event => event.queueId));
                Telemetry.writeQueue(Telemetry.readQueue().filter(event => !sent.has(event.queueId)));
            }
        } catch {
            // 离线/弱网是正常状态，保留队列等待后续重试，不把观测失败升级成游戏错误。
        } finally {
            Telemetry.flushing = false;
        }
    }

    private static config(): RuntimeConfig {
        return (globalThis as any).__GOOSE_CONFIG ?? {};
    }

    private static readQueue(): TelemetryEvent[] {
        try {
            const value = JSON.parse(sys.localStorage.getItem(Telemetry.STORE) ?? '[]');
            if (!Array.isArray(value)) return [];
            return value.filter(event => event && typeof event === 'object'
                && typeof event.name === 'string' && typeof event.at === 'string'
                && typeof event.sessionId === 'string'
                && event.props && typeof event.props === 'object' && !Array.isArray(event.props))
                .slice(-Telemetry.MAX_QUEUE)
                .map(event => ({
                    ...event,
                    queueId: typeof event.queueId === 'string' && event.queueId
                        ? event.queueId : Telemetry.makeEventId(),
                }));
        } catch { return []; }
    }

    private static writeQueue(queue: TelemetryEvent[]): void {
        try { sys.localStorage.setItem(Telemetry.STORE, JSON.stringify(queue)); } catch { /* 本局放弃 */ }
    }

    private static makeSessionId(): string {
        const cryptoApi = (globalThis as any).crypto;
        if (cryptoApi?.randomUUID) return cryptoApi.randomUUID();
        return `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 10)}`;
    }

    private static makeEventId(): string {
        return `${Telemetry.sessionId}:${Telemetry.nextEventId++}`;
    }

    private static trim(value: string): string {
        return value.replace(/https?:\/\/[^\s]+/g, '[url]').slice(0, 240);
    }

    private static fileName(value: string): string {
        return value ? value.split('/').pop()?.slice(0, 80) ?? '' : '';
    }
}
