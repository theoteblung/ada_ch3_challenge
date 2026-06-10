//
//  mainScreenView.swift
//  ada_ch3
//
//  Created by Kevin Prananta Tjhai on 26/05/26.
//

import SwiftUI
import Combine

struct mainScreenView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @EnvironmentObject var volumeManager: VolumeManager
    @EnvironmentObject var audioManager: AudioManager
    
    // MARK: - Animation State
    @State private var pulse1Scale: CGFloat = 1.0
    @State private var pulse1Opacity: Double = 0.5
    @State private var pulse2Scale: CGFloat = 1.0
    @State private var pulse2Opacity: Double = 0.2
    @State private var innerScale: CGFloat = 1.0

    // MARK: - App State
    @StateObject private var settings = AppSettings()
    @State private var isPlaying: Bool = false
    
    @State private var activeNoise: NoiseSelection = .brown
    @State private var activeIndex: Int = 3000
    @State private var isVolSheetExpanded: Bool = false

    // MARK: - Design Tokens
    private let innerCircle   = Color(hex: "#CAABA6")
    private let middleCircle  = Color(hex: "#CAABA6")
    private let outerCircle   = Color(hex: "#99645A")

    private let outerDiameter:  CGFloat = 180
    private let middleDiameter: CGFloat = 150
    private let innerDiameter:  CGFloat = 110

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group {
                    if isPlaying {
                        BreathingGuideView(onStop: {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                isPlaying = false
                            }
                        })
                        .environmentObject(volumeManager)
                        .environmentObject(audioManager)
                        .transition(.opacity)
                        .environmentObject(settings)
                        .onTapGesture { handleTap() }
                    } else {
                        mainShell
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityHidden(isVolSheetExpanded)

                VolumeSheet(isVolSheetExpanded: $isVolSheetExpanded)
                    .ignoresSafeArea(edges: .bottom)
                    .environmentObject(volumeManager)
                    .environmentObject(audioManager)
                    .zIndex(1.0)
                    .accessibilityAction(AccessibilityActionKind.escape) {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            isVolSheetExpanded = false
                        }
                    }
            }
            .animation(.easeInOut(duration: 0.8), value: isPlaying)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .background(Color("ColorBG").ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
        .environment(\.font, .system(.body, design: .default))
        .environmentObject(settings)
    }

    // MARK: - Main Shell
    private var mainShell: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, 20)
                .padding(.top, 4)
            
            VStack {
                HStack {
                    Text(activeNoise.rawValue.components(separatedBy: " ").first ?? "")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(Color("TextPrimary").opacity(0.2))
                    Text(activeNoise.rawValue.components(separatedBy: " ").last ?? "Noise")
                        .font(.system(size: 50, weight: .regular))
                        .foregroundStyle(Color("TextPrimary").opacity(0.2))
                }
                
                Text("playing...")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundStyle(Color("TextPrimary").opacity(0.2))
            }
            .padding(.top, 40)
            .accessibilityElement(children: .ignore)
            .accessibilityValue("\(activeNoise.rawValue) Currently playing.")
            .accessibilityAdjustableAction { direction in
                let allCases = NoiseSelection.allCases
                guard let currentIdx = allCases.firstIndex(of: activeNoise) else { return }
                
                if direction == .increment {
                    let nextIdx = (currentIdx + 1) % allCases.count
                    activeNoise = allCases[nextIdx]
                    updateAudioForCurrentSelection(for: activeNoise)
                    settings.selectedNoise = activeNoise
                } else if direction == .decrement {
                    let prevIdx = (currentIdx - 1 + allCases.count) % allCases.count
                    activeNoise = allCases[prevIdx]
                    updateAudioForCurrentSelection(for: activeNoise)
                    settings.selectedNoise = activeNoise
                }
            }
            
            // noise tabview
            TabView(selection: $activeIndex) {
                ForEach(0..<3, id: \.self) { index in
                    let noise = noiseForIndex(index)
                    
                    centerContentView(for: noise)
                        .tag(index)
                        .onAppear {
                            startPulse()
                        }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .accessibilityElement(children: .contain)
            .onAppear {
                activeIndex = 1
                updateAudioForCurrentSelection(for: activeNoise)
                settings.selectedNoise = activeNoise
            }
            .onChange(of: activeIndex) { oldValue, newValue in
                let newlySelectedNoise = noiseForIndex(newValue)
                
                if newValue != 1 {
                    updateAudioForCurrentSelection(for: newlySelectedNoise)
                    settings.selectedNoise = newlySelectedNoise
                }
                
                handleInfiniteLoop(currentValue: newValue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { handleTap() }
        }
        .overlay(alignment: .bottom) {
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { dotIndex in
                    Circle()
                        .fill(NoiseSelection.allCases.firstIndex(of: activeNoise) == dotIndex ? (isDarkMode ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.2)) : Color.gray.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .animation(.smooth(duration: 0.3), value: activeNoise)
                }
            }
            .padding(.bottom, 120)
            .accessibilityElement(children: .ignore)
            .accessibilityHidden(true)
        }
    }
    
    @ViewBuilder
    private func centerContentView(for noise: NoiseSelection) -> some View {
        let isLight = !isDarkMode
        let currentShadow = noise.shadowRadius(isLightMode: isLight)
        
        ZStack {
            Color.clear
            
            ZStack {
                VStack {
                    Text("Tap to")
                        .font(.system(size: 40, weight: .regular))
                        .lineLimit(1)
                        .fixedSize()
                        .offset(x: -120)
                    
                    Text("start")
                        .font(.system(size: 40, weight: .bold))
                        .lineLimit(1)
                        .fixedSize()
                        .offset(x: -110)
                }
                .accessibilityHidden(true)
                
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: noise.color.opacity(1.0), location: 0.0),
                                    .init(color: noise.color.opacity(noise.outerEdgeOpacity(isLightMode: isLight)), location: 1.0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: outerDiameter / 2
                            )
                        )
                        .frame(width: outerDiameter, height: outerDiameter)
                        .scaleEffect(pulse2Scale)
                        .opacity(pulse2Opacity)
                        .offset(x:-15)
                        .shadow(radius: currentShadow, x: currentShadow > 0 ? 4 : 0, y: currentShadow > 0 ? 3 : 0)

                    // Inner glow
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: noise.color.opacity(1.0), location: 0.0),
                                    .init(color: noise.color.opacity(noise.innerEdgeOpacity(isLightMode: isLight)), location: 1.0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: innerDiameter / 2
                            )
                        )
                        .frame(width: innerDiameter, height: innerDiameter)
                        .scaleEffect(innerScale)
                        .offset(x: -15)

                    // Hand icon
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 100, weight: .regular))
                        .foregroundColor(.white)
                        .offset(x: 15, y: 40)
                        .shadow(radius: 8, x: 4, y: 3)
                }
                .frame(width: outerDiameter, height: outerDiameter)
                .offset(x: 50)
            }
            .offset(x: 40)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Start Breathing Guide")
        .accessibilityHint("Double tap to begin the session.")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            NavigationLink {
                InfoPageView()
                    .environmentObject(settings)
            } label: {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 26, weight: .regular))
                    .foregroundColor(Color("IconBG"))
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Information")
//            .accessibilityHint("Opens noise info and breathing details.")

            Spacer()
            
            //darkmode button
            Button {
                isDarkMode.toggle()
            } label: {
                Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                    .font(.system(size: 26, weight: .regular))
                    .foregroundColor(Color("IconBG"))
                    .padding(8)
            }
            .accessibilityLabel("Appearance Mode")
//            .accessibilityValue(isDarkMode ? "Dark Mode Active" : "Light Mode Active")
            
            //setting button
//            NavigationLink {
//                SettingsView()
//                    .environmentObject(settings)
//            } label: {
//                Image(systemName: "gearshape.fill")
//                    .font(.system(size: 26, weight: .regular))
//                    .foregroundColor(Color("IconBG"))
//                    .padding(8)
//                    .contentShape(Rectangle())
//            }
        }
    }
    
    private func noiseForIndex(_ index: Int) -> NoiseSelection {
        let allCases = NoiseSelection.allCases
        guard let currentIdx = allCases.firstIndex(of: activeNoise) else { return .brown }
        
        if index == 0 {
            // Left Page: Get the previous item in the Enum array
            let prevIdx = (currentIdx - 1 + allCases.count) % allCases.count
            return allCases[prevIdx]
        } else if index == 2 {
            // Right Page: Get the next item in the Enum array
            let nextIdx = (currentIdx + 1) % allCases.count
            return allCases[nextIdx]
        } else {
            // Center Page: Always show the active selection
            return activeNoise
        }
    }
    
    private func handleInfiniteLoop(currentValue: Int) {
        let allCases = NoiseSelection.allCases
        guard let currentIdx = allCases.firstIndex(of: activeNoise) else { return }
        
        if currentValue == 0 {
            // User swiped left: Update the true state to the previous noise
            let prevIdx = (currentIdx - 1 + allCases.count) % allCases.count
            activeNoise = allCases[prevIdx]
            resetToCenter()
        } else if currentValue == 2 {
            // User swiped right: Update the true state to the next noise
            let nextIdx = (currentIdx + 1) % allCases.count
            activeNoise = allCases[nextIdx]
            resetToCenter()
        }
    }

    private func resetToCenter() {
        // A small delay ensures the visual slide completely finishes before we teleport back
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            var transaction = Transaction()
            transaction.disablesAnimations = true // This hides the snap back to center!
            
            withTransaction(transaction) {
                activeIndex = 1
            }
        }
    }
    
    private func updateAudioForCurrentSelection(for noise: NoiseSelection) {
        switch noise {
        case .brown:
            volumeManager.mediaVol = 20
            volumeManager.voiceVol = 50
            volumeManager.noiseVol = 50
            audioManager.setSoundVolume(volume: 0.1)
            audioManager.playNoiseDynamic(.brownNoise)

        case .white:
            volumeManager.mediaVol = 20
            volumeManager.voiceVol = 50
            volumeManager.noiseVol = 50
            audioManager.setSoundVolume(volume: 0.1)
            audioManager.playNoiseDynamic(.whiteNoise)

        case .pink:
            volumeManager.mediaVol = 10
            volumeManager.voiceVol = 50
            volumeManager.noiseVol = 50
            audioManager.setSoundVolume(volume: 0.05)
            audioManager.playNoiseDynamic(.pinkNoise)
        }
    }

    // MARK: - Pulse Animation
    private func startPulse() {
        innerScale    = 1.0
        pulse2Scale   = 1.0
        pulse2Opacity = 0.2

        DispatchQueue.main.async {
            let pulseAnimation = Animation
                .easeInOut(duration: 2.4)
                .repeatForever(autoreverses: true)

            withAnimation(pulseAnimation) {
                innerScale    = 1.10
                pulse2Scale   = 1.25
                pulse2Opacity = 0.55
            }
        }

    }

    // MARK: - Tap Handler
    private func handleTap() {
        UIAccessibility.post(notification: .screenChanged, argument: nil)
        
        withAnimation(.easeInOut(duration: 0.8)) {
            if (isVolSheetExpanded) {
                isVolSheetExpanded.toggle()
            }else {
                isPlaying = true
            }
            
        }
    }
}

#Preview {
    mainScreenView().environmentObject(VolumeManager()).environmentObject(AudioManager())
}
