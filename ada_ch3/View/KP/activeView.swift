//
//  ActiveView.swift
//  ada_ch3
//
//  Created by Kevin Prananta Tjhai on 26/05/26.
//

import SwiftUI
import MediaPlayer
import AVKit

struct ActiveView: View {
    var onStop: () -> Void
    
    @StateObject private var audioManager = AudioManager()
    
    // System volume binding
    @State private var volume: Float = AVAudioSession.sharedInstance().outputVolume

    private let accentColor = Color(hex: "#CAABA6")
    private let background  = Color(hex: "#1A1916")
    

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── Bottom cluster
                VStack(alignment: .leading, spacing: 20) {

//                    playingTitle

                    volumeRow

                    stopButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            audioManager.playNoiseDynamic(.pinkNoise, volume: 0.5)
        }
    }

    // MARK: - Playing Title
    private var playingTitle: some View {
        (
            Text("Playing ")
                .font(.system(size: 32, weight: .bold))
            + Text("Brown")
                .font(.system(size: 32, weight: .bold).italic())
            + Text(" Noise")
                .font(.system(size: 32, weight: .bold))
        )
        .foregroundColor(.white)
    }

    // MARK: - Volume Row
    private var volumeRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "speaker.wave.1.fill")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.60))

            SystemVolumeSlider()
                .frame(height: 32)
                .tint(accentColor)
        }
    }

    // MARK: - Stop Button
    private var stopButton: some View {
        Button {
            if audioManager.isPlaying {
                audioManager.stopNoiseDynamic()
            }
            onStop()
        } label: {
            Text("Stop")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(.white.opacity(0.60))
                .padding(8)

            Spacer()

            AirPlayRoutePicker()
                .frame(width: 28, height: 28)
                .padding(8)

            Image(systemName: "ellipsis.circle.fill")
                .font(.system(size: 22, weight: .regular))
                .foregroundColor(.white.opacity(0.60))
                .padding(8)
        }
    }
}

// MARK: - System Volume Slider 
struct SystemVolumeSlider: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        let view = MPVolumeView()
        // Tint the slider track to #CAABA6
        view.tintColor = UIColor(Color(hex: "#CAABA6"))
        return view
    }

    func updateUIView(_ uiView: MPVolumeView, context: Context) {}
}

import AVKit

struct AirPlayRoutePicker: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.prioritizesVideoDevices = false
        picker.activeTintColor = UIColor(Color.white)
        picker.tintColor = UIColor(Color.white.opacity(0.6))
        return picker
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}

// MARK: - Preview
#Preview {
    ActiveView(onStop: {})
}

