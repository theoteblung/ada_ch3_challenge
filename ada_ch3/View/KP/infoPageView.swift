//
//  infoPageView.swift
//  ada_ch3
//
//  Created by Kevin Prananta Tjhai on 02/06/26.
//

import SwiftUI

// MARK: - Noise Model
struct NoiseType: Identifiable {
    let id = UUID()
    let name: String
    let whatItIs: String
    let soundsLike: String
    let primaryUses: String
}

let noiseTypes: [NoiseType] = [
    NoiseType(
        name: "White Noise",
        whatItIs: "White noise contains equal energy across all audible frequencies. Because human ears are more sensitive to higher frequencies, it sounds like a bright, constant hiss or a television tuned to an unused channel.",
        soundsLike: "A running ceiling fan, a static hum, or a vacuum cleaner.",
        primaryUses: "Ideal for masking sudden, disruptive environmental sounds (like loud traffic or slamming doors) because it flattens out sound variations. It is highly effective for focused studying or helping some people sleep, though the high-pitched hiss can be irritating to others."
    ),
    NoiseType(
        name: "Pink Noise",
        whatItIs: "Pink noise has equal energy per octave, meaning lower frequencies carry more power. It sounds fuller and more balanced than white noise, resembling natural soundscapes.",
        soundsLike: "Steady rainfall, rustling leaves, or a gentle waterfall.",
        primaryUses: "Popular for sleep improvement and relaxation. Research suggests pink noise may enhance deep sleep stages and memory consolidation, making it a favourite for overnight use."
    ),
    NoiseType(
        name: "Brown Noise",
        whatItIs: "Brown noise (also called red noise) emphasises even lower frequencies than pink noise, producing a deep, rumbling quality. The energy decreases more steeply at higher frequencies.",
        soundsLike: "Strong ocean waves, heavy rain, or distant thunder.",
        primaryUses: "Often preferred by people who find white or pink noise too sharp. Its deep, immersive rumble is widely used for focus, anxiety relief, and blocking low-frequency environmental sounds."
    ),
    NoiseType(
        name: "Blue Noise",
        whatItIs: "Blue noise boosts higher frequencies, giving it a thin, hiss-like quality. It is the inverse of brown noise in terms of frequency emphasis.",
        soundsLike: "A faint high-pitched spray, similar to water misting from a nozzle.",
        primaryUses: "Less common for relaxation, but used in audio engineering and dithering. Some people find short bursts helpful for alertness or concentration in quiet environments."
    )
]

struct InfoPageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int = 0

    var body: some View {
        ZStack {
            Color("ColorBG").ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Carousel
                TabView(selection: $currentIndex) {
                    ForEach(Array(noiseTypes.enumerated()), id: \.offset) { index, noise in
                        noiseCard(noise: noise)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 220)
                .padding(.top, 12)

                // ── Noise title
                Text(noiseTypes[currentIndex].name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)

                Divider()
                    .background(Color("CardBorder"))

                // ── Scrollable text x
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        infoSection(
                            heading: "What is \(noiseTypes[currentIndex].name)?",
                            body: noiseTypes[currentIndex].whatItIs
                        )
                        infoSection(
                            heading: "What it sounds like",
                            body: noiseTypes[currentIndex].soundsLike
                        )
                        infoSection(
                            heading: "Primary Uses",
                            body: noiseTypes[currentIndex].primaryUses
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
                }
            }
        }
        .navigationTitle("Noise Information")
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
            }
        }
    }

    // ── Carousel card
    private func noiseCard(noise: NoiseType) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(0.18))
                .frame(width: 170, height: 170)

            HStack(spacing: 4) {
                ForEach([0.45, 0.70, 1.0, 0.70, 0.45], id: \.self) { h in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color("TextSecondary").opacity(0.50))
                        .frame(width: 4, height: 36 * h)
                }
            }

            ZStack {
//                Circle()
//                    .fill(Color.white.opacity(0.25))
//                    .frame(width: 44, height: 44)
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color("TextPrimary"))
                    .offset(x: 2)
            }
        }
    }

    // ── Text section
    @ViewBuilder
    private func infoSection(heading: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(heading)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
            Text(body)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(Color("TextSecondary"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        InfoPageView()
    }
    .preferredColorScheme(.light)
}
