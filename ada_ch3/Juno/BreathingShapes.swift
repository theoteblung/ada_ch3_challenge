//
//  BreathingShapes.swift
//  ada_ch3
//
//  Shape outlines + ball-path geometry for the breathing diagrams.
//  Same theme as the original box breathing: a ball rides the perimeter of the
//  shape, one breath phase per segment.
//

import SwiftUI

// MARK: - Triangle outline (apex up)
struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))     // apex
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))  // bottom-right
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))  // bottom-left
        p.closeSubpath()
        return p
    }
}

// MARK: - Shape outline view for the active diagram
@ViewBuilder
func breathOutline(for shape: BreathShape, size: CGFloat, color: Color) -> some View {
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

// MARK: - Ball position along the perimeter
/// Offset (relative to the diagram centre) of the travelling ball for the current
/// phase and its 0...1 progress. One phase maps to one continuous segment of the shape.
func breathBallOffset(shape: BreathShape,
                      phaseIndex: Int,
                      progress: CGFloat,
                      size: CGFloat) -> CGSize {
    let half = size / 2

    switch shape {
    case .square:
        // 4 phases, clockwise from top-left
        switch phaseIndex {
        case 0:  return CGSize(width: -half + size * progress, height: -half) // top: L→R
        case 1:  return CGSize(width: half, height: -half + size * progress)  // right: T→B
        case 2:  return CGSize(width: half - size * progress, height: half)   // bottom: R→L
        default: return CGSize(width: -half, height: half - size * progress)  // left: B→T
        }

    case .circle:
        // 2 phases, clockwise from top (12 o'clock)
        let r = half
        let baseDeg: Double = phaseIndex == 0 ? -90 : 90   // inhale: top→bottom, exhale: bottom→top
        let angle = (baseDeg + Double(progress) * 180) * .pi / 180
        return CGSize(width: r * cos(angle), height: r * sin(angle))

    case .triangle:
        // 3 phases, one straight edge each (clockwise).
        let apex        = CGPoint(x: 0, y: -half)
        let bottomRight = CGPoint(x: half, y: half)
        let bottomLeft  = CGPoint(x: -half, y: half)

        switch phaseIndex {
        case 0:  return lerp(bottomLeft, apex, progress)        // inhale: left edge up
        case 1:  return lerp(apex, bottomRight, progress)       // hold:   right edge down
        default: return lerp(bottomRight, bottomLeft, progress) // exhale: bottom edge back
        }
    }
}

private func lerp(_ a: CGPoint, _ b: CGPoint, _ t: CGFloat) -> CGSize {
    CGSize(width: a.x + (b.x - a.x) * t,
           height: a.y + (b.y - a.y) * t)
}

// MARK: - Ball path effect
/// Moves the ball along the shape's perimeter. Because `animatableData` is the
/// progress, SwiftUI recomputes the offset every frame and the ball follows the
/// real curve (arc / edges) instead of a straight line between start and end.
struct BallPathEffect: GeometryEffect {
    var progress: CGFloat
    let shape: BreathShape
    let phaseIndex: Int
    let size: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func effectValue(size _: CGSize) -> ProjectionTransform {
        let offset = breathBallOffset(
            shape: shape,
            phaseIndex: phaseIndex,
            progress: progress,
            size: size
        )
        return ProjectionTransform(
            CGAffineTransform(translationX: offset.width, y: offset.height)
        )
    }
}
