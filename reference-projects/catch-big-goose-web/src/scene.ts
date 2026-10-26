import * as THREE from 'three';
import * as CANNON from 'cannon-es';
import { FRUITS, seededRandom, type FruitKind, type Piece } from './game.ts';

interface Actor { piece: Piece; mesh: THREE.Group; body: CANNON.Body }

export class OrchardScene {
  readonly renderer: THREE.WebGLRenderer;
  readonly scene = new THREE.Scene();
  readonly camera = new THREE.OrthographicCamera(-7, 7, 5, -5, 0.1, 80);
  readonly world = new CANNON.World({ gravity: new CANNON.Vec3(0, -18, 0), allowSleep: true });
  readonly actors = new Map<number, Actor>();
  private raycaster = new THREE.Raycaster();
  private pointer = new THREE.Vector2();
  private occluders: THREE.Object3D[] = [];
  private hovered: number | null = null;
  private hintKind: FruitKind | null = null;
  private hintUntil = 0;
  private observer: ResizeObserver;
  private goose: THREE.Group;
  private random = seededRandom(1);
  private down: { x: number; y: number; id: number } | null = null;
  private materials = new Map<string, THREE.MeshStandardMaterial>();
  private sphere = new THREE.SphereGeometry(1, 20, 14);
  private cylinder = new THREE.CylinderGeometry(1, 1, 1, 12);
  private cone = new THREE.ConeGeometry(1, 1, 12);
  private elapsed = 0;
  private onPick: (id: number, x: number, y: number) => void;
  private onShake: (strength?: number, direction?: number) => void;
  inputEnabled = false;

  constructor(private container: HTMLElement, onPick: OrchardScene['onPick'], onShake: OrchardScene['onShake']) {
    this.onPick = onPick;
    this.onShake = onShake;
    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'high-performance' });
    this.renderer.setPixelRatio(Math.min(devicePixelRatio, 1.8));
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    this.renderer.outputColorSpace = THREE.SRGBColorSpace;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.3;
    container.append(this.renderer.domElement);
    this.renderer.domElement.setAttribute('aria-label', '3D 水果篮，点击水果放入收集槽，拖动或按空格颠锅');
    this.camera.position.set(0, 13, 9);
    this.camera.lookAt(0, 0.4, 0);
    this.scene.add(new THREE.HemisphereLight('#fff9e7', '#b9c9a5', 3));
    const sunlight = new THREE.DirectionalLight('#fff6df', 4);
    sunlight.position.set(-5, 12, 6);
    sunlight.castShadow = true;
    sunlight.shadow.mapSize.set(1024, 1024);
    Object.assign(sunlight.shadow.camera, { left: -7, right: 7, top: 7, bottom: -7, near: 1, far: 30 });
    sunlight.shadow.normalBias = 0.035;
    sunlight.shadow.bias = -0.0003;
    this.scene.add(sunlight);
    this.world.defaultContactMaterial.friction = 0.38;
    this.world.defaultContactMaterial.restitution = 0.12;
    this.world.broadphase = new CANNON.SAPBroadphase(this.world);
    (this.world.solver as CANNON.GSSolver).iterations = 12;
    this.buildBasket();
    this.goose = this.buildGoose();
    this.goose.position.set(0, 0.06, 0.3);
    this.goose.scale.setScalar(0.9);
    this.scene.add(this.goose);
    this.observer = new ResizeObserver(() => this.resize());
    this.observer.observe(container);
    this.resize();
    this.renderer.domElement.addEventListener('pointerdown', this.pointerDown);
    this.renderer.domElement.addEventListener('pointermove', this.pointerMove);
    this.renderer.domElement.addEventListener('pointerup', this.pointerUp);
    this.renderer.domElement.addEventListener('pointercancel', this.pointerCancel);
    this.renderer.domElement.addEventListener('pointerleave', this.pointerLeave);
  }

  private material(color: string, roughness = 0.72): THREE.MeshStandardMaterial {
    const key = `${color}:${roughness}`;
    if (!this.materials.has(key)) this.materials.set(key, new THREE.MeshStandardMaterial({ color, roughness }));
    return this.materials.get(key)!;
  }

  private part(parent: THREE.Group, geometry: THREE.BufferGeometry, color: string, scale: number[], position: number[]): THREE.Mesh {
    const mesh = new THREE.Mesh(geometry, this.material(color));
    mesh.scale.set(scale[0], scale[1], scale[2]);
    mesh.position.set(position[0], position[1], position[2]);
    mesh.castShadow = true;
    mesh.receiveShadow = true;
    parent.add(mesh);
    return mesh;
  }

  private buildBasket(): void {
    const basket = new THREE.Group();
    const profile = [[3.6, -0.22], [3.85, -0.06], [4.2, 1.05], [4.22, 1.16], [4.05, 1.16], [3.74, 0.05]];
    const sides = new THREE.Mesh(new THREE.LatheGeometry(profile.map(([radius, height]) => new THREE.Vector2(radius, height)), 80), this.material('#d8bc87'));
    sides.material.side = THREE.DoubleSide;
    sides.castShadow = true;
    sides.receiveShadow = true;
    basket.add(sides);
    this.occluders.push(sides);
    const bottom = this.part(basket, this.cylinder, '#e4cda0', [3.75, 0.16, 3.75], [0, -0.07, 0]);
    this.occluders.push(bottom);
    for (let ring = 0; ring < 6; ring++) {
      const height = 0.08 + ring * 0.2;
      const trim = new THREE.Mesh(new THREE.TorusGeometry(3.87 + height * 0.27, 0.035, 5, 80), this.material(ring % 2 ? '#bca174' : '#ead6b1'));
      trim.rotation.x = Math.PI / 2;
      trim.position.y = height;
      basket.add(trim);
    }
    for (let index = 0; index < 56; index++) {
      const angle = index / 56 * Math.PI * 2;
      const stripe = this.part(basket, this.cylinder, '#c3a574', [0.025, 1.12, 0.025], [Math.cos(angle) * 4, 0.55, Math.sin(angle) * 4]);
      stripe.rotation.z = -Math.cos(angle) * 0.26;
      stripe.rotation.x = Math.sin(angle) * 0.26;
    }
    const rim = new THREE.Mesh(new THREE.TorusGeometry(4.12, 0.12, 10, 80), this.material('#efdcba'));
    rim.rotation.x = Math.PI / 2;
    rim.position.y = 1.15;
    rim.castShadow = true;
    basket.add(rim);
    for (const side of [-1, 1]) {
      const handle = new THREE.Mesh(new THREE.TorusGeometry(0.57, 0.085, 8, 30), this.material('#c5aa7d'));
      handle.rotation.x = Math.PI / 2;
      handle.scale.y = 1.4;
      handle.position.set(side * 4.22, 0.7, 0);
      basket.add(handle);
    }
    this.scene.add(basket);
    const floor = new CANNON.Body({ mass: 0, shape: new CANNON.Plane() });
    floor.quaternion.setFromEuler(-Math.PI / 2, 0, 0);
    this.world.addBody(floor);
    for (let index = 0; index < 24; index++) {
      const angle = index * Math.PI / 12;
      const wall = new CANNON.Body({ mass: 0, shape: new CANNON.Box(new CANNON.Vec3(0.22, 2.6, 0.57)) });
      wall.position.set(Math.cos(angle) * 3.92, 2.5, Math.sin(angle) * 3.92);
      wall.quaternion.setFromEuler(0, -angle, 0);
      this.world.addBody(wall);
    }
    const ground = new THREE.Mesh(new THREE.PlaneGeometry(200, 200), this.material('#e9eddd'));
    ground.rotation.x = -Math.PI / 2;
    ground.position.y = -0.25;
    ground.receiveShadow = true;
    this.scene.add(ground);
  }

  private buildGoose(): THREE.Group {
    const goose = new THREE.Group();
    this.part(goose, this.sphere, '#fff9e9', [0.76, 0.48, 0.48], [0, 0.55, 0]);
    this.part(goose, this.sphere, '#e7e9d9', [0.5, 0.24, 0.12], [-0.1, 0.58, 0.42]).rotation.z = -0.18;
    this.part(goose, this.cylinder, '#fff9e9', [0.2, 0.87, 0.2], [0.45, 1.03, 0]);
    this.part(goose, this.sphere, '#fff9e9', [0.3, 0.33, 0.3], [0.47, 1.52, 0]);
    this.part(goose, this.cone, '#e8a548', [0.18, 0.45, 0.17], [0.81, 1.49, 0]).rotation.z = -Math.PI / 2;
    for (const side of [-1, 1]) {
      this.part(goose, this.sphere, '#243f34', [0.04, 0.045, 0.035], [0.57, 1.61, side * 0.26]);
      this.part(goose, this.sphere, '#e8a548', [0.23, 0.065, 0.14], [side * 0.25, 0.1, 0.12]);
    }
    return goose;
  }

  private fruit(kind: FruitKind): THREE.Group {
    const group = new THREE.Group();
    const color = FRUITS[kind].color;
    if (kind === 'grape') {
      for (let index = 0; index < 9; index++) {
        const angle = index * 2.4;
        const height = Math.floor(index / 3);
        const radius = height === 2 ? 0.14 : 0.3;
        this.part(group, this.sphere, index % 2 ? '#9585b9' : '#80709f', [0.26, 0.27, 0.26], [Math.cos(angle) * radius, 0.26 - height * 0.27, Math.sin(angle) * radius]);
      }
    } else if (kind === 'pear') {
      this.part(group, this.sphere, color, [0.52, 0.46, 0.5], [0, -0.15, 0]);
      this.part(group, this.sphere, color, [0.32, 0.46, 0.31], [0, 0.19, 0]);
    } else if (kind === 'peach') {
      this.part(group, this.sphere, '#efa096', [0.4, 0.51, 0.49], [-0.17, 0, 0]);
      this.part(group, this.sphere, '#f4b3a0', [0.39, 0.5, 0.49], [0.18, 0, 0]);
    } else {
      this.part(group, this.sphere, color, [0.55, kind === 'orange' ? 0.5 : 0.53, 0.53], [0, 0, 0]);
      if (kind === 'orange') {
        for (let index = 0; index < 15; index++) {
          const angle = index * 2.4;
          const height = 0.12 + (index % 4) * 0.07;
          const radius = Math.sqrt(0.52 ** 2 - height ** 2);
          this.part(group, this.sphere, '#e4a03d', [0.015, 0.015, 0.015], [Math.cos(angle) * radius, height, Math.sin(angle) * radius]);
        }
      }
    }
    this.part(group, this.cylinder, '#82613d', [0.045, 0.25, 0.045], [0, 0.55, 0]).rotation.z = -0.16;
    const leaf = this.part(group, this.sphere, '#71915b', [0.28, 0.035, 0.12], [0.2, 0.57, 0]);
    leaf.rotation.z = 0.35;
    if (kind === 'mangosteen') {
      for (let index = 0; index < 4; index++) {
        const angle = index * Math.PI / 2;
        const petal = this.part(group, this.sphere, '#829857', [0.28, 0.06, 0.13], [Math.cos(angle) * 0.13, 0.48, Math.sin(angle) * 0.13]);
        petal.rotation.y = -angle;
      }
    }
    return group;
  }

  reset(pieces: Piece[], seed: number): void {
    for (const actor of this.actors.values()) { this.scene.remove(actor.mesh); this.world.removeBody(actor.body); }
    this.actors.clear();
    this.random = seededRandom(seed);
    this.hovered = null;
    this.hintKind = null;
    this.goose.scale.setScalar(0.9);
    const places: [number, number][] = [];
    for (let row = -2; row <= 2; row++) for (let column = -2; column <= 2; column++) {
      if (Math.hypot(row, column) <= 2.5) places.push([column * 1.22, row * 1.22]);
    }
    pieces.forEach((piece, index) => {
      const [horizontal, depth] = places[index % places.length];
      this.add(piece, horizontal + (this.random() - 0.5) * 0.12, 1.8 + Math.floor(index / places.length) * 1.25, depth);
    });
    for (let frame = 0; frame < 100; frame++) this.world.step(1 / 60);
    this.updateTransforms();
  }

  add(piece: Piece, horizontal = 0, height = 3.2, depth = 0): void {
    const mesh = this.fruit(piece.kind);
    mesh.userData.pieceId = piece.id;
    mesh.traverse(child => { child.userData.pieceId = piece.id; });
    const body = new CANNON.Body({ mass: 1, shape: new CANNON.Sphere(0.57), linearDamping: 0.28, angularDamping: 0.4, sleepSpeedLimit: 0.18, sleepTimeLimit: 0.65 });
    body.position.set(horizontal, height, depth);
    body.quaternion.setFromEuler((this.random() - 0.5) * 1.3, this.random() * Math.PI * 2, (this.random() - 0.5) * 1.3);
    this.world.addBody(body);
    this.scene.add(mesh);
    this.actors.set(piece.id, { piece, mesh, body });
  }

  remove(id: number): void {
    const actor = this.actors.get(id);
    if (!actor) return;
    this.scene.remove(actor.mesh);
    this.world.removeBody(actor.body);
    this.actors.delete(id);
    this.hovered = null;
    for (const other of this.actors.values()) other.body.wakeUp();
  }

  shake(strength = 1, direction = 0): void {
    for (const { body } of this.actors.values()) {
      body.wakeUp();
      body.applyImpulse(new CANNON.Vec3((this.random() - 0.5) * 3 + direction, (3.7 + this.random() * 2.2) * strength, (this.random() - 0.5) * 3));
      body.angularVelocity.set((this.random() - 0.5) * 6, (this.random() - 0.5) * 5, (this.random() - 0.5) * 6);
    }
  }

  hint(kind: FruitKind): void { this.hintKind = kind; this.hintUntil = this.elapsed + 4; }

  private updateTransforms(): void {
    for (const { mesh, body, piece } of this.actors.values()) {
      if (body.position.y < -1 || Math.hypot(body.position.x, body.position.z) > 4.6) {
        body.position.set(0, 2.8, 0);
        body.velocity.setZero();
        body.wakeUp();
      }
      mesh.position.copy(body.position as unknown as THREE.Vector3);
      mesh.quaternion.copy(body.quaternion as unknown as THREE.Quaternion);
      const highlighted = piece.id === this.hovered || (this.hintKind === piece.kind && this.elapsed < this.hintUntil);
      mesh.scale.setScalar(highlighted ? 1.07 + Math.sin(this.elapsed * 7) * 0.02 : 1);
    }
  }

  frame(seconds: number, simulate: boolean, won: boolean): void {
    this.elapsed += seconds;
    if (simulate) this.world.step(1 / 60, Math.min(seconds, 0.1), 5);
    this.updateTransforms();
    if (won) {
      this.goose.rotation.y = Math.sin(this.elapsed * 1.6) * 0.2;
      this.goose.position.y = 0.15 + Math.abs(Math.sin(this.elapsed * 3)) * 0.28;
      this.goose.scale.lerp(new THREE.Vector3(1.55, 1.55, 1.55), 0.04);
    } else { this.goose.position.y = 0.06; this.goose.rotation.y = 0; }
    this.renderer.render(this.scene, this.camera);
  }

  private resize(): void {
    const width = this.container.clientWidth;
    const height = this.container.clientHeight;
    if (!width || !height) return;
    const aspect = width / height;
    const vertical = Math.max(9.2, 10.5 / aspect);
    Object.assign(this.camera, { left: -vertical * aspect / 2, right: vertical * aspect / 2, top: vertical / 2, bottom: -vertical / 2 });
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  }

  private hit(clientX: number, clientY: number): number | null {
    const rect = this.renderer.domElement.getBoundingClientRect();
    this.pointer.set((clientX - rect.left) / rect.width * 2 - 1, -(clientY - rect.top) / rect.height * 2 + 1);
    this.raycaster.setFromCamera(this.pointer, this.camera);
    const hits = this.raycaster.intersectObjects([...this.actors.values()].map(actor => actor.mesh).concat(this.occluders as THREE.Group[]), true);
    return hits[0]?.object.userData.pieceId ?? null;
  }

  private pointerDown = (event: PointerEvent): void => {
    if (!this.inputEnabled || event.button !== 0) return;
    this.down = { x: event.clientX, y: event.clientY, id: event.pointerId };
    this.renderer.domElement.setPointerCapture(event.pointerId);
  };
  private pointerMove = (event: PointerEvent): void => {
    this.hovered = this.inputEnabled ? this.hit(event.clientX, event.clientY) : null;
    this.renderer.domElement.style.cursor = this.hovered !== null ? 'pointer' : this.down ? 'grabbing' : 'grab';
  };
  private pointerUp = (event: PointerEvent): void => {
    if (!this.down || this.down.id !== event.pointerId) return;
    const distance = Math.hypot(event.clientX - this.down.x, event.clientY - this.down.y);
    if (this.inputEnabled) {
      if (distance > 20) this.onShake(1, Math.sign(event.clientX - this.down.x) * 1.5);
      else { const id = this.hit(event.clientX, event.clientY); if (id !== null) this.onPick(id, event.clientX, event.clientY); }
    }
    this.down = null;
    if (this.renderer.domElement.hasPointerCapture(event.pointerId)) this.renderer.domElement.releasePointerCapture(event.pointerId);
  };
  private pointerCancel = (): void => { this.down = null; };
  private pointerLeave = (): void => { this.hovered = null; };

  inspect(): { id: number; kind: FruitKind; x: number; y: number; visible: boolean }[] {
    this.scene.updateMatrixWorld(true);
    const rect = this.renderer.domElement.getBoundingClientRect();
    return [...this.actors.values()].map(({ piece, mesh }) => {
      const point = mesh.position.clone().project(this.camera);
      const horizontal = rect.left + (point.x + 1) / 2 * rect.width;
      const vertical = rect.top + (1 - point.y) / 2 * rect.height;
      return { ...piece, x: horizontal, y: vertical, visible: this.hit(horizontal, vertical) === piece.id };
    });
  }

  dispose(): void {
    this.observer.disconnect();
    this.renderer.domElement.removeEventListener('pointerdown', this.pointerDown);
    this.renderer.domElement.removeEventListener('pointermove', this.pointerMove);
    this.renderer.domElement.removeEventListener('pointerup', this.pointerUp);
    this.renderer.domElement.removeEventListener('pointercancel', this.pointerCancel);
    this.renderer.domElement.removeEventListener('pointerleave', this.pointerLeave);
    const geometries = new Set<THREE.BufferGeometry>([this.sphere, this.cylinder, this.cone]);
    this.scene.traverse(object => { if (object instanceof THREE.Mesh) geometries.add(object.geometry); });
    for (const geometry of geometries) geometry.dispose();
    for (const material of this.materials.values()) material.dispose();
    this.renderer.dispose();
  }
}
