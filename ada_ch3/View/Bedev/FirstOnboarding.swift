//
//  FirstOnboarding.swift
//  Onboarding page trial
//
//  Created by Beatrice Deviana on 28/05/26.
//

import SwiftUI
import Foundation

struct FirstOnboarding: View {
    
    @EnvironmentObject var onboardingManager: OnboardingManager
    
    @State var animate: Bool = false
    @State var showNext: Bool = false
    @State var textStep: Int = 0
    
    var body: some View {
        
        ZStack {
            Image("Onboarding BG")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
            Section {
                Image ("Oval 2")
                    .offset(x: -80, y: 170)
                    .opacity(animate ? 0.0 : 1.0)
                    .animation(
                        .easeInOut(duration: 3.5)
                        .repeatForever(autoreverses: true), value: animate
                        )
                    .onAppear {
                        animate = true
                    }
                
                Image ("Oval 1")
                    .offset(x: 90, y: 100)
                    .opacity(animate ? 0.0 : 1.0)
                    .animation(
                        .easeInOut(duration: 4.5)
                        .repeatForever(autoreverses: true), value: animate
                        )
                    .onAppear {
                        animate = true
                    }
                
                Image("Oval 3")
                    .offset(x: -150, y: -70)
                    .opacity(animate ? 0.0 : 1.0)
                    .animation(
                        .easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true), value: animate
                        )
                    .onAppear {
                        animate = true
                    }
            }
            .offset( y: -170)
            

            VStack {
                if textStep < 2 {
                    if textStep == 0 {
                    VStack (alignment: .leading, spacing: 20){
                        Text("Find your quiet.")
                        
                            .font(.title)
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        
                        
                        Text("We listen to your environment to instantly **find the perfect noise** to help you reset.")
                            .foregroundStyle(.white)
                            .fontDesign(.rounded)
                            .font(.title3)
                        }
                        .frame(width: 280)
                        .offset(x: -30, y: 230)
                }else {
                    VStack (alignment: .leading, spacing: 20){
                        Text("Block your chaos.")
                        
                            .font(.title)
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        
                        Text("**One click** reads your environment and builds a custom **audio shield.**")
                            .foregroundStyle(.white)
                            .fontDesign(.rounded)
                            .font(.title3)
                    }
                    .frame(width: 280)
                    .offset(x: -55, y: 230)
                    }
                    
                    Image(systemName: "arrow.right")
                        .resizable()
                        .foregroundStyle(Color.white.opacity(0.5))
                        .offset(x: 150, y: 250)
                        .frame(width: 30, height: 30)
                }
            }

            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.5)){
                textStep += 1
                if(textStep == 2){
                    onboardingManager.isCompleted = true
                }
            }
        }
    }
}

#Preview {
    FirstOnboarding()
}
