/* ============================================================
   COFFEETOSH — main.js
   Three.js hero, GSAP ScrollTrigger, Lenis, waves, copy, accordion
   ============================================================ */

/* ----------------------------------------------------------
   WAVE DIVIDERS
   ---------------------------------------------------------- */
function renderWaves() {
  document.querySelectorAll('.wave-divider').forEach(el => {
    const fromColor = el.dataset.from || 'var(--bg-base)';
    const toColor   = el.dataset.to   || 'var(--bg-popover)';
    const flip      = el.dataset.flip === 'true';
    el.innerHTML = `
      <svg viewBox="0 0 1440 80" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg"
           style="display:block;width:100%;height:80px;${flip ? 'transform:scaleY(-1)' : ''}">
        <path d="M0,40 C240,80 480,0 720,40 C960,80 1200,0 1440,40 L1440,80 L0,80 Z" fill="${toColor}"/>
      </svg>`;
  });
}

/* ----------------------------------------------------------
   COPY BUTTONS
   ---------------------------------------------------------- */
function initCopyButtons() {
  document.querySelectorAll('.copy-block__btn').forEach(btn => {
    btn.addEventListener('click', async () => {
      const code = btn.closest('.copy-block').querySelector('.copy-block__code').textContent.trim();
      try {
        await navigator.clipboard.writeText(code);
      } catch (_) {
        /* fallback for older browsers */
        const ta = document.createElement('textarea');
        ta.value = code;
        ta.style.position = 'fixed';
        ta.style.opacity = '0';
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
      }
      const iconCopy  = btn.querySelector('.icon-copy');
      const iconCheck = btn.querySelector('.icon-check');
      if (iconCopy && iconCheck) {
        iconCopy.style.display  = 'none';
        iconCheck.style.display = 'block';
        btn.style.color = 'var(--accent)';
        setTimeout(() => {
          iconCopy.style.display  = 'block';
          iconCheck.style.display = 'none';
          btn.style.color = '';
        }, 1500);
      }
    });
  });
}

/* ----------------------------------------------------------
   LEGO SCROLL ANIMATIONS
   ---------------------------------------------------------- */
function initLegoAnimations() {
  gsap.registerPlugin(ScrollTrigger);

  document.querySelectorAll('.lego-section').forEach(section => {
    const items = section.querySelectorAll('.lego-item');
    if (!items.length) return;

    gsap.fromTo(items,
      { opacity: 0, y: 40, scale: 0.96 },
      {
        opacity: 1, y: 0, scale: 1,
        duration: 0.65,
        ease: 'cubic-bezier(0.22, 1, 0.36, 1)',
        stagger: 0.08,
        scrollTrigger: {
          trigger: section,
          start: 'top 82%',
          once: true
        }
      }
    );
  });
}

/* ----------------------------------------------------------
   ACCORDION (Docs page)
   ---------------------------------------------------------- */
function initAccordion() {
  document.querySelectorAll('.accordion-header').forEach(header => {
    header.addEventListener('click', () => {
      const item = header.closest('.accordion-item');
      const wasOpen = item.classList.contains('open');

      /* Close all siblings in the same group */
      const group = item.closest('.accordion-group');
      if (group) {
        group.querySelectorAll('.accordion-item.open').forEach(openItem => {
          openItem.classList.remove('open');
        });
      }

      if (!wasOpen) {
        item.classList.add('open');
      }
    });
  });
}

/* ----------------------------------------------------------
   MOBILE NAV TOGGLE
   ---------------------------------------------------------- */
function initMobileNav() {
  const toggle = document.querySelector('.nav-toggle');
  const links  = document.querySelector('.nav-links');
  if (!toggle || !links) return;

  toggle.addEventListener('click', () => {
    links.classList.toggle('open');
    const isOpen = links.classList.contains('open');
    toggle.setAttribute('aria-expanded', isOpen);
  });

  /* Close on link click */
  links.querySelectorAll('a').forEach(a => {
    a.addEventListener('click', () => {
      links.classList.remove('open');
      toggle.setAttribute('aria-expanded', 'false');
    });
  });
}

/* ----------------------------------------------------------
   NAV ACTIVE LINK
   ---------------------------------------------------------- */
function initActiveNav() {
  const path = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav-links a').forEach(a => {
    const href = a.getAttribute('href');
    if (href === path || (path === '' && href === 'index.html')) {
      a.classList.add('active');
    }
  });
}

/* ----------------------------------------------------------
   THREE.JS HERO SCENE
   ---------------------------------------------------------- */
function initHeroScene() {
  const canvas = document.getElementById('hero-canvas');
  if (!canvas) return;

  /* WebGL check */
  try {
    const testCanvas = document.createElement('canvas');
    const gl = testCanvas.getContext('webgl') || testCanvas.getContext('experimental-webgl');
    if (!gl) { canvas.style.display = 'none'; return; }
  } catch (_) { canvas.style.display = 'none'; return; }

  const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: false });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.setSize(window.innerWidth, window.innerHeight);

  const scene  = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 100);
  camera.position.z = 5;

  /* --- Particle field: 300 coffee-tinted dots --- */
  const particleCount = 300;
  const positions = new Float32Array(particleCount * 3);
  for (let i = 0; i < particleCount; i++) {
    positions[i * 3]     = (Math.random() - 0.5) * 20;
    positions[i * 3 + 1] = (Math.random() - 0.5) * 12;
    positions[i * 3 + 2] = (Math.random() - 0.5) * 8;
  }
  const particleGeo = new THREE.BufferGeometry();
  particleGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
  const particleMat = new THREE.PointsMaterial({
    color: 0xD4923A, size: 0.018, transparent: true, opacity: 0.35, sizeAttenuation: true
  });
  scene.add(new THREE.Points(particleGeo, particleMat));

  /* --- Dither shader: full-screen amber glow quad --- */
  const ditherVert = `
    varying vec2 vUv;
    void main() {
      vUv = uv;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    }
  `;
  const ditherFrag = `
    uniform float time;
    varying vec2 vUv;

    float bayer4[16];

    float dither(vec2 pos, float brightness) {
      bayer4[0]=0./16.; bayer4[1]=8./16.; bayer4[2]=2./16.; bayer4[3]=10./16.;
      bayer4[4]=12./16.; bayer4[5]=4./16.; bayer4[6]=14./16.; bayer4[7]=6./16.;
      bayer4[8]=3./16.; bayer4[9]=11./16.; bayer4[10]=1./16.; bayer4[11]=9./16.;
      bayer4[12]=15./16.; bayer4[13]=7./16.; bayer4[14]=13./16.; bayer4[15]=5./16.;
      int ix = int(mod(pos.x, 4.0));
      int iy = int(mod(pos.y, 4.0));
      return brightness > bayer4[iy * 4 + ix] ? 1.0 : 0.0;
    }

    void main() {
      vec2 uv = vUv - 0.5;
      float dist = length(uv);
      float glow = smoothstep(0.7, 0.0, dist);
      glow *= 0.5 + 0.15 * sin(time * 0.6);
      vec2 screenPos = gl_FragCoord.xy;
      float d = dither(screenPos, glow);
      vec3 amber = vec3(0.831, 0.573, 0.227);
      gl_FragColor = vec4(amber * d, d * 0.18);
    }
  `;

  const ditherMat = new THREE.ShaderMaterial({
    vertexShader: ditherVert,
    fragmentShader: ditherFrag,
    uniforms: { time: { value: 0 } },
    transparent: true,
    depthWrite: false,
    blending: THREE.AdditiveBlending
  });
  const quad = new THREE.Mesh(new THREE.PlaneGeometry(20, 12), ditherMat);
  quad.position.z = -1;
  scene.add(quad);

  /* --- Mouse parallax --- */
  if (typeof gsap !== 'undefined' && gsap.quickTo) {
    const quickX = gsap.quickTo(camera.rotation, 'y', { duration: 1.2, ease: 'power2.out' });
    const quickY = gsap.quickTo(camera.rotation, 'x', { duration: 1.2, ease: 'power2.out' });
    window.addEventListener('mousemove', e => {
      const targetX = (e.clientX / window.innerWidth  - 0.5) * 0.14;
      const targetY = (e.clientY / window.innerHeight - 0.5) * -0.08;
      quickX(targetX);
      quickY(targetY);
    });
  }

  /* --- Resize handler --- */
  window.addEventListener('resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
  });

  /* --- Animate only while hero is visible --- */
  let animating = true;
  const observer = new IntersectionObserver(([entry]) => {
    animating = entry.isIntersecting;
    if (animating) animate();
  }, { threshold: 0.01 });
  observer.observe(canvas);

  function animate() {
    if (!animating) return;
    requestAnimationFrame(animate);
    ditherMat.uniforms.time.value += 0.016;

    /* Slowly drift particles upward */
    const pos = particleGeo.attributes.position;
    for (let i = 0; i < particleCount; i++) {
      pos.array[i * 3 + 1] += 0.0005;
      if (pos.array[i * 3 + 1] > 6) pos.array[i * 3 + 1] = -6;
    }
    pos.needsUpdate = true;
    renderer.render(scene, camera);
  }
  animate();
}

/* ----------------------------------------------------------
   STEPS CONNECTOR ANIMATION
   ---------------------------------------------------------- */
function initStepsConnector() {
  const connector = document.querySelector('.steps-line');
  if (!connector) return;

  gsap.fromTo(connector,
    { strokeDashoffset: 600 },
    {
      strokeDashoffset: 0,
      duration: 1.5,
      ease: 'power2.inOut',
      scrollTrigger: {
        trigger: connector.closest('section'),
        start: 'top 75%',
        once: true
      }
    }
  );
}

/* ----------------------------------------------------------
   INIT (DOMContentLoaded)
   ---------------------------------------------------------- */
document.addEventListener('DOMContentLoaded', () => {
  /* 1. Lenis smooth scroll */
  if (typeof Lenis !== 'undefined') {
    const lenis = new Lenis({ lerp: 0.1, smoothWheel: true });
    function raf(time) { lenis.raf(time); requestAnimationFrame(raf); }
    requestAnimationFrame(raf);

    /* Sync GSAP ScrollTrigger with Lenis */
    if (typeof ScrollTrigger !== 'undefined') {
      lenis.on('scroll', ScrollTrigger.update);
      gsap.ticker.add((time) => { lenis.raf(time * 1000); });
      gsap.ticker.lagSmoothing(0);
    }
  }

  /* 2. Three.js hero (index only) */
  if (document.getElementById('hero-canvas')) {
    initHeroScene();
  }

  /* 3. Wave dividers */
  renderWaves();

  /* 4. Lego scroll animations */
  if (typeof gsap !== 'undefined') {
    initLegoAnimations();
    initStepsConnector();
  }

  /* 5. Copy buttons */
  initCopyButtons();

  /* 6. Docs accordion */
  initAccordion();

  /* 7. Mobile nav */
  initMobileNav();

  /* 8. Nav active link */
  initActiveNav();
});
