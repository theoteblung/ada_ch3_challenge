//
//  MusicManager.swift
//  ada_ch3
//
//  Created by kiki on 25/05/26.
//

import Foundation
import MusicKit
import Combine

@MainActor
class MusicManager: ObservableObject {
    // ApplicationMusicPlayer plays audio directly inside your app
    private let player = ApplicationMusicPlayer.shared
    
    @Published var isAuthorized = false
    @Published var isPlaying = false
    
    /// Requests Apple Music access permission
    func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        self.isAuthorized = (status == .authorized)
    }
    
    /// Fetches a specific song by ID and plays it
    func playSong(withId songId: String) async {
        // 1. Guard against unauthorized access
        guard MusicAuthorization.currentStatus == .authorized else {
            print("Apple Music access not authorized.")
            return
        }
        
        do {
            // 2. Create a request for the specific song ID from the Apple Music Catalog
            let musicItemID = MusicItemID(songId)
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
            let response = try await request.response()
            
            // 3. Extract the song from the response
            guard let song = response.items.first else {
                print("Song ID \(songId) not found in the catalog.")
                return
            }
            
            // 4. Set the player queue to this specific song and play
            player.queue = [song]
            try await player.play()
            
            self.isPlaying = true
            print("Successfully playing: \(song.title)")
            
        } catch {
            print("Error playing song: \(error.localizedDescription)")
        }
    }
    
    /// Optional: Call this to pause the music
    func stopSong() {
        player.stop()
        self.isPlaying = false
    }
}
