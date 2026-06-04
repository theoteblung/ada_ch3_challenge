//
//  mainViewSound.swift
//  ada_ch3
//
//  Created by kiki on 01/06/26.
//

import SwiftUI

struct MainViewSound: View {
    @StateObject private var onboardingManager = OnboardingManager()
    @StateObject private var volumeManager = VolumeManager()
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        if onboardingManager.isCompleted {
            mainScreenView().environmentObject(volumeManager)
                .environmentObject(audioManager)
        } else {
            NavigationStack {
                FirstOnboarding()
            }
            .environmentObject(onboardingManager)
        }
    }
}
