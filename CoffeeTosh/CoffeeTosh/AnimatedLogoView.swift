import SwiftUI

// MARK: - Animated Coffee Cup Logo
// Pure SwiftUI implementation using TimelineView + Canvas.
// Replaces the previous WKWebView/WebKit approach which was unreliable
// in the MenuBarExtra sandboxed window context.

struct AnimatedLogoView: View {
    var size: CGFloat = 120
    var color: Color = warmAmber

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince1970
            // 5-second looping cycle normalised to 0…1
            let t = (elapsed.truncatingRemainder(dividingBy: 5.0)) / 5.0
            CoffeeCupCanvas(t: t, color: color)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - REMOVED: WKWebView wrapper (was dead in sandbox context)
// The original NSViewRepresentable+WKWebView approach is replaced above.
// Keeping this stub only long enough to satisfy any legacy call sites — see below.

// MARK: - Per-frame Canvas renderer

struct CoffeeCupCanvas: View {
    let t: Double   // 0…1 representing position in the 5 s animation cycle
    let color: Color

    // MARK: Easing

    /// Smooth-step (cubic hermite) mapping t from [a,b] → [0,1]
    private func smooth(_ a: Double, _ b: Double, _ t: Double) -> Double {
        let x = max(0, min(1, (t - a) / (b - a)))
        return x * x * (3 - 2 * x)
    }

    // MARK: Animation values

    /// 0 = empty cup, 1 = liquid at the brim
    var liquidFill: Double {
        if t < 0.15 { return 0 }
        if t < 0.45 { return smooth(0.15, 0.45, t) }
        if t < 0.75 { return 1 }
        if t < 0.90 { return 1 - smooth(0.75, 0.90, t) }
        return 0
    }

    /// Wave sway control (drives wave asymmetry)
    var waveSway: Double {
        if t < 0.36 || t > 0.56 { return 0 }
        if t < 0.42 { return smooth(0.36, 0.42, t) * -5 }
        if t < 0.47 { return -5 + smooth(0.42, 0.47, t) * 9 }   // −5 → +4
        if t < 0.52 { return  4 - smooth(0.47, 0.52, t) * 6 }   // +4 → −2
        return -2 + smooth(0.52, 0.56, t) * 2                    // −2 → 0
    }

    /// Cup squeeze bounce: returns (scaleX, scaleY)
    var cupBounce: (CGFloat, CGFloat) {
        if t < 0.43 || t > 0.62 { return (1, 1) }
        if t < 0.47 { let p = smooth(0.43,0.47,t); return (CGFloat(1+0.06*p), CGFloat(1-0.06*p)) }
        if t < 0.52 { let p = smooth(0.47,0.52,t); return (CGFloat(1.06-0.09*p), CGFloat(0.94+0.09*p)) }
        if t < 0.57 { let p = smooth(0.52,0.57,t); return (CGFloat(0.97+0.04*p), CGFloat(1.03-0.04*p)) }
        let p = smooth(0.57, 0.62, t)
        return (CGFloat(1.01 - 0.01 * p), CGFloat(0.99 + 0.01 * p))
    }

    /// Returns (offset in canvas pts, opacity) for a single droplet.
    private func droplet(start: Double, ex: CGFloat, ey: CGFloat) -> (CGPoint, Double) {
        let end = start + 0.15
        guard t >= start && t <= end else { return (.zero, 0) }
        let p = smooth(start, end, t)
        let opacity = p < 0.6 ? 1.0 : 1 - (p - 0.6) / 0.4
        return (CGPoint(x: ex * p, y: ey * p), opacity)
    }

    // MARK: Body

    var body: some View {
        Canvas { ctx, size in
            // Scale from SVG viewBox (0 0 24 24) to canvas size
            let s = size.width / 24.0

            // ── Cup center for bounce pivot ────────────────────────────────────
            let cx = CGFloat(11.0) * s
            let cy = CGFloat(13.5) * s
            let (scX, scY) = cupBounce

            // ── Path builders (all coordinates in canvas pts) ──────────────────

            func cupBodyPath() -> Path {
                var p = Path()
                p.move(to:    CGPoint(x: 2.5*s,  y: 5.5*s))
                p.addLine(to: CGPoint(x: 2.5*s,  y: 13.0*s))
                p.addCurve(to:       CGPoint(x: 11*s,   y: 22.0*s),
                           control1: CGPoint(x: 2.5*s,  y: 18.0*s),
                           control2: CGPoint(x: 6.0*s,  y: 22.0*s))
                p.addCurve(to:       CGPoint(x: 19.5*s, y: 13.0*s),
                           control1: CGPoint(x: 16.0*s, y: 22.0*s),
                           control2: CGPoint(x: 19.5*s, y: 18.0*s))
                p.addLine(to: CGPoint(x: 19.5*s, y: 5.5*s))
                p.closeSubpath()
                return p
            }

            func liquidWavePath() -> Path {
                let totalHeight = CGFloat(16.5) * s
                let liquidY     = CGFloat(22.0) * s - CGFloat(liquidFill) * totalHeight
                let amp  = 1.3 * s
                let sway = CGFloat(waveSway / 5.0)   // normalised −1…+1

                var p = Path()
                p.move(to: CGPoint(x: -5*s, y: liquidY + amp * sway))
                p.addCurve(to:       CGPoint(x: 11*s,  y: liquidY - amp * sway),
                           control1: CGPoint(x: 2*s,   y: liquidY - amp * (1 + sway)),
                           control2: CGPoint(x: 7*s,   y: liquidY + amp * (1 - sway)))
                p.addCurve(to:       CGPoint(x: 30*s,  y: liquidY + amp * sway),
                           control1: CGPoint(x: 15*s,  y: liquidY - amp * (1 - sway)),
                           control2: CGPoint(x: 24*s,  y: liquidY + amp * (1 + sway)))
                p.addLine(to: CGPoint(x: 30*s, y: 28*s))
                p.addLine(to: CGPoint(x: -5*s, y: 28*s))
                p.closeSubpath()
                return p
            }

            func cupOutlinePath() -> Path {
                var p = Path()
                p.move(to:    CGPoint(x: 2.5*s,  y: 5.5*s))
                p.addLine(to: CGPoint(x: 2.5*s,  y: 13.0*s))
                p.addCurve(to:       CGPoint(x: 11*s,   y: 22.0*s),
                           control1: CGPoint(x: 2.5*s,  y: 18.0*s),
                           control2: CGPoint(x: 6.0*s,  y: 22.0*s))
                p.addCurve(to:       CGPoint(x: 19.5*s, y: 13.0*s),
                           control1: CGPoint(x: 16.0*s, y: 22.0*s),
                           control2: CGPoint(x: 19.5*s, y: 18.0*s))
                p.addLine(to: CGPoint(x: 19.5*s, y: 5.5*s))
                // Handle
                p.move(to: CGPoint(x: 19.5*s, y: 8.5*s))
                p.addCurve(to:       CGPoint(x: 19.5*s, y: 14.5*s),
                           control1: CGPoint(x: 24.0*s, y: 8.5*s),
                           control2: CGPoint(x: 24.0*s, y: 14.5*s))
                return p
            }

            let rimPath = Path(ellipseIn: CGRect(x: (11-8.5)*s,
                                                 y: (5.5-2.8)*s,
                                                 width: 17.0*s,
                                                 height: 5.6*s))

            func facePath() -> Path {
                var p = Path()
                // Left eye
                p.move(to:    CGPoint(x: 8*s,    y: 10.5*s))
                p.addLine(to: CGPoint(x: 8*s,    y: 12.5*s))
                // Right eye
                p.move(to:    CGPoint(x: 14*s,   y: 10.5*s))
                p.addLine(to: CGPoint(x: 14*s,   y: 12.5*s))
                // Nose stroke
                p.move(to:    CGPoint(x: 11.5*s, y: 11.0*s))
                p.addLine(to: CGPoint(x: 11.5*s, y: 13.5*s))
                p.addArc(center:     CGPoint(x: 10.5*s, y: 13.5*s),
                         radius:     1.0 * s,
                         startAngle: .degrees(0),
                         endAngle:   .degrees(180),
                         clockwise:  false)
                // Smile
                p.move(to: CGPoint(x: 8*s, y: 16*s))
                p.addQuadCurve(to:      CGPoint(x: 14*s, y: 16*s),
                               control: CGPoint(x: 11*s, y: 18.5*s))
                return p
            }

            func teardrop(px: CGFloat, py: CGFloat, r: CGFloat) -> Path {
                var p = Path()
                p.move(to: CGPoint(x: px, y: py - 2.5*r))
                p.addCurve(to:       CGPoint(x: px + r, y: py + r),
                           control1: CGPoint(x: px + 1.5*r, y: py - r),
                           control2: CGPoint(x: px + r,     y: py))
                p.addArc(center:     CGPoint(x: px, y: py + r),
                         radius:     r,
                         startAngle: .degrees(0),
                         endAngle:   .degrees(180),
                         clockwise:  false)
                p.addCurve(to:       CGPoint(x: px, y: py - 2.5*r),
                           control1: CGPoint(x: px - r,     y: py),
                           control2: CGPoint(x: px - 1.5*r, y: py - r))
                p.closeSubpath()
                return p
            }

            let stroke = StrokeStyle(lineWidth: 1.3 * s, lineCap: .round, lineJoin: .round)

            // ── 1. Liquid fill (clipped to cup body, bounce transform) ─────────
            var bounceCtx = ctx
            bounceCtx.translateBy(x: cx, y: cy)
            bounceCtx.scaleBy(x: scX, y: scY)
            bounceCtx.translateBy(x: -cx, y: -cy)

            if liquidFill > 0 {
                var liquidCtx = bounceCtx
                liquidCtx.clip(to: cupBodyPath())
                liquidCtx.fill(liquidWavePath(), with: .color(color.opacity(0.88)))
            }

            // ── 2. Mac face — dark espresso so it cuts through the liquid fill ──
            let faceColor = Color(red: 55/255, green: 30/255, blue: 10/255)
            bounceCtx.stroke(facePath(), with: .color(faceColor), style: stroke)

            // ── 3. Cup outline + rim (amber — always visible against dark bg) ───
            bounceCtx.stroke(cupOutlinePath(), with: .color(color), style: stroke)
            bounceCtx.stroke(rimPath,          with: .color(color), style: stroke)

            // ── 4. Droplets (independent — fly free of cup bounce) ─────────────
            let dropDefs: [(start: Double, bx: Double, by: Double, ex: Double, ey: Double)] = [
                (0.41,  5.0, 6.0, -7.0 * s, -7.0 * s),   // upper-left
                (0.42, 17.0, 6.0,  9.0 * s, -6.0 * s),   // upper-right
                (0.44, 11.0, 4.0,  2.0 * s, -10.0 * s),  // straight up
            ]
            for d in dropDefs {
                let (offset, opacity) = droplet(start: d.start,
                                                ex: CGFloat(d.ex),
                                                ey: CGFloat(d.ey))
                guard opacity > 0 else { continue }
                let px = CGFloat(d.bx) * s + offset.x
                let py = CGFloat(d.by) * s + offset.y
                ctx.fill(teardrop(px: px, py: py, r: 1.1 * s),
                         with: .color(color.opacity(opacity)))
            }
        }
    }
}

#Preview("Logo static mid-fill") {
    CoffeeCupCanvas(t: 0.5, color: warmAmber)
        .frame(width: 180, height: 180)
        .background(Color(red: 42/255, green: 32/255, blue: 25/255))
}

#Preview("Logo animated") {
    AnimatedLogoView(size: 180)
        .frame(width: 180, height: 180)
        .background(Color(red: 42/255, green: 32/255, blue: 25/255))
}

// MARK: - Migration note
// ProMaxOnboardingView previously called AnimatedLogoView(width:height:colorHex:).
// That call site is updated in the same session to AnimatedLogoView(size:color:).
// The WKWebView / WebKit import has been fully removed.
