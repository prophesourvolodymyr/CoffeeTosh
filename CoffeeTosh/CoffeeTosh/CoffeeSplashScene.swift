import SwiftUI
import SpriteKit
import CoreImage

class CoffeeSplashScene: SKScene {

    // Metaball chain: blur circles first, then snap the alpha → liquid blobs
    // This is safe as long as SpriteView is only inserted when isActive = true
    // (i.e. the user is actually on page 4, with a real Metal context backing it).
    private let thresholdNode = SKEffectNode()
    private let blurNode      = SKEffectNode()
    private let fluidContainer = SKNode()

    // Coffee palette — all dark espresso shades so the merged blob reads as liquid coffee
    private let colors: [NSColor] = [
        NSColor(red: 60/255,  green: 35/255,  blue: 15/255,  alpha: 1),  // darkest espresso
        NSColor(red: 76/255,  green: 44/255,  blue: 18/255,  alpha: 1),  // button colour
        NSColor(red: 95/255,  green: 58/255,  blue: 24/255,  alpha: 1),  // medium roast
    ]

    // Auto-drip state
    private var lastDripTime: TimeInterval = 0
    private let dripInterval: TimeInterval = 0.28       // spawn every ~0.28s
    private let maxAmbientDrops: Int = 70               // cap for performance
    private var isDripping: Bool = true                  // ambient drip active
    private var isFlooding: Bool = false                 // flood triggered

    /// Callback fired ~1.8s after flood, signalling the SwiftUI layer to transition.
    var onFloodComplete: (() -> Void)?

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        // Cream background — must be opaque, transparency triggers CoreImage crash
        backgroundColor = NSColor(red: 240/255, green: 230/255, blue: 216/255, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        setupMetaball()
        isDripping = true
    }

    private func setupMetaball() {
        // Guard re-entry: SpriteView re-inserts the scene each time isActive flips.
        // Calling addChild on a node that already has a parent crashes SpriteKit.
        guard thresholdNode.parent == nil else { return }

        // Step 1 — Gaussian blur
        let blur = CIFilter(name: "CIGaussianBlur")!
        blur.setValue(12.0, forKey: kCIInputRadiusKey)
        blurNode.filter = blur
        // Start DISABLED — Metal framebuffer allocation is deferred until
        // didChangeSize confirms we have valid non-zero dimensions.
        // Enabling at zero size causes the UINT_MAX Metal crash.
        blurNode.shouldEnableEffects = false

        // Step 2 — Alpha threshold / metaball snap
        let threshold = CIFilter(name: "CIColorMatrix")!
        threshold.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputRVector")
        threshold.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        threshold.setValue(CIVector(x: 0, y: 0, z: 1, w: 0), forKey: "inputBVector")
        threshold.setValue(CIVector(x: 0, y: 0, z: 0, w: 60),  forKey: "inputAVector")
        threshold.setValue(CIVector(x: 0, y: 0, z: 0, w: -28), forKey: "inputBiasVector")
        thresholdNode.filter = threshold
        thresholdNode.shouldEnableEffects = false  // disabled until real size confirmed

        // Tree: scene → threshold → blur → drops
        blurNode.addChild(fluidContainer)
        thresholdNode.addChild(blurNode)
        addChild(thresholdNode)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard size.width > 1, size.height > 1 else {
            // Invalid size — kill effects so SKCEffectNode does NOT touch Metal
            blurNode.shouldEnableEffects      = false
            thresholdNode.shouldEnableEffects = false
            size = (oldSize.width > 1 && oldSize.height > 1)
                ? oldSize
                : CGSize(width: 700, height: 500)
            return
        }
        super.didChangeSize(oldSize)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        // Now safe — Metal framebuffer allocation has valid dimensions
        blurNode.shouldEnableEffects      = true
        thresholdNode.shouldEnableEffects = true
    }

    // MARK: - Frame Loop (Auto-drip)

    override func update(_ currentTime: TimeInterval) {
        guard isDripping, !isFlooding else { return }
        guard size.width > 1, size.height > 1 else { return }

        // Throttle: only spawn on interval
        if lastDripTime == 0 { lastDripTime = currentTime }
        guard currentTime - lastDripTime >= dripInterval else { return }
        lastDripTime = currentTime

        // Cap live drops — remove oldest if over limit
        while fluidContainer.children.count >= maxAmbientDrops {
            fluidContainer.children.first?.removeFromParent()
        }

        // Spawn 1-2 droplets per tick from random X along the top
        let count = Int.random(in: 1...2)
        for _ in 0..<count {
            spawnDrip()
        }
    }

    private func spawnDrip() {
        let radius = CGFloat.random(in: 8...14)
        let drop   = SKShapeNode(circleOfRadius: radius)
        drop.fillColor   = colors.randomElement()!
        drop.strokeColor = .clear

        // Spawn just above the top edge at a random X
        let margin: CGFloat = 30
        drop.position = CGPoint(
            x: CGFloat.random(in: margin...(size.width - margin)),
            y: size.height + radius + 5   // just above visible area
        )

        drop.physicsBody = SKPhysicsBody(circleOfRadius: radius * 0.95)
        drop.physicsBody?.restitution    = 0.12
        drop.physicsBody?.friction       = 0.15
        drop.physicsBody?.density        = 1.3
        drop.physicsBody?.allowsRotation = false

        // Small random horizontal drift so drops don't stack perfectly
        drop.physicsBody?.applyImpulse(CGVector(
            dx: CGFloat.random(in: -8...8),
            dy: CGFloat.random(in: -2...0)
        ))

        fluidContainer.addChild(drop)
    }

    // MARK: - Flood (on button tap)

    func triggerFlood() {
        guard !isFlooding else { return }
        isFlooding = true
        isDripping = false

        // Massive burst — spawn drops across the full width in waves
        let totalDrops = 180
        for i in 0..<totalDrops {
            let radius = CGFloat.random(in: 14...24)
            let drop   = SKShapeNode(circleOfRadius: radius)
            drop.fillColor   = colors[i % colors.count]
            drop.strokeColor = .clear

            // Spread across entire width, spawn from top half
            drop.position = CGPoint(
                x: CGFloat.random(in: 10...(size.width - 10)),
                y: size.height + CGFloat.random(in: 10...200)
            )

            drop.physicsBody = SKPhysicsBody(circleOfRadius: radius * 0.95)
            drop.physicsBody?.restitution    = 0.10
            drop.physicsBody?.friction       = 0.12
            drop.physicsBody?.density        = 1.4
            drop.physicsBody?.allowsRotation = false

            // Downward impulse + slight spread
            drop.physicsBody?.applyImpulse(CGVector(
                dx: CGFloat.random(in: -30...30),
                dy: CGFloat.random(in: -120...(-40))
            ))

            fluidContainer.addChild(drop)
        }

        // Notify SwiftUI after the flood has settled
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
            self?.onFloodComplete?()
        }
    }

    // MARK: - Legacy splash (kept for reference, unused)

    func triggerSplash(at point: CGPoint) {
        triggerFlood()
    }

    // MARK: - Drag to interact

    #if os(macOS)
    private var draggedNode: SKNode?

    override func mouseDown(with event: NSEvent) {
        let loc = event.location(in: self)
        if let body = physicsWorld.body(at: loc), body.node !== self {
            draggedNode = body.node
            draggedNode?.physicsBody?.isDynamic = false
        }
    }

    override func mouseDragged(with event: NSEvent) {
        draggedNode?.position = event.location(in: fluidContainer)
    }

    override func mouseUp(with event: NSEvent) {
        draggedNode?.physicsBody?.isDynamic = true
        draggedNode?.physicsBody?.applyImpulse(
            CGVector(dx: event.deltaX * 8, dy: -event.deltaY * 8)
        )
        draggedNode = nil
    }
    #endif
}

