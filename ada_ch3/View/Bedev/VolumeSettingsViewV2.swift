//
//  VolumeSettingsViewV2.swift
//  ada_ch3
//
//  Created by Christofer Theodore on 03/06/26.
//

import SwiftUI

struct VolumeSettingsViewV2: View {
    
    // volumemanager.mediavol ==>example
    
    @EnvironmentObject var volumeManager: VolumeManager
    
    var body: some View {
        
        VStack (alignment: .leading){
            Text("Media")
                .font(.callout)
                .foregroundStyle(Color.gray)
                .bold()
            
            HStack {
                
                Button(action: {
                    
                    if !volumeManager.mediaMute {
                        volumeManager.mediaPreMute = volumeManager.mediaVol
                    }
                    
                    volumeManager.mediaMute.toggle()
                    
                    if volumeManager.mediaMute {
                        volumeManager.mediaVol = 0.0
                    }else {
                        volumeManager.mediaVol = volumeManager.mediaPreMute
                    }
                }) {
                    Image(systemName: volumeManager.mediaMute || volumeManager.mediaVol == 0.0 ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .tint(Color.white)
                    }
                
                Slider(value: $volumeManager.mediaVol, in: 0...100)
                    .accentColor(.white)
                
            }
            
            Text("Breathing Voiceover")
                .font(.callout)
                .foregroundStyle(Color.gray)
                .bold()
            
            HStack {
                
                Button(action: {
                    
                    if !volumeManager.voiceMute {
                        volumeManager.voicePreMute = volumeManager.voiceVol
                    }
                    
                    volumeManager.voiceMute.toggle()
                    
                    if volumeManager.voiceMute {
                        volumeManager.voiceVol = 0.0
                    }else {
                        volumeManager.voiceVol = volumeManager.voicePreMute
                    }
                }) {
                    Image(systemName: volumeManager.voiceMute || volumeManager.voiceVol == 0.0 ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .tint(Color.white)
                    }
                
                Slider(value: $volumeManager.voiceVol, in: 0...100)
                    .accentColor(.white)
                
            }
            
            Text("Background Noise")
                .font(.callout)
                .foregroundStyle(Color.gray)
                .bold()
            
            HStack {
                
                Button(action: {
                    
                    if !volumeManager.noiseMute {
                        volumeManager.noisePreMute = volumeManager.noiseVol
                    }
                    
                    volumeManager.noiseMute.toggle()
                    
                    if volumeManager.noiseMute {
                        volumeManager.noiseVol = 0.0
                    }else {
                        volumeManager.noiseVol = volumeManager.noisePreMute
                    }
                    
                }) {
                    Image(systemName: volumeManager.noiseMute || volumeManager.noiseVol == 0.0 ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .tint(Color.white)
                    }
                
                Slider(value: $volumeManager.noiseVol, in: 0...100)
                    .accentColor(.white)
                
            }
        }
        
        
        
    }
}

#Preview {
    VolumeSettingsViewV2().environmentObject(VolumeManager())
}
