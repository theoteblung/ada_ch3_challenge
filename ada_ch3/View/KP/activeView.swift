//
//  ActiveView.swift
//  ada_ch3
//
//  Created by Kevin Prananta Tjhai on 26/05/26.
//

import SwiftUI

// MARK: - Box Breathing Phase
enum BoxPhase: Int, CaseIterable {
    case breatheIn   // top edge: left → right
    case holdTop     // right edge: top → bottom
    case breatheOut  // bottom edge: right → left
    case holdBottom  // left edge: bottom → top

    var label: String {
        switch self {
        case .breatheIn:  return "Breathe in"
        case .holdTop:    return "Hold"
        case .breatheOut: return "Breathe out"
        case .holdBottom: return "Hold"
        }
    }
}

struct ActiveView: View {
    var onStop: () -> Void

    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var volumeManager: VolumeManager
    @EnvironmentObject var audioManager: AudioManager

    // MARK: - Breathing State
    @State private var phase: BoxPhase = .breatheIn
    @State private var labelOpacity: Double = 0
    @State private var ballPosition: CGFloat = 0
    @State private var ballScale: CGFloat = 1.0
    @State private var phaseTimer: Timer?

    // MARK: - Constants
    private let initialBufferDuration: Double = 1
    private let phaseDuration: Double = 4.0
    private let fadeOutDuration: Double = 0.4
    private let textGapDuration: Double = 0.5
    private let boxSize: CGFloat = 250

    // Trail tuning
    private let trailSegments: Int = 24
    private let trailHeadWidth: CGFloat = 7
    private let trailTaperExponent: Double = 2.8
    // Trail length cap: 3/4 of one side
    private let maxTrailFraction: CGFloat = 0.75 / 4.0  // = 0.1875

    var body: some View {
        ZStack {
            Color("ColorBG").ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Spacer()
                    Button {
                        handleStop()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(Color("IconBG"))
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)

                Spacer()

                // Box breathing
                breathingBox

                Spacer()

                Color.clear.frame(height: 1)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            audioManager.breathIndex = 0
            startSession()
        }
        .onDisappear {
            stopAllTimers()
        }
    }

    // MARK: - Breathing Box
    private var breathingBox: some View {
        ZStack {
            // Outline
            Rectangle()
                .strokeBorder(Color("BoxBorder"), lineWidth: 2)
                .frame(width: boxSize, height: boxSize)

            // Comet trail
            ForEach(0..<trailSegments, id: \.self) { i in
                let widthRatio = pow(Double(i + 1) / Double(trailSegments), trailTaperExponent)
                TrailSegmentShape(
                    ballPosition: ballPosition,
                    segmentIndex: i,
                    totalSegments: trailSegments,
                    maxTrailFraction: maxTrailFraction
                )
                .stroke(
                    Color("BallColor"),
                    style: StrokeStyle(
                        lineWidth: trailHeadWidth * CGFloat(widthRatio),
                        lineCap: .round
                    )
                )
                .frame(width: boxSize, height: boxSize)
            }

            Text(phase.label)
                .font(.system(size: 40, weight: .bold))
                .opacity(labelOpacity)

            // Moving ball
            Circle()
                .fill(Color("BallColor"))
                .frame(width: 14, height: 14)
                .scaleEffect(ballScale)
                .offset(ballOffset)
        }
        .frame(width: boxSize, height: boxSize)
    }

    // MARK: - Ball Position
    // Derived from continuous ballPosition; clockwise from top-left.
    private var ballOffset: CGSize {
        let half = boxSize / 2
        let raw = ballPosition.truncatingRemainder(dividingBy: 1.0)
        let normalized = raw < 0 ? raw + 1 : raw
        let edgeIdx = Int(floor(normalized * 4)) % 4
        let edgeProg = (normalized * 4) - floor(normalized * 4)

        switch edgeIdx {
        case 0: return CGSize(width: -half + boxSize * edgeProg, height: -half)
        case 1: return CGSize(width: half, height: -half + boxSize * edgeProg)
        case 2: return CGSize(width: half - boxSize * edgeProg, height: half)
        case 3: return CGSize(width: -half, height: half - boxSize * edgeProg)
        default: return .zero
        }
    }

    // MARK: - Session Engine
    private func startSession() {
        // Reset
        phase = .breatheIn
        labelOpacity = 0
        ballPosition = 0
        ballScale = 1.0

        // Wait for view transition to fully settle before animation begins
        DispatchQueue.main.asyncAfter(deadline: .now() + initialBufferDuration) {
            runPhase()
        }
    }

    private func runPhase() {
        audioManager.playBreathDynamic()
        audioManager.breathIndex += 1
        if audioManager.breathIndex > 3 {
            audioManager.breathIndex = 0
        }

        // Fade label in
        withAnimation(.easeInOut(duration: 0.6)) {
            labelOpacity = 1.0
        }

        // Continuous ball position — advances 0.25 per phase, never resets between laps.
        let positionTarget = ballPosition + 0.25
        withAnimation(.linear(duration: phaseDuration)) {
            ballPosition = positionTarget
        }

        // Ball scale — eased to reflect breath state
        withAnimation(.easeInOut(duration: phaseDuration)) {
            ballScale = ballTargetScale(for: phase)
        }

        // Schedule fade-out so it completes textGapDuration BEFORE next phase begins
        let fadeOutStart = phaseDuration - fadeOutDuration - textGapDuration

        phaseTimer?.invalidate()
        phaseTimer = Timer.scheduledTimer(withTimeInterval: fadeOutStart, repeats: false) { _ in
            withAnimation(.easeInOut(duration: fadeOutDuration)) {
                labelOpacity = 0
            }
            // After fade-out + clean gap, advance phase (which kicks off new fade-in)
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDuration + textGapDuration) {
                advancePhase()
            }
        }
    }

    private func ballTargetScale(for phase: BoxPhase) -> CGFloat {
        switch phase {
        case .breatheIn:  return 1.8
        case .holdTop:    return 1.8
        case .breatheOut: return 1.0
        case .holdBottom: return 1.0
        }
    }

    private func advancePhase() {
        let nextIndex = (phase.rawValue + 1) % BoxPhase.allCases.count
        // No trail reset — ballPosition continues to grow across laps.
        phase = BoxPhase(rawValue: nextIndex) ?? .breatheIn
        runPhase()
    }

    // MARK: - Stop
    private func handleStop() {
        exitToMain()
    }

    private func exitToMain() {
        stopAllTimers()
        onStop()
    }

    private func stopAllTimers() {
        phaseTimer?.invalidate()
        phaseTimer = nil
    }
}

// MARK: - Trail Segment Shape
struct TrailSegmentShape: Shape {
    var ballPosition: CGFloat
    let segmentIndex: Int
    let totalSegments: Int
    let maxTrailFraction: CGFloat

    var animatableData: CGFloat {
        get { ballPosition }
        set { ballPosition = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let trailLen = min(ballPosition, maxTrailFraction)
        guard trailLen > 0 else { return Path() }

        let segLen = trailLen / CGFloat(totalSegments)
        let rawStart = ballPosition - trailLen + CGFloat(segmentIndex) * segLen
        let rawEnd   = ballPosition - trailLen + CGFloat(segmentIndex + 1) * segLen
        guard rawEnd > rawStart else { return Path() }

        var path = Path()
        path.move(to: pointOnPerimeter(t: rawStart, s: s))

        // Walk along the perimeter, adding a vertex at each corner crossed.
        var current = rawStart
        var safety = 0
        while current < rawEnd && safety < 8 {
            let baseCorner = floor(current * 4 + 1e-9)
            let nextCorner = (baseCorner + 1) / 4
            if nextCorner >= rawEnd {
                path.addLine(to: pointOnPerimeter(t: rawEnd, s: s))
                break
            }
            path.addLine(to: pointOnPerimeter(t: nextCorner, s: s))
            current = nextCorner
            safety += 1
        }

        return path
    }

    private func pointOnPerimeter(t: CGFloat, s: CGFloat) -> CGPoint {
        let r = t.truncatingRemainder(dividingBy: 1.0)
        let normalized = r < 0 ? r + 1 : r
        let edgeIdx = Int(floor(normalized * 4)) % 4
        let edgeProg = (normalized * 4) - floor(normalized * 4)

        switch edgeIdx {
        case 0: return CGPoint(x: s * edgeProg, y: 0)           // top    L → R
        case 1: return CGPoint(x: s, y: s * edgeProg)           // right  T → B
        case 2: return CGPoint(x: s - s * edgeProg, y: s)       // bottom R → L
        case 3: return CGPoint(x: 0, y: s - s * edgeProg)       // left   B → T
        default: return .zero
        }
    }
}

#Preview {
    ActiveView(onStop: {})
        .environmentObject(AppSettings())
        .environmentObject(VolumeManager())
        .environmentObject(AudioManager())
}
