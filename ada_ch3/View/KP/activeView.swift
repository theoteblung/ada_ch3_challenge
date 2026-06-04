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
    @State private var ballProgress: CGFloat = 0  // 0...1 within a single edge
    @State private var ballScale: CGFloat = 1.0
    @State private var phaseTimer: Timer?

    // MARK: - Constants
    private let initialBufferDuration: Double = 1
    private let phaseDuration: Double = 4.0
    private let fadeOutDuration: Double = 0.4
    private let textGapDuration: Double = 0.5
    private let boxSize: CGFloat = 250

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
                .strokeBorder(Color("BoxBorder"), lineWidth: 2)
                .frame(width: boxSize, height: boxSize)

            // Center label (no implicit .animation — explicit withAnimation handles it)
            Text(phase.label)
                .font(.system(size: 40, weight: .bold))
//                .gradientText()
                .opacity(labelOpacity)

            // Moving ball (clockwise around the perimeter)
            Circle()
                .fill(Color("BallColor"))
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
        // Reset
        phase = .breatheIn
        labelOpacity = 0
        ballProgress = 0
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

        // Ball position — linear travel along edge
        ballProgress = 0
        withAnimation(.linear(duration: phaseDuration)) {
            ballProgress = 1.0
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
        case .breatheIn:  return 1.8   // grow while inhaling
        case .holdTop:    return 1.8   // stay large
        case .breatheOut: return 1.0   // shrink while exhaling
        case .holdBottom: return 1.0   // stay small
        }
    }

    private func advancePhase() {
        let next = (phase.rawValue + 1) % BoxPhase.allCases.count
        phase = BoxPhase(rawValue: next) ?? .breatheIn
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

#Preview {
    ActiveView(onStop: {})
        .environmentObject(AppSettings())
        .environmentObject(VolumeManager())
        .environmentObject(AudioManager())
}
