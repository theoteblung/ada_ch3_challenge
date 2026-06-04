//
//  BreathingGuideView.swift
//  ada_ch3
//
//  Breathing Guide screen. Shows the active breathing animation plus the
//  "Choose a breathing exercise" selector (square / triangle / circle).
//
//  - Square  (4-4):   ball circles a box, inhale-hold-exhale-hold.
//  - Triangle (5-5-5): ball rides one edge per phase, inhale-hold-exhale.
//  - Circle  (4-6):   ring expands for 4s (inhale), contracts for 6s (exhale).
//
//  Switching exercises mid-animation is seamless: every scheduled step carries
//  a `generation` token, so stale timers from the previous exercise no-op
//  instead of fighting the new one.
//

import SwiftUI

struct BreathingGuideView: View {
    var onStop: () -> Void

    @EnvironmentObject var audioManager: AudioManager

    // MARK: - Selection
    @State private var selected: BreathingExercise = .box

    // MARK: - Animation state
    @State private var phaseIndex: Int = 0
    @State private var labelOpacity: Double = 0
    @State private var ballProgress: CGFloat = 0     // 0...1 within current edge
    @State private var ballScale: CGFloat = 1.0      // box / triangle ball
    @State private var circleScale: CGFloat = 0.45   // circle expand/contract

    // MARK: - Lifecycle guard
    @State private var generation: Int = 0
    // Placed true AFTER the screen's entrance animation, with animations
    // disabled, so the ball/ring snap onto the shape instead of flying in.
    @State private var ready: Bool = false

    // MARK: - Constants
    private let diagramSize: CGFloat = 250
    private let ballSize: CGFloat = 14
    private let minCircleScale: CGFloat = 0.45
    private let maxCircleScale: CGFloat = 1.0
    private let initialBuffer: Double = 1.0
    private let fadeOutDuration: Double = 0.4
    private let textGapDuration: Double = 0.5

    private var currentPhase: BreathPhase {
        let i = min(max(phaseIndex, 0), selected.phases.count - 1)
        return selected.phases[i]
    }

    var body: some View {
        ZStack {
            Color("ColorBG").ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Top bar
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

                diagram

                Spacer()

                selector
                    .padding(.bottom, 120)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            audioManager.breathIndex = 0
            startSession()
            // Drop the ball/ring onto the shape without inheriting the
            // screen's entrance animation (no fly-in from center/offscreen).
            DispatchQueue.main.async {
                var tx = Transaction()
                tx.disablesAnimations = true
                withTransaction(tx) { ready = true }
            }
        }
        .onDisappear {
            ready = false
            invalidate()
            audioManager.stopBreathDynamic()
        }
    }

    // MARK: - Diagram
    @ViewBuilder
    private var diagram: some View {
        ZStack {
            if selected.shape == .circle {
                // Expanding / contracting ring
                Circle()
                    .strokeBorder(Color("BoxBorder"), lineWidth: 2)
                    .frame(width: diagramSize, height: diagramSize)

                if ready {
                    Circle()
                        .fill(Color("BallColor").opacity(0.25))
                        .frame(width: diagramSize, height: diagramSize)
                        .scaleEffect(circleScale)
                }

                Text(currentPhase.label)
                    .font(.system(size: 32, weight: .bold))
                    .opacity(labelOpacity)
            } else {
                // Square / triangle: ball rides the perimeter
                breathOutline(for: selected.shape, size: diagramSize, color: Color("BoxBorder"))

                Text(currentPhase.label)
                    .font(.system(size: 32, weight: .bold))
                    .opacity(labelOpacity)

                // Gated by `ready`: inserted only after the entrance animation,
                // so the ball snaps onto the start corner instead of flying in.
                if ready {
                    Circle()
                        .fill(Color("BallColor"))
                        .frame(width: ballSize, height: ballSize)
                        .scaleEffect(ballScale)
                        .modifier(BallPathEffect(
                            progress: ballProgress,
                            shape: selected.shape,
                            phaseIndex: phaseIndex,
                            size: diagramSize
                        ))
                }
            }
        }
        .frame(width: diagramSize, height: diagramSize)
    }

    // MARK: - Selector
    private var selector: some View {
        VStack(spacing: 16) {
            Text("Choose a breathing exercise")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 36) {
                ForEach(BreathingExercise.all) { exercise in
                    Button {
                        select(exercise)
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: icon(for: exercise.shape))
                                .font(.system(size: 26, weight: .regular))
                            Text(exercise.shortName)
                                .font(.caption2)
                        }
                        .foregroundColor(exercise == selected ? Color("BallColor") : Color("IconBG"))
                        .frame(width: 56)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func icon(for shape: BreathShape) -> String {
        switch shape {
        case .square:   return "square"
        case .triangle: return "triangle"
        case .circle:   return "circle"
        }
    }

    // MARK: - Session engine
    private func startSession() {
        generation += 1
        let gen = generation

        phaseIndex = 0
        labelOpacity = 0
        ballProgress = 0
        ballScale = 1.0
        circleScale = minCircleScale

        DispatchQueue.main.asyncAfter(deadline: .now() + initialBuffer) {
            runPhase(gen)
        }
    }

    private func runPhase(_ gen: Int) {
        guard gen == generation else { return }

        let phase = currentPhase

        // Audio cue for this phase
        audioManager.breathIndex = phase.type.breathIndex
        audioManager.playBreathDynamic()

        // Fade the label in
        withAnimation(.easeInOut(duration: 0.6)) {
            labelOpacity = 1.0
        }

        // Drive the shape's animation
        if selected.shape == .circle {
            withAnimation(.easeInOut(duration: phase.duration)) {
                circleScale = phase.type == .inhale ? maxCircleScale : minCircleScale
            }
        } else {
            ballProgress = 0
            withAnimation(.linear(duration: phase.duration)) {
                ballProgress = 1.0
            }
            withAnimation(.easeInOut(duration: phase.duration)) {
                ballScale = ballTargetScale(for: phase.type)
            }
        }

        // Fade label out a beat before the next phase, then advance.
        let fadeOutStart = max(0.1, phase.duration - fadeOutDuration - textGapDuration)

        DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutStart) {
            guard gen == generation else { return }
            withAnimation(.easeInOut(duration: fadeOutDuration)) {
                labelOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutDuration + textGapDuration) {
                guard gen == generation else { return }
                phaseIndex = (phaseIndex + 1) % selected.phases.count
                runPhase(gen)
            }
        }
    }

    private func ballTargetScale(for type: BreathPhaseType) -> CGFloat {
        switch type {
        case .inhale: return 1.8   // grow while inhaling
        case .hold:   return 1.8   // stay large
        case .exhale: return 1.0   // shrink while exhaling
        }
    }

    // MARK: - Switching exercise
    private func select(_ exercise: BreathingExercise) {
        guard exercise != selected else { return }
        invalidate()                       // kill pending steps from old exercise
        audioManager.stopBreathDynamic()
        selected = exercise
        startSession()
    }

    // MARK: - Stop
    private func handleStop() {
        invalidate()
        audioManager.stopBreathDynamic()
        onStop()
    }

    /// Bumping the generation makes every in-flight scheduled closure no-op.
    private func invalidate() {
        generation += 1
    }
}

#Preview {
    BreathingGuideView(onStop: {})
        .environmentObject(AudioManager())
}
