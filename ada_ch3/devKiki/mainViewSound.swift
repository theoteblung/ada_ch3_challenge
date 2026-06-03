//
//  mainViewSound.swift
//  ada_ch3
//
//  Created by kiki on 01/06/26.
//

import SwiftUI

struct MainViewSound: View {
    @StateObject private var onboardingManager = OnboardingManager()
    
    var body: some View {
        if onboardingManager.isCompleted {
            mainScreenView()
        } else {
            NavigationStack {
                FirstOnboarding()
            }
            .environmentObject(onboardingManager)
        }
    }
}
