import SwiftUI

struct screenView: View {
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
