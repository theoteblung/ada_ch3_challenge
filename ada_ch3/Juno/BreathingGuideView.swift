//
//  BreathingGuideView.swift
//  ada_ch3
//
//  The Breathing Guide screen.
//
//  It shows ONE diagram that works the same way for every technique:
//    • the outline of a shape (square / triangle / circle),
//    • a ball that travels around that outline,
//    • the ball grows while you breathe in and shrinks while you breathe out,
//    • a comet trail chasing the ball,
//    • a label in the middle ("Breathe in", "Hold", "Breathe out").
//
//  At the bottom is a selector to switch technique. Switching mid-animation is
//  safe: every scheduled step carries a `sessionID`, so leftover timers from the
//  old exercise quietly do nothing instead of fighting the new one.
//
//  Techniques:
//    • Square   (4-4):   in / hold / out / hold, one side per phase.
//    • Triangle (5-5-5): in / hold / out, one edge per phase.
//    • Circle   (4-6):   in (top → bottom) / out (bottom → top), one half per phase.
//

import SwiftUI

struct BreathingGuideView: View {
    var onStop: () -> Void

    @EnvironmentObject var audioManager: AudioManager

    // MARK: - What's selected
    @State private var selectedExercise: BreathingExercise = .box

    // MARK: - Animation state
    @State private var currentPhaseIndex: Int = 0
    @State private var labelOpacity: Double = 0
    @State private var ballLapProgress: CGFloat = 0   // how far around the shape (in laps); never resets mid-session
    @State private var ballScale: CGFloat = 1.0       // grows on inhale, shrinks on exhale
    @State private var ringScale: CGFloat = 0.55      // circle's breathing ring; resting (exhaled) = small

    // MARK: - Session control
    // Bumped every time we (re)start; lets us cancel stale scheduled steps.
    @State private var sessionID: Int = 0
    // Turned on once the screen has settled, so the ball/trail SNAP into place
    // instead of flying in from the centre with the screen's entrance animation.
    @State private var isReady: Bool = false

    // MARK: - Layout & timing constants
    private let diagramSize: CGFloat = 250
    private let ballSize: CGFloat = 14
    private let minBallScale: CGFloat = 1.0
    private let maxBallScale: CGFloat = 1.8
    private let minRingScale: CGFloat = 1      // circle ring at rest / fully exhaled
    private let maxRingScale: CGFloat = 1.25       // circle ring fully inhaled (fills the diagram)
    private let startDelay: Double = 1.0          // let the screen transition settle first
    private let labelFadeOutDuration: Double = 0.4
    private let labelGapDuration: Double = 0.5    // quiet beat between phases

    private var currentPhase: BreathPhase {
        let i = min(max(currentPhaseIndex, 0), selectedExercise.phases.count - 1)
        return selectedExercise.phases[i]
    }

    /// One phase = one piece of the outline.
    private var segmentCount: Int { selectedExercise.segmentCount }

    var body: some View {
        ZStack {
            Color("ColorBG").ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Top bar (close button)
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

                exerciseSelector
                    .padding(.bottom, 120)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            audioManager.breathIndex = 0
            startSession()
            // Drop the ball/trail onto the shape WITHOUT inheriting the screen's
            // entrance animation (no fly-in from the centre).
            DispatchQueue.main.async {
                var tx = Transaction()
                tx.disablesAnimations = true
                withTransaction(tx) { isReady = true }
            }
        }
        .onDisappear {
            isReady = false
            cancelSession()
            audioManager.stopBreathDynamic()
        }
    }

    // MARK: - Diagram (same layout for every shape)
    @ViewBuilder
    private var diagram: some View {
        ZStack {
            // Outline + trail + ball ride together inside this group. For the circle
            // we scale the whole group, so the ring "breathes" (bigger on inhale,
            // back to resting on exhale) and the ball + comet stay glued to the rim.
            ZStack {
                // The outline the ball rides on.
                breathingOutline(for: selectedExercise.shape, size: diagramSize, color: Color("BoxBorder"))

                // Comet trail (only after the screen has settled).
                if isReady {
                    CometTrailView(
                        shape: selectedExercise.shape,
                        ballLapProgress: ballLapProgress,
                        diagramSize: diagramSize,
                        // Tail length = 3/4 of one phase's worth of travel.
                        trailLength: 0.75 / CGFloat(segmentCount)
                    )
                }

                // The travelling ball that grows on inhale and shrinks on exhale.
                if isReady {
                    Circle()
                        .fill(Color("BallColor"))
                        .frame(width: ballSize, height: ballSize)
                        .scaleEffect(ballScale)
                        .modifier(BallFollowsPerimeter(
                            lapProgress: ballLapProgress,
                            shape: selectedExercise.shape,
                            diagramSize: diagramSize
                        ))
                }
            }
            .scaleEffect(selectedExercise.shape == .circle ? ringScale : 1.0)

            // Breath instruction in the centre. Kept outside the scaled group so the
            // text stays a constant size while the ring breathes.
            Text(currentPhase.label)
                .font(.system(size: 32, weight: .bold))
                .opacity(labelOpacity)
                .offset(
                    x: selectedExercise.shape == .triangle ? 0 : 0,
                    y: selectedExercise.shape == .triangle ? 80 : 0
                )
        }
        .frame(width: diagramSize, height: diagramSize)
    }

    // MARK: - Selector
    private var exerciseSelector: some View {
        VStack(spacing: 16) {
            Text("Choose a breathing exercise")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 36) {
                ForEach(BreathingExercise.all) { exercise in
                    Button {
                        selectExercise(exercise)
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: iconName(for: exercise.shape))
                                .font(.system(size: 26, weight: .regular))
                            Text(exercise.shortName)
                                .font(.caption2)
                        }
                        .foregroundColor(exercise == selectedExercise ? Color("BallColor") : Color("IconBG"))
                        .frame(width: 56)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func iconName(for shape: BreathShape) -> String {
        switch shape {
        case .square:   return "square"
        case .triangle: return "triangle"
        case .circle:   return "circle"
        }
    }

    // MARK: - Session engine

    /// Starts a fresh run of the selected exercise from the beginning.
    private func startSession() {
        sessionID += 1
        let id = sessionID

        currentPhaseIndex = 0
        labelOpacity = 0
        ballLapProgress = 0
        ballScale = minBallScale
        ringScale = minRingScale

        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            runPhase(id)
        }
    }

    /// Animates one phase, then schedules the next one.
    private func runPhase(_ id: Int) {
        guard id == sessionID else { return }   // a newer session started; bail out
        let phase = currentPhase

        // Play the sound for this phase.
        audioManager.breathIndex = phase.type.breathIndex
        audioManager.playBreathDynamic()

        // Fade the label in.
        withAnimation(.easeInOut(duration: 0.6)) {
            labelOpacity = 1.0
        }

        // Move the ball forward by exactly one piece of the outline, at a steady
        // pace. Linear timing keeps the trail evenly spaced behind the ball.
        let nextLapProgress = ballLapProgress + 1.0 / CGFloat(segmentCount)
        withAnimation(.linear(duration: phase.duration)) {
            ballLapProgress = nextLapProgress
        }

        // Grow / shrink the ball to match the breath.
        withAnimation(.easeInOut(duration: phase.duration)) {
            ballScale = targetBallScale(for: phase.type, current: ballScale)
        }

        // Make the circle's ring breathe — bigger on inhale, back to resting on exhale.
        // (Other shapes keep a fixed-size outline.)
        if selectedExercise.shape == .circle {
            withAnimation(.easeInOut(duration: phase.duration)) {
                ringScale = (phase.type == .inhale) ? maxRingScale : minRingScale
            }
        }

        // Fade the label out a little before the phase ends, then advance.
        let fadeOutStart = max(0.1, phase.duration - labelFadeOutDuration - labelGapDuration)
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutStart) {
            guard id == sessionID else { return }
            withAnimation(.easeInOut(duration: labelFadeOutDuration)) {
                labelOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + labelFadeOutDuration + labelGapDuration) {
                guard id == sessionID else { return }
                currentPhaseIndex = (currentPhaseIndex + 1) % selectedExercise.phases.count
                runPhase(id)
            }
        }
    }

    /// How big the ball should be during a phase.
    /// "Hold" keeps whatever size we already are, so a hold after inhaling stays
    /// big and a hold after exhaling stays small.
    private func targetBallScale(for type: BreathPhaseType, current: CGFloat) -> CGFloat {
        switch type {
        case .inhale: return maxBallScale   // grow while breathing in
        case .exhale: return minBallScale   // shrink while breathing out
        case .hold:   return current        // hold the current size
        }
    }

    // MARK: - Switching exercise
    private func selectExercise(_ exercise: BreathingExercise) {
        guard exercise != selectedExercise else { return }
        cancelSession()                       // stop the old exercise's pending steps
        audioManager.stopBreathDynamic()
        selectedExercise = exercise
        startSession()
    }

    // MARK: - Stop
    private func handleStop() {
        cancelSession()
        audioManager.stopBreathDynamic()
        onStop()
    }

    /// Bumping the session id makes every in-flight scheduled step quietly no-op.
    private func cancelSession() {
        sessionID += 1
    }
}

#Preview {
    BreathingGuideView(onStop: {})
        .environmentObject(AudioManager())
}
