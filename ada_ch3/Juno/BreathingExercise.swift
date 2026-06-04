//
//  BreathingExercise.swift
//  ada_ch3
//
//  The DATA for each breathing technique. No animation lives here — just a
//  description of what each exercise is made of.
//
//  Every exercise shares the same idea: a ball travels around the outline of a
//  shape, one breath phase per side/edge/half, while a label in the middle tells
//  you what to do ("Breathe in", "Hold", "Breathe out").
//
//  Want a new technique? Add a preset at the bottom. The engine and the diagram
//  pick it up automatically.
//

import Foundation

/// The three kinds of breath. The label shown on screen is stored on the phase
/// itself; this type only describes the *kind* so the engine knows how to react
/// (which sound to play, whether the ball should grow or shrink).
enum BreathPhaseType {
    case inhale
    case hold
    case exhale

    /// Bridge to `AudioManager.playBreathDynamic()`:
    /// 0 -> breathe_in sound, 2 -> breathe_out sound, 1 -> hold sound.
    var breathIndex: Int {
        switch self {
        case .inhale: return 0
        case .hold:   return 1
        case .exhale: return 2
        }
    }
}

/// The outline the ball travels around.
enum BreathShape {
    case square     // 4-4 box breathing
    case circle     // 4-6 expand / contract breathing
    case triangle   // 5-5-5 triangle breathing
}

/// A single step of a breathing exercise: how long it lasts and what to show.
struct BreathPhase: Identifiable {
    let id = UUID()
    let type: BreathPhaseType
    let duration: Double      // seconds
    var label: String         // e.g. "Breathe in"
}

/// One complete breathing technique.
struct BreathingExercise: Identifiable, Equatable {
    let id = UUID()
    let shortName: String     // caption under the selector icon, e.g. "4-4"
    let shape: BreathShape
    let phases: [BreathPhase]

    /// How many pieces the shape's outline is split into.
    /// One phase = one piece (square -> 4 sides, triangle -> 3 edges, circle -> 2 halves).
    var segmentCount: Int { phases.count }

    static func == (lhs: BreathingExercise, rhs: BreathingExercise) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Presets

    /// 4-4 Box: breathe in, hold, breathe out, hold — ball circles a square.
    static let box = BreathingExercise(
        shortName: "4-4",
        shape: .square,
        phases: [
            BreathPhase(type: .inhale, duration: 4, label: "Breathe in"),
            BreathPhase(type: .hold,   duration: 4, label: "Hold"),
            BreathPhase(type: .exhale, duration: 4, label: "Breathe out"),
            BreathPhase(type: .hold,   duration: 4, label: "Hold")
        ]
    )

    /// 5-5-5 Triangle: breathe in, hold, breathe out — ball rides one edge per phase.
    static let triangle = BreathingExercise(
        shortName: "5-5-5",
        shape: .triangle,
        phases: [
            BreathPhase(type: .inhale, duration: 5, label: "Breathe in"),
            BreathPhase(type: .hold,   duration: 5, label: "Hold"),
            BreathPhase(type: .exhale, duration: 5, label: "Breathe out")
        ]
    )

    /// 4-6 Circle: short breathe in, long breathe out — ball loops the circle.
    static let circle = BreathingExercise(
        shortName: "4-6",
        shape: .circle,
        phases: [
            BreathPhase(type: .inhale, duration: 4, label: "Breathe in"),
            BreathPhase(type: .exhale, duration: 6, label: "Breathe out")
        ]
    )

    /// Order shown in the selector: square, triangle, circle.
    static let all: [BreathingExercise] = [box, triangle, circle]
}
