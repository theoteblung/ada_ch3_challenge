//
//  BreathingExercise.swift
//  ada_ch3
//
//  Breathing rhythm definitions. Each exercise reuses the box-breathing theme:
//  a ball travels the perimeter of a shape while a centered label cues the breath.
//  Add a new rhythm = add a preset below; the engine + diagram adapt automatically.
//

import Foundation

enum BreathPhaseType {
    case inhale
    case hold
    case exhale

    /// Bridge to AudioManager.playBreathDynamic(): 0 -> breathe_in, 2 -> breathe_out, else hold.
    var breathIndex: Int {
        switch self {
        case .inhale: return 0
        case .exhale: return 2
        case .hold:   return 1
        }
    }
}

/// Geometry the breath ball travels around.
enum BreathShape {
    case square     // 4-4 box breathing
    case circle     // 4-6 expand/contract breathing
    case triangle   // 5-5-5 triangle breathing
}

struct BreathPhase: Identifiable {
    let id = UUID()
    let type: BreathPhaseType
    let duration: Double
    var label: String
}

struct BreathingExercise: Identifiable, Equatable {
    let id = UUID()
    let shortName: String    // carousel caption, e.g. "4-4"
    let shape: BreathShape
    let phases: [BreathPhase]

    static func == (lhs: BreathingExercise, rhs: BreathingExercise) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Presets

    /// 4-4 Box: inhale, hold, exhale, hold — ball circles a square.
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

    /// 5-5-5 Triangle: inhale, hold, exhale — ball traces one edge per phase.
    static let triangle = BreathingExercise(
        shortName: "5-5-5",
        shape: .triangle,
        phases: [
            BreathPhase(type: .inhale, duration: 5, label: "Breathe in"),
            BreathPhase(type: .hold,   duration: 5, label: "Hold"),
            BreathPhase(type: .exhale, duration: 5, label: "Breathe out")
        ]
    )

    /// 4-6 Circle: short inhale, long exhale — ring expands then contracts.
    static let circle = BreathingExercise(
        shortName: "4-6",
        shape: .circle,
        phases: [
            BreathPhase(type: .inhale, duration: 4, label: "Breathe in"),
            BreathPhase(type: .exhale, duration: 6, label: "Breathe out")
        ]
    )

    /// Carousel order matches the prototype: square, triangle, circle.
    static let all: [BreathingExercise] = [box, triangle, circle]
}
