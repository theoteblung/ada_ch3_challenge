import SwiftUI

struct screenView: View {
    @StateObject private var onboardingManager = OnboardingManager()
    @StateObject private var volumeManager = VolumeManager()
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
//        if onboardingManager.isCompleted {
            mainScreenView().environmentObject(volumeManager).environmentObject(audioManager)
//        } else {
//            NavigationStack {
//                FirstOnboarding()
//            }
//            .environmentObject(onboardingManager)
//        }
    }
}
