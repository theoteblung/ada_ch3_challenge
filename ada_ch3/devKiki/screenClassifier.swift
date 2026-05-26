//
//  screenClassifier.swift
//  ada_ch3
//
//  Created by kiki on 25/05/26.
//

import SwiftUI

struct ScreenClassifier: View {
    @StateObject private var classifier = SoundClassifier()
    
    var themeColor: Color {
        if classifier.recommendedNoise.contains("White") { return .gray }
        if classifier.recommendedNoise.contains("Pink") { return .pink }
        if classifier.recommendedNoise.contains("Green") { return .green }
        return .blue
    }
    
    var body: some View {
        VStack(spacing: 35) {
            Text("AI Sound Classifier")
                .font(.title2)
                .bold()
            
            // AI Radar Status Ring
            ZStack {
                Circle()
                    .stroke(themeColor.opacity(classifier.isAnalyzing ? 0.6 : 0.2), lineWidth: 3)
                    .frame(width: 140, height: 140)
                    .scaleEffect(classifier.isAnalyzing ? 1.1 : 1.0)
                    .animation(classifier.isAnalyzing ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: classifier.isAnalyzing)
                
                Image(systemName: classifier.isAnalyzing ? "brain.head.profile" : "waveform.circle")
                    .font(.system(size: 54))
                    .foregroundColor(themeColor)
            }
            
            // AI Prediction Telemetry Card
            VStack(alignment: .leading, spacing: 12) {
                Text("LIVE ML INTELLIGENCE")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.blue)
                
                Divider()
                
                HStack {
                    Text("Detected Sound:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(classifier.detectedSound)
                        .bold()
                }
                
                HStack {
                    Text("AI Confidence:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.1f%%", classifier.confidence))
                        .font(.system(.body, design: .monospaced))
                        .bold()
                }
                
                Divider()
                
                Text("RECOMMENDED MASK:")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
                
                Text(classifier.recommendedNoise)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(themeColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
            
            // Toggle Button
            Button(action: {
                if classifier.isAnalyzing {
                    classifier.stopAnalysis()
                } else {
                    classifier.startAnalysis()
                }
            }) {
                Text(classifier.isAnalyzing ? "Stop AI Analysis" : "Start Live AI Analysis")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(classifier.isAnalyzing ? Color.red : Color.blue)
                    .cornerRadius(14)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    ScreenClassifier()
}
