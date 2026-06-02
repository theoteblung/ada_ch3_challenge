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
    @State private var isLoopingBreathing: Bool = false
    
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
//                            audioManager.playNoiseFile(named: "pink-noise", volume: 1.0, ext: "wav")
//                            audioManager.playNoiseFile(named: "white-noise", volume: 1.0, ext: "wav")
                            audioManager.playNoiseFile(named: "brown-noise", volume: 1.0, ext: "caf")
                            
                        }
                    }) {
                        Text(audioManager.isPlaying ? "Stop" : "Play")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(audioManager.isPlaying ? Color.red : Color.blue)
                            .cornerRadius(14)
                    }
                    Button(action: {
                        audioManager.playNoiseDynamic(.whiteNoise, volume: 0.25)
                    }) {
                        Text("Play White Noise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    Button(action: {
                        audioManager.playNoiseDynamic(.pinkNoise, volume: 0.5)
                            
                        
                    }) {
                        Text("Play Pink Noise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    Button(action: {
                        audioManager.playNoiseDynamic(.brownNoise, volume: 0.75)
                            
                        
                    }) {
                        Text("Play Brown Noise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    Button(action: {
                        if audioManager.isBreathPlaying {
                            audioManager.stopBreathDynamic()
                            isLoopingBreathing = false
                        } else {
                            audioManager.breathIndex = 0
                            audioManager.playBreathDynamic()
                            isLoopingBreathing = true
                            //testing only
                            Task {
                                try await Task.sleep(for: .seconds(2))
                                if (isLoopingBreathing) {
                                    audioManager.breathIndex += 1
                                    audioManager.playBreathDynamic()
                                    if (audioManager.breathIndex > 3) {
                                        audioManager.breathIndex = 0
                                    }
                                }
                                
                                
                            }
                            Task {
                                try await Task.sleep(for: .seconds(4))
                                if (isLoopingBreathing) {
                                    audioManager.breathIndex += 1
                                    audioManager.playBreathDynamic()
                                    if (audioManager.breathIndex > 3) {
                                        audioManager.breathIndex = 0
                                    }
                                }
                                
                            }
                            Task {
                                try await Task.sleep(for: .seconds(6))
                                if (isLoopingBreathing) {
                                    audioManager.breathIndex += 1
                                    audioManager.playBreathDynamic()
                                    if (audioManager.breathIndex > 3) {
                                        audioManager.breathIndex = 0
                                    }
                                }
                                
                            }
                            Task {
                                try await Task.sleep(for: .seconds(8))
                                if (isLoopingBreathing) {
                                    audioManager.breathIndex += 1
                                    audioManager.playBreathDynamic()
                                    if (audioManager.breathIndex > 3) {
                                        audioManager.breathIndex = 0
                                    }
                                }
                                
                            }
                            Task {
                                try await Task.sleep(for: .seconds(10))
                                if (isLoopingBreathing) {
                                    audioManager.breathIndex += 1
                                    audioManager.playBreathDynamic()
                                    if (audioManager.breathIndex > 3) {
                                        audioManager.breathIndex = 0
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }) {
                        Text(audioManager.isBreathPlaying ? "Stop Breathing" : "Play Breathe Sound")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    Button(action: {
                        audioManager.stopNoiseDynamic()
                    }) {
                        Text(audioManager.isPlaying ? "Stop" : "No Sound is playing")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(audioManager.isPlaying ? Color.red : Color.blue)
                            .cornerRadius(14)
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
