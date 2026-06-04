//
//  settingsView.swift
//  ada_ch3
//
//  Created by Kevin Prananta Tjhai on 02/06/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    private let cardBg     = Color.black.opacity(0.20)
    private let borderColor = Color(hex: "#979797").opacity(0.20)

    var body: some View {
        ZStack {
            Color("ColorBG").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Automatic Background Sound
                    VStack(alignment: .leading, spacing: 12) {
                        toggleRow(
                            title: "Automatic Background Sound",
                            isOn: $settings.autoBackgroundSound
                        )

                        // Noise cards (only enabled when auto is off)
                        VStack(spacing: 10) {
                            ForEach(NoiseSelection.allCases) { noise in
                                noiseCard(noise)
                            }
                        }
                        .opacity(settings.autoBackgroundSound ? 0.40 : 1.0)
                        .disabled(settings.autoBackgroundSound)
                        .animation(.easeInOut(duration: 0.25),
                                   value: settings.autoBackgroundSound)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
//                .padding(.top, 12)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
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
                    .foregroundColor(.white.opacity(0.85))
                }
            }
        }
    }

    // MARK: - Toggle Row
    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.90))
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(hex: "#CAABA6"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1)
        )
    }

    // MARK: - Noise Card
    private func noiseCard(_ noise: NoiseSelection) -> some View {
        let isSelected = settings.selectedNoise == noise
        return Button {
            settings.selectedNoise = noise
        } label: {
            HStack(spacing: 14) {
                // Color swatch
                Circle()
                    .fill(noise.color)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )

                Text(noise.rawValue)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.90))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#CAABA6"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color(hex: "#CAABA6").opacity(0.50) : borderColor,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppSettings())
    }
    .preferredColorScheme(.dark)
}
