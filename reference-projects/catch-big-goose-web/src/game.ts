export type FruitKind = 'peach' | 'orange' | 'pear' | 'apple' | 'grape' | 'mangosteen';
export type Phase = 'ready' | 'playing' | 'paused' | 'won' | 'lost';
export type LevelId = 'picnic' | 'harvest';

export const FRUITS: Record<FruitKind, { name: string; color: string; icon: string }> = {
  peach: { name: '蜜桃', color: '#efaaa0', icon: '🍑' },
  orange: { name: '橘子', color: '#f4b24d', icon: '🍊' },
  pear: { name: '青梨', color: '#bed078', icon: '🍐' },
  apple: { name: '苹果', color: '#db6759', icon: '🍎' },
  grape: { name: '葡萄', color: '#9585b9', icon: '🍇' },
  mangosteen: { name: '山竹', color: '#6d6389', icon: '🟣' },
};

export const LEVELS: Record<LevelId, { name: string; kinds: FruitKind[]; copies: number; seconds: number }> = {
  picnic: { name: '午后果园', kinds: ['peach', 'orange', 'pear'], copies: 6, seconds: 180 },
  harvest: { name: '丰收挑战', kinds: ['peach', 'orange', 'pear', 'apple', 'grape', 'mangosteen'], copies: 9, seconds: 300 },
};

export interface Piece { id: number; kind: FruitKind }
export interface PickResult { accepted: boolean; matched: Piece[] }

export function seededRandom(seed: number): () => number {
  let state = seed >>> 0;
  return () => {
    state += 0x6d2b79f5;
    let mixed = Math.imul(state ^ state >>> 15, 1 | state);
    mixed ^= mixed + Math.imul(mixed ^ mixed >>> 7, 61 | mixed);
    return ((mixed ^ mixed >>> 14) >>> 0) / 4294967296;
  };
}

export class Game {
  readonly capacity = 7;
  phase: Phase = 'ready';
  board: Piece[] = [];
  tray: Piece[] = [];
  removed = 0;
  remainingSeconds = 180;
  level: LevelId = 'picnic';
  seed = 1;
  lossReason: 'full' | 'timeout' | null = null;
  hintUses = 3;
  undoUses = 3;
  private undoPiece: Piece | null = null;

  get total(): number { return LEVELS[this.level].copies * LEVELS[this.level].kinds.length; }

  reset(level: LevelId, seed: number): void {
    this.level = level;
    this.seed = seed;
    this.phase = 'ready';
    this.tray = [];
    this.removed = 0;
    this.remainingSeconds = LEVELS[level].seconds;
    this.hintUses = 3;
    this.undoUses = 3;
    this.lossReason = null;
    this.undoPiece = null;
    const random = seededRandom(seed);
    this.board = [];
    LEVELS[level].kinds.forEach((kind, kindIndex) => {
      for (let copy = 0; copy < LEVELS[level].copies; copy++) {
        this.board.push({ id: kindIndex * LEVELS[level].copies + copy, kind });
      }
    });
    for (let index = this.board.length - 1; index > 0; index--) {
      const target = Math.floor(random() * (index + 1));
      [this.board[index], this.board[target]] = [this.board[target], this.board[index]];
    }
  }

  start(): void { if (this.phase === 'ready') this.phase = 'playing'; }
  pause(): void { if (this.phase === 'playing') this.phase = 'paused'; }
  resume(): void { if (this.phase === 'paused') this.phase = 'playing'; }

  tick(seconds: number): void {
    if (this.phase !== 'playing' || !Number.isFinite(seconds) || seconds <= 0) return;
    this.remainingSeconds = Math.max(0, this.remainingSeconds - seconds);
    if (this.remainingSeconds === 0) { this.lossReason = 'timeout'; this.phase = 'lost'; }
  }

  pick(id: number): PickResult {
    if (this.phase !== 'playing') return { accepted: false, matched: [] };
    const index = this.board.findIndex(piece => piece.id === id);
    if (index === -1 || this.tray.length >= this.capacity) return { accepted: false, matched: [] };
    const [piece] = this.board.splice(index, 1);
    const lastSame = this.tray.map(item => item.kind).lastIndexOf(piece.kind);
    this.tray.splice(lastSame === -1 ? this.tray.length : lastSame + 1, 0, piece);
    const same = this.tray.filter(item => item.kind === piece.kind);
    const matched = same.length >= 3 ? same.slice(0, 3) : [];
    this.undoPiece = matched.length ? null : piece;
    if (matched.length) {
      const matchedIds = new Set(matched.map(item => item.id));
      this.tray = this.tray.filter(item => !matchedIds.has(item.id));
      this.removed += matched.length;
    }
    if (this.board.length === 0 && this.tray.length === 0) this.phase = 'won';
    else if (this.tray.length >= this.capacity) { this.lossReason = 'full'; this.phase = 'lost'; }
    return { accepted: true, matched };
  }

  get canUndo(): boolean { return this.phase === 'playing' && this.undoUses > 0 && this.undoPiece !== null; }

  undo(): Piece | null {
    if (!this.canUndo) return null;
    const piece = this.undoPiece!;
    this.tray = this.tray.filter(item => item.id !== piece.id);
    this.board.push(piece);
    this.undoUses--;
    this.undoPiece = null;
    return piece;
  }

  hint(): FruitKind | null {
    if (this.phase !== 'playing' || this.hintUses === 0) return null;
    const kinds = LEVELS[this.level].kinds.filter(kind => this.board.some(piece => piece.kind === kind));
    kinds.sort((left, right) => this.tray.filter(piece => piece.kind === right).length - this.tray.filter(piece => piece.kind === left).length);
    if (!kinds.length) return null;
    this.hintUses--;
    return kinds[0];
  }
}
