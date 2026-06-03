//
//  generalUtils.swift
//  ada_ch3
//
//  Created by kiki on 01/06/26.
//

import SwiftUI
import Combine

class OnboardingManager: ObservableObject {
    @Published var isCompleted = false
}
class VolumeManager: ObservableObject {
    @Published var mediaVol: Float = 50.0
    @Published var mediaPreMute: Float = 50.0
    @Published var mediaMute: Bool = false
    
    @Published var voiceVol: Float = 50.0
    @Published var voicePreMute: Float = 50.0
    @Published var voiceMute: Bool = false
    
    @Published var noiseVol: Float = 50.0
    @Published var noisePreMute: Float = 50.0
    @Published var noiseMute: Bool = false
}


