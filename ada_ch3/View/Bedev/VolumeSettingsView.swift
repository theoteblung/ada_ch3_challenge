//
//  VolumeSettingsView.swift
//  ada_ch3
//
//  Created by Beatrice Deviana on 02/06/26.
//

import SwiftUI

struct VolumeSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State var mediaVol: Float = 50.0
    @State var mediaPreMute: Float = 50.0
    @State var mediaMute: Bool = false
    
    @State var voiceVol: Float = 50.0
    @State var voicePreMute: Float = 50.0
    @State var voiceMute: Bool = false
    
    @State var noiseVol: Float = 50.0
    @State var noisePreMute: Float = 50.0
    @State var noiseMute: Bool = false
    
    
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack (alignment: .leading){
                HStack {
                    Text("Volume")
                        .font(.title3)
                        .foregroundStyle(Color.white)
                        .bold()
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white)
                }
            
                VStack (alignment: .leading){
                    Text("Media")
                        .font(.callout)
                        .foregroundStyle(Color.gray)
                        .bold()
                    
                    HStack {
                        
                        Button(action: {
                            
                            if !mediaMute {
                                mediaPreMute = mediaVol
                            }
                            
                            mediaMute.toggle()
                            
                            if mediaMute {
                                mediaVol = 0.0
                            }else {
                                mediaVol = mediaPreMute
                            }
                        }) {
                            Image(systemName: mediaMute || mediaVol == 0.0 ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .tint(Color.white)
                            }
                        
                        Slider(value: $mediaVol, in: 0...100)
                            .accentColor(.white)
                        
                    }
                    
                    Text("Breathing Voiceover")
                        .font(.callout)
                        .foregroundStyle(Color.gray)
                        .bold()
                    
                    HStack {
                        
                        Button(action: {
                            
                            if !voiceMute {
                                voicePreMute = voiceVol
                            }
                            
                            voiceMute.toggle()
                            
                            if voiceMute {
                                voiceVol = 0.0
                            }else {
                                voiceVol = voicePreMute
                            }
                        }) {
                            Image(systemName: voiceMute || voiceVol == 0.0 ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .tint(Color.white)
                            }
                        
                        Slider(value: $voiceVol, in: 0...100)
                            .accentColor(.white)
                        
                    }
                    
                    Text("Background Noise")
                        .font(.callout)
                        .foregroundStyle(Color.gray)
                        .bold()
                    
                    HStack {
                        
                        Button(action: {
                            
                            if !noiseMute {
                                noisePreMute = noiseVol
                            }
                            
                            noiseMute.toggle()
                            
                            if noiseMute {
                                noiseVol = 0.0
                            }else {
                                noiseVol = noisePreMute
                            }
                            
                        }) {
                            Image(systemName: noiseMute || noiseVol == 0.0 ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .tint(Color.white)
                            }
                        
                        Slider(value: $noiseVol, in: 0...100)
                            .accentColor(.white)
                        
                    }
                }
            
            }
            .padding()
        }
    }
}

#Preview {
    VolumeSettingsView()
}
