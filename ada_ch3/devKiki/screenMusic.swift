//
//  screenMusic.swift
//  ada_ch3
//
//  Created by kiki on 25/05/26.
//

import SwiftUI

struct ScreenMusic: View {
    @StateObject private var musicManager = MusicManager()
    
    // Replace this with your specific Apple Music Track ID
    let targetSongId = "1440893933"
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Apple Music Integration")
                .font(.largeTitle)
                .bold()
            
            if musicManager.isAuthorized {
                // If authorized, show the Play/Stop controls
                Button(action: {
                    Task {
                        if musicManager.isPlaying {
                            musicManager.stopSong()
                        } else {
                            await musicManager.playSong(withId: targetSongId)
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: musicManager.isPlaying ? "stop.fill" : "play.fill")
                        Text(musicManager.isPlaying ? "Stop Music" : "Play Specific Song")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(musicManager.isPlaying ? Color.gray : Color.pink)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
            } else {
                // If not authorized, show the permission button
                Button(action: {
                    Task {
                        await musicManager.requestAuthorization()
                    }
                }) {
                    Text("Grant Apple Music Access")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .task {
            // Check authorization status right when the view appears
            await musicManager.requestAuthorization()
        }
    }
}

#Preview {
    ScreenMusic()
}
