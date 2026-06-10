//
//  infoPageView.swift
//  ada_ch3
//
//  Created by Kevin Prananta Tjhai on 02/06/26.
//

import SwiftUI

// MARK: - Models

struct NoiseInfo: Identifiable {
    let id = UUID()
    let name: String
    let whatItIs: String
    let soundsLike: String
    let primaryUses: String
}

enum BreathingShape {
    case square
    case triangle
    case circle
}

struct BreathingInfo: Identifiable {
    let id = UUID()
    let name: String              // "4-4"
    let fullName: String          // "Box Breathing"
    let shape: BreathingShape
    let whatItIs: String
    let howToDoIt: String
    let primaryUses: String
}

// MARK: - Content Data

let noiseInfoList: [NoiseInfo] = [
    NoiseInfo(
        name: "White Noise",
        whatItIs: "White noise contains equal energy across all audible frequencies. Because human ears are more sensitive to higher frequencies, it sounds like a bright, constant hiss or a television tuned to an unused channel.",
        soundsLike: "A running ceiling fan, a static hum, or a vacuum cleaner.",
        primaryUses: "Ideal for masking sudden, disruptive environmental sounds like loud traffic or slamming doors because it flattens out sound variations. It is highly effective for focused studying or helping some people sleep, though the high-pitched hiss can be irritating to others."
    ),
    NoiseInfo(
        name: "Pink Noise",
        whatItIs: "Pink noise has equal energy per octave, meaning lower frequencies carry more power. It sounds fuller and more balanced than white noise, resembling natural soundscapes.",
        soundsLike: "Steady rainfall, rustling leaves, or a gentle waterfall.",
        primaryUses: "Popular for sleep improvement and relaxation. Research suggests pink noise may enhance deep sleep stages and memory consolidation, making it a favourite for overnight use."
    ),
    NoiseInfo(
        name: "Brown Noise",
        whatItIs: "Brown noise, also called red noise, emphasises even lower frequencies than pink noise, producing a deep, rumbling quality. The energy decreases more steeply at higher frequencies.",
        soundsLike: "Strong ocean waves, heavy rain, or distant thunder.",
        primaryUses: "Often preferred by people who find white or pink noise too sharp. Its deep, immersive rumble is widely used for focus, anxiety relief, and blocking low-frequency environmental sounds."
    )
]

let breathingInfoList: [BreathingInfo] = [
    BreathingInfo(
        name: "4-4-4-4",
        fullName: "Box Breathing",
        shape: .square,
        whatItIs: "Box breathing, also known as square breathing, follows a four-part cycle of equal lengths: inhale, hold, exhale, hold. Each side of the \"box\" lasts four seconds. It originates from the ancient yogic practice of pranayama and is famously used by Navy SEALs, athletes, and first responders to stay calm under pressure.",
        howToDoIt: "Sit upright in a comfortable position. Inhale slowly through your nose for 4 seconds. Hold your breath for 4 seconds. Exhale through your mouth for 4 seconds. Hold empty for 4 seconds. Repeat the cycle for several minutes.",
        primaryUses: "Best used during the day for focus, mental clarity, and stress management. The balanced rhythm has a neutral energetic effect; it neither stimulates nor sedates, leaving you alert, grounded, and ready for action. Helpful before high-pressure situations like meetings, exams, or athletic performance."
    ),
    BreathingInfo(
        name: "4-7-8",
        fullName: "Relaxing Breath",
        shape: .triangle,
        whatItIs: "The 4-7-8 technique, popularised by Dr. Andrew Weil, is rooted in pranayama. It uses an uneven rhythm where the exhale is twice as long as the inhale, with an extended hold in between. This pattern is sometimes called a \"natural tranquilliser for the nervous system.\"",
        howToDoIt: "Place the tip of your tongue against the ridge behind your upper front teeth. Exhale completely through your mouth. Close your mouth and inhale through your nose for 4 seconds. Hold your breath for 7 seconds. Exhale forcefully through your mouth for 8 seconds, making a soft whoosh sound. Begin with 4 cycles; work up to 8 over time.",
        primaryUses: "Best used in the evening or during moments of acute stress. Activates the parasympathetic nervous system, slowing heart rate and easing the body into a rest state. Particularly effective for falling asleep, managing anxiety, and breaking emotional reactions like anger or panic."
    ),
    BreathingInfo(
        name: "4-6",
        fullName: "Calming Breath",
        shape: .circle,
        whatItIs: "The 4-6 breathing technique is a simple two-part rhythm: a 4-second inhale followed by a 6-second exhale. Because the exhale is longer than the inhale, it engages the body's natural calming response without requiring breath holds, making it accessible for almost anyone.",
        howToDoIt: "Sit or lie comfortably and close your eyes. Breathe in deeply through your nose for 4 seconds. Breathe out fully through your nose for 6 seconds. Continue for 1 to 10 minutes. No counting apps, mantras, or breath holds required, just the steady ratio.",
        primaryUses: "Best used as an everyday on-demand tool for offloading stress, focusing on a task, or winding down before sleep. Suitable for people with respiratory conditions who find breath holds uncomfortable. Regular daily practice has been shown to reduce baseline stress over time."
    )
]

// MARK: - Info Page View

struct InfoPageView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isAboutExpanded: Bool = false
    @State private var isNoiseExpanded: Bool = false
    @State private var isBreathingExpanded: Bool = false

    var body: some View {
        ZStack {
            Color("ColorBG").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // ── About section
                    sectionHeader(
                        title: "About",
                        isExpanded: isAboutExpanded,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                isAboutExpanded.toggle()
                            }
                        }
                    )

                    if isAboutExpanded {
                        aboutSection
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Divider()
                        .background(Color("CardBorder"))

                    // ── Noise section
                    sectionHeader(
                        title: "Noise",
                        isExpanded: isNoiseExpanded,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                isNoiseExpanded.toggle()
                            }
                        }
                    )

                    if isNoiseExpanded {
                        VStack(spacing: 32) {
                            ForEach(noiseInfoList) { noise in
                                noiseSection(noise)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Divider()
                        .background(Color("CardBorder"))

                    // ── Breathing section
                    sectionHeader(
                        title: "Breathing",
                        isExpanded: isBreathingExpanded,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                isBreathingExpanded.toggle()
                            }
                        }
                    )

                    if isBreathingExpanded {
                        VStack(spacing: 32) {
                            ForEach(breathingInfoList) { breathing in
                                breathingSection(breathing)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Divider()
                        .background(Color("CardBorder"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Information")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(Color("ColorBG"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(Color("TextPrimary").opacity(0.85))
                }
                .accessibilityLabel("Back")
                .accessibilityHint("Returns to the home screen")
                .accessibilityAddTraits(.isButton)
            }
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // App identity
            VStack(alignment: .leading, spacing: 8) {
                Text("Hush")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                Text("Version 1.0.0")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color("TextSecondary"))
            }
            // Read as one phrase: "Hush, Version 1.0.0".
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            infoBlock(
                heading: "What is this app?",
                body: "Hush is a calm companion designed for moments of overstimulation. It combines guided breathing exercises with curated background noise to help you regulate, focus, and rest. Built with sensory sensitivity in mind, every detail — from the muted color palette to the slow, predictable animations — is chosen to soothe rather than stimulate."
            )

            infoBlock(
                heading: "How to use it",
                body: "Tap the center of the home screen to begin a breathing session. Open the volume sheet at the bottom to adjust app, breathing guide, and background noise levels independently. Tap the gear icon to choose your preferred background sound or let the app pick automatically."
            )

            // Credits
            VStack(alignment: .leading, spacing: 6) {
                Text("Made by")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color("TextSecondary"))
                Text("Team 12 ADA26")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color("TextPrimary"))
            }
            .accessibilityElement(children: .combine)

//            // Contact / Links
//            VStack(alignment: .leading, spacing: 12) {
//                Text("Get in touch")
//                    .font(.system(size: 17, weight: .regular))
//                    .foregroundColor(Color("TextSecondary"))
//
//                aboutLink(label: "Send feedback", icon: "envelope.fill")
//                aboutLink(label: "Privacy Policy", icon: "lock.fill")
//                aboutLink(label: "Terms of Service", icon: "doc.text.fill")
//                aboutLink(label: "Rate on the App Store", icon: "star.fill")
//            }
//
//            // Acknowledgements
//            infoBlock(
//                heading: "Acknowledgements",
//                body: "Breathing technique information sourced from published research and reputable health publications including Cleveland Clinic, Harvard Health, and the U.S. Navy SEAL training tradition. Background noise samples and sound design adapted for sensory comfort."
//            )
//
//            // Copyright
//            Text("© 2026 Hush. All rights reserved.")
//                .font(.system(size: 12, weight: .regular))
//                .foregroundColor(Color("TextSecondary"))
//                .padding(.top, 4)
        }
    }

    // MARK: - About Link Row
    private func aboutLink(label: String, icon: String) -> some View {
        Button(action: {
            // TODO: wire up the actual destination per link
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color("TextPrimary"))
                    .frame(width: 20)
                Text(label)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("TextSecondary"))
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: - Section Header
    private func sectionHeader(title: String, isExpanded: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                Spacer()
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                    .animation(.easeInOut(duration: 0.25), value: isExpanded)
            }
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // Expandable disclosure row: announce the name, its state, and what a tap does.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
        .accessibilityHint(isExpanded ? "Collapses the section" : "Expands the section")
        .accessibilityAddTraits([.isButton, .isHeader])
    }

    // MARK: - Noise Section
    private func noiseSection(_ noise: NoiseInfo) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(noise.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .accessibilityAddTraits(.isHeader)
                Spacer()
//                playButton
            }

            infoBlock(
                heading: "What is \(noise.name)?",
                body: noise.whatItIs
            )
            infoBlock(
                heading: "What it sounds like",
                body: noise.soundsLike
            )
            infoBlock(
                heading: "Primary Uses",
                body: noise.primaryUses
            )
        }
    }

    // MARK: - Breathing Section
    private func breathingSection(_ breathing: BreathingInfo) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Text(breathing.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .accessibilityLabel("\(breathing.fullName), \(breathing.name)")
                    .accessibilityAddTraits(.isHeader)
                techniqueShape(for: breathing.shape)
                Spacer()
            }

            infoBlock(
                heading: "What is the \(breathing.name) Breathing Technique?",
                body: breathing.whatItIs
            )
            infoBlock(
                heading: "How to do it",
                body: breathing.howToDoIt
            )
            infoBlock(
                heading: "Primary Uses",
                body: breathing.primaryUses
            )
        }
    }

    // MARK: - Reusable Pieces

    private var playButton: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 36, height: 36)
            Image(systemName: "play.fill")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color("TextPrimary"))
                .offset(x: 1)
        }
        .accessibilityElement()
        .accessibilityLabel("Play sample")
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private func techniqueShape(for shape: BreathingShape) -> some View {
        switch shape {
        case .square:
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(Color("TextPrimary"), lineWidth: 2)
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)
        case .triangle:
            TriangleShape()
                .stroke(Color("TextPrimary"), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                .frame(width: 30, height: 28)
                .accessibilityHidden(true)
        case .circle:
            Circle()
                .strokeBorder(Color("TextPrimary"), lineWidth: 2)
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private func infoBlock(heading: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(heading)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color("TextSecondary"))
            Text(body)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color("TextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
        }
        // Read the heading and its body together as a single, coherent passage.
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        InfoPageView()
    }
    .preferredColorScheme(.dark)
}
