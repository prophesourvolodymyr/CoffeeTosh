import MetalKit
import SwiftUI

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - GPU-matching structs
// ═══════════════════════════════════════════════════════════════════════════════

/// Must match `Particle` in CoffeeLiquid.metal (32 bytes)
private struct GPUParticle {
    var position: SIMD2<Float>
    var velocity: SIMD2<Float>
    var radius: Float
    var speed: Float
    var _pad: SIMD2<Float> = .zero
}

/// Must match `Uniforms` in CoffeeLiquid.metal (64 bytes)
private struct GPUUniforms {
    var resolution: SIMD2<Float>       // offset 0
    var time: Float                    // offset 8
    var particleCount: Int32           // offset 12
    var influenceScale: Float          // offset 16
    var threshold: Float               // offset 20
    var _p1: SIMD2<Float> = .zero      // offset 24
    var liquidColor: SIMD4<Float>      // offset 32
    var bgColor: SIMD4<Float>          // offset 48
}

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - CPU-side particle
// ═══════════════════════════════════════════════════════════════════════════════

private struct Droplet {
    var position: SIMD2<Float>
    var velocity: SIMD2<Float>
    var renderPos: SIMD2<Float>    // smoothed position sent to GPU
    var radius: Float
}

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - LiquidController
// ═══════════════════════════════════════════════════════════════════════════════

class LiquidController {
    fileprivate var renderer: MetalLiquidRenderer?
    var onFloodComplete: (() -> Void)?

    func triggerFlood() {
        renderer?.triggerFlood()
        // Give enough time for 6 waves to fill + settle before transitioning
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) { [weak self] in
            self?.onFloodComplete?()
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - MetalLiquidRenderer
// ═══════════════════════════════════════════════════════════════════════════════

class MetalLiquidRenderer: NSObject, MTKViewDelegate {

    // Metal
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    private var particleBuffer: MTLBuffer?
    private let maxParticleCount = 300

    // View
    private var viewSize: SIMD2<Float> = .zero
    var contentScale: Float = 2.0

    // Particles
    private var drops: [Droplet] = []

    // Timing
    private var startTime: Double = CACurrentMediaTime()
    private var lastFrame: Double = 0

    // Drip state
    var isDripping: Bool = true
    private(set) var isFlooding: Bool = false
    private var lastDripTime: Double = 0
    private let dripInterval: Double = 0.22
    private var didInitialPour: Bool = false
    private let maxAmbientDrops: Int = 300  // hard safety cap

    // Flood state
    private var floodStartTime: Double = 0
    private var floodWavesDone: Int = 0

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │  FLUIDITY CONTROLS — tune these to change how water-like it feels  │
    // └─────────────────────────────────────────────────────────────────────┘

    // PHYSICS
    private let gravity: Float       = 1800
    private let restitution: Float   = 0.0
    private let floorFriction: Float = 0.08  // very low = liquid spreads wide on floor
    private let overlapAllow: Float  = 0.38  // deep overlap = particles melt into each other
    private let pushStrength: Float  = 0.03  // soft push-apart
    private let velExchange: Float   = 0.6   // high damping between particles
    private let lateralPressure: Float = 120.0  // sideways push when particles stack (simulates liquid pressure)
    private let impactSplashRadius: Float = 3.0  // how far an impact wakes up neighbors
    private let impactSplashForce: Float  = 0.4  // sideways kick from impact

    // SMOOTHING
    private let globalDamping: Float = 0.94   // strong per-frame slowdown (settled particles nearly stop but never freeze)
    private let settledDamping: Float = 0.88  // extra damping for floor-touching particles
    private let renderSmooth: Float  = 8.0    // slower lerp = silkier surface movement

    // VISUALS (shader)
    private let influenceScale: Float = 7.0  // very wide field = drops merge into one smooth body
    private let threshold: Float      = 0.10 // low cutoff = maximum merge

    // Mouse interaction
    private let mouseRadius: Float      = 80.0   // influence radius around cursor (pts)
    private let mouseForce: Float       = 3000.0 // push strength
    var mousePosition: SIMD2<Float>?             // in drawable pixels; nil = cursor outside
    private var prevMousePosition: SIMD2<Float>? // for velocity-based push

    // Colors — liquid matches button: rgb(60,40,20)
    private let coffee = SIMD4<Float>(60.0/255, 40.0/255, 20.0/255, 1)
    private let cream  = SIMD4<Float>(240.0/255, 230.0/255, 216.0/255, 1)

    // ── Init ────────────────────────────────────────────────────────────────

    init?(mtkView: MTKView) {
        guard let device   = mtkView.device,
              let queue    = device.makeCommandQueue(),
              let library  = device.makeDefaultLibrary(),
              let vert     = library.makeFunction(name: "liquidVertex"),
              let frag     = library.makeFunction(name: "liquidFragment")
        else { return nil }

        self.device = device
        self.commandQueue = queue

        let desc = MTLRenderPipelineDescriptor()
        desc.vertexFunction   = vert
        desc.fragmentFunction = frag
        desc.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat

        guard let pipeline = try? device.makeRenderPipelineState(descriptor: desc)
        else { return nil }
        self.pipelineState = pipeline

        self.particleBuffer = device.makeBuffer(
            length: MemoryLayout<GPUParticle>.stride * maxParticleCount,
            options: .storageModeShared
        )

        super.init()
    }

    func resume() {
        lastFrame    = 0
        lastDripTime = CACurrentMediaTime()
    }

    // ── Spawning ────────────────────────────────────────────────────────────

    private func spawnDrop() {
        guard drops.count < maxParticleCount, viewSize.x > 1 else { return }
        let s = contentScale
        let r = Float.random(in: 8...14) * s
        let margin: Float = 40 * s
        let pos = SIMD2<Float>(
            Float.random(in: margin...(viewSize.x - margin)),
            -r - Float.random(in: 0...20) * s
        )
        drops.append(Droplet(
            position: pos,
            velocity: SIMD2<Float>(
                Float.random(in: -6...6) * s,
                Float.random(in: 60...150) * s
            ),
            renderPos: pos,
            radius: r
        ))
    }

    private func spawnInitialPour() {
        guard viewSize.x > 1 else { return }
        didInitialPour = true
        let s  = contentScale
        let cx = viewSize.x / 2

        for i in 0..<6 {
            let r = Float.random(in: 10...18) * s
            let pos = SIMD2<Float>(
                cx + Float.random(in: -70...70) * s,
                -r - Float(i) * 14 * s
            )
            drops.append(Droplet(
                position: pos,
                velocity: SIMD2<Float>(
                    Float.random(in: -10...10) * s,
                    Float.random(in: 120...260) * s
                ),
                renderPos: pos,
                radius: r
            ))
        }
    }

    func triggerFlood() {
        guard !isFlooding else { return }
        isFlooding = true
        isDripping = false
        floodStartTime = CACurrentMediaTime()
        floodWavesDone = 0
        spawnFloodWave()
    }

    private func spawnFloodWave() {
        guard viewSize.x > 1 else { return }
        let s = contentScale
        // Fewer but well-spaced particles — influenceScale does the merging
        for _ in 0..<30 {
            let r = Float.random(in: 20...34) * s
            let pos = SIMD2<Float>(
                Float.random(in: 0...viewSize.x),
                Float.random(in: -600...(-10)) * s
            )
            drops.append(Droplet(
                position: pos,
                velocity: SIMD2<Float>(
                    Float.random(in: -10...10) * s,
                    Float.random(in: 600...1100) * s
                ),
                renderPos: pos,
                radius: r
            ))
        }
        floodWavesDone += 1
    }

    // ── Physics ─────────────────────────────────────────────────────────────

    private func stepPhysics(_ dt: Float) {
        let g     = gravity * contentScale
        let floor = viewSize.y
        let wallL: Float = 0
        let wallR = viewSize.x

        // ── Integration + boundaries ────────────────────────────────────
        for i in drops.indices {
            drops[i].velocity.y += g * dt
            drops[i].velocity  *= globalDamping
            drops[i].position  += drops[i].velocity * dt

            // Floor — extra damping when touching
            let onFloor = drops[i].position.y + drops[i].radius > floor
            if onFloor {
                drops[i].position.y = floor - drops[i].radius
                if drops[i].velocity.y > 0 {
                    drops[i].velocity.y = -drops[i].velocity.y * restitution
                }
                drops[i].velocity.x *= floorFriction
                drops[i].velocity   *= settledDamping  // heavy floor damping
            }

            // Walls
            if drops[i].position.x - drops[i].radius < wallL {
                drops[i].position.x = wallL + drops[i].radius
                drops[i].velocity.x = abs(drops[i].velocity.x) * 0.1
            }
            if drops[i].position.x + drops[i].radius > wallR {
                drops[i].position.x = wallR - drops[i].radius
                drops[i].velocity.x = -abs(drops[i].velocity.x) * 0.1
            }
        }

        // ── Particle-particle interactions ───────────────────────────────
        let n = drops.count
        for i in 0..<n {
            for j in (i + 1)..<n {
                let delta = drops[i].position - drops[j].position
                let dist  = length(delta)
                let minD  = (drops[i].radius + drops[j].radius) * overlapAllow
                guard dist < minD, dist > 0.01 else { continue }

                let overlap = minD - dist
                let dir     = delta / dist

                // Soft push-apart
                drops[i].position += dir * overlap * pushStrength
                drops[j].position -= dir * overlap * pushStrength

                // Velocity exchange
                let relVel = dot(drops[i].velocity - drops[j].velocity, dir)
                if relVel < 0 {
                    let impulse = dir * relVel * velExchange
                    drops[i].velocity -= impulse
                    drops[j].velocity += impulse
                }

                // ── Impact splash: fast drop hits slow one → kick sideways ──
                let spdI = length(drops[i].velocity)
                let spdJ = length(drops[j].velocity)
                let slow = spdI > spdJ ? j : i
                let fastSpd = max(spdI, spdJ)
                let slowSpd = min(spdI, spdJ)
                if fastSpd > 100 * contentScale && slowSpd < 30 * contentScale {
                    // Kick the slow one sideways
                    let sideways = SIMD2<Float>(-dir.y, dir.x)
                    let kick = sideways * impactSplashForce * fastSpd * dt
                    let sign: Float = Float.random(in: 0...1) > 0.5 ? 1.0 : -1.0
                    drops[slow].velocity += kick * sign
                }

                // ── Lateral pressure: stacked particles push sideways ────
                // If both are near the floor and one is above the other,
                // the lower one gets pushed sideways (liquid spreads)
                let iOnFloor = drops[i].position.y + drops[i].radius >= floor - 2
                let jOnFloor = drops[j].position.y + drops[j].radius >= floor - 2
                if iOnFloor || jOnFloor {
                    let heightDiff = drops[j].position.y - drops[i].position.y
                    if abs(heightDiff) > 0.5 {
                        // Push the LOWER particle sideways (it's under pressure)
                        let lower = heightDiff < 0 ? j : i
                        let sideways = SIMD2<Float>(dir.x > 0 ? 1.0 : -1.0, 0)
                        drops[lower].velocity.x += sideways.x * lateralPressure * dt
                    }
                }
            }
        }

        // ── Mouse repulsion ─────────────────────────────────────────────
        if let mpos = mousePosition {
            let radius = mouseRadius * contentScale
            let r2 = radius * radius
            // Compute cursor velocity for directional push
            let cursorVel: SIMD2<Float>
            if let prev = prevMousePosition {
                cursorVel = (mpos - prev) / max(dt, 1e-4)
            } else {
                cursorVel = .zero
            }
            prevMousePosition = mpos

            for i in drops.indices {
                let delta = drops[i].position - mpos
                let dist2 = dot(delta, delta)
                guard dist2 < r2, dist2 > 0.01 else { continue }
                let dist = sqrt(dist2)
                let dir  = delta / dist
                let t    = 1.0 - dist / radius   // 1 at center, 0 at edge
                // Radial push (always away from cursor)
                drops[i].velocity += dir * mouseForce * t * t * dt * contentScale
                // Add a fraction of cursor velocity for directional swipe feel
                let cursorSpd = length(cursorVel)
                if cursorSpd > 10 {
                    drops[i].velocity += cursorVel * 0.3 * t * dt
                }
            }
        } else {
            prevMousePosition = nil
        }

        // ── Smoothly lerp render positions ───────────────────────────────
        let lerpFactor = min(renderSmooth * dt, 1.0)
        for i in drops.indices {
            drops[i].renderPos += (drops[i].position - drops[i].renderPos) * lerpFactor
        }

        drops.removeAll {
            $0.position.y < -500 ||
            $0.position.x < -300 ||
            $0.position.x > viewSize.x + 300
        }
    }

    // ── Fill check ──────────────────────────────────────────────────────────

    /// Finds the highest (lowest Y value) settled particle.
    /// Only stops dripping when liquid has stacked up to 15% from the top.
    private func isCanvasFull() -> Bool {
        guard viewSize.x > 1, viewSize.y > 1 else { return false }
        let floor = viewSize.y
        let thresh: Float = 20 * contentScale
        var highestY: Float = floor  // start at floor (bottom)
        for drop in drops {
            if drop.position.y + drop.radius >= floor - 4 &&
               length(drop.velocity) < thresh {
                let top = drop.position.y - drop.radius
                if top < highestY { highestY = top }
            }
        }
        // Stop when the liquid pile reaches within 15% of the top
        return highestY < viewSize.y * 0.15
    }

    private func checkFillLevel() {
        guard isDripping, !isFlooding else { return }
        if isCanvasFull() || drops.count >= maxAmbientDrops {
            isDripping = false
        }
    }

    // ── MTKViewDelegate ─────────────────────────────────────────────────────

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewSize = SIMD2<Float>(Float(size.width), Float(size.height))
    }

    func draw(in view: MTKView) {
        let now = CACurrentMediaTime()
        let dt  = lastFrame == 0 ? Float(1.0 / 60.0) : Float(now - lastFrame)
        lastFrame = now
        let cdt = min(dt, 1.0 / 30.0)

        if !didInitialPour && viewSize.x > 1 && viewSize.y > 1 {
            spawnInitialPour()
        }

        if isDripping && !isFlooding {
            if now - lastDripTime >= dripInterval {
                lastDripTime = now
                spawnDrop()
            }
        }

        if isFlooding {
            // 5 waves at 0.3s intervals — fills entire screen
            if floodWavesDone < 5 &&
               now - floodStartTime > Double(floodWavesDone) * 0.3 {
                spawnFloodWave()
            }
        }

        stepPhysics(cdt)
        checkFillLevel()

        guard let drawable = view.currentDrawable,
              let rpd      = view.currentRenderPassDescriptor,
              let cb       = commandQueue.makeCommandBuffer(),
              let enc      = cb.makeRenderCommandEncoder(descriptor: rpd)
        else { return }

        var uniforms = GPUUniforms(
            resolution:     viewSize,
            time:           Float(now - startTime),
            particleCount:  Int32(min(drops.count, maxParticleCount)),
            influenceScale: influenceScale,
            threshold:      threshold,
            liquidColor:    coffee,
            bgColor:        cream
        )

        enc.setRenderPipelineState(pipelineState)
        enc.setFragmentBytes(&uniforms,
                             length: MemoryLayout<GPUUniforms>.stride,
                             index: 0)

        let drawCount = min(drops.count, maxParticleCount)
        if drawCount > 0, let buf = particleBuffer {
            let ptr = buf.contents().assumingMemoryBound(to: GPUParticle.self)
            for i in 0..<drawCount {
                let vel = drops[i].velocity
                let spd = sqrt(vel.x * vel.x + vel.y * vel.y)
                ptr[i] = GPUParticle(position: drops[i].renderPos,  // ← smoothed position
                                     velocity: vel,
                                     radius: drops[i].radius,
                                     speed: spd)
            }
            enc.setFragmentBuffer(buf, offset: 0, index: 1)
        } else {
            var dummy = GPUParticle(position: .zero, velocity: .zero,
                                    radius: 0, speed: 0)
            enc.setFragmentBytes(&dummy,
                                 length: MemoryLayout<GPUParticle>.stride,
                                 index: 1)
        }

        enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        enc.endEncoding()
        cb.present(drawable)
        cb.commit()
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - Gesture-transparent MTKView
// ═══════════════════════════════════════════════════════════════════════════════

class PassthroughMTKView: MTKView {
    weak var renderer: MetalLiquidRenderer?

    // Accept mouse tracking but forward clicks to the button underneath
    override var acceptsFirstResponder: Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? {
        // Return self so tracking areas fire, but we forward clicks manually
        return self
    }

    // Forward clicks through so the button underneath still works
    override func mouseDown(with event: NSEvent) {
        super.nextResponder?.mouseDown(with: event)
    }
    override func mouseUp(with event: NSEvent) {
        super.nextResponder?.mouseUp(with: event)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas { removeTrackingArea(area) }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeInActiveApp, .inVisibleRect],
            owner: self, userInfo: nil
        )
        addTrackingArea(area)
    }

    override func mouseMoved(with event: NSEvent) {
        updateMousePos(event)
    }

    override func mouseDragged(with event: NSEvent) {
        updateMousePos(event)
    }

    override func mouseExited(with event: NSEvent) {
        renderer?.mousePosition = nil
    }

    private func updateMousePos(_ event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)
        let scale = (window?.backingScaleFactor ?? 2.0)
        // Convert to drawable-pixel coords (Metal uses top-left origin)
        let px = SIMD2<Float>(
            Float(loc.x * scale),
            Float((bounds.height - loc.y) * scale)
        )
        renderer?.mousePosition = px
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - MetalLiquidView (SwiftUI wrapper)
// ═══════════════════════════════════════════════════════════════════════════════

struct MetalLiquidView: NSViewRepresentable {
    let controller: LiquidController
    let isActive: Bool

    func makeNSView(context: Context) -> PassthroughMTKView {
        let view = PassthroughMTKView()
        guard let device = MTLCreateSystemDefaultDevice() else { return view }

        view.device = device
        view.colorPixelFormat = .bgra8Unorm
        view.clearColor = MTLClearColor(red: 240.0/255, green: 230.0/255,
                                        blue: 216.0/255, alpha: 1)
        view.preferredFramesPerSecond = 60
        view.enableSetNeedsDisplay = false
        view.isPaused = !isActive

        let scale = Float(NSScreen.main?.backingScaleFactor ?? 2.0)

        if let renderer = MetalLiquidRenderer(mtkView: view) {
            renderer.contentScale = scale
            view.delegate = renderer
            view.renderer = renderer
            controller.renderer = renderer
        }

        return view
    }

    func updateNSView(_ nsView: PassthroughMTKView, context: Context) {
        let shouldPause = !isActive
        if nsView.isPaused != shouldPause {
            nsView.isPaused = shouldPause
            if !shouldPause {
                controller.renderer?.resume()
            }
        }
    }
}
