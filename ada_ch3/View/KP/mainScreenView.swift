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
                        ActiveView(onStop: {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                isPlaying = false
                            }
                        })
                        .environmentObject(volumeManager)
                        .environmentObject(audioManager)
                        .transition(.opacity)
                        .environmentObject(settings)
                    } else {
                        mainShell
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VolumeSheet()
                    .ignoresSafeArea(edges: .bottom)
                    .environmentObject(volumeManager)
                    .environmentObject(audioManager)
            }
            .animation(.easeInOut(duration: 0.8), value: isPlaying)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .background(Color("ColorBG").ignoresSafeArea())
            .onAppear {
//                audioManager.playNoiseDynamic(.pinkNoise, volume: 0.5)
                startPulse()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .environmentObject(settings)
    }

    // MARK: - Main Shell
    private var mainShell: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, 20)
                .padding(.top, 4)

            // Center content (tap area)
            ZStack {
                Color.clear

                // Tap area horizontally aligned: text left, circles right
                ZStack {
                    VStack{
                        Text("Tap to")
                            .font(.system(size: 40, weight: .light))                        .lineLimit(1)
                            .fixedSize()
                            .offset(x: -120)
                        
                        Text("start")
                            .font(.system(size: 40, weight: .bold))                        .lineLimit(1)
                            .fixedSize()
                            .offset(x: -110)
                    }

                    ZStack {
                        // Outer glow — #99645A radial
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(hex: "#99645A").opacity(1.0), location: 0.0),
                                        .init(color: Color(hex: "#99645A").opacity(0.0), location: 1.0)
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

                        // Inner glow — #CAABA6 radial
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color(hex: "#CAABA6").opacity(1.0), location: 0.0),
                                        .init(color: Color(hex: "#CAABA6").opacity(0.0), location: 1.0)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { handleTap() }
        }
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

            Spacer()
            
            //darkmode button
            Button {
                withAnimation(.easeInOut) {
                    isDarkMode.toggle()
                }
            } label: {
                Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                    .font(.system(size: 26, weight: .regular))
                    .foregroundColor(Color("IconBG"))
                    .padding(8)
            }
            
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

    // MARK: - Pulse Animation
    private func startPulse() {
        let pulseAnimation = Animation
            .easeInOut(duration: 2.4)
            .repeatForever(autoreverses: true)

        withAnimation(pulseAnimation) {
            innerScale    = 1.10
            pulse2Scale   = 1.25
            pulse2Opacity = 0.55
        }
        
    }

    // MARK: - Tap Handler
    private func handleTap() {
        withAnimation(.easeInOut(duration: 0.8)) {
            isPlaying = true
        }
    }
}

#Preview {
    mainScreenView().environmentObject(VolumeManager()).environmentObject(AudioManager())
}
