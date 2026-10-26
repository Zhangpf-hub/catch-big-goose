/**
 * 放在 CDN 上、不进包体的大切图。
 *
 * 只有「显示尺寸远小于源图、且单张过 1MB」的切图才值得挪出去——包内资源是同步就位的，
 * 换成远程就多了一次网络往返，为省几十 KB 去换首屏闪动不划算。目前符合条件的两张：
 *
 *   station-frame-v3   1448×1086 → 显示 330×247（4.4 倍过采样），1.3MB
 *   selection-badge-v1 1254×1254 → 显示 68×68（18 倍过采样），1.2MB
 *
 * 两张都已按 3 倍 DPR 重采样后再压缩（990×742 / 204×204），合计 2.5MB → 209KB。
 * 3 倍是按设计分辨率 390×844 封顶算的，主流手机 DPR 不超过 3，肉眼看不出与原图的差别。
 *
 * 域名 audiopaytest.cos.tx.xmcdn.com 是**线上域名**（名字里的 test 是历史命名，
 * 不代表测试环境），地址可直接用于发布，不需要上线前替换。
 *
 * 协议统一用 https（该域名实测支持）：微信小游戏只允许 https，且 downloadFile
 * 合法域名要在小程序后台登记，否则真机取不到图。取不到不会报错、也不会白屏——
 * UIKit.image 的失败分支是静默返回，表现为「站点框和勾章不出现，其余页面正常」，
 * 排查时先看这里。
 */
export const RemoteTextures = {
    /** 首页路线上每个站点的木框底座（含圆章内芯与羊皮纸名牌）。 */
    stationFrame: {
        remote: 'https://audiopaytest.cos.tx.xmcdn.com/storages/b007-audiotest/64/2C/GAqSoUUOUgqAAAMP7wACEWUL.png',
        fallback: 'textures/challenge-ui/fallback/station-frame/texture',
    },
    /** 选中态的手绘勾章：站点右上角与难度档位各用一次。 */
    selectionBadge: {
        remote: 'https://audiopaytest.cos.tx.xmcdn.com/storages/ec09-audiotest/C1/DE/GAqSpGcOUgqAAAA0pwACEWUM.png',
        fallback: 'textures/challenge-ui/fallback/selection-badge/texture',
    },
} as const;
