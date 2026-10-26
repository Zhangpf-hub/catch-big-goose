import { _decorator, Component, Node, Quat, Vec3 } from 'cc';

const { ccclass } = _decorator;

/** 挂在盒中每个可拾取物件上的标记 */
@ccclass('ItemTag')
export class ItemTag extends Component {
    id = '';
    picked = false;
    /**
     * 金鹅彩蛋（见 LevelConfig.LevelDef.goldenGoose）。
     * 拾取路径对它完全另走一套：不进暂存槽、不计入胜利判定、即时结算奖励。
     */
    golden = false;
    /** 冰封中：点不动，要靠三消化开（见 GameManager.thawNearest）。 */
    frozen = false;
    /**
     * 该件在物理世界（JoltWorld）里的标识。-1 = 尚未入物理 / 已摘除。
     * 射线拾取回传的就是它，摘件、唤醒邻居也都用它——节点与刚体的唯一连接点。
     */
    bodyKey = -1;
    /**
     * 冰壳节点（半透明冰块 + 霜晶，见 GameManager.addIceShell）。
     * 物件本身保持原色，冻/化只是加上或销毁这个子节点。
     */
    iceNode: Node | null = null;
    /**
     * 连续"困在锚点小 blob 内"的巡检周期计数:达到阈值即判定已停在原位、直接冻结。
     * 这是精简后**唯一**的逐件冻结判据(取代旧的 slow/rattle/pin/trail 多套启发式):
     * 用**锚点振幅**而非逐周期净位移——无论真静止还是被夹缝原地振荡(每拍抖几毫米、
     * 整体不挪窝),都困在 blob 内 → 收敛;真在下落/滚动会跑出 blob、重置锚点,不误冻。
     * 抓不到的极端边角交给 GameManager 的 0.9s 定时器兜底。
     */
    stillTicks = 0;
    /** 静止判定的锚点世界坐标:物件跑出锚点小 blob 才更新它。anchorY=-99 作哨兵:首拍必更新、不冻。 */
    anchorX = 0;
    anchorY = -99;
    anchorZ = 0;
    /**
     * 装饰性晃动（GameManager.jiggleAround）进行中时的静止位姿。
     *
     * 连点两次时第二次晃动会在第一次的中途启动，若直接读当前 transform 当基准，
     * 记下的就是个偏移位，来回几次堆会整体走形。所以一旦开晃就把静止位姿钉在这里，
     * 后续晃动一律从它出发，晃完再清空。null = 当前没有晃动在飞。
     */
    restPos: Vec3 | null = null;
    restRot: Quat | null = null;
}
