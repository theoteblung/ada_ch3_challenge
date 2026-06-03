//
//  SecondOnboarding.swift
//  Onboarding page trial
//
//  Created by Beatrice Deviana on 28/05/26.
//

import SwiftUI

struct SecondOnboardingBC: View {
    
    @State var showAccess: Bool = false
    
    var body: some View {
        
        ZStack {
            Image("Onboarding BG")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
            Section {
                Image ("Oval 2")
                    .offset(x: -80, y: 170)
                    
                
                Image ("Oval 1")
                    .offset(x: 90, y: 100)
                    
                
                Image("Oval 3")
                    .offset(x: -150, y: -70)
            }
            .offset( y: -170)
            

            Section {
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
            }
            .frame(width: 280)
            .offset(x: -50, y: 200)
            
            Image(systemName: "arrow.right")
                .resizable()
                .foregroundStyle(Color.white.opacity(0.5))
                .offset(x: 150, y: 300)
                .frame(width: 30, height: 30)
        }
        .onTapGesture {
            showAccess.toggle()
        }
        
        .fullScreenCover(isPresented: $showAccess) {
            AccessViewBC()
        }
        
        .transaction { transaction in
            if showAccess {
                transaction.disablesAnimations = true
            }
        }
        
        
    }
}

#Preview {
    SecondOnboardingBC()
}
