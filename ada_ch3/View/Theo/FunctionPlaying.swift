//
//  FunctionPlaying.swift
//  ada_ch3
//
//  Created by Christofer Theodore on 02/06/26.
//
import SwiftUI
import Foundation
import AVFoundation

struct NowPlayingBar: View {
    @Binding var isPlaying: Bool

    var body: some View {
        HStack {
            // Album Artwork Placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(.secondary)
                .frame(width: 45, height: 45)
                .padding(.leading, 8)
            
            Text("Song Title - Artist")
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Spacer()
            
            // Play/Pause Button
            Button(action: {
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            
            // Skip Button
            Button(action: {
                // Skip action
            }) {
                Image(systemName: "forward.fill")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            .padding(.trailing, 12)
        }
        .padding(.vertical, 8)
    }
}
