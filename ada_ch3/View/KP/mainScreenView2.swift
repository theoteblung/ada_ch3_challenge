//
//  mainScreenView.swift
//  ada_ch3
//
//  Created by Kevin Prananta Tjhai on 26/05/26.
//

import SwiftUI

struct mainScreenView2: View {

    // MARK: - Animation State
    @State private var pulse1Scale: CGFloat = 1.0
    @State private var pulse1Opacity: Double = 0.5
    @State private var pulse2Scale: CGFloat = 1.0
    @State private var pulse2Opacity: Double = 0.2
    @State private var innerScale: CGFloat = 1.0
    @State private var selectedTimer: Int? = nil
    @State private var isLightMode: Bool = false
    @State private var isTapped: Bool = false
    @State private var showInfoModal: Bool = false
    @State private var isPlaying: Bool = false


    // MARK: - Design Tokens
    private let background      = Color(hex: "#1A1916")
    private let innerCircle     = Color(hex: "#CAABA6")
    private let middleCircle    = Color(hex: "#CAABA6")
    private let outerCircle     = Color(hex: "#99645A")
    private let accentText      = Color(hex: "#CAABA6")
    private let appNameColor    = Color.white.opacity(0.20)

    // Circle sizes
    private let outerDiameter:  CGFloat = 200
    private let middleDiameter: CGFloat = 150
    private let innerDiameter:  CGFloat = 110

    var body: some View {
        if isPlaying {
            ActiveView(onStop: {
                isPlaying = false
            })
        } else {
            ZStack {

                // ── Background
                background
                    .ignoresSafeArea()

                // ── Main layout
                VStack(spacing: 0) {

                    // Top bar
                    topBar
                        .padding(.horizontal, 20)
                        .padding(.top, 4)

                    Spacer()

                    // Tap area + label
                    tapCluster
                        .padding(.bottom, 60)

                    Spacer(minLength: 0)

                    // App name footer
                    Text("[App name]")
                        .font(.system(size: 17, weight: .regular, design: .default))
                        .foregroundColor(appNameColor)
                        .padding(.bottom, 32)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                handleTap()
            }
            .preferredColorScheme(isLightMode ? .light : .dark)
            .onAppear { startPulse() }
            .sheet(isPresented: $showInfoModal) {
                InfoModalView()
            }
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                showInfoModal = true
            } label: {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white.opacity(0.60))
                    .padding(8)
                    .contentShape(Rectangle())
            }

            Spacer()

            Menu {
                Menu {
                    Button {
                        selectedTimer = nil
                    } label: {
                        if selectedTimer == nil {
                            Label("Off", systemImage: "checkmark")
                        } else {
                            Text("Off")
                        }
                    }

                    Divider()

                    Button {
                        selectedTimer = 5
                    } label: {
                        if selectedTimer == 5 {
                            Label("5 minutes", systemImage: "checkmark")
                        } else {
                            Text("5 minutes")
                        }
                    }

                    Button {
                        selectedTimer = 10
                    } label: {
                        if selectedTimer == 10 {
                            Label("10 minutes", systemImage: "checkmark")
                        } else {
                            Text("10 minutes")
                        }
                    }

                    Button {
                        selectedTimer = 15
                    } label: {
                        if selectedTimer == 15 {
                            Label("15 minutes", systemImage: "checkmark")
                        } else {
                            Text("15 minutes")
                        }
                    }

                    Button {
                        selectedTimer = 30
                    } label: {
                        if selectedTimer == 30 {
                            Label("30 minutes", systemImage: "checkmark")
                        } else {
                            Text("30 minutes")
                        }
                    }

                    Button {
                        selectedTimer = 45
                    } label: {
                        if selectedTimer == 45 {
                            Label("45 minutes", systemImage: "checkmark")
                        } else {
                            Text("45 minutes")
                        }
                    }

                    Button {
                        selectedTimer = 60
                    } label: {
                        if selectedTimer == 60 {
                            Label("60 minutes", systemImage: "checkmark")
                        } else {
                            Text("60 minutes")
                        }
                    }

                } label: {
                    Label("Timer", systemImage: "timer")
                }

                Toggle(isOn: $isLightMode) {
                    Label("Light Mode", systemImage: "sun.max")
                }

            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white.opacity(0.60))
                    .padding(8)
                    .contentShape(Rectangle())
            }
        }
    }

    // MARK: - Tap Cluster
    private var tapCluster: some View {
        HStack(alignment: .center, spacing: 24) {

            // Pulsing circles + hand icon
            ZStack {
                // Outer pulse ring
                Circle()
                    .fill(outerCircle.opacity(0.50))
                    .frame(width: outerDiameter, height: outerDiameter)
                    .scaleEffect(pulse2Scale)
                    .opacity(pulse2Opacity)

                // Middle pulse ring
                Circle()
                    .fill(middleCircle.opacity(0.50))
                    .frame(width: middleDiameter, height: middleDiameter)
                    .scaleEffect(pulse1Scale)
                    .opacity(pulse1Opacity)
                    .shadow(color: Color.white.opacity(0.08), radius: 8, x: 0, y: 2)
                    .shadow(color: innerCircle.opacity(0.35), radius: 24, x: 0, y: 10)

                // Inner static circle
                Circle()
                    .fill(innerCircle.opacity(0.70))
                    .frame(width: innerDiameter, height: innerDiameter)
                    .scaleEffect(innerScale)
                    .shadow(color: Color.white.opacity(0.08), radius: 8, x: 0, y: 2)
                    .shadow(color: innerCircle.opacity(0.35), radius: 24, x: 0, y: 10)
                
                // Hand icon
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 100, weight: .regular))
                    .foregroundColor(.white)
                    .offset(x: 40, y: 40)
            }
            .frame(width: outerDiameter, height: outerDiameter)

            // "Tap to start" label
            VStack(alignment: .leading, spacing: 2) {
                Text("Tap to")
                    .font(.system(size: 20, weight: .regular, design: .default))
                    .foregroundColor(accentText)
                Text("start")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(accentText)
            }
        }
        .padding(.leading, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .offset(y: 150)
    }
        

    // MARK: - Pulse Animation
    private func startPulse() {
        let pulseAnimation = Animation
            .easeInOut(duration: 1.6)
                .repeatForever(autoreverses: true)

            withAnimation(pulseAnimation) {

                // Inner
                innerScale = 1.05

                // Middle
                pulse1Scale = 1.12
                pulse1Opacity = 0.30

                // Outer
                pulse2Scale = 1.20
                pulse2Opacity = 0.1

            }
    }

    // MARK: - Tap Handler
    private func handleTap() {
        isPlaying = true
    }
}

// MARK: - Color Hex Extension
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let r, g, b: UInt64
//        switch hex.count {
//        case 6:
//            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
//        default:
//            (r, g, b) = (1, 1, 0)
//        }
//        self.init(
//            .sRGB,
//            red:   Double(r) / 255,
//            green: Double(g) / 255,
//            blue:  Double(b) / 255,
//            opacity: 1
//        )
//    }
//}

// MARK: - Preview
#Preview {
    mainScreenView2()
}
