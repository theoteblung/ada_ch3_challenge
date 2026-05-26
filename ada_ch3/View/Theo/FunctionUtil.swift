//
//  FunctionUtil.swift
//  ada_ch3
//
//  Created by Christofer Theodore on 26/05/26.
//

import SwiftUI
import Foundation
import AVFoundation

struct FunctionUtil: View {
    @StateObject private var audioManager = AudioManager()
    
    var themeColor: Color {
        if audioManager.recommendedNoise.contains("White") { return .gray }
        if audioManager.recommendedNoise.contains("Pink") { return .pink }
        if audioManager.recommendedNoise.contains("Green") { return .green }
        if audioManager.recommendedNoise.contains("Brown") { return .brown }
        return .blue
    }
    
    var body: some View {
        ScrollView { // Switched to ScrollView to prevent screen cramping
            VStack(spacing: 30) {
                
                // -------------------------------------------
                
                // Action Buttons
                VStack(spacing: 15) {
                    // Button 1: Start / Stop Analyzer
                    Button(action: {
                        if audioManager.isPlaying {
                            audioManager.stopPlayback()
                        } else {
                            audioManager.playNoiseFile()
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
                    
                    // Button 2: Dynamic Sound Machine (Plays your imported MP3 files loopable!)
                    if !audioManager.isRecording && audioManager.recommendedNoise != "Analyzing..." && !audioManager.recommendedNoise.contains("Silence") {
                        Button(action: {
                            if audioManager.isPlaying {
                                audioManager.stopPlayback()
                            } else {
                                audioManager.startRecommendedNoisePlayback()
                            }
                        }) {
                            Label(
                                title: { Text(audioManager.isPlaying ? "Turn Off Mask Sound" : "Play Suggested Mask Sound") },
                                icon: { Image(systemName: audioManager.isPlaying ? "speaker.slash.fill" : "speaker.wave.3.fill") }
                            )
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(themeColor)
                            .cornerRadius(14)
                        }
                    }
                    
                    // Button 3: Debug playback tool (Hear what mic captured)
                    if let _ = audioManager.recordedAudioURL, audioManager.isRecording == false {
                        Button(action: {
                            if audioManager.isPlaying {
                                audioManager.stopPlayback()
                            } else {
                                audioManager.startPlayback()
                            }
                        }) {
                            Label(
                                title: { Text(audioManager.isPlaying ? "Stop Listening" : "Hear What Mic Heard") },
                                icon: { Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill") }
                            )
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray5))
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
    FunctionUtil()
}
