//
//  BreathingShapes.swift
//  ada_ch3
//
//  All the GEOMETRY for the breathing diagrams:
//   1. The shape outlines (square / circle / triangle).
//   2. One function that says "where is the ball right now?" for any shape.
//   3. The effect that makes the ball follow that path smoothly.
//   4. The comet trail that chases the ball around any shape.
//
//  The ball and the trail BOTH ask the same function for positions, so they can
//  never disagree about where the outline is.
//

import SwiftUI

// MARK: - Triangle outline (apex pointing up)
struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))     // apex (top)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))  // bottom-right
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))  // bottom-left
        p.closeSubpath()
        return p
    }
}

// MARK: - The outline shown behind the ball
@ViewBuilder
func breathingOutline(for shape: BreathShape, size: CGFloat, color: Color) -> some View {
    switch shape {
    case .square:
        Rectangle()
            .strokeBorder(color, lineWidth: 2)
            .frame(width: size, height: size)
    case .circle:
        Circle()
            .strokeBorder(color, lineWidth: 2)
            .frame(width: size, height: size)
    case .triangle:
        TriangleShape()
            .stroke(color, lineWidth: 2)
            .frame(width: size, height: size)
    }
}

// MARK: - "Where is the ball?"
/// Returns the ball's position measured **from the centre of the diagram**, so
/// (0, 0) is the middle.
///
/// `lapProgress` is measured in *laps*:
///   0.0  = the start point
///   1.0  = exactly one full loop around the shape
///   1.25 = a quarter of the way into the second loop
///
/// We never reset `lapProgress`, so it just keeps growing as the session runs;
/// `truncatingRemainder` below folds it back into a single 0...1 loop.
func ballPositionOnPerimeter(shape: BreathShape, lapProgress: CGFloat, diagramSize: CGFloat) -> CGPoint {
    let half = diagramSize / 2

    // Fold lapProgress back into one loop (0 up to but not including 1).
    let raw = lapProgress.truncatingRemainder(dividingBy: 1.0)
    let loop = raw < 0 ? raw + 1 : raw

    switch shape {
    case .square:
        // Four sides, clockwise, starting at the top-left corner.
        let sideIndex = Int(floor(loop * 4)) % 4
        let alongSide = loop * 4 - floor(loop * 4)   // 0...1 along the current side
        switch sideIndex {
        case 0:  return CGPoint(x: -half + diagramSize * alongSide, y: -half) // top:    left → right
        case 1:  return CGPoint(x: half,  y: -half + diagramSize * alongSide) // right:  top → bottom
        case 2:  return CGPoint(x: half - diagramSize * alongSide, y: half)   // bottom: right → left
        default: return CGPoint(x: -half, y: half - diagramSize * alongSide)  // left:   bottom → top
        }

    case .triangle:
        // Three edges, clockwise, starting at the bottom-left corner.
        let apex        = CGPoint(x: 0,     y: -half)
        let bottomRight = CGPoint(x: half,  y: half)
        let bottomLeft  = CGPoint(x: -half, y: half)
        let edgeIndex = Int(floor(loop * 3)) % 3
        let alongEdge = loop * 3 - floor(loop * 3)   // 0...1 along the current edge
        switch edgeIndex {
        case 0:  return lerpPoint(bottomLeft, apex,        alongEdge) // breathe in:  up the left edge
        case 1:  return lerpPoint(apex,       bottomRight, alongEdge) // hold:        down the right edge
        default: return lerpPoint(bottomRight, bottomLeft, alongEdge) // breathe out: back along the bottom
        }

    case .circle:
        // One smooth loop. Start at the top (12 o'clock) and go clockwise.
        let radius = half
        let angle = (-90 + Double(loop) * 360) * .pi / 180
        return CGPoint(x: radius * CGFloat(cos(angle)), y: radius * sin(angle))
    }
}

/// Straight-line blend between two points (used for the triangle's edges).
private func lerpPoint(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGPoint {
    CGPoint(x: a.x + (b.x - a.x) * t,
            y: a.y + (b.y - a.y) * t)
}

// MARK: - Make the ball follow the outline
/// Moves the ball along the shape's real outline.
///
/// We can't just animate `.offset` from the start of a phase to the end, because
/// for the CIRCLE that would slide the ball straight across the middle instead of
/// around the rim. A `GeometryEffect` fixes that: SwiftUI re-asks for the position
/// every single frame, so the ball hugs curves and corners exactly.
struct BallFollowsPerimeter: GeometryEffect {
    var lapProgress: CGFloat
    let shape: BreathShape
    let diagramSize: CGFloat

    // Telling SwiftUI "animate by changing lapProgress" is what makes it recompute
    // the position frame-by-frame.
    var animatableData: CGFloat {
        get { lapProgress }
        set { lapProgress = newValue }
    }

    func effectValue(size _: CGSize) -> ProjectionTransform {
        let point = ballPositionOnPerimeter(shape: shape, lapProgress: lapProgress, diagramSize: diagramSize)
        return ProjectionTransform(CGAffineTransform(translationX: point.x, y: point.y))
    }
}

// MARK: - Comet trail
/// The fading "comet tail" that follows the ball around ANY shape.
///
/// It's drawn as a stack of thin-to-thick slices: the slice nearest the ball is
/// widest, the slices behind it get thinner, so together they look like a comet
/// that fades out toward its tail.
struct CometTrailView: View {
    let shape: BreathShape
    let ballLapProgress: CGFloat
    let diagramSize: CGFloat
    /// How long the tail is, measured in laps.
    /// (e.g. for a square one side = 0.25 of a lap, so 0.1875 = 3/4 of one side.)
    let trailLength: CGFloat

    // Look & feel
    private let sliceCount = 24            // more slices = smoother taper
    private let headWidth: CGFloat = 7     // thickness right behind the ball
    private let taperExponent: Double = 2.8

    var body: some View {
        ForEach(0..<sliceCount, id: \.self) { slice in
            // Slices near the head (high index) are wide; slices near the tail are thin.
            let widthRatio = pow(Double(slice + 1) / Double(sliceCount), taperExponent)
            CometTrailSlice(
                ballLapProgress: ballLapProgress,
                shape: shape,
                sliceIndex: slice,
                sliceCount: sliceCount,
                trailLength: trailLength,
                diagramSize: diagramSize
            )
            .stroke(
                Color("BallColor"),
                style: StrokeStyle(lineWidth: headWidth * CGFloat(widthRatio), lineCap: .round)
            )
            .frame(width: diagramSize, height: diagramSize)
        }
    }
}

/// One slice of the comet tail. Each slice covers a short stretch of the outline
/// just behind the ball; stacking all the slices makes the full tapering tail.
struct CometTrailSlice: Shape {
    var ballLapProgress: CGFloat
    let shape: BreathShape
    let sliceIndex: Int
    let sliceCount: Int
    let trailLength: CGFloat
    let diagramSize: CGFloat

    // Animating this is what lets the whole trail glide along with the ball.
    var animatableData: CGFloat {
        get { ballLapProgress }
        set { ballLapProgress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        // At the very start of a session the tail grows from nothing,
        // then settles at its full length.
        let tail = min(ballLapProgress, trailLength)
        guard tail > 0 else { return Path() }

        let sliceLength = tail / CGFloat(sliceCount)
        let startProgress = ballLapProgress - tail + CGFloat(sliceIndex)     * sliceLength
        let endProgress   = ballLapProgress - tail + CGFloat(sliceIndex + 1) * sliceLength
        guard endProgress > startProgress else { return Path() }

        return perimeterPath(
            shape: shape,
            fromLapProgress: startProgress,
            toLapProgress: endProgress,
            diagramSize: diagramSize,
            in: rect
        )
    }
}

/// Traces the outline between two travel points. It walks the path in lots of
/// tiny steps so curves come out smooth and corners come out crisp — the same
/// code works for the square, the triangle, and the circle.
private func perimeterPath(shape: BreathShape,
                           fromLapProgress: CGFloat,
                           toLapProgress: CGFloat,
                           diagramSize: CGFloat,
                           in rect: CGRect) -> Path {
    var path = Path()
    let span = toLapProgress - fromLapProgress
    guard span > 0 else { return path }

    // ballPositionOnPerimeter gives points around (0,0); the Path needs them in
    // the view's own coordinates, where the centre is rect.midX / rect.midY.
    let center = CGPoint(x: rect.midX, y: rect.midY)

    let stepSize: CGFloat = 0.0025                       // smaller = smoother
    let sampleCount = max(2, Int(ceil(span / stepSize)) + 1)

    for i in 0..<sampleCount {
        let progress = fromLapProgress + span * CGFloat(i) / CGFloat(sampleCount - 1)
        let local = ballPositionOnPerimeter(shape: shape, lapProgress: progress, diagramSize: diagramSize)
        let point = CGPoint(x: center.x + local.x, y: center.y + local.y)
        if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
    }
    return path
}
