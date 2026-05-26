//
//  screen.swift
//  ada_ch3
//
//  Created by kiki on 22/05/26.
//

//
//  ContentView.swift
//  ada_ch3
//
//  Created by Christofer Theodore on 22/05/26.
//

import SwiftUI

import Foundation
import AVFoundation

struct ScreenKiki: View {
    @StateObject private var audioManager = AudioManager()
    
    var themeColor: Color {
        if audioManager.recommendedNoise.contains("White") { return .gray }
        if audioManager.recommendedNoise.contains("Pink") { return .pink }
        if audioManager.recommendedNoise.contains("Green") { return .green }
        return .blue
    }
    
    var body: some View {
        ScrollView { // Switched to ScrollView to prevent screen cramping
            VStack(spacing: 30) {
                Text(audioManager.isRecording ? "Analyzing Room Audio..." : "Noise Analyzer")
                    .font(.title2)
                    .bold()
                
                // Pulse Visualizer Circle
                ZStack {
                    Circle()
                        .fill(themeColor.opacity(0.15))
                        .frame(width: 140, height: 140)
                        .scaleEffect(audioManager.isRecording ? CGFloat(1.0 + (audioManager.ambientDecibels + 60) / 100) : 1.0)
                        .animation(.linear(duration: 0.2), value: audioManager.ambientDecibels)
                    
                    Image(systemName: audioManager.isRecording ? "waveform.and.mic" : "mic.circle.fill")
                        .font(.system(size: 54))
                        .foregroundColor(themeColor)
                }
                
                // Recommendation Card Box
                VStack(alignment: .leading, spacing: 10) {
                    Text("ANALYSIS RESULT")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.secondary)
                    
                    Text(audioManager.recommendedNoise)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(14)
                
                // --- NEW DEBUG DASHBOARD ---
                VStack(alignment: .leading, spacing: 12) {
                    Text("LIVE AUDIO TELEMETRY (DEBUG)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.orange)
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Average Power:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.2f dB", audioManager.ambientDecibels))
                                .font(.system(.body, design: .monospaced))
                                .bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Peak Power:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.2f dB", audioManager.debugPeakPower))
                                .font(.system(.body, design: .monospaced))
                                .bold()
                        }
                    }
                    
                    HStack {
                        Text("Current Variance:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.2f dB", audioManager.debugVariance))
                            .font(.system(.body, design: .monospaced))
                            .bold()
                            .foregroundColor(audioManager.debugVariance > 12 ? .red : .primary)
                    }
                    
                    Text("• Rule 1: Silence if Avg < -55 dB\n• Rule 2: White Noise if Avg Variance > 12 dB\n• Rule 3: Green Noise if Avg > -35 dB\n• Rule 4: Otherwise Pink Noise")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
                // -------------------------------------------
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        if audioManager.isRecording {
                            audioManager.stopRecording()
                        } else {
                            audioManager.startRecording()
                        }
                    }) {
                        Text(audioManager.isRecording ? "Stop & Match" : "Analyze Room")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(audioManager.isRecording ? Color.red : Color.blue)
                            .cornerRadius(14)
                    }
                    
                    if let _ = audioManager.recordedAudioURL {
                        Button(action: {
                            if audioManager.isPlaying {
                                audioManager.stopPlayback()
                            } else {
                                audioManager.startPlayback()
                            }
                        }) {
                            Label(
                                title: { Text(audioManager.isPlaying ? "Stop Listening" : "Hear What It Heard") },
                                icon: { Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill") }
                            )
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(themeColor)
                            .cornerRadius(14)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ScreenKiki()
}
