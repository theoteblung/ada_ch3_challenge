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

//    var cue: BreathingCue {
//        switch self {
//        case .breatheIn:  return .breatheIn
//        case .holdTop:    return .breathe        // placeholder hold cue
//        case .breatheOut: return .letItOut
//        case .holdBottom: return .breathe        // placeholder hold cue
//        }
//    }
}

struct ActiveView: View {
    var onStop: () -> Void

    @EnvironmentObject var settings: AppSettings
    
    @State private var ballScale: CGFloat = 1.0

    private let initialBufferDuration: Double = 2.0
    private let fadeOutDuration: Double = 0.4
    private let textGapDuration: Double = 0.5

    // MARK: - Breathing State
    @State private var phase: BoxPhase = .breatheIn
    @State private var labelOpacity: Double = 0
    @State private var ballProgress: CGFloat = 0  // 0...1 within a single edge
    @State private var phaseTimer: Timer?
    @State private var ballAnimationTimer: Timer?

    // MARK: - Session Timer (from settings)
    @State private var sessionRemaining: Int? = nil   // seconds remaining
    @State private var sessionTimer: Timer?
    @State private var pendingStop: Bool = false      // stop after current cycle ends

    // MARK: - Constants
    private let phaseDuration: Double = 4.0
    private let boxSize: CGFloat = 250
    private let borderColor = Color(hex: "#636261")
    private let background  = Color(hex: "#1A1916")
    
    // theo add audio player
    @EnvironmentObject var volumeManager: VolumeManager
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Top bar
                HStack {
                    Spacer()
                    Button {
                        handleStop()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(.white.opacity(0.70))
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)

                Spacer()

                // ── Box breathing
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
                .strokeBorder(borderColor, lineWidth: 2)
                .frame(width: boxSize, height: boxSize)

            // Center label
            Text(phase.label)
                .font(.system(size: 40, weight: .bold))
                .gradientText()
                .opacity(labelOpacity)
                .animation(.easeInOut(duration: 0.6), value: labelOpacity)

            // Moving ball (clockwise around the perimeter)
            Circle()
                .fill(Color.white)
                .frame(width: 14, height: 14)
                .scaleEffect(ballScale)
                .offset(ballOffset)
        }
        .frame(width: boxSize, height: boxSize)
    }

    // MARK: - Ball Position
    private var ballOffset: CGSize {
        let half = boxSize / 2
        switch phase {
        case .breatheIn:
            return CGSize(width: -half + boxSize * ballProgress, height: -half)
        case .holdTop:
            return CGSize(width: half, height: -half + boxSize * ballProgress)
        case .breatheOut:
            return CGSize(width: half - boxSize * ballProgress, height: half)
        case .holdBottom:
            return CGSize(width: -half, height: half - boxSize * ballProgress)
        }
    }

    // MARK: - Session Engine
    private func startSession() {
        if let mins = settings.selectedTimer {
            sessionRemaining = mins * 60
            startSessionTimer()
        } else {
            sessionRemaining = nil
        }

        // Reset
        phase = .breatheIn
        labelOpacity = 0
        ballProgress = 0
        ballScale = 1.0

        // Wait for view transition to fully settle before animation
        DispatchQueue.main.asyncAfter(deadline: .now() + initialBufferDuration) {
            runPhase()
        }
    }
    private func startSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard var remaining = sessionRemaining else { return }
            remaining -= 1
            sessionRemaining = remaining
            if remaining <= 0 {
                // Timer expired: stop after current full cycle ends
                pendingStop = true
                sessionTimer?.invalidate()
                sessionTimer = nil
            }
        }
    }

    private func runPhase() {
        audioManager.playBreathDynamic()
        audioManager.breathIndex += 1
        if (audioManager.breathIndex > 3) {
            audioManager.breathIndex = 0
        }
        // Fade label in
        withAnimation(.easeInOut(duration: 0.6)) {
            labelOpacity = 1.0
        }

        // Ball position — linear travel along edge
        ballProgress = 0
        withAnimation(.linear(duration: phaseDuration)) {
            ballProgress = 1.0
        }

        // Ball scale — eased to reflect breath state
        withAnimation(.easeInOut(duration: phaseDuration)) {
            ballScale = ballTargetScale(for: phase)
        }

        // Schedule fade-out so it completes textGapDuration before next phase begins
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
        case .breatheIn:  return 1.8   // grow while inhaling
        case .holdTop:    return 1.8   // stay large
        case .breatheOut: return 1.0   // shrink while exhaling
        case .holdBottom: return 1.0   // stay small
        }
    }

    private func advancePhase() {
        let next = (phase.rawValue + 1) % BoxPhase.allCases.count
        let nextPhase = BoxPhase(rawValue: next) ?? .breatheIn

        // Check if we just completed a full cycle (back to breatheIn)
        let cycleCompleted = (nextPhase == .breatheIn)

        if cycleCompleted && pendingStop {
            // Timer expired during last cycle — exit now
            exitToMain()
            return
        }

        phase = nextPhase
        runPhase()
    }

    // MARK: - Stop
    private func handleStop() {
        exitToMain()
    }

    private func exitToMain() {
        stopAllTimers()
//        AudioManager.shared.stopAll()
        onStop()
    }

    private func stopAllTimers() {
        phaseTimer?.invalidate()
        phaseTimer = nil
        sessionTimer?.invalidate()
        sessionTimer = nil
        ballAnimationTimer?.invalidate()
        ballAnimationTimer = nil
    }
}

#Preview {
    ActiveView(onStop: {})
        .environmentObject(AppSettings())
        .environmentObject(VolumeManager()).environmentObject(AudioManager())
}
