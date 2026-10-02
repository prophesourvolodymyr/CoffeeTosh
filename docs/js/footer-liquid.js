(function () {
  'use strict';

  var WRAP_SELECTOR = '.footer-wave-wrap';
  var VIEWBOX_WIDTH = 1440;
  var VIEWBOX_HEIGHT = 120;
  var DROP_COUNT = 6;
  var TAU = Math.PI * 2;
  var reducedMotionQuery;

  function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
  }

  function smoothstep(value) {
    var t = clamp(value, 0, 1);
    return t * t * (3 - 2 * t);
  }

  function cubic(p0, p1, p2, p3, t) {
    var inv = 1 - t;
    return inv * inv * inv * p0
      + 3 * inv * inv * t * p1
      + 3 * inv * t * t * p2
      + t * t * t * p3;
  }

  function sourceEdgeY(x) {
    var px = clamp(x, 0, VIEWBOX_WIDTH);
    if (px <= 615) {
      return cubic(40, 14, 40, 68, px / 615);
    }
    if (px <= 1026) {
      return cubic(68, 92, 54, 34, (px - 615) / 411);
    }
    return cubic(34, 14, 62, 42, (px - 1026) / 414);
  }

  function makePath(ctx, width, height, time) {
    var samples = 88;
    var heightScale = height / VIEWBOX_HEIGHT;
    var x;
    var i;

    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(width, 0);
    for (i = samples; i >= 0; i -= 1) {
      x = width * i / samples;
      ctx.lineTo(x, edgeY(x, width, heightScale, time));
    }
    ctx.closePath();
  }

  function edgeY(x, width, heightScale, time) {
    var normalized = width > 0 ? x / width : 0;
    var sourceY = sourceEdgeY(normalized * VIEWBOX_WIDTH);
    var gentleWave = Math.sin(normalized * 16.5 + time * 0.58) * 0.92
      + Math.sin(normalized * 34 - time * 0.32 + 0.8) * 0.42
      + Math.sin(normalized * 5.4 - time * 0.19) * 0.3;
    return clamp(sourceY * heightScale + gentleWave * heightScale, 8 * heightScale, (VIEWBOX_HEIGHT - 5) * heightScale);
  }

  function init() {
    var wrap = document.querySelector(WRAP_SELECTOR);
    if (!wrap || !window.HTMLCanvasElement) return;

    var canvas = document.createElement('canvas');
    canvas.className = 'footer-liquid-canvas';
    canvas.setAttribute('aria-hidden', 'true');
    canvas.setAttribute('role', 'presentation');

    var ctx = canvas.getContext('2d', { alpha: true, desynchronized: true });
    if (!ctx) return;

    wrap.appendChild(canvas);

    var fallback = wrap.querySelector('svg');
    if (fallback) {
      fallback.style.display = 'none';
      fallback.setAttribute('aria-hidden', 'true');
    }

    var width = 0;
    var height = 0;
    var dpr = 1;
    var lastTime = 0;
    var elapsed = 0;
    var frameId = 0;
    var inViewport = false;
    var pageVisible = document.visibilityState !== 'hidden';
    var disposed = false;
    var prefersReducedMotion = false;

    reducedMotionQuery = window.matchMedia
      ? window.matchMedia('(prefers-reduced-motion: reduce)')
      : null;
    prefersReducedMotion = !!(reducedMotionQuery && reducedMotionQuery.matches);

    var anchors = [0.115, 0.285, 0.445, 0.605, 0.765, 0.905];
    var drops = [];
    var i;
    for (i = 0; i < DROP_COUNT; i += 1) {
      drops.push({
        anchor: anchors[i],
        seed: 1.7 + i * 3.91,
        state: 0,
        timer: 0.52 + i * 0.56,
        age: 0,
        x: 0,
        y: 0,
        radius: 0,
        neck: 0,
        shapeRecovery: 0,
        formDuration: 0,
        velocityX: 0,
        velocityY: 0,
        satellite: {
          active: false,
          emitted: false,
          age: 0,
          x: 0,
          y: 0,
          radius: 0,
          velocityX: 0,
          velocityY: 0
        }
      });
    }

    function syncSize() {
      var nextWidth = Math.max(1, wrap.clientWidth || 1);
      var nextHeight = Math.max(1, wrap.clientHeight || VIEWBOX_HEIGHT);
      var nextDpr = Math.min(window.devicePixelRatio || 1, 2);
      var previousWidth = width;
      var previousHeight = height;
      if (nextWidth === width && nextHeight === height && nextDpr === dpr) return;

      if (previousWidth > 0 && previousHeight > 0 && drops.length) {
        var widthRatio = nextWidth / previousWidth;
        var heightRatio = nextHeight / previousHeight;
        for (var resizeIndex = 0; resizeIndex < drops.length; resizeIndex += 1) {
          var resizedDrop = drops[resizeIndex];
          if (resizedDrop.state !== 0) {
            resizedDrop.x = clamp(resizedDrop.x * widthRatio, 3, nextWidth - 3);
            resizedDrop.y = clamp(resizedDrop.y * heightRatio, -nextHeight, nextHeight * 1.2);
          }
          if (resizedDrop.satellite.active) {
            resizedDrop.satellite.x = clamp(resizedDrop.satellite.x * widthRatio, 2, nextWidth - 2);
            resizedDrop.satellite.y = clamp(resizedDrop.satellite.y * heightRatio, -nextHeight, nextHeight * 1.2);
          }
        }
      }

      width = nextWidth;
      height = nextHeight;
      dpr = nextDpr;
      canvas.width = Math.max(1, Math.round(width * dpr));
      canvas.height = Math.max(1, Math.round(height * dpr));
      canvas.style.width = width + 'px';
      canvas.style.height = height + 'px';
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    }
    function resetSatellite(drop) {
      drop.satellite.active = false;
      drop.satellite.emitted = false;
      drop.satellite.age = 0;
    }


    function spawn(drop) {
      var sizeScale = clamp(width / 720, 0.82, 1.12);
      var sign = Math.sin(drop.seed) < 0 ? -1 : 1;
      drop.state = 1;
      drop.age = 0;
      drop.radius = (4.6 + (drop.seed % 1.4) * 1.5) * sizeScale;
      drop.neck = 1;
      drop.shapeRecovery = 0;
      drop.formDuration = 0.42 + (drop.seed % 0.16);
      drop.x = clamp((drop.anchor + Math.sin(drop.seed * 1.31) * 0.008) * width, 8, width - 8);
      drop.velocityX = sign * (2.6 + (drop.seed % 2.2));
      drop.velocityY = 11 + (drop.seed % 7);
      resetSatellite(drop);
    }

    function schedule(drop, index) {
      drop.state = 0;
      drop.age = 0;
      drop.timer = 1.05 + index * 0.23 + (drop.seed % 0.42);
      resetSatellite(drop);
    }

    function updateSatellite(drop, dt) {
      var satellite = drop.satellite;
      if (!satellite.active) return;
      satellite.age += dt;
      satellite.velocityY += 112 * dt;
      satellite.x += satellite.velocityX * dt;
      satellite.y += satellite.velocityY * dt;
      if (satellite.y - satellite.radius > height - 2 || satellite.age > 1.35) {
        satellite.active = false;
      }
    }

    function updateDrop(drop, index, dt, time) {
      if (drop.state === 0) {
        drop.timer -= dt;
        if (drop.timer <= 0) spawn(drop);
        return;
      }

      if (drop.state === 1) {
        drop.age += dt;
        if (drop.age >= drop.formDuration) {
          var currentEdge = edgeY(drop.x, width, height / VIEWBOX_HEIGHT, time);
          drop.state = 2;
          drop.age = 0;
          drop.neck = 2 + drop.radius * 1.45;
          drop.shapeRecovery = 0.48 + (drop.seed % 0.14);
          drop.y = currentEdge + drop.neck + drop.radius * 0.95;
          drop.velocityY = 13 + drop.radius * 1.7;
        }
        return;
      }

      drop.age += dt;
      drop.shapeRecovery *= Math.max(0, 1 - dt * 4.8);
      drop.velocityY += 142 * dt;
      drop.x += drop.velocityX * dt;
      drop.y += drop.velocityY * dt;
      if (!drop.satellite.active && !drop.satellite.emitted && drop.age > 0.17) {
        var satelliteSign = Math.sin(drop.seed * 2.2) < 0 ? -1 : 1;
        var satellite = drop.satellite;
        satellite.active = true;
        satellite.emitted = true;
        satellite.age = 0;
        satellite.radius = drop.radius * 0.25;
        satellite.x = drop.x + satelliteSign * drop.radius * 1.22;
        satellite.y = drop.y - drop.radius * 0.52;
        satellite.velocityX = drop.velocityX * 0.45 + satelliteSign * 8;
        satellite.velocityY = drop.velocityY * 0.66 - 14;
      }
      updateSatellite(drop, dt);

      if (drop.y - drop.radius * 2 > height - 1 || drop.age > 1.7) {
        schedule(drop, index);
      }
    }

    function drawAttachedDrop(drop, time) {
      var scale = height / VIEWBOX_HEIGHT;
      var surface = edgeY(drop.x, width, scale, time);
      var progress = smoothstep(drop.age / drop.formDuration);
      var radius = drop.radius * (0.14 + progress * 0.86);
      var neck = (1.2 + progress * (2.1 + drop.radius * 1.2)) * scale;
      var neckWidth = Math.max(0.7, radius * (0.22 - progress * 0.06));
      var bodyTop = surface + neck * 0.7;
      var bodyBottom = bodyTop + radius * (1.75 + progress * 0.25);
      var sway = Math.sin(time * 3.4 + drop.seed) * radius * 0.08;
      var gradient = ctx.createRadialGradient(
        drop.x - radius * 0.38,
        bodyTop + radius * 0.26,
        0.3,
        drop.x,
        bodyTop + radius,
        Math.max(1, radius * 1.7)
      );
      gradient.addColorStop(0, 'rgba(171, 105, 40, 0.98)');
      gradient.addColorStop(0.18, 'rgba(105, 51, 18, 0.98)');
      gradient.addColorStop(0.72, 'rgba(44, 19, 8, 0.99)');
      gradient.addColorStop(1, 'rgba(16, 8, 4, 0.99)');

      ctx.beginPath();
      ctx.moveTo(drop.x - neckWidth, surface - 0.7);
      ctx.bezierCurveTo(
        drop.x - neckWidth * 1.45,
        surface + neck * 0.46,
        drop.x - radius * 1.18 + sway,
        bodyTop - radius * 0.22,
        drop.x - radius * 0.92,
        bodyTop + radius * 0.34
      );
      ctx.bezierCurveTo(
        drop.x - radius * 1.2,
        bodyTop + radius * 1.14,
        drop.x - radius * 0.6,
        bodyBottom,
        drop.x,
        bodyBottom + radius * 0.08
      );
      ctx.bezierCurveTo(
        drop.x + radius * 0.73,
        bodyBottom,
        drop.x + radius * 1.16,
        bodyTop + radius * 1.04,
        drop.x + radius * 0.9,
        bodyTop + radius * 0.32
      );
      ctx.bezierCurveTo(
        drop.x + radius * 0.48,
        bodyTop - radius * 0.08,
        drop.x + neckWidth * 1.4,
        surface + neck * 0.44,
        drop.x + neckWidth,
        surface - 0.7
      );
      ctx.closePath();
      ctx.fillStyle = gradient;
      ctx.fill();

      ctx.beginPath();
      ctx.moveTo(drop.x - radius * 0.43, bodyTop + radius * 0.3);
      ctx.quadraticCurveTo(
        drop.x - radius * 0.12,
        bodyTop + radius * 0.03,
        drop.x + radius * 0.15,
        bodyTop + radius * 0.26
      );
      ctx.strokeStyle = 'rgba(245, 237, 227, 0.43)';
      ctx.lineWidth = Math.max(0.45, radius * 0.11);
      ctx.lineCap = 'round';
      ctx.stroke();
    }

    function drawFallingDrop(drop) {
      var stretch = 1 + drop.shapeRecovery * Math.cos(drop.age * 19);
      var radiusX = drop.radius / Math.sqrt(stretch);
      var radiusY = drop.radius * stretch;
      var tipY = drop.y - radiusY * (1 + drop.shapeRecovery * 0.3);
      var gradient = ctx.createRadialGradient(
        drop.x - radiusX * 0.34,
        drop.y - radiusY * 0.33,
        0.25,
        drop.x,
        drop.y,
        Math.max(1, radiusY * 1.2)
      );
      gradient.addColorStop(0, 'rgba(184, 116, 49, 0.98)');
      gradient.addColorStop(0.18, 'rgba(119, 60, 21, 0.98)');
      gradient.addColorStop(0.72, 'rgba(46, 20, 8, 0.99)');
      gradient.addColorStop(1, 'rgba(15, 7, 3, 0.99)');

      ctx.beginPath();
      ctx.moveTo(drop.x, tipY);
      ctx.bezierCurveTo(
        drop.x - radiusX * 0.552, tipY,
        drop.x - radiusX, drop.y - radiusY * 0.552,
        drop.x - radiusX, drop.y
      );
      ctx.bezierCurveTo(
        drop.x - radiusX, drop.y + radiusY * 0.552,
        drop.x - radiusX * 0.552, drop.y + radiusY,
        drop.x, drop.y + radiusY
      );
      ctx.bezierCurveTo(
        drop.x + radiusX * 0.552, drop.y + radiusY,
        drop.x + radiusX, drop.y + radiusY * 0.552,
        drop.x + radiusX, drop.y
      );
      ctx.bezierCurveTo(
        drop.x + radiusX, drop.y - radiusY * 0.552,
        drop.x + radiusX * 0.552, tipY,
        drop.x, tipY
      );
      ctx.closePath();
      ctx.fillStyle = gradient;
      ctx.fill();

      ctx.beginPath();
      ctx.moveTo(drop.x - radiusX * 0.38, drop.y - radiusY * 0.33);
      ctx.quadraticCurveTo(
        drop.x - radiusX * 0.14,
        drop.y - radiusY * 0.56,
        drop.x + radiusX * 0.16,
        drop.y - radiusY * 0.3
      );
      ctx.strokeStyle = 'rgba(245, 237, 227, 0.44)';
      ctx.lineWidth = Math.max(0.42, radiusX * 0.12);
      ctx.lineCap = 'round';
      ctx.stroke();
    }

    function drawSatellite(satellite) {
      if (!satellite.active) return;
      var radius = satellite.radius;
      var gradient = ctx.createRadialGradient(
        satellite.x - radius * 0.32,
        satellite.y - radius * 0.32,
        0.1,
        satellite.x,
        satellite.y,
        Math.max(0.5, radius * 1.4)
      );
      gradient.addColorStop(0, 'rgba(167, 98, 35, 0.98)');
      gradient.addColorStop(0.35, 'rgba(82, 37, 13, 0.98)');
      gradient.addColorStop(1, 'rgba(19, 8, 3, 0.98)');
      ctx.beginPath();
      ctx.ellipse(satellite.x, satellite.y, radius * 0.8, radius * 1.18, 0, 0, TAU);
      ctx.fillStyle = gradient;
      ctx.fill();
    }

    function draw(time) {
      if (!width || !height) return;
      var scale = height / VIEWBOX_HEIGHT;
      var j;

      ctx.clearRect(0, 0, width, height);
      makePath(ctx, width, height, time);
      var coffeeGradient = ctx.createLinearGradient(0, 0, 0, height);
      coffeeGradient.addColorStop(0, '#1A1310');
      coffeeGradient.addColorStop(0.48, '#1a1310');
      coffeeGradient.addColorStop(1, '#100a07');
      ctx.fillStyle = coffeeGradient;
      ctx.fill();

      ctx.save();
      ctx.clip();
      for (j = 0; j < 3; j += 1) {
        ctx.beginPath();
        var reflectionX;
        for (reflectionX = 0; reflectionX <= width; reflectionX += 56) {
          var reflectionY = edgeY(reflectionX, width, scale, time)
            - (5 + j * 9) * scale
            + Math.sin(reflectionX * 0.025 + time * 0.44 + j) * 1.4;
          if (reflectionX === 0) ctx.moveTo(reflectionX, reflectionY);
          else ctx.lineTo(reflectionX, reflectionY);
        }
        ctx.strokeStyle = j === 0
          ? 'rgba(245, 237, 227, 0.14)'
          : 'rgba(212, 146, 58, ' + (0.08 - j * 0.015) + ')';
        ctx.lineWidth = (j === 0 ? 1.25 : 0.8) * scale;
        ctx.lineCap = 'round';
        ctx.stroke();
      }
      ctx.restore();

      ctx.beginPath();
      ctx.moveTo(0, edgeY(0, width, scale, time));
      for (var segment = 1; segment <= 88; segment += 1) {
        var edgeX = width * segment / 88;
        ctx.lineTo(edgeX, edgeY(edgeX, width, scale, time));
      }
      ctx.strokeStyle = 'rgba(245, 237, 227, 0.17)';
      ctx.lineWidth = Math.max(0.7, 1.15 * scale);
      ctx.lineCap = 'round';
      ctx.stroke();

      if (prefersReducedMotion) return;
      for (j = 0; j < DROP_COUNT; j += 1) {
        var drop = drops[j];
        if (drop.state === 1) drawAttachedDrop(drop, time);
        else if (drop.state === 2) {
          drawFallingDrop(drop);
          drawSatellite(drop.satellite);
        }
      }
    }

    function stop() {
      if (!frameId) return;
      window.cancelAnimationFrame(frameId);
      frameId = 0;
      lastTime = 0;
    }

    function tick(now) {
      frameId = 0;
      if (disposed || !inViewport || !pageVisible) return;
      if (!lastTime) lastTime = now;
      var dt = clamp((now - lastTime) / 1000, 0, 0.075);
      lastTime = now;
      elapsed += dt;
      if (!prefersReducedMotion) {
        for (var k = 0; k < DROP_COUNT; k += 1) updateDrop(drops[k], k, dt, elapsed);
      }
      draw(elapsed);
      frameId = window.requestAnimationFrame(tick);
    }

    function start() {
      if (disposed || prefersReducedMotion || !inViewport || !pageVisible || frameId) return;
      syncSize();
      lastTime = performance.now();
      draw(elapsed);
      frameId = window.requestAnimationFrame(tick);
    }

    function drawStatic() {
      syncSize();
      draw(0);
    }

    function visibilityChanged() {
      pageVisible = document.visibilityState !== 'hidden';
      if (!pageVisible) stop();
      else start();
    }

    function motionPreferenceChanged(event) {
      prefersReducedMotion = !!event.matches;
      if (prefersReducedMotion) {
        stop();
        drawStatic();
      } else {
        start();
      }
    }

    syncSize();
    drawStatic();

    var observer = typeof IntersectionObserver === 'function'
      ? new IntersectionObserver(function (entries) {
        inViewport = !!(entries[0] && entries[0].isIntersecting);
        if (inViewport) start();
        else stop();
      }, { rootMargin: '120px 0px', threshold: 0 })
      : {
        observe: function () {
          inViewport = true;
          start();
        },
        disconnect: function () {}
      };
    observer.observe(wrap);

    var resizeObserver = typeof ResizeObserver === 'function'
      ? new ResizeObserver(function () {
        syncSize();
        if (!frameId) draw(elapsed);
      })
      : null;
    var resizeListener = null;
    if (resizeObserver) {
      resizeObserver.observe(wrap);
    } else {
      resizeListener = function () {
        syncSize();
        if (!frameId) draw(elapsed);
      };
      window.addEventListener('resize', resizeListener, { passive: true });
    }

    document.addEventListener('visibilitychange', visibilityChanged, { passive: true });
    if (reducedMotionQuery) {
      if (typeof reducedMotionQuery.addEventListener === 'function') {
        reducedMotionQuery.addEventListener('change', motionPreferenceChanged);
      } else if (typeof reducedMotionQuery.addListener === 'function') {
        reducedMotionQuery.addListener(motionPreferenceChanged);
      }
    }

    wrap.addEventListener('footer-liquid:destroy', function () {
      disposed = true;
      stop();
      observer.disconnect();
      if (resizeObserver) resizeObserver.disconnect();
      if (resizeListener) window.removeEventListener('resize', resizeListener);
      if (reducedMotionQuery) {
        if (typeof reducedMotionQuery.removeEventListener === 'function') {
          reducedMotionQuery.removeEventListener('change', motionPreferenceChanged);
        } else if (typeof reducedMotionQuery.removeListener === 'function') {
          reducedMotionQuery.removeListener(motionPreferenceChanged);
        }
      }
      canvas.remove();
      if (fallback) fallback.style.display = '';
    }, { once: true });
  }

  document.addEventListener('DOMContentLoaded', init, { once: true });
}());
