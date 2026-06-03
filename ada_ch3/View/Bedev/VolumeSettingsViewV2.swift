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
    @EnvironmentObject var audioManager: AudioManager
    
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
                
                Slider(value: $volumeManager.mediaVol, in: 0...100) {_ in if volumeManager.mediaVol > 0.0{
                    volumeManager.mediaMute = false}}
                    .accentColor(.white)
                    .onChange(of: volumeManager.mediaVol) { oldValue, newValue in
                        let percentageGlobal = newValue / 100
                        let backgroundVol = volumeManager.noiseVol * percentageGlobal
                        let breathVol = volumeManager.voiceVol * percentageGlobal
                        audioManager.setSoundVolume(volume: backgroundVol / 100 )
                        audioManager.setBreathVolume(volume: breathVol / 100)
                    }
                
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
                
                Slider(value: $volumeManager.voiceVol, in: 0...100) {_ in if volumeManager.voiceVol > 0.0{
                    volumeManager.voiceMute = false}}
                    .accentColor(.white)
                    .onChange(of: volumeManager.voiceVol) { oldValue, newValue in
                        audioManager.setBreathVolume(volume: newValue / 100)
                    }
                
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
                
                Slider(value: $volumeManager.noiseVol, in: 0...100) {_ in if volumeManager.noiseVol > 0.0{
                    volumeManager.noiseMute = false}}
                    .accentColor(.white)
                    .onChange(of: volumeManager.noiseVol) { oldValue, newValue in
                        audioManager.setSoundVolume(volume: newValue / 100)
                    }
                
            }
        }
        
        
        
    }
}

#Preview {
    VolumeSettingsViewV2().environmentObject(VolumeManager()).environmentObject(AudioManager())
}
