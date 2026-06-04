//
//  infoPageView.swift
//  ada_ch3
//
//  Created by Kevin Prananta Tjhai on 02/06/26.
//

import SwiftUI

struct InfoPageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int = 0

    private let background = Color(hex: "#1A1916")

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

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
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)

                Divider()
                    .background(Color.white.opacity(0.15))

                // ── Scrollable text 
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
        .toolbarBackground(background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
                    .foregroundColor(.white.opacity(0.85))
                }
            }
        }
    }

    // ── Carousel card ────────────────────────────────────────────────
    private func noiseCard(noise: NoiseType) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.18))
                .frame(width: 170, height: 170)

            HStack(spacing: 4) {
                ForEach([0.45, 0.70, 1.0, 0.70, 0.45], id: \.self) { h in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.50))
                        .frame(width: 4, height: 36 * h)
                }
            }

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 44, height: 44)
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .offset(x: 2)
            }
        }
    }

    // ── Text section ─────────────────────────────────────────────────
    @ViewBuilder
    private func infoSection(heading: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(heading)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(hex: "#CAABA6").opacity(0.75))
            Text(body)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        InfoPageView()
    }
    .preferredColorScheme(.dark)
}
