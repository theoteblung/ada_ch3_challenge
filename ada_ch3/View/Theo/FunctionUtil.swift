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
                    
                }
            }
            .padding()
        }
    }
}

#Preview {
    FunctionUtil()
}
