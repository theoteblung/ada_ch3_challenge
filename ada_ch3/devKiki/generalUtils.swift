//
//  generalUtils.swift
//  ada_ch3
//
//  Created by kiki on 01/06/26.
//

import SwiftUI
import Combine

enum NoiseSelection: String, CaseIterable, Identifiable {
    case white = "White Noise"
    case pink  = "Pink Noise"
    case brown = "Brown Noise"
    var id: String { rawValue }
    var color: Color {
        switch self {
            case .white: return Color.white.opacity(0.85)
            case .pink:  return Color(hex: "#CAABA6")
            case .brown: return Color(hex: "#99645A")
        }
    }
}

class OnboardingManager: ObservableObject {
    @Published var isCompleted = false
}

class VolumeManager: ObservableObject {
    @Published var mediaVol: Float = 50.0
    @Published var mediaPreMute: Float = 50.0
    @Published var mediaMute: Bool = false
    
    @Published var voiceVol: Float = 50.0
    @Published var voicePreMute: Float = 50.0
    @Published var voiceMute: Bool = false
    
    @Published var noiseVol: Float = 50.0
    @Published var noisePreMute: Float = 50.0
    @Published var noiseMute: Bool = false
}

class AppSettings: ObservableObject {
    @Published var selectedTimer: Int? = nil
    @Published var isLightMode: Bool = false
    @Published var loopBreathing: Bool = true
    @Published var autoBackgroundSound: Bool = true
    @Published var selectedNoise: NoiseSelection = .white
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: 1
        )
    }
}

//extension View {
//    func gradientText() -> some View {
//        self.modifier(GradientTextModifier())
//    }
//}

//struct GradientTextModifier: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .overlay(
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color.white.opacity(0.60),
//                        Color.white
//                    ]),
//                    startPoint: .topTrailing,
//                    endPoint: .bottomLeading
//                )
//            )
//            .mask(content)
//    }
//}


