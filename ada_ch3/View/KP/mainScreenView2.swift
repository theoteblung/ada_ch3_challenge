//
//  mainScreenView.swift
//  ada_ch3
//
//  Created by Kevin Prananta Tjhai on 26/05/26.
//

import SwiftUI

// MARK: - Gradient Text ViewModifier
struct GradientTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.60),
                        Color.white
                    ]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            )
            .mask(content)
    }
}

extension View {
    func gradientText() -> some View {
        self.modifier(GradientTextModifier())
    }
}

// MARK: - Tab Page
enum TabPage {
    case home, history
}

struct mainScreenView2: View {

    // MARK: - Animation State
    @State private var pulse1Scale: CGFloat = 1.0
    @State private var pulse1Opacity: Double = 0.5
    @State private var pulse2Scale: CGFloat = 1.0
    @State private var pulse2Opacity: Double = 0.2
    @State private var innerScale: CGFloat = 1.0

    // MARK: - App State
    @State private var selectedTimer: Int? = nil
    @State private var isLightMode: Bool = false
    @State private var showInfoModal: Bool = false
    @State private var isPlaying: Bool = false
    @State private var currentTab: TabPage = .home
    @State private var dragOffset: CGFloat = 0

    // MARK: - Design Tokens
    private let background    = Color(hex: "#1A1916")
    private let innerCircle   = Color(hex: "#CAABA6")
    private let middleCircle  = Color(hex: "#CAABA6")
    private let outerCircle   = Color(hex: "#99645A")
    private let appNameColor  = Color.white.opacity(0.20)

    private let outerDiameter:  CGFloat = 200
    private let middleDiameter: CGFloat = 150
    private let innerDiameter:  CGFloat = 110

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            if isPlaying {
                ActiveView(onStop: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        isPlaying = false
                    }
                })
                .transition(.opacity)

            } else {
                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, 20)
                        .padding(.top, 4)

                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            homeContent
                                .frame(width: geo.size.width)
//                            HistoryView()
//                                .frame(width: geo.size.width)
                        }
                        .offset(x: currentTab == .home
                            ? dragOffset
                            : -geo.size.width + dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let translation = value.translation.width
                                    if (currentTab == .home && translation > 0) ||
                                       (currentTab == .history && translation < 0) {
                                        dragOffset = translation * 0.15
                                    } else {
                                        dragOffset = translation
                                    }
                                }
                                .onEnded { value in
                                    let threshold: CGFloat = geo.size.width * 0.3
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        if value.translation.width < -threshold && currentTab == .home {
                                            currentTab = .history
                                        } else if value.translation.width > threshold && currentTab == .history {
                                            currentTab = .home
                                        }
                                        dragOffset = 0
                                    }
                                }
                        )
                    }

                    customTabBar
                        .padding(.bottom, 20)

                    Text("[App name]")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(appNameColor)
                        .padding(.top, 6)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.8), value: isPlaying)
        .preferredColorScheme(isLightMode ? .light : .dark)
        .onAppear { startPulse() }
        .sheet(isPresented: $showInfoModal) { InfoModalView() }
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
                    Button { selectedTimer = nil } label: {
                        if selectedTimer == nil { Label("Off", systemImage: "checkmark") }
                        else { Text("Off") }
                    }
                    Divider()
                    ForEach([5, 10, 15, 30, 45, 60], id: \.self) { mins in
                        Button { selectedTimer = mins } label: {
                            if selectedTimer == mins { Label("\(mins) minutes", systemImage: "checkmark") }
                            else { Text("\(mins) minutes") }
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

    // MARK: - Home Content
    private var homeContent: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                tapCluster
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard currentTab == .home else { return }
            handleTap()
        }
    }

    // MARK: - Tap Cluster
    private var tapCluster: some View {
        HStack(alignment: .center, spacing: 24) {
            ZStack {
                Circle()
                    .fill(outerCircle.opacity(0.50))
                    .frame(width: outerDiameter, height: outerDiameter)
                    .scaleEffect(pulse2Scale)
                    .opacity(pulse2Opacity)

                Circle()
                    .fill(middleCircle.opacity(0.50))
                    .frame(width: middleDiameter, height: middleDiameter)
                    .scaleEffect(pulse1Scale)
                    .opacity(pulse1Opacity)
                    .shadow(color: Color.white.opacity(0.08), radius: 8, x: 0, y: 2)
                    .shadow(color: innerCircle.opacity(0.35), radius: 24, x: 0, y: 10)

                Circle()
                    .fill(innerCircle.opacity(0.70))
                    .frame(width: innerDiameter, height: innerDiameter)
                    .scaleEffect(innerScale)
                    .shadow(color: Color.white.opacity(0.08), radius: 8, x: 0, y: 2)
                    .shadow(color: innerCircle.opacity(0.35), radius: 24, x: 0, y: 10)


                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 120, weight: .regular))
                    .foregroundColor(.white)
                    .offset(x: 40, y: 50)

                // Put text last so it draws above everything in this ZStack
                Text("Tap to start")
                    .font(.system(size: 32, weight: .bold))
                    .gradientText()
                    .lineLimit(1)
                    .fixedSize()
                    .offset(x: outerDiameter / 2 + 60)
            }
            .frame(width: outerDiameter, height: outerDiameter)

            // Remove the separate Text from the HStack
            // (since it's now layered inside the ZStack)
            Spacer(minLength: 0)
        }
        .padding(.leading, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 10) {
            if currentTab == .home {
                Image(systemName: "house.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                Circle()
                    .fill(Color.white.opacity(0.40))
                    .frame(width: 6, height: 6)
                
            } else {
                Circle()
                    .fill(Color.white.opacity(0.40))
                    .frame(width: 6, height: 6)
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentTab)
    }

    // MARK: - Pulse Animation
    private func startPulse() {
        let pulseAnimation = Animation
            .easeInOut(duration: 1.6)
            .repeatForever(autoreverses: true)

        withAnimation(pulseAnimation) {
            innerScale    = 1.05
            pulse1Scale   = 1.12
            pulse1Opacity = 0.30
            pulse2Scale   = 1.20
            pulse2Opacity = 0.1
        }
    }

    // MARK: - Tap Handler
    private func handleTap() {
        withAnimation(.easeInOut(duration: 0.8)) {
            isPlaying = true
        }
    }
}

// MARK: - Color Hex Extension
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

// MARK: - Preview
#Preview {
    mainScreenView2()
}
