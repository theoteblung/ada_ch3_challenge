//
//  AccessView.swift
//  Onboarding page trial
//
//  Created by Beatrice Deviana on 28/05/26.
//

import SwiftUI

struct AccessViewTemp: View {
    // Instantiate managers here
    @StateObject private var audioManager = AudioManager()
    @StateObject private var locationManager = LocationManager()
    
    // State tracks to safely navigate away or change button states later
    @State private var micGranted = false
    @State private var locationGranted = false
    
    var body: some View {
        ZStack {
            Image("Access BG")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
            VStack {
                VStack (alignment: .leading, spacing: 30){
                    Text("Let's scan your space.")
                    
                        .font(.title)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    
                    Text("Grant **microphone / location access** so we can detect ambient noise levels and recommend your ideal soundscape.")
                        .foregroundStyle(.white)
                        .fontDesign(.rounded)
                        .font(.title3)
                    
                    VStack (alignment: .leading){
                        Text("[App name] values your privacy.")
                            .italic()
                            .foregroundStyle(.white)
                            
                        Text("Audio processing happens locally and never leaves your device.")
                            .italic()
                            .foregroundStyle(.white)

                            
                    }
                    
                }
            }
            .frame(width: 300)
            .offset(x: -30, y: -50)
            
            VStack (alignment: .trailing, spacing: 15) {
                // Update Button Action to handle both systems sequentially
                Button(action: {
                    handlePermissionsFlow()
                }) {
                    Text("**􀊱 Enable Permissions**")
                        .padding(5)
                }
                .tint(Color.brown.opacity(0.9))
                .buttonStyle(.borderedProminent) // Un-commented to give button visual presence
                    
                Button(action: {
                    // Logic to skip or dismiss onboarding
                    print("User bypassed permissions for now")
                }) {
                    Text("Not now")
                }
                .underline()
                .foregroundStyle(.white.opacity(0.8))
            }
            .offset(x: 80, y: 250)
        }
    }
    
    private func handlePermissionsFlow() {
        audioManager.requestMicrophonePermission { micAllowed in
            self.micGranted = micAllowed
            print("Microphone response: \(micAllowed)")
            
            // Chain the next prompt smoothly without popups colliding
            locationManager.requestLocationAccess { locationAllowed in
                self.locationGranted = locationAllowed
                print("Location response: \(locationAllowed)")
            }
        }
    }
}
    

#Preview {
    AccessViewTemp()
}
