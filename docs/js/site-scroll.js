(() => {
  const useGsapTicker = !!window.gsap;
  const lenis = new Lenis({
    autoRaf: !useGsapTicker,
    lerp: 0.09,
    anchors: { offset: -24, duration: 1.1, lerp: 0 },
    allowNestedScroll: true,
    stopInertiaOnNavigate: true,
    respectReducedMotion: true
  });
  const tick = time => lenis.raf(time * 1000);
  const resize = () => lenis.resize();
  if (useGsapTicker) {
    gsap.ticker.add(tick);
    gsap.ticker.lagSmoothing(0);
  }
  if (window.ScrollTrigger) {
    lenis.on('scroll', ScrollTrigger.update);
    ScrollTrigger.addEventListener('refresh', resize);
  }
  window.siteScroll = {
    to(target, options = {}) {
      lenis.resize();
      lenis.scrollTo(target, {
        duration: 1.1,
        lerp: 0,
        easing: value => 1 - Math.pow(1 - value, 4),
        ...options
      });
    }
  };
  const settleAnchor = () => {
    if (!location.hash) return;
    let id;
    try {
      id = decodeURIComponent(location.hash.slice(1));
    } catch {
      return;
    }
    requestAnimationFrame(() => {
      const target = document.getElementById(id);
      if (target) window.siteScroll.to(target, { immediate: true, offset: -24 });
    });
  };
  window.addEventListener('load', settleAnchor, { once: true });
  window.addEventListener('pageshow', resize);
  window.addEventListener('pagehide', event => {
    if (event.persisted) return;
    if (useGsapTicker) gsap.ticker.remove(tick);
    if (window.ScrollTrigger) ScrollTrigger.removeEventListener('refresh', resize);
    lenis.destroy();
    window.removeEventListener('pageshow', resize);
    window.removeEventListener('load', settleAnchor);
  });
})();
