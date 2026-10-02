/* Coffeetosh hero device scene.
 * Loaded after Three.js + GLTFLoader; all state remains private to this module.
 */
(function heroDevicesModule() {
  'use strict';

  function onReady(callback) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', callback, { once: true });
    } else {
      callback();
    }
  }

  onReady(function initHeroDevices() {
    const canvas = document.getElementById('laptop-canvas');
    const container = document.getElementById('hero-illus');
    const THREE = window.THREE;
    if (!canvas || !container || !THREE || !THREE.GLTFLoader) return;

    const hero = container.closest('.hero') || container;
    const reducedQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    let reducedMotion = reducedQuery.matches;

    let width = container.clientWidth || window.innerWidth;
    let height = container.clientHeight || Math.round(window.innerHeight * 0.65);
    let isMobile = width < 700;
    const renderer = new THREE.WebGLRenderer({ canvas: canvas, alpha: true, antialias: true });
    renderer.setSize(width, height, false);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    if ('outputColorSpace' in renderer && THREE.SRGBColorSpace) {
      renderer.outputColorSpace = THREE.SRGBColorSpace;
    } else if ('outputEncoding' in renderer && THREE.sRGBEncoding) {
      renderer.outputEncoding = THREE.sRGBEncoding;
    }
    canvas.setAttribute('aria-hidden', 'true');
    canvas.style.opacity = '0';
    canvas.style.willChange = 'opacity';

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(isMobile ? 60 : 35, width / height || 1, 0.01, 100);
    camera.position.set(0, isMobile ? 0.6 : 0.55, isMobile ? 3.5 : 3.0);
    camera.lookAt(0, 0.24, 0);

    scene.add(new THREE.AmbientLight(0xfff8ed, 0.58));
    const keyLight = new THREE.DirectionalLight(0xfff4df, 1.05);
    keyLight.position.set(3, 5, 4);
    scene.add(keyLight);
    const amberLight = new THREE.PointLight(0xd4923a, 0.72, 2.8);
    amberLight.position.set(0, 0.2, 0.7);
    scene.add(amberLight);

    const masterGroup = new THREE.Group();
    scene.add(masterGroup);

    /* Screen video is intentionally kept on the real GLB screen mesh. */
    const video = document.createElement('video');
    video.src = 'assets/Maxine.mp4';
    video.loop = false;
    video.muted = true;
    video.playsInline = true;
    video.preload = 'auto';
    video.playbackRate = 1.5;
    video.crossOrigin = 'anonymous';
    video.load();
    let videoReady = false;
    let screenVideoTexture = null;
    let screenMeshRef = null;

    class AnimatedTerminal {
      constructor(side) {
        this.canvas = document.createElement('canvas');
        this.canvas.width = 300;
        this.canvas.height = 649;
        this.ctx = this.canvas.getContext('2d');
        this.texture = new THREE.CanvasTexture(this.canvas);
        if ('colorSpace' in this.texture && THREE.SRGBColorSpace) {
          this.texture.colorSpace = THREE.SRGBColorSpace;
        } else if ('encoding' in this.texture && THREE.sRGBEncoding) {
          this.texture.encoding = THREE.sRGBEncoding;
        }
        this.texture.anisotropy = 4;
        this.side = side;
        this.typingIndex = 0;
        this.lines = [];
        this.currentLineChars = 0;
        this.timer = 0;
        this.started = false;
        this.cursorVisible = true;
        this.cursorTimer = 0;
        this.script = side === 'L' ? [
          { text: 'admin@iphone:~ $ ssh my-mac', delay: 0.6, typeSpeed: 0.045 },
          { text: 'Connecting to my-mac.local...', delay: 0.3, typeSpeed: 0 },
          { text: 'ECDSA key fingerprint SHA256:xK9...', delay: 0.15, typeSpeed: 0 },
          { text: "Warning: added 'my-mac' (ED25519) to known hosts.", delay: 0.2, typeSpeed: 0 },
          { text: "admin@my-mac's password: ********", delay: 0.5, typeSpeed: 0.07 },
          { text: 'Last login: Sat Mar  7 09:12 on ttys001', delay: 0.15, typeSpeed: 0 },
          { text: 'Access granted.', delay: 0.25, typeSpeed: 0 },
          { text: '> Coffeetosh Daemon active.', delay: 0.6, typeSpeed: 0.03 }
        ] : [
          { text: 'guest@iphone:~ $ systemctl status cmd', delay: 0.9, typeSpeed: 0.04 },
          { text: '● cmd.service - Link Manager', delay: 0.25, typeSpeed: 0 },
          { text: '   Loaded: loaded (/etc/systemd/system/)', delay: 0.1, typeSpeed: 0 },
          { text: '   Active: active (running) since 09:14', delay: 0.35, typeSpeed: 0 },
          { text: '   PID: 4821 (coffeetoshd)', delay: 0.1, typeSpeed: 0 },
          { text: 'Starting secondary diagnostic ping...', delay: 0.4, typeSpeed: 0 },
          { text: '64 bytes from 192.168.1.10: time=1.2ms', delay: 0.22, typeSpeed: 0 },
          { text: '64 bytes from 192.168.1.10: time=1.1ms', delay: 0.18, typeSpeed: 0 },
          { text: '64 bytes from 192.168.1.10: time=0.9ms', delay: 0.18, typeSpeed: 0 },
          { text: '> Secure Stream OK.', delay: 0.6, typeSpeed: 0.045 }
        ];
        this.redraw();
      }

      start() {
        if (this.started) return;
        this.started = true;
        this.timer = this.script.length ? this.script[0].delay : 0;
      }

      reset() {
        this.typingIndex = 0;
        this.lines = [];
        this.currentLineChars = 0;
        this.timer = this.script.length ? this.script[0].delay : 0;
        this.started = false;
        this.cursorVisible = true;
        this.cursorTimer = 0;
        this.redraw();
      }

      showStatic() {
        this.lines = this.script.map(line => line.text);
        this.typingIndex = this.script.length;
        this.started = true;
        this.cursorVisible = false;
        this.redraw();
      }

      update(dt) {
        this.cursorTimer += dt;
        if (this.cursorTimer >= 0.5) {
          this.cursorTimer -= 0.5;
          this.cursorVisible = !this.cursorVisible;
          if (this.started) this.redraw();
        }
        if (!this.started || this.typingIndex >= this.script.length) return;
        this.timer -= dt;
        const active = this.script[this.typingIndex];
        let dirty = false;
        if (this.timer <= 0) {
          if (active.typeSpeed > 0 && this.currentLineChars < active.text.length) {
            this.currentLineChars += 1;
            this.timer = Math.max(0.012, active.typeSpeed + (Math.random() * 0.025 - 0.01));
            dirty = true;
          } else {
            this.lines.push(active.text);
            this.typingIndex += 1;
            this.currentLineChars = 0;
            this.timer = this.typingIndex < this.script.length ? this.script[this.typingIndex].delay : 0;
            dirty = true;
          }
        }
        if (dirty) this.redraw();
      }

      colorForLine(line) {
        if (line.indexOf('>') === 0) return '#D4923A';
        if (line.indexOf('Coffeetosh') !== -1 || line.indexOf('Secure') !== -1) return '#D4923A';
        if (line.indexOf('granted') !== -1 || line.indexOf('active (run') !== -1) return '#98c379';
        if (line.indexOf('192.168') !== -1 || line.indexOf('time=') !== -1) return '#D4923A';
        if (line.indexOf('admin') === 0 || line.indexOf('guest') === 0) return '#61afef';
        if (line.indexOf('$ ') !== -1) return '#ffffff';
        if (line.indexOf('PID:') !== -1 || line.indexOf('Loaded:') !== -1) return '#5c6370';
        return '#abb2bf';
      }

      redraw() {
        const c = this.ctx;
        const w = 300;
        const h = 649;
        c.fillStyle = '#1e2227';
        c.fillRect(0, 0, w, h);

        c.fillStyle = '#000000';
        const notchW = 100;
        const notchH = 26;
        const notchR = 10;
        const nx = (w - notchW) / 2;
        c.beginPath();
        c.moveTo(nx, 0);
        c.lineTo(nx + notchW, 0);
        c.lineTo(nx + notchW, notchH - notchR);
        c.quadraticCurveTo(nx + notchW, notchH, nx + notchW - notchR, notchH);
        c.lineTo(nx + notchR, notchH);
        c.quadraticCurveTo(nx, notchH, nx, notchH - notchR);
        c.closePath();
        c.fill();

        c.fillStyle = '#ffffff';
        c.font = 'bold 15px -apple-system, sans-serif';
        c.textAlign = 'left';
        c.fillText('12:00', 18, 23);
        c.strokeStyle = '#ffffff';
        c.lineWidth = 1.2;
        const bx = 248;
        const by = 10;
        const bw = 26;
        const bh = 13;
        const br = 3;
        c.beginPath();
        c.moveTo(bx + br, by);
        c.lineTo(bx + bw - br, by);
        c.quadraticCurveTo(bx + bw, by, bx + bw, by + br);
        c.lineTo(bx + bw, by + bh - br);
        c.quadraticCurveTo(bx + bw, by + bh, bx + bw - br, by + bh);
        c.lineTo(bx + br, by + bh);
        c.quadraticCurveTo(bx, by + bh, bx, by + bh - br);
        c.lineTo(bx, by + br);
        c.quadraticCurveTo(bx, by, bx + br, by);
        c.closePath();
        c.stroke();
        c.fillRect(bx + 3, by + 3, bw - 6, bh - 6);
        c.fillRect(bx + bw + 1, by + 3, 2.5, bh - 6);
        for (let i = 0; i < 4; i += 1) {
          const barH = 4 + i * 3;
          c.fillRect(230 + i * 5, 10 + (13 - barH), 3, barH);
        }

        c.font = '13px "SF Mono", "Menlo", monospace';
        let y = 70;
        const lineH = 22;
        for (const line of this.lines) {
          c.fillStyle = this.colorForLine(line);
          c.fillText(line, 16, y, w - 32);
          y += lineH;
        }
        if (this.typingIndex < this.script.length) {
          const active = this.script[this.typingIndex];
          if (active.typeSpeed > 0 && this.currentLineChars > 0) {
            const partial = active.text.substring(0, this.currentLineChars);
            c.fillStyle = '#ffffff';
            c.fillText(partial, 16, y, w - 32);
            if (this.cursorVisible) {
              const tw = c.measureText(partial).width;
              c.fillStyle = '#D4923A';
              c.fillRect(17 + tw, y - 12, 8, 15);
            }
          }
        } else if (this.started && this.cursorVisible) {
          const prompt = this.side === 'L' ? 'admin@my-mac:~ $ ' : 'guest@iphone:~ $ ';
          c.fillStyle = '#61afef';
          c.fillText(prompt, 16, y, w - 32);
          const tw = c.measureText(prompt).width;
          c.fillStyle = '#D4923A';
          c.fillRect(17 + tw, y - 12, 8, 15);
        }
        c.fillStyle = 'rgba(0,0,0,0.04)';
        for (let sy = 0; sy < h; sy += 3) c.fillRect(0, sy, w, 1);
        this.texture.needsUpdate = true;
      }
    }

    function makeRoundedBoxGeometry(w, h, d, r) {
      const shape = new THREE.Shape();
      const hw = w / 2 - r;
      const hh = h / 2 - r;
      shape.moveTo(-hw, -h / 2);
      shape.lineTo(hw, -h / 2);
      shape.quadraticCurveTo(w / 2, -h / 2, w / 2, -hh);
      shape.lineTo(w / 2, hh);
      shape.quadraticCurveTo(w / 2, h / 2, hw, h / 2);
      shape.lineTo(-hw, h / 2);
      shape.quadraticCurveTo(-w / 2, h / 2, -w / 2, hh);
      shape.lineTo(-w / 2, -hh);
      shape.quadraticCurveTo(-w / 2, -h / 2, -hw, -h / 2);
      const geometry = new THREE.ExtrudeGeometry(shape, {
        depth: d,
        bevelEnabled: true,
        bevelThickness: Math.min(r * 0.3, d * 0.3),
        bevelSize: Math.min(r * 0.3, 0.02),
        bevelSegments: 3
      });
      geometry.center();
      return geometry;
    }

    function createPhone(x, y, z, rotationY, rotationX, rotationZ, terminal) {
      const group = new THREE.Group();
      const phoneW = 0.38;
      const phoneH = 0.82;
      const phoneD = 0.04;
      const body = new THREE.Mesh(
        makeRoundedBoxGeometry(phoneW, phoneH, phoneD, 0.045),
        new THREE.MeshStandardMaterial({ color: 0x111111, metalness: 0.9, roughness: 0.2 })
      );
      body.castShadow = true;
      group.add(body);
      const screenMaterial = new THREE.MeshBasicMaterial({ map: terminal.texture, side: THREE.DoubleSide });
      const screen = new THREE.Mesh(new THREE.PlaneGeometry(phoneW - 0.04, phoneH - 0.04), screenMaterial);
      screen.position.z = phoneD / 2 + Math.min(0.045 * 0.3, phoneD * 0.3) + 0.002;
      group.add(screen);
      group.position.set(x, y, z);
      group.rotation.set(rotationX, rotationY, rotationZ);
      group.scale.setScalar(0);
      return group;
    }

    let phoneXOffset = isMobile ? 0.55 : 1.25;
    let phoneLeftY = isMobile ? 0.55 : 0.58;
    let phoneRightY = isMobile ? 0.45 : 0.48;
    const phoneLeftZ = 0.35;
    const phoneRightZ = 0.40;
    const phoneHeight = 0.82;
    const phoneBottom = -phoneHeight / 2;
    const terminalLeft = new AnimatedTerminal('L');
    const terminalRight = new AnimatedTerminal('R');
    const phoneLeft = createPhone(-phoneXOffset, phoneLeftY, phoneLeftZ, 0.25, -0.06, -0.06, terminalLeft);
    const phoneRight = createPhone(phoneXOffset, phoneRightY, phoneRightZ, -0.25, -0.06, 0.06, terminalRight);
    masterGroup.add(phoneLeft, phoneRight);

    const attachmentGeometry = new THREE.SphereGeometry(0.022, 12, 8);
    const attachmentMaterialLeft = new THREE.MeshBasicMaterial({
      color: 0xf0b45d, transparent: true, opacity: 0, blending: THREE.AdditiveBlending, depthWrite: false
    });
    const attachmentMaterialRight = attachmentMaterialLeft.clone();
    const phoneAttachmentLeft = new THREE.Mesh(attachmentGeometry, attachmentMaterialLeft);
    const phoneAttachmentRight = new THREE.Mesh(attachmentGeometry, attachmentMaterialRight);
    phoneAttachmentLeft.position.set(0, phoneBottom - 0.006, 0.024);
    phoneAttachmentRight.position.set(0, phoneBottom - 0.006, 0.024);
    phoneLeft.add(phoneAttachmentLeft);
    phoneRight.add(phoneAttachmentRight);

    let phoneRevealLeft = 0;
    let phoneRevealRight = 0;
    let phoneVisibleScale = isMobile ? 0.72 : 1;

    function applyPhoneLayout() {
      phoneXOffset = isMobile ? 0.55 : 1.25;
      phoneLeftY = isMobile ? 0.55 : 0.58;
      phoneRightY = isMobile ? 0.45 : 0.48;
      phoneLeft.position.set(-phoneXOffset, phoneLeftY, phoneLeftZ);
      phoneRight.position.set(phoneXOffset, phoneRightY, phoneRightZ);
      phoneVisibleScale = isMobile ? 0.72 : 1;
    }

    function applyPhoneScales() {
      phoneLeft.scale.setScalar(phoneRevealLeft * phoneVisibleScale);
      phoneRight.scale.setScalar(phoneRevealRight * phoneVisibleScale);
      phoneLeft.updateMatrix();
      phoneRight.updateMatrix();
    }

    /* Link meshes use actual 3D tubes. LineDashedMaterial linewidth is not portable. */
    const LINK_SEGMENTS = 64;
    const LINK_COLOR = new THREE.Color(0xd4923a);
    const LINK_HALO_COLOR = new THREE.Color(0xf0b45d);
    const linkVertexShader = [
      'varying vec2 vUv;',
      'uniform vec3 uStartShift;',
      'void main() {',
      '  vUv = uv;',
      '  vec3 point = position + uStartShift * (1.0 - uv.x);',
      '  gl_Position = projectionMatrix * modelViewMatrix * vec4(point, 1.0);',
      '}'
    ].join('\n');
    const linkFragmentShader = [
      'uniform vec3 uColor;',
      'uniform float uOpacity;',
      'uniform float uReveal;',
      'uniform float uTime;',
      'uniform float uReduced;',
      'uniform float uHalo;',
      'varying vec2 vUv;',
      'void main() {',
      '  float head = smoothstep(0.0, 0.085, uReveal * 1.085 - vUv.x);',
      '  float flow = mix(0.65 + 0.35 * pow(0.5 + 0.5 * sin(vUv.x * 25.13 - uTime * 3.2), 6.0), 1.0, uReduced);',
      '  float alpha = head * uOpacity * flow;',
      '  if (uHalo > 0.5) alpha *= 0.25;',
      '  gl_FragColor = vec4(uColor, alpha);',
      '}'
    ].join('\n');

    function createLinkMaterial(color, opacity, halo) {
      return new THREE.ShaderMaterial({
        uniforms: {
          uStartShift: { value: new THREE.Vector3() },
          uColor: { value: color.clone() },
          uOpacity: { value: opacity },
          uReveal: { value: 0 },
          uTime: { value: 0 },
          uReduced: { value: reducedMotion ? 1 : 0 },
          uHalo: { value: halo ? 1 : 0 }
        },
        vertexShader: linkVertexShader,
        fragmentShader: linkFragmentShader,
        transparent: true,
        depthWrite: false,
        side: THREE.FrontSide,
        blending: halo ? THREE.AdditiveBlending : THREE.NormalBlending,
        toneMapped: false
      });
    }

    let lineLeft = null;
    let lineRight = null;
    let bodyBounds = null;
    let linkEndLeft = null;
    let linkEndRight = null;

    function disposeLink(link) {
      if (!link) return;
      masterGroup.remove(link.mesh, link.halo, link.packet, link.endCap);
      link.mesh.geometry.dispose();
      link.halo.geometry.dispose();
      link.mesh.material.dispose();
      link.halo.material.dispose();
      link.packet.geometry.dispose();
      link.packet.material.dispose();
      link.endCap.geometry.dispose();
      link.endCap.material.dispose();
    }

    function phoneAnchorLocal(phone) {
      const oldScale = phone.scale.x;
      phone.scale.setScalar(phoneVisibleScale);
      phone.updateMatrix();
      const anchor = new THREE.Vector3(0, phoneBottom, 0).applyMatrix4(phone.matrix);
      phone.scale.setScalar(oldScale);
      phone.updateMatrix();
      return anchor;
    }

    function makeLink(start, end, side) {
      const curveStart = start.clone();
      const curveEnd = end.clone();
      const direction = end.clone().sub(start);
      const normal = new THREE.Vector3(-direction.y, direction.x, 0).normalize();
      const amplitude = THREE.MathUtils.clamp(direction.length() * 0.2, 0.045, 0.13);
      const points = [curveStart];
      for (let index = 0; index < 4; index += 1) {
        const progress = 0.18 + index * 0.21;
        const offset = (index % 2 === 0 ? 1 : -1) * side * amplitude;
        points.push(start.clone().lerp(end, progress).addScaledVector(normal, offset));
      }
      points.push(curveEnd);
      const curve = new THREE.CatmullRomCurve3(points, false, 'catmullrom', 0.35);
      const radius = isMobile ? 0.0045 : 0.004;
      const tube = new THREE.TubeGeometry(curve, LINK_SEGMENTS, radius, 7, false);
      const haloTube = new THREE.TubeGeometry(curve, LINK_SEGMENTS, radius * 2.6, 7, false);
      const material = createLinkMaterial(LINK_COLOR, 0.84, false);
      const haloMaterial = createLinkMaterial(LINK_HALO_COLOR, 0.32, true);
      const mesh = new THREE.Mesh(tube, material);
      const halo = new THREE.Mesh(haloTube, haloMaterial);
      mesh.renderOrder = 4;
      halo.renderOrder = 3;
      const packet = new THREE.Mesh(
        new THREE.SphereGeometry(radius * 2.8, 10, 8),
        new THREE.MeshBasicMaterial({ color: 0xffce82, transparent: true, opacity: 0, blending: THREE.AdditiveBlending, depthWrite: false })
      );
      packet.renderOrder = 6;
      const endCap = new THREE.Mesh(
        new THREE.SphereGeometry(radius * 1.5, 10, 8),
        new THREE.MeshBasicMaterial({ color: 0xf0b45d, transparent: true, opacity: 0, blending: THREE.AdditiveBlending, depthWrite: false })
      );
      endCap.position.copy(end);
      endCap.renderOrder = 5;
      masterGroup.add(mesh, halo, packet, endCap);
      const link = {
        curve: curve,
        mesh: mesh,
        halo: halo,
        packet: packet,
        endCap: endCap,
        progress: 0,
        offset: side < 0 ? 0 : 0.47,
        packetPoint: new THREE.Vector3(),
        phone: side < 0 ? phoneLeft : phoneRight,
        anchorShift: new THREE.Vector3(),
        start: curveStart,
        end: curveEnd
      };
      return link;
    }

    function buildLinks() {
      if (!bodyBounds) return;
      if (lineLeft) disposeLink(lineLeft);
      if (lineRight) disposeLink(lineRight);
      const bodyWidth = bodyBounds.max.x - bodyBounds.min.x;
      const bodyMidZ = (bodyBounds.min.z + bodyBounds.max.z) * 0.5;
      const sideInset = Math.min(0.075, bodyWidth * 0.045);
      linkEndLeft = new THREE.Vector3(bodyBounds.min.x + sideInset, bodyBounds.max.y + 0.018, bodyMidZ + 0.012);
      linkEndRight = new THREE.Vector3(bodyBounds.max.x - sideInset, bodyBounds.max.y + 0.018, bodyMidZ + 0.012);
      const startLeft = phoneAnchorLocal(phoneLeft);
      const startRight = phoneAnchorLocal(phoneRight);
      lineLeft = makeLink(startLeft, linkEndLeft, -1);
      lineRight = makeLink(startRight, linkEndRight, 1);
      applyPhoneScales();
    }

    function applyLinkProgress(link, phoneProgress, elapsed) {
      if (!link) return;
      link.anchorShift.set(0, phoneBottom, 0).applyMatrix4(link.phone.matrix).sub(link.start);
      link.mesh.material.uniforms.uStartShift.value.copy(link.anchorShift);
      link.halo.material.uniforms.uStartShift.value.copy(link.anchorShift);
      const reveal = reducedMotion ? 1 : THREE.MathUtils.clamp((phoneProgress - 0.70) / 0.30, 0, 1);
      link.progress = reveal;
      link.mesh.material.uniforms.uReveal.value = reveal;
      link.halo.material.uniforms.uReveal.value = reveal;
      link.mesh.material.uniforms.uTime.value = elapsed;
      link.halo.material.uniforms.uTime.value = elapsed;
      link.mesh.material.uniforms.uReduced.value = reducedMotion ? 1 : 0;
      link.halo.material.uniforms.uReduced.value = reducedMotion ? 1 : 0;
      const opacity = reducedMotion ? 0.74 : reveal * 0.84;
      const haloOpacity = reducedMotion ? 0.28 : reveal * 0.31;
      link.mesh.material.uniforms.uOpacity.value = opacity;
      link.halo.material.uniforms.uOpacity.value = haloOpacity;
      link.packet.material.opacity = reducedMotion ? 0 : reveal * (0.50 + 0.18 * Math.sin(elapsed * 4.0 + link.offset));
      link.endCap.material.opacity = phoneProgress > 0.04 ? (reducedMotion ? 0.58 : 0.38 + phoneProgress * 0.25) : 0;
      if (!reducedMotion && reveal > 0.01) {
        const packetT = (elapsed * 0.17 + link.offset) % 1;
        link.curve.getPointAt(packetT < 0 ? packetT + 1 : packetT, link.packetPoint);
        link.packet.position.copy(link.packetPoint);
        link.packet.position.addScaledVector(link.anchorShift, 1 - packetT);
        link.packet.scale.setScalar(0.72 + 0.28 * Math.sin(elapsed * 5.0 + link.offset));
        link.packet.visible = true;
      } else {
        link.packet.visible = false;
      }
    }

    let lidPivot = null;
    let bodyNodeRef = null;
    let lidNodeRef = null;
    let modelLoaded = false;
    let modelRef = null;
    let modelDisposed = false;
    let LID_OPEN_ANGLE = 0;
    let LID_CLOSE_ANGLE = 2.0 - 0.052;
    let LID_PIVOT_Y0 = 0;
    let LID_PIVOT_Z0 = 0;
    let LID_CLOSE_Z_OFFSET = 0.06;
    let lidProgress = 0;
    let lidIsClosed = false;
    let lidIsAnimating = false;
    let lidAnimFrom = 0;
    let lidAnimTo = 0;
    let lidAnimStartMs = 0;
    const LID_TOGGLE_DUR_MS = 1400;

    let heroState = 'LOADING';
    let playStartTime = 0;
    const PLAY_FALLBACK_SEC = 6;
    let pendingReopen = false;
    const INTRO_DUR_MS = reducedMotion ? 0 : 1150;
    const INTRO_Y_OFFSET = -0.10;
    const INTRO_Z_OFFSET = -0.055;
    let introStartMs = 0;
    let introComplete = reducedMotion;
    let introAlpha = reducedMotion ? 1 : 0;
    let scrollAlpha = 1;
    let elapsed = 0;
    let lastFrameMs = 0;
    let rafId = 0;
    let running = false;
    let isVisible = true;
    let wasVideoPlaying = false;

    function clamp01(value) {
      return Math.max(0, Math.min(1, value));
    }

    function ease(t) {
      const n = clamp01(t);
      return n < 0.5 ? 4 * n * n * n : 1 - Math.pow(-2 * n + 2, 3) / 2;
    }

    function setCanvasOpacity() {
      const value = clamp01(introAlpha * scrollAlpha);
      canvas.style.opacity = String(value);
    }

    function updateScrollAlpha() {
      const rect = hero.getBoundingClientRect();
      const exitEnd = window.innerHeight * 0.10;
      const exitRange = Math.max(180, window.innerHeight * 0.42);
      scrollAlpha = clamp01((rect.bottom - exitEnd) / exitRange);
      setCanvasOpacity();
    }

    function applyLidPose(progress) {
      if (!lidPivot) return;
      lidPivot.rotation.x = LID_OPEN_ANGLE + (LID_CLOSE_ANGLE - LID_OPEN_ANGLE) * progress;
      lidPivot.position.y = LID_PIVOT_Y0;
      lidPivot.position.z = LID_PIVOT_Z0 + LID_CLOSE_Z_OFFSET * progress;
    }

    function startAutoClose() {
      if (reducedMotion || heroState !== 'PLAYING' || !lidPivot) return;
      heroState = 'CLOSING';
      lidIsAnimating = true;
      lidAnimFrom = lidProgress;
      lidAnimTo = 1;
      lidAnimStartMs = performance.now();
    }

    function onCloseComplete() {
      lidIsClosed = true;
      if (videoReady) video.pause();
      if (pendingReopen) {
        pendingReopen = false;
        heroState = 'CLOSED';
        startReopen();
        return;
      }
      heroState = 'CLOSED';
    }

    function startReopen() {
      if (heroState === 'CLOSING') {
        pendingReopen = true;
        return;
      }
      if (heroState !== 'CLOSED') return;
      heroState = 'OPENING';
      if (videoReady) {
        video.currentTime = 0;
        video.pause();
      }
      lidIsAnimating = true;
      lidAnimFrom = lidProgress;
      lidAnimTo = 0;
      lidAnimStartMs = performance.now();
    }

    function onOpenComplete() {
      heroState = 'PLAYING';
      lidIsClosed = false;
      lidProgress = 0;
      playStartTime = elapsed;
      terminalLeft.reset();
      terminalRight.reset();
      if (videoReady && !reducedMotion) {
        video.playbackRate = 1.5;
        video.play().catch(function noop() {});
      }
    }

    function applyVideoToScreen() {
      if (!screenMeshRef || screenVideoTexture) return;
      screenVideoTexture = new THREE.VideoTexture(video);
      if ('colorSpace' in screenVideoTexture && THREE.SRGBColorSpace) {
        screenVideoTexture.colorSpace = THREE.SRGBColorSpace;
      } else if ('encoding' in screenVideoTexture && THREE.sRGBEncoding) {
        screenVideoTexture.encoding = THREE.sRGBEncoding;
      }
      screenMeshRef.material = new THREE.MeshBasicMaterial({ map: screenVideoTexture, toneMapped: false });
      video.currentTime = 0;
    }

    const loader = new THREE.GLTFLoader();
    loader.load('assets/macbook.glb', function onModelLoaded(gltf) {
      if (modelDisposed) return;
      const model = gltf.scene;
      modelRef = model;
      const initialBox = new THREE.Box3().setFromObject(model);
      const initialSize = initialBox.getSize(new THREE.Vector3());
      const scaleFactor = 1.75 / Math.max(initialSize.x, initialSize.y, initialSize.z);
      model.scale.setScalar(scaleFactor);
      const centeredBox = new THREE.Box3().setFromObject(model);
      const center = centeredBox.getCenter(new THREE.Vector3());
      model.position.sub(center);
      model.position.y += 0.42;
      model.updateMatrixWorld(true);

      let lidNode = null;
      let bodyNode = null;
      model.traverse(function findNodes(object) {
        if (!lidNode && object.name && object.name.indexOf('VCQqxpxkUlzqcJI') !== -1) lidNode = object;
        if (!bodyNode && object.name && object.name.indexOf('BoBvWqDHZjAeVrp') !== -1) bodyNode = object;
      });
      lidNodeRef = lidNode;
      bodyNodeRef = bodyNode;
      if (lidNode && bodyNode) {
        const lidBox = new THREE.Box3().setFromObject(lidNode);
        const bodyBox = new THREE.Box3().setFromObject(bodyNode);
        bodyBounds = bodyBox.clone();
        const hingeWorld = new THREE.Vector3(
          (bodyBox.min.x + bodyBox.max.x) * 0.5,
          bodyBox.max.y,
          bodyBox.min.z
        );
        lidPivot = new THREE.Group();
        lidPivot.position.copy(model.worldToLocal(hingeWorld.clone()));
        LID_PIVOT_Y0 = lidPivot.position.y;
        LID_PIVOT_Z0 = lidPivot.position.z;
        model.add(lidPivot);
        model.updateMatrixWorld(true);
        lidPivot.attach(lidNode);
        model.updateMatrixWorld(true);
        LID_OPEN_ANGLE = 0;
        LID_CLOSE_ANGLE = 2.0 - 0.052;
        LID_CLOSE_Z_OFFSET = 0.06;
        applyLidPose(0);

        lidNode.traverse(function findScreen(object) {
          if (!screenMeshRef && object.isMesh && object.material && object.material.name === 'sfCQkHOWyrsLmor') screenMeshRef = object;
        });
        if (video.readyState >= 3) {
          videoReady = true;
          applyVideoToScreen();
        }
        buildLinks();
      }

      masterGroup.add(model);
      modelLoaded = true;
      masterGroup.position.y = reducedMotion ? 0 : INTRO_Y_OFFSET;
      masterGroup.position.z = reducedMotion ? 0 : INTRO_Z_OFFSET;
      masterGroup.rotation.set(0, 0, 0);
      if (reducedMotion) {
        phoneRevealLeft = 1;
        phoneRevealRight = 1;
        lidProgress = 1;
        applyLidPose(1);
        terminalLeft.showStatic();
        terminalRight.showStatic();
        applyPhoneScales();
        if (lineLeft) applyLinkProgress(lineLeft, 1, 0);
        if (lineRight) applyLinkProgress(lineRight, 1, 0);
        heroState = 'PLAYING';
        introComplete = true;
        introAlpha = 1;
        setCanvasOpacity();
        startLoop();
      }
    }, undefined, function onModelError() {
      /* Keep the DOM hero usable if WebGL or the optional model is unavailable. */
      modelLoaded = true;
      heroState = 'PLAYING';
      introComplete = true;
      introAlpha = 1;
      setCanvasOpacity();
    });

    video.addEventListener('canplay', function onVideoReady() {
      if (!screenMeshRef) return;
      videoReady = true;
      applyVideoToScreen();
    }, { once: true });

    video.addEventListener('timeupdate', function onVideoTime() {
      if (reducedMotion || heroState !== 'PLAYING') return;
      if (video.duration && video.currentTime >= video.duration - 1) startAutoClose();
    });

    canvas.addEventListener('pointerdown', function onCanvasPointerDown() {
      if (!lidPivot || !modelLoaded || lidIsAnimating) return;
      if (heroState === 'CLOSED') startReopen();
      else if (heroState === 'PLAYING') startAutoClose();
    });
    canvas.style.cursor = 'pointer';

    let mouseNX = 0;
    let mouseNY = 0;
    let currentTiltX = 0;
    let currentTiltY = 0;
    const TILT_MAX_X = 0.042;
    const TILT_MAX_Y = 0.062;
    const TILT_LERP = 0.055;
    function onMouseMove(event) {
      mouseNX = (event.clientX / window.innerWidth) * 2 - 1;
      mouseNY = (event.clientY / window.innerHeight) * 2 - 1;
    }
    function onMouseLeave() {
      mouseNX = 0;
      mouseNY = 0;
    }
    function onTouchMove(event) {
      if (!event.touches.length) return;
      mouseNX = (event.touches[0].clientX / window.innerWidth) * 2 - 1;
      mouseNY = (event.touches[0].clientY / window.innerHeight) * 2 - 1;
    }
    window.addEventListener('mousemove', onMouseMove, { passive: true });
    window.addEventListener('mouseleave', onMouseLeave, { passive: true });
    window.addEventListener('touchmove', onTouchMove, { passive: true });

    function updateFrame(now, dt) {
      elapsed += dt;
      if (heroState === 'LOADING' && modelLoaded) {
        heroState = reducedMotion ? 'PLAYING' : 'INTRO';
        introStartMs = now;
        if (reducedMotion) {
          introComplete = true;
          introAlpha = 1;
        }
      }

      if (heroState === 'INTRO' && !introComplete) {
        const progress = INTRO_DUR_MS ? Math.min((now - introStartMs) / INTRO_DUR_MS, 1) : 1;
        const eased = ease(progress);
        masterGroup.position.y = INTRO_Y_OFFSET * (1 - eased);
        masterGroup.position.z = INTRO_Z_OFFSET * (1 - eased);
        introAlpha = Math.min(1, eased * 1.08);
        if (progress >= 1) {
          masterGroup.position.y = 0;
          masterGroup.position.z = 0;
          introAlpha = 1;
          introComplete = true;
          heroState = 'PLAYING';
          playStartTime = elapsed;
          if (videoReady && !reducedMotion) video.play().catch(function noop() {});
        }
        setCanvasOpacity();
      }

      if (heroState === 'PLAYING' && !videoReady && !reducedMotion && elapsed - playStartTime > PLAY_FALLBACK_SEC) {
        startAutoClose();
      }

      if (lidPivot) {
        if (lidIsAnimating) {
          const progress = Math.min((now - lidAnimStartMs) / LID_TOGGLE_DUR_MS, 1);
          lidProgress = lidAnimFrom + (lidAnimTo - lidAnimFrom) * ease(progress);
          if (progress >= 1) {
            lidProgress = lidAnimTo;
            lidIsAnimating = false;
            if (lidAnimTo === 1) onCloseComplete();
            else onOpenComplete();
          }
        }
        applyLidPose(lidProgress);
      }

      if (reducedMotion) {
        phoneRevealLeft = 1;
        phoneRevealRight = 1;
      } else {
        const sequence = THREE.MathUtils.clamp((lidProgress - 0.80) / 0.20, 0, 1);
        phoneRevealLeft = ease(THREE.MathUtils.clamp(sequence / 0.5, 0, 1));
        phoneRevealRight = ease(THREE.MathUtils.clamp((sequence - 0.5) / 0.5, 0, 1));
      }
      applyPhoneScales();
      const leftLinkP = lineLeft ? phoneRevealLeft : 0;
      const rightLinkP = lineRight ? phoneRevealRight : 0;
      applyLinkProgress(lineLeft, leftLinkP, elapsed);
      applyLinkProgress(lineRight, rightLinkP, elapsed);

      if (!reducedMotion) {
        if (phoneRevealLeft > 0.3) terminalLeft.start();
        if (phoneRevealRight > 0.3) terminalRight.start();
        terminalLeft.update(dt);
        terminalRight.update(dt);
        if (heroState !== 'INTRO' && heroState !== 'LOADING') {
          if (elapsed >= 4) masterGroup.position.y = Math.sin((elapsed - 4) * 1.2) * 0.0045;
          currentTiltY += (mouseNX * TILT_MAX_Y - currentTiltY) * TILT_LERP;
          currentTiltX += (-mouseNY * TILT_MAX_X - currentTiltX) * TILT_LERP;
          masterGroup.rotation.y = currentTiltY;
          masterGroup.rotation.x = currentTiltX;
        }
      } else {
        currentTiltX = 0;
        currentTiltY = 0;
        masterGroup.rotation.set(0, 0, 0);
        masterGroup.position.y = 0;
        masterGroup.position.z = 0;
      }

      renderer.render(scene, camera);
    }

    function frame(now) {
      if (!running) return;
      if (!lastFrameMs) lastFrameMs = now;
      const dt = Math.min((now - lastFrameMs) / 1000, 0.05);
      lastFrameMs = now;
      updateFrame(now, dt);
      if (reducedMotion && modelLoaded) {
        running = false;
        rafId = 0;
        lastFrameMs = 0;
      } else {
        rafId = window.requestAnimationFrame(frame);
      }
    }

    function startLoop() {
      if (running || modelDisposed || !isVisible || document.hidden) return;
      running = true;
      lastFrameMs = 0;
      rafId = window.requestAnimationFrame(frame);
      if (wasVideoPlaying && videoReady && heroState === 'PLAYING' && !reducedMotion) video.play().catch(function noop() {});
    }

    function stopLoop() {
      if (!running) return;
      running = false;
      window.cancelAnimationFrame(rafId);
      rafId = 0;
      lastFrameMs = 0;
      wasVideoPlaying = videoReady && !video.paused;
      if (wasVideoPlaying) video.pause();
    }

    function onVisibilityChange() {
      if (document.hidden) stopLoop();
      else startLoop();
    }

    const visibilityObserver = 'IntersectionObserver' in window ? new IntersectionObserver(function observeHero(entries) {
      isVisible = entries.length ? entries[0].isIntersecting : true;
      if (isVisible) startLoop();
      else stopLoop();
    }, { threshold: 0.01 }) : null;
    if (visibilityObserver) visibilityObserver.observe(container);

    function onResize() {
      const nextWidth = container.clientWidth || window.innerWidth;
      const nextHeight = container.clientHeight || Math.round(window.innerHeight * 0.65);
      const nextMobile = nextWidth < 700;
      width = nextWidth;
      height = nextHeight;
      if (nextMobile !== isMobile) {
        isMobile = nextMobile;
        applyPhoneLayout();
        buildLinks();
      }
      camera.fov = isMobile ? 60 : 35;
      camera.aspect = width / height || 1;
      camera.position.set(0, isMobile ? 0.6 : 0.55, isMobile ? 3.5 : 3.0);
      camera.lookAt(0, 0.24, 0);
      camera.updateProjectionMatrix();
      renderer.setSize(width, height, false);
      updateScrollAlpha();
      if (reducedMotion) startLoop();
    }

    function onReducedMotionChange(event) {
      reducedMotion = event.matches;
      if (reducedMotion) {
        introComplete = true;
        introAlpha = 1;
        phoneRevealLeft = 1;
        phoneRevealRight = 1;
        video.pause();
        lidIsAnimating = false;
        lidProgress = 1;
        heroState = 'CLOSED';
        applyLidPose(1);
        terminalLeft.showStatic();
        terminalRight.showStatic();
        if (lineLeft) applyLinkProgress(lineLeft, 1, elapsed);
        if (lineRight) applyLinkProgress(lineRight, 1, elapsed);
      }
      setCanvasOpacity();
      startLoop();
    }

    function cleanup() {
      if (modelDisposed) return;
      modelDisposed = true;
      stopLoop();
      window.removeEventListener('resize', onResize);
      window.removeEventListener('scroll', updateScrollAlpha);
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('mouseleave', onMouseLeave);
      window.removeEventListener('touchmove', onTouchMove);
      document.removeEventListener('visibilitychange', onVisibilityChange);
      reducedQuery.removeEventListener?.('change', onReducedMotionChange);
      if (visibilityObserver) visibilityObserver.disconnect();
      if (lineLeft) disposeLink(lineLeft);
      if (lineRight) disposeLink(lineRight);
      masterGroup.traverse(function disposeObject(object) {
        if (object.geometry && object.geometry.dispose) object.geometry.dispose();
        if (object.material) {
          const materials = Array.isArray(object.material) ? object.material : [object.material];
          materials.forEach(function disposeMaterial(material) {
            if (material.map && material.map !== screenVideoTexture) material.map.dispose();
            material.dispose();
          });
        }
      });
      if (screenVideoTexture) screenVideoTexture.dispose();
      renderer.dispose();
      video.pause();
      video.removeAttribute('src');
      video.load();
    }

    window.addEventListener('resize', onResize, { passive: true });
    window.addEventListener('scroll', updateScrollAlpha, { passive: true });
    document.addEventListener('visibilitychange', onVisibilityChange);
    reducedQuery.addEventListener?.('change', onReducedMotionChange);
    window.addEventListener('pagehide', event => {
      if (event.persisted) stopLoop();
      else cleanup();
    });
    window.addEventListener('pageshow', startLoop);
    updateScrollAlpha();
    startLoop();
  });
})();
