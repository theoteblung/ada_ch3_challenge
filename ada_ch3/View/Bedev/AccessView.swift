//
//  AccessView.swift
//  Onboarding page trial
//
//  Created by Beatrice Deviana on 28/05/26.
//

import SwiftUI

struct AccessView: View {
    var body: some View {
        ZStack {
            Image("Access BG")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
            VStack {
                VStack (alignment: .leading, spacing: 30){
                    Text("Let's scan your space.")
                    
                        .font(.title)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    
                    Text("Grant **microphone / location access** so we can detect ambient noise levels and recommend your ideal soundscape.")
                        .foregroundStyle(.white)
                        .fontDesign(.rounded)
                        .font(.title3)
                    
                    VStack (alignment: .leading){
                        Text("[App name] values your privacy.")
                            .italic()
                            .foregroundStyle(.white)
                            
                        Text("Audio processing happens locally and never leaves your device.")
                            .italic()
                            .foregroundStyle(.white)

                            
                    }
                    
                }
            }
            .frame(width: 300)
            .offset(x: -30, y: -50)
            
            VStack (alignment: .trailing, spacing: 15) {
                Button(){}
                label : {
                    Text("**􀊱 Enable Microphone**")
                        .padding(5)
                    }
//                .buttonStyle(.glassProminent)
                .tint(Color.brown.opacity(0.9))
                    
                Button(){}
                label : {
                    Text("Not now")
                    }
                .underline()
                .foregroundStyle(.white.opacity(0.8))
            }
            .offset(x: 80, y: 250)
        }
    }
}
    

#Preview {
    AccessView()
}
