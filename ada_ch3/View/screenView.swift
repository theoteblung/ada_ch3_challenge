import SwiftUI

struct screenView: View {
    @StateObject private var onboardingManager = OnboardingManager()
    @StateObject private var volumeManager = VolumeManager()
    
    var body: some View {
        if onboardingManager.isCompleted {
            mainScreenView().environmentObject(volumeManager)
        } else {
            NavigationStack {
                FirstOnboarding()
            }
            .environmentObject(onboardingManager)
        }
    }
}
